---
title: "FirebaseAuthで独自ドメインを使う"
emoji: "🔥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Firebase"]
published: true
---

# はじめに
Firebase Authenticationではメールアドレスの確認やパスワードのリセットなどの機能を提供していますが、デフォルトではFirebaseのドメインを使っています。

そのためデフォルトでは`noreply@<your-project-id>.firebaseapp.com`からメールが送信され、メール内のリンクも`https://<your-project-id>.firebaseapp.com/__/auth/action?mode=<action>&oobCode=<code>`のようなURLになります。

今回はFirebaseのドメインではなく独自ドメインを使う方法を簡単に紹介します。

# A. メールアドレスをカスタマイズ
こちらは簡単です。  
`Authentication` → `Template` → `メールアドレスの確認` など → 🖊アイコン（テンプレートを編集） → `ドメインをカスタマイズ`  
から指示に従えばOKです。  

http://zenn.dev/wake/articles/your-own-domain-mail-address-for-free

# B. メール内のリンク（アクションURL）をカスタマイズ
こちらは検索しても出てくる情報がバラバラだったので、私が試してうまく行った方法を紹介します。  
参考  
https://stackoverflow.com/questions/46972194/how-to-customize-firebase-action-url-for-password-reset-and-email-verification

ここでは大体3つの方法が紹介されていました。
1. ❌ Dynamic Linksを設定してから、アクションURLを設定する
	* 2番目の方法を使わず、いきなりDynamic Linksは設定できませんでした。
1. ✅ Hostingにカスタムドメインを設定してから、アクションURLを設定する
1. ❌ DNSを設定してから、アクションURLを設定する
	* `ERR_CERT_COMMON_NAME_INVALID`となってしまいます

2番目の方法でうまくいったので、こちらを紹介します。  

## 1. Hostingにカスタムドメインを設定
`Hosting` → `ダッシュボード` → `カスタムドメインを追加`と進み、指示に従うだけです。  
* 「`yourdomain` を既存のウェブサイトにリダイレクトする」はチェックしなくて大丈夫です。  
* セットアップモードは「クイックセットアップ」で大丈夫です  
* **DNSを設定したらしばらく待ちます。**  

:::message
ダッシュボード上の表示が「設定が必要です」→「証明書を作成しています」→「接続されました」と遷移していくので待ちます。  
10~20分かかりました。
:::

## 2. アクションURLをカスタマイズ
ダッシュボード上の表示が「接続されました」になったら、  
`Authentication` → `テンプレート` → `メールアドレスの確認` など → 🖊アイコン（テンプレートを編集） → `アクションURLをカスタマイズ` で
```
https://<your-custom-domain>/__/auth/action
```
と設定すればOKです。

# おわりに
毎回調べては結局どの方法が正しいのか混乱していたので整理しました。  
そのため画像などの無い手抜き記事で失礼します。  
画像がほしい方は以下のリンクを参考にしてください。  
https://ifedapo.com/posts/customise-firebase-action-url