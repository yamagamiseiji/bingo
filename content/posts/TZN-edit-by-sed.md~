+++
title = "Ledger-cliのトランザクション中のアカウント名をsedで一括変更"
author = ["YAMAGAMI"]
date = 2022-12-31T00:00:00+09:00
tags = ["ledger-cli", "sed", "accounts"]
categories = ["comp"]
draft = false
+++

## Ledger-cliのアカウント名を変更したい {#ledger-cliのアカウント名を変更したい}

Ledger-cli はいつでも自由にアカウント名（勘定科目名）やアカウント構造を変更できます。

今回は従来の ****CableTV**** というアカウントを変更して ****StreamTV:Netflix**** というアカウント名にしたい

```text
＜変更前＞
2019/07/15 Netflix
    Expenses:教養娯楽費:CableTV             1,296 JPY
    Liabilitie:Visa

＜変更後＞
2019/07/15 Netflix
    Expenses:教養娯楽費:StreamTV:Netflix    1,296 JPY
    Liabilitie:Visa
```

****CableTV**** には、NetflixだけではなくてHuluとかiTSCOMとかも含まれていますので、単純に `sed 's/CableTV/StreamTV:Netflix/g'` するわけには行きません。

> 文字列Netflixの「次の行」にCableTVがあったら
>
> それをStreamTV:Netflixに変更する

これをやりたいわけです。手動で変更するのは最悪で、件数が多いとかならずタイプミスが起こります。

どうしたら良いかと思っていたら、sedにはちゃんと方法があるんですね[^fn:1]。


## やったことは・・・ {#やったことは}

```text
$ sed -e '/Netflix/{n;s/CableTV/StreamTV:Netflix/}' original-ledger.dat > new-ledger.dat
```

つまり
****{n;}**** を使うだけ&#128517;

これでもともとのLedgerデータファイル中の
****Netflix**** という文字列がある行の<span style="color: red 次の行"></span>にある ****CableTV**** が ****StreamTV:Netflix**** に置換されました。めでたしめでたし！

sedで行をまたいだ文字列を置換できることが分かりましたので、過去のトランザクション中のアカウント名の変更がこれまで以上に簡単にできるようになりました。タイプミス リスクも大幅に減ります。

Ledger-cliが複式簿記を
Ledger-cliがデータとしてプレーンテキストであること
Bash/sed のすばらしさ、に感謝いっぱいです。


## Footnotes: {#footnotes}

[^fn:1]: 参考にさせていただいたサイトは [sedのお勉強2 特定文字列に一致した次の行を操作するスクリプト](<https://foxtrot0304.hatenablog.com/entry/2015/12/09/015537>)　です🙏
