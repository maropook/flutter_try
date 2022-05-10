## flutter_try

実装したもの
- 半円形のボタン
- Android ios共にアプリのバージョンを取得する(ネイティブコード記述)


# FlutterからネイティブAPIを呼びたい
[MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html)を使って、FlutterからKotlin（Android）とSwift（iOS）のネイティブコード呼び出しを試してみました。


# サンプルプロジェクトの作成
まずはサンプルプロジェクトを作成します。サンプルアプリでは、バッテリー残量を取得するネイティブコードを実装します。
`$ flutter create appVersion`


# Flutter側の呼び出しコード

サンプル画面のWidgetとアプリのバージョン取得のための実装を加えます。以下、`MyHomePage`を抜粋した`main.dart`ファイルです。


```main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    getAppVersion();
  }
  String _appVersion = '';

  Future<void> getAppVersion() async {
    String appVersion;
    try {
      appVersion = await AppInfo.appVersion ?? 'Unknown App version';
    } on PlatformException {
      appVersion = 'Failed app version';
    }
    setState(() {
      _appVersion = appVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Text(_appVersion, style: const TextStyle(fontSize: 20))),
    );
  }
}

class AppInfo {
  static const MethodChannel _channel = MethodChannel('appInfo');

  static Future<String?> get appVersion async {
    final String? version = await _channel.invokeMethod('getAppVersion');
    return version;
  }
}


```

`MethodChannel`で呼び出すアプリのバージョン取得のメソッド`getAppVersion`は、KotlinとSwift側でそれぞれ定義していきます。



# Kotlin側のネイティブコード（Android）
それではKotlin（Android）のコードを書いていきましょう。

## 必要なimportの追加

`MainActivity.kt`にimportを追加。
元々一番上にあった`package com.example.packageの名前`を消さないように気を付けてください

```MainActivity.kt
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.ExperimentalCoroutinesApi

```

## getAppVersionの実装

`MainActivity`で`MethodChannel`を定義し、`setMethodCallHandler`を呼び出します。


```MainActivity.kt
class MainActivity: FlutterActivity() {
    private val CHANNEL = "appInfo"

    @OptIn(ExperimentalCoroutinesApi::class)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler{
                call, result ->
        }
    }
}

```


Android端末でアプリのバージョンを取得するコードを追加します。

```MainActivity.kt

if(call.method == "getAppVersion"){
                try {
                    val pInfo = applicationContext.packageManager.getPackageInfo(context.packageName, 0)
                    var version = pInfo.versionName
                    result.success("${pInfo.versionName}");

                } catch (e: PackageManager.NameNotFoundException) {
                    e.printStackTrace()
                    result.notImplemented()
                }
            }else{
                result.notImplemented()
            }

```

全体のコードです。

```MainActivity.kt
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.ExperimentalCoroutinesApi

class MainActivity: FlutterActivity() {
    private val CHANNEL = "appInfo"

    @OptIn(ExperimentalCoroutinesApi::class)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler{
                call, result ->
            if(call.method == "getAppVersion"){
                try {
                    val pInfo = applicationContext.packageManager.getPackageInfo(context.packageName, 0)
                    var version = pInfo.versionName
                    result.success("${pInfo.versionName}");

                } catch (e: PackageManager.NameNotFoundException) {
                    e.printStackTrace()
                    result.notImplemented()
                }
            }else{
                result.notImplemented()
            }
        }
    }
}}
  }
```

これでAndroid用Kotlinネイティブコードの呼び出し準備は完了です。

# エミュレーター上で実行

上記コードをエミュレーター上でbuild runするとアプリのバージョンが取得できます。
M1macでビルドする際は，こちらの記事を参考にしてみてください
https://zenn.dev/maropook/articles/e4ac4c79d0648b

<img width="438" alt="スクリーンショット 2022-05-10 10 38 05" src="https://user-images.githubusercontent.com/84751550/167525568-6c8cd894-6d4a-4b71-b8cf-8fffa6c95d96.png">

できました。


# Swift側のネイティブコード（iOS）
続いてSwift（iOS）のコードを書いていきます。
AppDelegate.swiftを開く

## getAppVersionを実装

Androidと同じく`MethodChannel`の実装を定義します。

```AppDelegate.swift
import UIKit
import Flutter


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let helloMethodChannel = FlutterMethodChannel(name: "appInfo",binaryMessenger: controller as! FlutterBinaryMessenger)
    helloMethodChannel.setMethodCallHandler({
      (call:FlutterMethodCall,result:FlutterResult) -> Void in
      }
      
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

```

アプリのバージョン取得のメソッド`getAppVersion`を追加。

```AppDelegate.swift
   switch call.method{
          case "getAppVersion":
              result(Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String)
          default:
             result("iOS" + UIDevice.current.systemVersion)
      }
```

全体のコードです

```AppDelegate.swift
import UIKit
import Flutter


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let helloMethodChannel = FlutterMethodChannel(name: "appInfo",binaryMessenger: controller as! FlutterBinaryMessenger)
    helloMethodChannel.setMethodCallHandler({
      (call:FlutterMethodCall,result:FlutterResult) -> Void in

      switch call.method{
          case "getAppVersion":
              result(Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String)
          default:
             result("iOS" + UIDevice.current.systemVersion)
      }
      
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

```

iOS Simulatorを起動すると、アプリのバージョンが表示されるはずです。

<img width="438" alt="スクリーンショット 2022-05-10 10 38 05" src="https://user-images.githubusercontent.com/84751550/167525699-b54d3792-f1ae-441d-9a74-61d1673d0c70.PNG">

1.0.0と表示されています。バージョンを取得できているのでSwift側で書いたコードが動いていることがわかりますね。


