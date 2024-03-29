---
title: "独自ドメインのメアドを無料で作るならZoho Mailがおすすめ"
emoji: "📧"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["メール"]
published: true
---

# はじめに
独自ドメインを取得したらメールアドレスも作りたいですよね。  
色々調べたらZoho Mailが良さそうだったので紹介します。  
また、メールだけでなく、カレンダーやメモやタスクドライブなども使えるので、小規模なチームのGoogle Workspaceの代替としてもおすすめです。  

# 欲しかった機能

* 無料 or 安く独自ドメインのメールアドレスを作りたい
* エイリアスやメーリングリストを沢山作りたい
	* admin@, info@, support@, contact@, ...
	* service-name@, 
* セキュリティ（SPF, DKIM, DMARC）を設定したい
	* なりすまし防止のための仕組みです
* IMAP

# メジャーなサービスとの比較
サービス名 | 価格 | エイリアス | メーリングリスト | SPF | DKIM | DMARC | IMAP
--- | --- | --- | --- | --- | --- | --- | ---
[Google Workspace](https://workspace.google.com/pricing?hl=ja) | 680円/User/月~ | 30個まで | 〇 | 〇 | 〇 | 〇 | 〇
[Microsoft 365](https://www.microsoft.com/ja-jp/microsoft-365/business/compare-all-microsoft-365-business-products) | 750円/User/月~ | 400個まで | 〇 | 〇 | 〇 | 〇 | 〇
[さくらのメールボックス](https://rs.sakura.ad.jp/mail/) | 86円/月~ | ❌? | 10個まで | 〇 | ❌[対応予定](https://www.sakura.ad.jp/corporate/information/announcements/2023/12/19/1968214527/) | 〇 | 〇
[Zoho Mail](https://www.zoho.com/jp/mail/zohomail-pricing.html) | 無料~<br>(120円/User/月~) | 上限不明 | 〇 | 〇 | 〇 | 〇 | 〇

Zoho Mailは5人まで無料で使えます。  
また、iCloud+に登録していれば、独自ドメインのメールアドレスを作れますが、1つのドメインに対して3つまでしかアドレスを作れませんでした。  

# 便利だと思ったこと
### Gmailのようなエイリアス
Gmailでは`user+<文字列>@gmail.com`というアドレスを使うと、`user@gmail.com`に届くので、エイリアスとして色々便利に使えます。  
Zohoでも同様なことができます。

### メールでタスク作成
エイリアスの要領で、`user+task@yourdomain.com`というアドレスにメールを送ると、そのユーザーのタスクが作成されます。  
さらに、`user+task+4Jan@yourdomain.com`として期限を指定したりもできます。

### チャット
Google Chatのようにチャットもできます。

# 結論
5人までは無料でGoogle Workspaceの代替のように使えるので、小規模なチームであればおすすめです。  
サーバー借りようか、AmazonSESで無理やり構築しようか、と模索していたので非常にありがたかったです。  