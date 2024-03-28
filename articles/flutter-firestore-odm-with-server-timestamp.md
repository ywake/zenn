---
title: "Cloud Firestore ODMでサーバータイムスタンプを使う方法"
emoji: "🕑"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["flutter", "firebase", "firestore"]
published: true
---

| Github | [![ywake/zenn](https://img.shields.io/badge/ywake-zenn-blue?logo=github)](https://github.com/ywake/zenn) |
| --- | --- |

`cloud_firestore_odm: ^1.0.0-dev.84`で確認

# 実現したいこと

Flutterの[Cloud Firestore ODM](https://pub.dev/packages/cloud_firestore_odm)でFirestoreを操作する際、`createdAt`や`updatedAt`などのフィールドにサーバータイムスタンプを使いたい。
ODMを使わないなら`FieldValue.serverTimestamp()`を直接使えばいいが、ODMにはそれらしいものがなかった。

# 解決方法

カスタムコンバーターを作成して、`toJson()`の際に`FieldValue.serverTimestamp()`に変換する。

```dart
class ServerTimestamp extends JsonConverter<DateTime, dynamic> {
  const ServerTimestamp();

  @override
  DateTime fromJson(dynamic json) => json == null
      ? DateTime.now()
      : const FirestoreDateTimeConverter().fromJson(json as Timestamp);
      // サーバータイムスタンプをセットする際に、リスナーが一瞬nullを受信することがある
      // のでその瞬間はクライアントの現在時間を使用

  @override
  dynamic toJson(DateTime object) => FieldValue.serverTimestamp();
}
```

# 使い方

```dart
class Task {
  Task({
    this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  @Id()
  final String? id;
  final String title;
  @ServerTimestamp()
  final DateTime createdAt;
  @ServerTimestamp()
  final DateTime updatedAt;
}
```

## 注意
`.update()`を使う際には問題ないが、`.set()`を使う際には`createdAt`も更新されてしまうので注意が必要。
`.set()`にも対応するなら以下のようにして更新するときだけ`null`を渡すなどの工夫が必要。

```dart
class ServerTimestamp extends JsonConverter<DateTime?, dynamic> {
  const ServerTimestamp();

  @override
  DateTime? fromJson(dynamic json) => json == null
      ? DateTime.now()
      : const FirestoreDateTimeConverter().fromJson(json as Timestamp);

  @override
  dynamic toJson(DateTime? object) => object == null
	  ? FieldValue.serverTimestamp()
	  : const FirestoreDateTimeConverter().toJson(object);
}

class Task {
  Task({
    this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
  });

  @Id()
  final String? id;
  final String title;
  @ServerTimestamp()
  final DateTime? createdAt;
  @ServerTimestamp()
  final DateTime? updatedAt;
}
```

# 参考

https://github.com/FirebaseExtended/firestoreodm-flutter/issues/15

# 合わせて読みたい

https://zenn.dev/yucatio/articles/c5cc8718f54fd7

---

# 関連記事
* [flutter_flavorizrでFlutter+Firebaseの環境を分ける](https://zenn.dev/wake/articles/flutter-flavorizr)
* [FlutterでFirebaseAuth+FirebaseUIAuthを設定する手順](https://zenn.dev/wake/articles/flutter-firebase-auth-and-firebase-ui-auth)
* [FlutterでFirebaseのメールリンク認証を使う](https://zenn.dev/wake/articles/flutter-firebase-auth-with-email-link)
* [FirebaseAuthで独自ドメインを使う](https://zenn.dev/wake/articles/firebase-auth-with-custom-domain)
* [FlutterのバックグラウンドでFirebaseと通信(iOS)](https://zenn.dev/wake/articles/572fdd292ed482e6b5bc)