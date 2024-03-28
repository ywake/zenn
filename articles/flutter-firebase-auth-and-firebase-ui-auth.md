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
* Android用にSHA-1の設定が必要です。
* iOS用にはGoogleService-Info.plistを更新する必要があります。

### Android用設定
特に設定することはありません。

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
とりあえずApple端末でのみの設定です。

```bash
flutter pub add firebase_ui_oauth_apple
```

### Firebaseの設定
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

---

# 関連記事
* [flutter_flavorizrでFlutter+Firebaseの環境を分ける](https://zenn.dev/wake/articles/flutter-flavorizr)
* [FlutterでFirebaseのメールリンク認証を使う](https://zenn.dev/wake/articles/flutter-firebase-auth-with-email-link)
* [FlutterWebでFirebaseのメールリンク認証を使う](https://zenn.dev/wake/articles/flutter-web-firebase-auth-with-email-link)
* [FirebaseAuthで独自ドメインを使う](https://zenn.dev/wake/articles/firebase-auth-with-custom-domain)
* [Cloud Firestore ODMでサーバータイムスタンプを使う方法](https://zenn.dev/wake/articles/flutter-firestore-odm-with-server-timestamp)
* [FlutterのバックグラウンドでFirebaseと通信(iOS)](https://zenn.dev/wake/articles/572fdd292ed482e6b5bc)