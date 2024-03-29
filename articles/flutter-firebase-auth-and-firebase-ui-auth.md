---
title: "FlutterでFirebaseAuth+FirebaseUIAuthを設定する手順"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Flutter", "Firebase", "FirebaseAuth", "Dart"]
published: true
---

| Github | [![ywake/zenn](https://img.shields.io/badge/ywake-zenn-blue?logo=github)](https://github.com/ywake/zenn) |
| --- | --- |

自分用のため、公式の説明を焼き直してまとめただけな上、自分が使った機能しか書いていません。

### リファレンス
* pub.dev
	- [firebase_auth](https://pub.dev/packages/firebase_auth)
	- [firebase_ui_auth](https://pub.dev/packages/firebase_ui_auth)
	- [firebase_ui_localizations](https://pub.dev/packages/firebase_ui_localizations)

# インストール

```bash
flutter pub add firebase_auth firebase_ui_auth firebase_ui_localizations
```

# 多言語対応
`MaterialApp.localizationsDelegates`に`FirebaseUILocalizations.delegate`を追加します。
```diff
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'My App',
      routerConfig: router,
      localizationsDelegates: [
        ...context.localizationDelegates,
+       FirebaseUILocalizations.delegate, // 追加
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
```
> `easy_localization`や`flutter_riverpod`, `go_router`を使っている場合の例です。

# メールリンクサインイン
こちらで
https://zenn.dev/wake/articles/flutter-firebase-auth-with-email-link


# Google Sign In
[公式ドキュメント](https://github.com/firebase/FirebaseUI-Flutter/blob/main/docs/firebase-ui-auth/providers/oauth.md#google-sign-in)

```bash
flutter pub add firebase_ui_oauth_google
```

### Firebaseの設定
Firebaseのコンソール上でAuthenticationのログインプロバイダにGoogleを追加します。
* Android用にSHA-1の設定が必要なので下の項目で説明します。
* iOS用にはGoogleService-Info.plistを更新する必要があります。

### Android用設定
1. SHA-1の設定
	```bash
	keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
	```
	で取得したSHA-1をFirebaseのAndroidアプリに登録します。
1. [OAuth同意画面](https://console.developers.google.com/apis/credentials/consent)の必須項目を設定します。
	* `デベロッパーの連絡先情報`が必須ですが、入力されていない場合がありますので入力します。
	* 他の項目も必要に応じて入力します。

### iOS用設定
CFBundleURLTypes属性を`ios/Runner/Info.plist`に追加します。
```xml
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<!-- TODO Replace this value: -->
				<!-- Copied from GoogleService-Info.plist key REVERSED_CLIENT_ID -->
				<string>[YOUR REVERSED CLIENT ID]</string>
			</array>
		</dict>
	</array>
```
:::message
macOSの場合は`macos/Runner/Info.plist`に以下を追加します。
```xml
	<key>keychain-access-groups</key>
	<array>
		<string>$(AppIdentifierPrefix)com.google.GIDSignIn</string>
	</array>
```
:::
:::message
#### flutter_flavorizrを使っている場合
1. `flavorizr.yaml`に以下を追加します。
	```yaml
	ios:
	  bundleId: com.example.app
	  variables:
	    REVERSED_CLIENT_ID:
	      value: "YOUR REVERSED CLIENT ID"
	```
1. `ios/Runner/Info.plist`に以下を追加します。
	```xml
		<key>CFBundleURLTypes</key>
		<array>
			<dict>
				<key>CFBundleTypeRole</key>
				<string>Editor</string>
				<key>CFBundleURLSchemes</key>
				<array>
					<string>$(REVERSED_CLIENT_ID)</string>
				</array>
			</dict>
		</array>
	```
:::

### Dart実装
```dart
SignInScreen(
  providers: [
    GoogleProvider(clientId: '', iOSPreferPlist: true),
  ],
);
```

# Sign in with Apple
[公式ドキュメント](https://github.com/firebase/FirebaseUI-Flutter/blob/main/docs/firebase-ui-auth/providers/oauth.md#sign-in-with-apple)

```bash
flutter pub add firebase_ui_oauth_apple
```

### Firebaseの設定
Firebaseのコンソール上でAuthenticationのログインプロバイダにAppleを追加します。
* Android/Webでも有効にするには設定が必要です。下の項目で説明します。
* Darwin向けにはFirebase上の設定は特にありません。

### Android/Webの設定
Firebaseの設定に必要なのは4つあります。
手順は長いので折りたたみますが、ポチポチするだけです。
:::message
firebaseにカスタムドメインを設定している方も`<your-firebase-project-id>.firebaseapp.com`で設定する必要があり、変更の仕方はわかりませんでした😢
:::
* Sign in with Apple用のServiceID
	::::details ServiceIDの取得
	1. Certificates, Identifiers & Profilesの[Identifiers](https://developer.apple.com/account/resources/identifiers/list/serviceId)にアクセスします。
	1. `+`ボタンをクリックしてServiceIDを作成します。`description`と`identifier`を入力して作成を完了します。
		* `description`はログイン画面にサービス名として表示される名前になります。
			![](/images/sign_in_with_apple.png)
		![](/images/apple_developer_certificates_identifier_service_id.png)
	1. 今作成したServiceIDが一覧にあると思うのでそれをクリックします。
	1. `Sign In with Apple`にチェックを入れて`Configure`をクリックします。
		1. `Primary App ID`には今回紐づけるアプリのBundle IDを入力します。
		1. `Domains and Subdomains`には`<your-firebase-project-id>.firebaseapp.com`を入力します。
		1. `Return URLs`には`https://<your-firebase-project-id>.firebaseapp.com/__/auth/handler`を入力します。これはFirebaseコンソールでAppleのプロバイダ設定をする際にコピーできます。
			:::message
			カスタムドメインを設定している方も`<your-firebase-project-id>.firebaseapp.com`で設定する必要があり、変更の仕方はわかりませんでした😢
			:::
			![](/images/apple_developer_certificates_identifier_service_id_configure.png)
	1. 設定が終わったら`Continue` → `Save`で設定を保存します。
	1. 先ほど設定したServiceIDをFirebaseのコンソールのAppleのプロバイダ設定に追加すれば完了です。
	::::
* Team ID → [こちら](https://developer.apple.com/account#membership-details)で確認
* Key ID と 秘密鍵
	:::details 作成方法
	> 既にPush通知用などで秘密鍵を持っている場合はそれを使っても構いません。

	1. 今度はCertificates, Identifiers & Profilesの[Keys](https://developer.apple.com/account/resources/authkeys/list)にアクセスします。
	1. `+`ボタンをクリックして`Key`を作成します。
		1. `Key Name`に任意の名前を入力します。
		1. `Sign in with Apple`にチェックを入れます。
		1. `Configure`から`Primary App ID`に今回紐づけるアプリのBundle IDを選択します。
		1. 戻って`Continue` → `Register`で設定を完了します。
		1. Keyを`Download`します。1度しかできないので安全な場所にバックアップしておきます。
		1. また、`Key ID`が作られるのでこれもメモします。
	:::

用意できたらFirebaseコンソールに戻り、Appleのプロバイダ設定に`OAuth コードフローの構成（省略可）`に追加してください。
省略可ありますが、AndroidとWebで使うには必要です。

### iOSの設定
1. Xcode上でSign in with Appleを有効にします。
```bash
open ios/Runner.xcworkspace
```
1. Signing & Capabilitiesタブを開き、「+ Capability」から「Sign in with Apple」を追加します。
	![](/images/signin_capabilities.png)
1. Firebaseのコンソール上でSign in with Appleを有効にします。

### Dart実装
```dart
SignInScreen(
  providers: [
    AppleProvider(),
  ],
);
```
<!--
### 匿名メールアドレスの転送設定
登録に利用されるランダムなメールアドレスとやりとり出来るメールアドレスやドメインを設定します。
1. Certificates, Identifiers & Profilesの[Services](https://developer.apple.com/account/resources/services/list)から`Sign in with Apple for Email Communication`の`Configure`をクリックします。
1. `+`ボタンをクリックして`Email Domain`を追加します。
	1. `Domain`にはやり取りしたいメールアドレスのドメインがあれば入力します。
	1. `Email Address`に`noreply@<your-firebase-project-id>.firebaseapp.com`か[カスタム](https://zenn.dev/wake/articles/firebase-auth-with-custom-domain#a.-メールアドレスをカスタマイズ)している場合はそれを入力します。
		![](/images/apple_developer_certificates_services_email_communication.png)
-->
---

# 関連記事
* [flutter_flavorizrでFlutter+Firebaseの環境を分ける](https://zenn.dev/wake/articles/flutter-flavorizr)
* [FlutterでFirebaseのメールリンク認証を使う](https://zenn.dev/wake/articles/flutter-firebase-auth-with-email-link)
* [FlutterWebでFirebaseのメールリンク認証を使う](https://zenn.dev/wake/articles/flutter-web-firebase-auth-with-email-link)
* [FirebaseAuthで独自ドメインを使う](https://zenn.dev/wake/articles/firebase-auth-with-custom-domain)
* [Cloud Firestore ODMでサーバータイムスタンプを使う方法](https://zenn.dev/wake/articles/flutter-firestore-odm-with-server-timestamp)
* [FlutterのバックグラウンドでFirebaseと通信(iOS)](https://zenn.dev/wake/articles/572fdd292ed482e6b5bc)