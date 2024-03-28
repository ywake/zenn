---
title: "FlutterWebでFirebaseのメールリンク認証を使う"
emoji: "📥"
type: "tech"
topics: ["Flutter", "Dart", "Firebase", "FirebaseAuth"]
published: true
---

| 修正リクは ➡️ | [![ywake/zenn](https://img.shields.io/badge/ywake-zenn-blue?logo=github)](https://github.com/ywake/zenn) |
| --- | --- |

前回、[FlutterでFirebaseのメールリンク認証を使う](https://zenn.dev/wake/articles/flutter-firebase-auth-with-email-link)でiOSとAndroidでの方法を紹介しましたが、今回は[firebase_ui_auth](https://pub.dev/packages/firebase_ui_auth)で現状サポートされていないFlutter**Web**での方法の紹介です。

前回の続きを想定しているので基本的な設定は省略します。詳しくは前回の記事を参照してください。

# これからやること
1. WebはDynamicLinkをそのまま使えませんので、EmailLinkのリダイレクト先をサービスのログイン処理用のURLに設定します。
1. 入力されたメールアドレスを一時的に保存します。
1. 1のURLを処理できるように`go_router`等を設定します。
1. URLを受け取った後のログイン処理を行います。

# 1. EmailLinkのリダイレクト先を設定する
[前回の🎯Flutterの実装](https://zenn.dev/wake/articles/flutter-firebase-auth-with-email-link#iii.-🎯Flutterの実装)で設定した`ActionCodeSettings`のurlを変更します。
```dart diff
 final origin = kDebugMode
   ? 'http://localhost:8081' // httpにしてください
   : 'https://your-domain.com';
 ActionCodeSettings(
-  url: 'https://xxx.page.link',
+  url: '$origin/login/finish', // パスは自由です
   dynamicLinkDomain: 'xxx.page.link',
   handleCodeInApp: true,
   // ...
 );
```
一応デバッグ時は`localhost`を使うようにしています。ポートは好きにしてください。
ただし、`flutter run`する時、デフォルトではポートがランダムなので`--web-port 8081`等で指定する必要があります。

# 2. 入力されたメールアドレスを一時的に保存する
* 保存には`shared_preferences`を使います。（shared_preferencesの使い方は本稿では省略します）
* 入力されたメールアドレスを受け取る必要があります。
	* 今回は簡単に`firebase_ui_auth`の`EmailLinkSignInScreen`を弄って使います。
	* 自分で実装するのももちろんありです。

[私のGitHubリポジトリ](https://github.com/ywake/FirebaseUI-Flutter/tree/email-link-web)にある改造した`firebase_ui_auth`をインストールします。
(保守し続けていない可能性が高いので、その時は[diff](https://github.com/firebase/FirebaseUI-Flutter/compare/ae01e9f...ywake:FirebaseUI-Flutter:email-link-web)を参照してご自身のフォークに反映して使ってください)

> 変更内容は
> ・webのサポートを追加
> ・EmailLinkSignInScreenに`onLinkSent`コールバックを追加
> の2点のみです。

***pubspec.yaml***
```yaml
dependencies:
  firebase_ui_auth:
    git:
      url: https://github.com/ywake/FirebaseUI-Flutter.git
      path: packages/firebase_ui_auth
      ref: email-link-web

dependency_overrides:
  firebase_ui_auth:
    git:
      url: https://github.com/ywake/FirebaseUI-Flutter.git
      path: packages/firebase_ui_auth
      ref: email-link-web
```

これで`EmailLinkSignInScreen`に`onLinkSent`コールバックが追加されましたので、それを使ってメールアドレスを保存します。
```dart diff
class EmailLinkView extends StatelessWidget {
  const EmailLinkView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmailLinkSignInScreen(
      onLinkSent: (email) {
        sharedPreferences.setString('emailForSignIn', email);
      },
    );
  }
}
```

# 3. URLを処理できるようにする
今回は`go_router`を使ってURLを処理できるようにします。(これも基本的な解説は省略します)
（ちなみにバージョンは`13.x.x`を想定しています。APIの更新早いので変わっているかもしれません）

```dart diff
import 'package:go_router/go_router.dart';

GoRouter(
  routes: [
    // ...
    GoRoute(
      path: '/login/link',
      pageBuilder: (context, state) => const EmailLinkView(),
    ),
+   GoRoute(
+     path: '/login/finish',
+     pageBuilder: (context, state) => FinishLogin(uri: state.uri),
+   ),
  ],
);
```
これから定義する`FinishLogin`に`Uri`を渡しています。これがDynamicLinkから伝わる情報になります。

それと***main.dart***に以下を追加します。
```dart diff
void main() {
+ setUrlStrategy(PathUrlStrategy());
  runApp(MyApp());
}
```
これがないデフォルトではURLが`your-domain.com/#/path`といった形になってしまいカッコ悪いです。
もちろん`#`があるままでもできますので、その場合はこれまでのコードを合わせてください。

:::message
これを追加したことでWeb以外のビルドに失敗する場合は[こちら](https://zenn.dev/link/comments/a7c538fd48b2e4)を参照してください。
(もっと良いやり方あったら教えてください！)
:::

# 4. ログイン処理を行う
ここまで設定すれば、送られてきたメールリンクをブラウザで開くと`your-domain.com/login/finish`に飛ぶはずですので、あとはそのページでログイン処理を行います。

> 概要を示すための適当なコードなので、適宜修正してください。

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FinishLogin extends StatelessWidget {
  const FinishLogin({Key? key, required this.uri}) : super(key: key);
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.isSignInWithEmailLink(uri.toString())) {
      // ログイン処理
      FirebaseAuth.instance.signInWithEmailLink(
        email: sharedPreferences.getString('emailForSignIn')!,
        emailLink: uri.toString(),
      ).then((_) {
        // ログイン成功時の処理
        sharedPreferences.remove('emailForSignIn');
      }).catchError((e) {
        // ログイン失敗時の処理
      });
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      // 省略
    }
  }
}

```
go_routerから持ってきた「URL」と、SharedPreferencesに保存した「入力されたメールアドレス」を`FirebaseAuth.instance.signInWithEmailLink()`に渡してログイン処理を行います。

# 5. 終わり🎉
お疲れ様でした！
いつかfirebase_ui_authでサポートされて簡単になることを願っています。

---

# 関連記事
* [flutter_flavorizrでFlutter+Firebaseの環境を分ける](https://zenn.dev/wake/articles/flutter-flavorizr)
* [FlutterでFirebaseAuth+FirebaseUIAuthを設定する手順](https://zenn.dev/wake/articles/flutter-firebase-auth-and-firebase-ui-auth)
* [FirebaseAuthで独自ドメインを使う](https://zenn.dev/wake/articles/firebase-auth-with-custom-domain)
* [FlutterでFirebaseのメールリンク認証を使う](https://zenn.dev/wake/articles/flutter-firebase-auth-with-email-link)
* [Cloud Firestore ODMでサーバータイムスタンプを使う方法](https://zenn.dev/wake/articles/flutter-firestore-odm-with-server-timestamp)
* [FlutterのバックグラウンドでFirebaseと通信(iOS)](https://zenn.dev/wake/articles/572fdd292ed482e6b5bc)
