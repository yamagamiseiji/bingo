+++
title = "Ledger — 支払先のタイプミスをチェックする"
author = ["YAMAGAMI"]
date = 2029-12-31T00:00:00+09:00
tags = ["farming", "food"]
categories = ["comp"]
draft = false
+++

##  {#d41d8c}

家計簿でも会社の帳簿でも、支払先の名前をタイプミスするとちょっと面倒なことが起こる。会計ソフトにはそれへの対応策が含まれている？

Ledgerでも簡単で便利なツールが用意されています。

以前（2019/10/04）、
[プレーンテキストファイルで「複式」家計簿(9)](https://bred-in-bingo.netlify.app/posts/9th-step_ledger/#payees%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89)
で `payees` コマンドと `-by-payee (-P)` オプションについて簡単に紹介。


### 復習しておきます {#復習しておきます}

`payees` コマンドには大きく分けて2通りの使い方があります。引数なしで起動すると `myledger.data` に含まれる全ての支払先名が表示されます。

```sh
  $ ledger payees -f myledger.data
ANA
APITA
ATM
AWS
Amazon
　：
```

これに `--count` オプションを付けて起動すると、各支払先の先頭に出現頻度が表示されます[^fn:1]。

```sh
    $ledger payees --count -f myledger.dat
    12 ANA
     2 APITA
     108 ATM
     56 AWS
     282 Amazon
　　　：
```

引数をつけて起動する方法もあります。たとえば、お酒(liquor)の購入先とその回数を知りたいときには次のようにします。

```sh
$ ledger payees liquor --count
60 Costco
1 KALDI
1 OKストア
1 まるきゅう
10 やまや
　　：
```


## さて本題 {#さて本題}

`--check-payees` オプションは
Enable strict and pedantic checking for payees as well as accounts, commodities and tags.

```sh
$ led b --check-payees -f myledger.data
```

ここでは、もう少し詳しく手順を説明します。


## Footnotes: {#footnotes}

[^fn:1]: この場合の頻度とはトランザクションの数ではなくて、トランザクション内に含まれるアカウントの数になっています。なので、たとえば<br />
    2020/10/10 レストランHOGE<br />
    　Expenses:Dinner         3,000 JPY<br />
    　Expenses:Grocery:Liquor 1,200 JPY<br />
    　visacard<br />
    レストランHOGEで一度しか食事してない場合でも ~ledger payees --count= すると、<br />
    　3 レストランHOGE<br />
    になります。
