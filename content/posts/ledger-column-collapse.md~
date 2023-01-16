+++
title = "Ledger-cliのregisterレポートのカラム崩壊"
author = ["YAMAGAMI"]
date = 2023-01-10T00:00:00+09:00
tags = ["ledger-cli", "カラム崩壊"]
categories = ["comp"]
draft = false
+++

## Ledger-cliは さいこーです・・・ {#ledger-cliは-さいこーです}

Ledger-cliは2003年に ****John Wiegley**** さんによって創られたきわめて高機能・多機能な ****プレインテキスト**** ベースの ****複式簿記**** 経理ソフト。

小規模ビジネスやNPOなどの団体、家計簿、研究費の経理・管理を行うときには「神アプリ」です。しかもオープンソースでフリー。サイエンス系の人たちにはこれ以上のものはない「福音」だと思います。

けれども、わが国ではユーザは多くないようです。

なぜでしょうか？

一つは、「貸し方」「借り方」という伝統的な概念を使わない複式簿記に馴染みがないからかも知れません。

日本語での参考資料が書籍でもホームページ上にも、からなずしも多くないことも関係しているかも知れません。

あともう一つの可能性は、勘定科目（account）や支払先（payee）内に日本語とアルファベットが混在していると、そのregisterレポート出力に ****カラム崩壊**** が起こることに関係があるかもしれません[^fn:1]。


## カラム崩壊例 {#カラム崩壊例}

激しく崩壊するのは、ターミナル幅が80文字と狭く、勘定科目(account)がマルチバイト混在しているときです。

Ledger-cliの
`--account-width`, `--abbrev-len` などのオプションを使って、何とか整列させてようと思っても、なかなか手に負えない状態になります。

`--wide` オプションをつけて、ターミナル幅を拡げて132文字にすれば少なくとも私のLedgerファイルについてはカラム崩壊は起こりません。なので、カラム崩壊のためにLedger-cliを使うのを止めるというほど致命的な障害ではありません。

希望はとてもささやかなものです。

> せめて、日付、支払先、金額の3つを並べた時には、金額列が ****右揃え**** になって欲しい

だけです。

たとえば、
`"^expenses and cars"` について次のようなフォーマット文でregisterレポートを表示してみましょう。

```text
$ ledger reg ^expenses and cars -b 01/20\
   --format "%d %-40P %(ansify_if(justify(scrub(display_amount), 15,\
   15 + int(prepend_width), true, color)))\n"
```

-   当然のことながら、マルチバイト文字を含まないアルファベットのみで構成されたトランザクションではカラムは完璧に整列します。
-   ところが、支払先（payee）に日本語、アルファベットが混在していると、次の図 [1](#figure--ugly-shot)のように残念な結果になります。

<a id="figure--ugly-shot"></a>

{{< figure src="/screenshot-ugly.png" caption="<span class=\"figure-number\">&#22259;1:  </span>Ledger-cliの標準出力" width="90%" >}}

これでは、どこかに報告書として出すのではなく、ごく私的に結果を見るだけだとしても、ちょっと苦しい。


### せめてこんな感じになって欲しい {#せめてこんな感じになって欲しい}

<a id="figure--pretty-shotpayeeが"></a>

{{< figure src="/screenshot-pp.png" caption="<span class=\"figure-number\">&#22259;2:  </span>カラム崩壊を抑えた出力のイメージ" width="90%" >}}

抜本的な対策はとても無理ですが、とりあえず迂回的で（姑息な？）やり方でなんとかしのいでいます[^fn:2]。ここではそれを紹介します。


## 苦し紛れの迂回策 {#苦し紛れの迂回策}

目的は、勘定科目名(account名)は表示せず、日付、支払先、金額の3項目だけをカラム崩壊なしで表示することにあります。

原理と仕掛けはとても簡単です：

> 1.  date+payee(日付+支払先)を固定長にするための関数を用意する
> 2.  固定長にされたdate+payeeの右側に、支出金額を右寄せにして表示する


### カラム崩壊を抑える関数 dp-file_justifier {#カラム崩壊を抑える関数-dp-file-justifier}

date,payeeファイルを右寄せするためのシンプルな関数です[^fn:3]。

```nil
#!/bin/bash
# date,payeeファイル(dp-file)を行末にスペースを埋めて固定長にする関数
#   引数　1. 入力ファイル ./tmp-dp.txt　
#        2. 出力ファイル ./tmpt-fixed-dp-file.txt

function dp-file_justifier () {
    local CUTOUT_BYTES=40
    # tmp-payee.txtを一旦SJISにし40バイト切り出してUTFに戻す
    iconv -f UTF-8 -t SHIFT-JIS ./tmp-dp.txt\
       | cut -b 1-${CUTOUT_BYTES} \
       | iconv -f SHIFT-JIS -t UTF-8  > ./tmp-fixed-dp.txt
}
```


### 補足説明 {#補足説明}

-   関数内のローカル変数は `${CUTOUT_BYTES}` のみです
-   切り出しバイト数は支払先（payee）の文字長に応じて適宜、変更が必要です
-   `./tmp-dp.txt, ./tmp-fixed-dp.txt` はグローバルな名前です


### 上の関数を呼び出す親スクリプト例 {#上の関数を呼び出す親スクリプト例}

```nil
#!/bin/bash
#
source  func-dp-file_justifier.sh
#　
from_date='2022/05/01'
to_date=$(date "+%Y/%m/%d")

# 日付(date)と支払先(payee)を取得し tmp-dp.txt へ保存
ledger reg ^expenses -b "${from_date}" -e "${to_date}"\
   --real --no-revalued\
   --format "%d %-40P\n"\
   -o ./tmp-dp.txt

# 関数コール（tmp-dp.txt から tmp-fixed-dp.txt を作る）
dp-file_justifier

# 金額amountを右寄せして tmp-amont.txt に保存
ledger reg ^expenses -b "${from_date}"  -e "${to_date}"\
   --format "%(ansify_if(justify(scrub(display_amount), 15, 15 + int(prepend_width), true, color)))\n"\
   -o tmp-amount.txt

# pasteで date,payee,amount(dpa)のpretty printファイルを生成
paste -d" " ./tmp-fixed-dp.txt ./tmp-amount.txt\
   > ./pretty-print-dpa.txt
exit 0
```

こんな感じで、苦しまぎれですがカラム崩壊を回避しています。

マルチバイト文字のバイト長やキャラクターの数は管理できても、画面上（または紙の上）で占める物理的な「長さ」をきちんと揃えるのは（bashでは）なかなかむずかしいようです。

どなたか Ledger-cliで使えそうな良い方法があれば教えて頂きたいと思います。


## Footnotes: {#footnotes}

[^fn:1]: バランスレポートのときには、価格（amount）の列が一番左のに来て、勘定科目（account）の列が右端にくるのでカラム崩壊は起こりません。
[^fn:2]: UTFでは、バイト数と文字数が単純に対応してるわけではないので、この方法で常にすべてのトランザクションのカラムが整列するわけではありません。この方法では「ほぼほぼ」カラムが整列してくれることを目指しています。もし完璧を求めるならもっと大掛かりな仕掛けが必要だと思います。
[^fn:3]: [こちら](https://teratail.com/questions/70409)を参考にさせていただきました。
