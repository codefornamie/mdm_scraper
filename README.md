# mdm_scraper

MDM(ソフトバンクの端末管理サービス「ビジネス・コンシェル・デバイスマネジメント」)のスクレイパー

このプログラムだけは現状GUIを必要とするため（Seleniumを使う）、役場据え置きのMacから実行していて、別レポジトリにしています。

## このプログラムについて

浪江町タブレット事業では、町民に配ったタブレットの端末管理をMDMを用いて行っています。MDMでは各ユーザーの端末のID, 更新日時、利用アプリなどを情報として持っており、アクセス解析に活かすことができます。

MDMでは全ユーザーのデバイス情報をcsvでダウンロードすることができますが、Androidユーザー向けのものは2015年9月時点で外部からアクセス可能なAPIがありません。集計を自動化するため、自動でブラウザを操作してCSVを落としてきてS3に置くスクリプトを作りました。

特に浪江町に依存することはやっていないので、configの値次第で別の組織のアカウントでも使えると思います。

このスクリプトではファイルをそのまま取り出してS3に置く、までしかやっていないので、文字コードはShift_JISで改行コードはCRLFのままなので注意してください。変換処理は別スクリプトでやっています。

## 対応環境

Mac OS X (確認した環境はYosemite)

※brewを使っている部分を代替で入れればLinuxでも使えると思います。

## インストール

* Firefoxをインストール

https://www.mozilla.org/ja/firefox/new/

* phantomjsをインストール 

```
brew install phantomjs
```

* ruby1.9以上をインストール

* AWSのcredential設定を済ませておく

```
brew install aws-cli
aws configure
```

rbenvを利用

## 使い方

* config.ymlをconfig.sample.ymlから作成

```
cp config.sample.yml config.yml
```

* config.ymlの該当箇所を埋める

* 依存ライブラリの設定

```
bundle install
```

### 実行方法

* 引数なしで実行すると当日分を実行する

```
bundle exec rake devlicelist
```

MDMではその時点でのデータしかダウンロードできないため、過去にさかのぼった実行は仕様上できません。

### cronからの実行

crontab
```
0 8 * * * /Users/yamadanaoyuki/Documents/codefornamie/mdm/exec.sh
```
pathは自分のものに置き換えてください。

## ライセンス

Apache 2.0
