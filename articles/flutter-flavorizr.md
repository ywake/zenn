---
title: "flutter_flavorizrでFlutter+Firebaseの環境を分ける"
emoji: "🪴"
type: "tech"
topics: ["Flutter", "Dart", "Firebase"]
published: true
---

| 修正リクは ➡️ | [![ywake/zenn](https://img.shields.io/badge/ywake-zenn-blue?logo=github)](https://github.com/ywake/zenn) |
| --- | --- |

Flutter 3.17以降[Dart-define-from-fileを使ったやり方](https://zenn.dev/altiveinc/articles/separating-environments-in-flutter)が複雑になったので、[flutter_flavorizr](https://pub.dev/packages/flutter_flavorizr)を使ってFirebaseを使いつつ環境を分ける方法を紹介します。

* firebase_cliは使わず、マニュアルインストールです。
* 今回は`dev`と`prod`のみです。

# 1. インストール
```sh
flutter pub add --dev flutter_flavorizr
```

以下は初回のみ実行（gem版のxcodeprojが必要です）
```sh
gem install xcodeproj
```

# 2. `flavorizr.yaml`の設定
```yaml
ide: "vscode" # or 'idea', .vscode/launch.jsonを作ってくれます。
flavors:
  dev:
    app:
      name: "[Dev]AppName"
    android:
      applicationId: "com.example.app_name.dev"
      firebase:
        config: ".firebase/dev/google-services.json"
    ios:
      bundleId: "com.example.app-name.dev"
      firebase:
        config: ".firebase/dev/GoogleService-Info.plist"
      variables:
        REVERSED_CLIENT_ID:
          value: "YOUR REVERSED CLIENT ID"
  prod:
    app:
      name: "AppName"
    android:
      applicationId: "com.example.app_name"
      firebase:
        config: ".firebase/prod/google-services.json"
    ios:
      bundleId: "com.example.app-name"
      firebase:
        config: ".firebase/prod/GoogleService-Info.plist"
      variables:
        REVERSED_CLIENT_ID:
          value: "YOUR REVERSED CLIENT ID"
```
[FirebaseAuthのGoogleSignInの設定](https://zenn.dev/wake/articles/0d41c27f6441a4#google-sign-in)でどうせつかうので、例も兼ねて`REVERSED_CLIENT_ID`を設定しています。
Info.plist内で`$(REVERSED_CLIENT_ID)`と書けば使えます。

Firebaseが不要の場合は`firebase:`や`variables:`は要りません。また、以下の手順3~5も不要です。

# 3. GoogleServiceファイルを設置
```sh
mkdir -p .firebase/dev .firebase/prod
```
`GoogleService-Info.plist`と`google-services.json`をそれぞれ設置します。

# 4. Androidのための設定
CLIを使った最新の設定ドキュメントからは無くなってしまったかもしれませんが、[昔のドキュメント](https://firebase.flutter.dev/docs/manual-installation/android/)では弄る場所が記載されています。
### *android/build.gradle*
```gradle diff
+buildscript {
+    repositories {
+        google()
+        mavenCentral()
+    }
+    dependencies {
+        classpath 'com.google.gms:google-services:4.3.8' // 最新verだとエラーになる
+    }
+}
+
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```
### *android/app/build.gradle*
```gradle diff
...
android {
	...
	defaultConfig {
		...
+		multiDexEnabled true
	}
	...
}
...
dependencies {
+	implementation 'com.android.support:multidex:1.0.3' // いらないかも？
}

+apply plugin: 'com.google.gms.google-services'
```
### Firebase Emulator Suiteを使う場合
エミュレーターでは暗号化されていないネットワークを使用しているそうなので、開発用の設定を追加します。
***android/app/src/debug/AndroidManifest.xml***
```xml diff
 <manifest xmlns:android="http://schemas.android.com/apk/res/android">
	<!-- The INTERNET permission is required for development. Specifically,
			the Flutter tool needs it to communicate with the running application
			to allow setting breakpoints, to provide hot reload, etc.
	-->
	<uses-permission android:name="android.permission.INTERNET"/>
+	<application android:usesCleartextTraffic="true">
+	<!-- possibly other elements -->
+	</application>
 </manifest>
```

# 5. iOSのための設定
***.gitignore***
```gitignore
*/Runner/GoogleService-Info.plist
```
このファイルはビルド毎に書き換わるので、`.gitignore`に追加しておきます。

# 6. 実行
```sh
dart run flutter_flavorizr
```
終わりです

# MacOS用 Warning抑制
### バージョンがどうのというwarning
***macos/Podfile***
```rb diff
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_macos_build_settings(target)
+    target.build_configurations.each do |config|
+      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.14' # 数字は任意
+    end
  end
end
```
### ・`warning: Run script build phase 'Firebase Setup' will be run during every build because it does not specify any outputs.`
XcodeのTARGETS`Runner` → `Build Phases`にある`Firebase Setup`のスクリプトの`Output Files`に以下を追加します。
```
$(SRCROOT)/Runner/GoogleService-Info.plist
```
![](/images/xcode_build_phase_firebase_setup_output_files.png)

---
# トラブルシュート
### ・`Unable to load contents of file list: ...`
上のOutputFilesを1度弄ったら治った。ちなみに戻しても治ったままだった🤔

公式で案内されている治し方はこちら
https://github.com/AngeloAvv/flutter_flavorizr/tree/master/doc/troubleshooting/unable-to-load-contents-of-file-list
↓ (コマンドだけ書き出し)
```sh
flutter clean
cd ios && pod deintegrate; cd -
rm -rf ios/Pods ios/.symlinks ios/Podfile.lock
flutter pub get
```

:::details mac用
```bash
flutter clean
cd macos && pod deintegrate; cd -
rm -rf macos/Pods macos/.symlinks macos/Podfile.lock
flutter pub get
```
:::

それでも治らないときは手動で治す
https://github.com/AngeloAvv/flutter_flavorizr/issues/223

### ・`Failed to load FirebaseOptions from resource. Check that you have defined values.xml correctly.`
```
E/flutter ( 5091): [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: PlatformException(java.lang.Exception: Failed to load FirebaseOptions from resource. Check that you have defined values.xml correctly., Exception, Cause: null, Stacktrace: java.lang.Exception: Failed to load FirebaseOptions from resource. Check that you have defined values.xml correctly.
E/flutter ( 5091): 	at io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin.lambda$optionsFromResource$4$io-flutter-plugins-firebase-core-FlutterFirebaseCorePlugin(FlutterFirebaseCorePlugin.java:207)
E/flutter ( 5091): 	at io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin$$ExternalSyntheticLambda2.run(Unknown Source:4)
E/flutter ( 5091): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1167)
E/flutter ( 5091): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:641)
E/flutter ( 5091): 	at java.lang.Thread.run(Thread.java:923)
E/flutter ( 5091): , null)
```
というエラーが出た場合はAndroidのための設定を忘れているか、`com.google.gms:google-services`のバージョンが高すぎる可能性があります。
記事執筆時点での最新は`4.4.1`ですが、`4.3.8`なら問題なく動作しました。（`4.4.0`,`4.3.9`は同様のエラーとなりました。）