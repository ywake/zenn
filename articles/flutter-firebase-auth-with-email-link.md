---
title: "FlutterでFirebaseのメールリンク認証を使う"
emoji: "📩"
type: "tech"
topics: ["Flutter", "Firebase", "FirebaseAuth", "Dart"]
published: true
---

| 修正リクは ➡️ | [![ywake/zenn](https://img.shields.io/badge/ywake-zenn-blue?logo=github)](https://github.com/ywake/zenn) |
| --- | --- |

Flutterで[firebase_auth](https://pub.dev/packages/firebase_auth)と[firebase_ui_auth](https://pub.dev/packages/firebase_ui_auth)を使って簡単にログイン画面を構成しつつ、Firebaseのメールリンク認証を使ってログインする方法を紹介します。

> 目を皿にしてしっかり設定したにも関わらずくっっっそハマりました。
> その理由と解決方法までわかりましたのでその辺りも書いていきます。

### リファレンス
* Firebase ドキュメント
	* [Flutter/メールリンク認証](https://firebase.google.com/docs/auth/flutter/email-link-auth?hl=ja)
	* [iOS/メールリンク認証](https://firebase.google.com/docs/auth/ios/email-link-auth?hl=ja)
	* [Flutter アプリで Firebase Dynamic Links を受信する](https://firebase.google.com/docs/dynamic-links/flutter/receive?hl=ja)
* Firebase UI ドキュメント
	* [メールリンク](https://github.com/firebase/FirebaseUI-Flutter/blob/main/docs/firebase-ui-auth/providers/email-link.md)

# I. 🔥Firebaseプロジェクトの設定
1. `Authentication` → `ログイン方法` から `メール/パスワード` を選択し、`メールリンク` を有効にします。
	![](/images/firebase_auth_provider_mail_link.png)
1. (カスタムドメインを設定する場合) `Hosting` → `カスタムドメインを追加` から指示に従ってください。
	* 設定し終わってもしばらく時間がかかります。(30分くらい？)
		`設定が必要です`→`証明書を作成しています`→`接続されました`と変化していきます。
1. `Dynamic Links`を追加します。`URL接頭辞の追加`では、ドメイン欄に何か文字を入れると`xxx.page.link`のようなURLが提案されるのでそれを選択します。(もしくは先ほど設定したカスタムドメインを設定します)
	:::message
	Dynamic Linksは2025年でサポート終了予定ですが、[AuthenticationのアクションURLは引き続き使えるようです](https://firebase.google.com/support/dynamic-links-faq?hl=ja#i_only_use_dynamic_links_for_firebase_authentication_will_email_link_authentication_in_firebase_authentication_continue_to_work)。
	:::
1. `Dynamic Links`に設定したドメインをホワイトリストに追加します。
	`Authentication` → `設定` → `承認済みドメイン` → `ドメインの追加`から先ほど作成したドメインを追加してください。
	![](/images/firebase_auth_setting_whitelist.png)
1. Appleアプリを構成している場合は`Dynamic Links`を機能させるために`Apple Store ID`と[`チームID`](https://developer.apple.com/account#MembershipDetailsCard)を設定します。
	`プロジェクトの設定` → `全般` → `マイアプリ` → `Apple アプリ`から設定します。

# II. 🎯Flutterプロジェクトの設定
## a. 依存関係のインストール
https://zenn.dev/wake/articles/flutter-firebase-auth-and-firebase-ui-auth

## b. iOSの設定
1. Xcode → **TARGETS**下の`Runner` → `Signing & Capabilities` → `+ Capability` から`Associated Domains`を追加し、`Domains`に以下を追加します。
	```
	applinks:xxx.page.link
	```
	:::message alert
	#### 今すぐ動作確認するつもりの場合
	```
	applinks:xxx.page.link?mode=developer
	```
	にしてください。詳しくは[下記トラブルシュート](#リンクがアプリで開かない（iOS）)で。
	:::
	![](/images/xcode_associated_domains_page_link.png)
1. 引き続きその画面で`Info`タブを開き、`URL Types`を追加します。
	`URL Scheme`を`$(PRODUCT_BUNDLE_IDENTIFIER)`を設定します。(`Identifier`は自由です)
	![](/images/xcode_info_url_types_bundle_id.png)
1. カスタムドメインを設定している場合は`Info.plist`に以下を追加します。
	```xml
	<key>FirebaseDynamicLinksCustomDomains</key>
	<array>
		<string>https://your.custom.domain</string>
	</array>
	```

## c. Androidの設定
***android/app/src/main/AndroidManifest.xml***を設定します
```xml diff
 <manifest ...>
   <application ...>
     <activity ...>
       <meta-data ...>
       <intent-filter>
         ...
       </intent-filter>
+      <intent-filter>
+        <action android:name="android.intent.action.VIEW"/>
+        <category android:name="android.intent.category.DEFAULT"/>
+        <category android:name="android.intent.category.BROWSABLE"/>
+        <data
+          android:host="xxx.page.link"
+          android:scheme="https"/>
+      </intent-filter>
     </activity>
   </application>
   ...
 </manifest>
```


# III. 🎯Flutterの実装
```dart
SignInScreen(
  providers: [
    EmailLinkAuthProvider(
      actionCodeSettings: ActionCodeSettings(
        url: 'https://xxx.page.link',
        dynamicLinkDomain: 'xxx.page.link',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.ios',
        androidPackageName: 'com.example.android',
        androidMinimumVersion: '0',
        androidInstallApp: true,
      ),
    ),
  ],
);
```
`ActionCodeSettings`の引数について詳しくは[こちら](https://firebase.google.com/docs/auth/flutter/email-link-auth?hl=ja#send_an_authentication_link_to_the_users_email_address)

# IV. 終わり🎉
お疲れ様でした！

FlutterWebでのメールリンク認証についても書きました↓
[FlutterWebでFirebaseのメールリンク認証を使う](https://zenn.dev/wake/articles/flutter-web-firebase-auth-with-email-link)

---

# トラブルシュート
### `Exceeded daily quota for email sign-in.`
上限に達するほどやってない気がしたんですが、仕方ないのでBlazeプランに変更して回避しました。
https://firebase.google.com/docs/auth/limits?hl=ja

### リンクがアプリで開かない（iOS）
1. iOSでユニバーサルリンクが機能するには以下の条件が整っている必要があります
	* `https://<your-domain>/apple-app-site-association`に正しい内容がある
	* `apple-app-site-association`ファイルの設定と一致するアプリがインストールされている
	* この辺をやってくれるのがDynamic Linksです。
1. そしてiOSはその`apple-app-site-association`ファイルを、あなたのドメインからではなく**AppleのCDN**から取得します。つまり**CDNに反映されるまで、ユニバーサルリンクは機能しません。** (最大24時間程度かかるらしいです)
1. デベロッパーのために回避する方法があります。
	1. デバッグに使っているiOS端末のデベロッパーモードを有効にします。
	1. `ユニバーサルリンク`カテゴリの`関連ドメインの開発`が有効になっていることを確認します。
		![](/images/ios_settings_developer_associated_domains_development.jpg =300x)
	1. Xcodeで`Associated Domains`で設定したものに`?mode=developer`を追加します。
		```
		applinks:xxx.page.link?mode=developer
		```
1. これで出来るはず

CDNに反映されたあとはmode戻した方が良いんですかね？
[救世主な元記事様](https://qiita.com/chichilam/items/9b646cdf4409d287195b#alternate-mode)



### リンクがアプリで開かない（Android）
私はまだ直面していませんが、見かけたので貼っておきます。
https://zenn.dev/yskuue/articles/b6e449fb9bd99d

---

# 関連記事
* [flutter_flavorizrでFlutter+Firebaseの環境を分ける](https://zenn.dev/wake/articles/flutter-flavorizr)
* [FlutterでFirebaseAuth+FirebaseUIAuthを設定する手順](https://zenn.dev/wake/articles/flutter-firebase-auth-and-firebase-ui-auth)
* [FirebaseAuthで独自ドメインを使う](https://zenn.dev/wake/articles/firebase-auth-with-custom-domain)
* [Cloud Firestore ODMでサーバータイムスタンプを使う方法](https://zenn.dev/wake/articles/flutter-firestore-odm-with-server-timestamp)
* [FlutterのバックグラウンドでFirebaseと通信(iOS)](https://zenn.dev/wake/articles/572fdd292ed482e6b5bc)