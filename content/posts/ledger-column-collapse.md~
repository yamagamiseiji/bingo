+++
title = "Ledger出力の列崩壊を回避する"
author = ["YAMAGAMI"]
date = 2021-05-01T00:00:00+09:00
tags = ["ledger", "account"]
categories = ["comp"]
draft = false
+++

Ledger-cliは

小規模ビジネスや団体、研究費、家庭の経理こんなに便利なツールは無いとくにサイエンス系、理系の人たちには福音といっても言い過ぎではない

いくら称賛しても称賛しきれないほど素晴らしいツール

しかし日本では多く使われている気配がない。

最大の理由は、伝統的な「貸し方」「借り方」という概念を使わない複式簿記になにか不安とか馴染みがないとか、

他にもいくつかの理由があるが、そのうちの一つ日本語とアルファベットが混在したbalance出力の金額列のカラムが整列しない。

カラム崩壊してしまうことも関係あるかもしれない。

たとえばこんなふうに：（）どうも列崩壊は治ったらしひかと思ったが、やはり治っていない。

2年間ほどは、まぁいいかと目をつぶっていたが、Ledgerで計算をする範囲が拡大するにつれて、結果の表示のカラム崩壊はだんだんと我慢ができなくなってきた。

ところがこの問題は、Ledgerの問題というだけではく、UTFのコードの問題。（参考資料）

2年間放置していたのは、これにかかずらわるのを避けていたから。

繰り返しになるが、しかし我慢ができなくなった。ので、どれほど暴力的であろうとも、ブサイクであろうとも、ともかく出力のカラム列を整列させたい、ということで、一つの方法を使うようになった。それをここで紹介する。:sweat_smile:

```nil
#!/bin/bash
set -eu
#
#  列崩壊のないbalance出力を得る
#
ledger bal cars --no-total  --balance-format \
       '%-.24((depth_spacer)+(partial_account))\n' \
       -o ./tmp-acnt.txt
#
ledger bal cars --no-total --balance-format  \
       '%(justify(scrub(display_total), 15, -1, true, color))\n' \
       -o ./tmp-amount.txt
## 列崩壊防止のため一旦SJISに変換
iconv -f UTF-8 -t SHIFT-JIS ./tmp-acnt.txt | \
    cut -b 1-24 | iconv -f SHIFT-JIS -t UTF-8 > ./tmp-24.txt
#
paste -d' ' ./tmp-24.txt ./tmp-amount.txt > ./tmp-pretty.txt
##
cat ./tmp-pretty.txt
exit 0
```

ミソは、 `cut -b 1-24` の数字部分。これが大きいとTABの混入とか変なことが起こる。
 `display_total` の文字数15も割に重要。これも小さくしすぎると列崩壊する。


## 列崩壊防止の実施前後のちがい {#列崩壊防止の実施前後のちがい}

```nil
 ：
Parking                      8,590 JPY
Toll                       320,260 JPY
保険                       164,150 JPY
  任意保険                 138,320 JPY
  自賠責                    25,830 JPY
整備修繕                   211,404 JPY
税金                       112,800 JPY
  手数料                     1,000 JPY
 ：
```