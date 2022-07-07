+++
title = "Ledger – 銀行csvをledgerファイルにする"
author = ["YAMAGAMI"]
date = 2022-05-30T00:00:00+09:00
tags = ["accounting", "ledger"]
categories = ["comp"]
draft = false
+++

## introduction {#introduction}

-   普通の家計では銀行口座に関するトランザクション数は限られている。手入力で書いてもよいし、スケジュールファイルに書いておいてそれをコピペしてもよい。
-   しかし小規模でもビジネスをしている場合には、日々、多くの銀行口座トランザクションがある
-   それを手入力するのは時間の無駄だし、キーボード入力エラーが発生する
-   多くの経理ソフトで、銀行口座からcsvファイルを読み込み、経理ソフトに適合する形に転記する機能がある
-   それらの経理ソフトではデータが固有のフォーマットになっていて、テキストファイルではない
-   セキュリティーが高いとはいえ、自分の経理データをソフト会社のサーバーに持っていかれること、他人に経理データを預けるのは気持ちが悪い

<!--listend-->

-   Ledger-cliは、トランザクションはテキストファイル。したがってcsvからLedgerに適合するように変換するのはさほど難しくはない
-   csvデータの構造が銀行によって異なっている。
-   主要な取引銀行については、csv-->Ledger-cliのトランザクションへ形式変換するスクリプトを作るのは、そんなに大掛かりな作業ではない。
-   しかし、それも面倒ならば
-   reckonを使ってみるのも　ありかも。
-   で、紹介。


## reckonの取得とインストール {#reckonの取得とインストール}

-   [Git reckon](https://github.com/cantino/reckon)
-   ruby/rubyreckonのインストールを確認

    ```nil
    $ ruby -v
    ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux-gnu]
    $ gem -v
    3.1.2
    ```
-   インストール

    ```nil
    $ gem install --user reckon
    ```
-   warning

    ```nil
    WARNING:  You don't have /home/yamagami/.gem/ruby/2.7.0/bin in your PATH,
    	  gem executables will not run.
    ```
-   上記binディレクトリのreckonを `~/bin/` に複写


### 使用例 {#使用例}

```nil
$ reckon -f hamagin_20210918093428.csv -o output.ledger
```

-   WARNING

    ```nil
    W, [2021-09-18T09:51:41.931030 #18784]  WARN -- : Skipping row: '?????????t, ???x?????z?i?~?j, ???a?????z?i?~?j, ???????c???i?~?j, ????' that doesn't have a valid date
    ```
-   半角カタカナでバグっている -->   `nkf --overwrite -w hoge.csv`
-   WARNING

    ```nil
    W, [2021-09-18T09:58:00.673340 #19054]  WARN -- : Skipping row: '2021-08-02, 12409, クレジツト   トヨタフアイナンス, 10775583, ' that doesn't have a valid date
    ```
-   日付のフォーマットで蹴られた　--> `sed -e -i 's/-/\//g' moge.csv`


#### こんな感じだが・・・ {#こんな感じだが}

```nil
$ reckon -f moge.csv -c 'JPY' --ledger-date-format '%Y/%m/%d' --suffixed --money-column 2 --inverse -o out.ledger

2021/08/02	クレジツト トヨタフアイナンス; 10775583
	liab:eneos
	Assets:Bank:Checking			-12,409.00 JPY

2021/08/03	ガス料; 10774471
	expns:gas
	Assets:Bank:Checking			-1,112.00 JPY

2021/08/05	電気料; 10769845セキュリティーが高いとはいえ
	expns:elec
	Assets:Bank:Checking			-4,626.00 JPY
  :
```


### bottom line is {#bottom-line-is}

-   YAMLファイルにルールを記述しないと使い物にはならない感じ。
-   金額をフォーマットで整数化できる？　yes.
-   amountは省略できればよいが


## Tips {#tips}


### 通貨単位を日本円にするなど {#通貨単位を日本円にするなど}

通貨単位をJPYにして、小数点以下のない整数にするには、ledgerファイルのヘッダーに以下を追加：

```nil
commodity JPY
  note Japanese Yen
  format 1,000,000 JPY
  nomarket
  default
```
