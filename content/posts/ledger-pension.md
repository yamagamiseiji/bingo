+++
title = "Ledger — 年金転記の落とし穴"
author = ["YAMAGAMI"]
date = 2021-12-31T00:00:00+09:00
tags = ["ledger", "pension", "年金"]
categories = ["comp"]
draft = false
+++

昨日（2021/10/22）、「年金の転記」に今まで気づかなかった穴があることに気づきました。
2年以上（or まだ2年）Ledgerを使っていたのに・・・。

きっかけは、 **`payee-ranking_plotter`** というスクリプトの出力がバグったこと。

このスクリプトは、指定した期間内における **支出額** を **支払先** （payee)別にソートして、上位13位までを **横棒グラフ** に描くというものです。期間のディフォールトは1年間なので、引数なしで起動すると、図[1](#org3f45598) のような出力になります。

<a id="org3f45598"></a>

{{< figure src="/payeee-12m-ranking.jpg" caption="&#22259;1:  `payee-ranking_plotter` の出力例（支払先の名前は一部マスクしています）" width="90%" >}}

これは正常な出力例ですが、昨日の出力では、この図の中に「 **国民年金** 」という項目が混入していました。

国民年金は **支出** ではありません。支出ランキングに乗ってくるのは明らかなバグ。どうしてこんな **アホ** なことが起こったかの説明です。


## `payee-ranking_plotter` スクリプト内のクエリパート {#payee-ranking-plotter-スクリプト内のクエリパート}

次のようになっています：

<a id="code-snippet--src-1"></a>
```nil
 ：
ledger bal ^expenses --group-by='payee' -b ${from_date} --current\
     --depth 1 --total-data -o ./tmp-raw.txt
 ：
```

<div class="src-block-caption">
  <span class="src-block-number"><a href="#code-snippet--src-1">ソースコード 1</a></span>:
  スクリプト内のクエリ部分
</div>

つまり、単純に `^expenses --group-by='payee'` でクエリして balance を計算して、それを一時ファイル `tmp-raw.txt` に保存しています。

年金のトランザクションを見ると次のようになっていました(金額は実際のものではなくて、改変しています)：

<a id="code-snippet--bad-trans"></a>
```nil
＜修正前＞
2021/10/15 * 国民年金
   Income:国民年金              (-100,866 JPY /2) ; [2021/08/15]
   Expenses:Insurance:介護保険    (18,400 JPY /2) ; [2021/08/15]
   Expenses:租税公課:地方税       (26,800 JPY /2) ; [2021/08/15]
   Income:国民年金              (-100,866 JPY /2) ; [2021/09/15]
   Expenses:Insurance:介護保険    (18,400 JPY /2) ; [2021/09/15]
   Expenses:租税公課:地方税       ( 26,800 JPY /2) ; [2021/09/15]
   Assets:Bank
```

<div class="src-block-caption">
  <span class="src-block-number"><a href="#code-snippet--bad-trans">ソースコード 2</a></span>:
  ledgerファイル内の国民年金の転記（修正前）
</div>

このトランザクションだと、 `^expenses` でクエリした後、payeeで `--gropu-by=` すれば、とうぜん次の支出が計上されます。

```text
Expenses:Insurance:介護保険
Expenses:租税公課:地方税
```


### ソースコード[2](#code-snippet--bad-trans)を使っていたワケ {#ソースコード-2--org16fe21e--を使っていたワケ}

なぜこんな風に転記したかの理由。

-   国民年金は、 **介護保険** と **住民税** が **天引**&nbsp;[^fn:1]されて支給されます。引かれた後の **振込金額** だけを銀行口座からゲットして記帳していると、天引された金額はunknownになります。

-   そこでこれまでは、ソースコード[2](#code-snippet--bad-trans)のように、「国民年金」のトランザクションを1ブロックにして、その中に、収入（Income）と支出（Expenses）を両方とも書いておくことにしました。こうすることで、年金支給の明細がわかりやすく記述できます。


### しかし昨日までは {#しかし昨日までは}

`--gropu-by='payee'`
という仕掛けを使うと、支払先の分析がとても簡単にできることに目を奪われていました。

```text
--group-by='payee' を使うときには
payeeに「国民年金」のように収入と支出の両側面をもつトランザクションを
書いてはならない
```

これが今回の教訓です。


### 対策 {#対策}

そこで、ソースコード[2](#code-snippet--bad-trans) は次のように、3つのパートに分けた形に書き換えることにしました[^fn:2]。

```nil
2021/10/15 * 国民年金
    Income:国民年金                   (-100,866 JPY /2) ; [2021/08/15]
    Income:国民年金                   (-100,866 JPY /2) ; [2021/09/15]
    Assets:Bank

2021/10/15 * 介護保険
    Expenses:Insurance:介護保険         (18,400 JPY /2) ; [2021/08/15]
    Expenses:Insurance:介護保険         (18,400 JPY /2) ; [2021/09/15]
    Assets:Bank

2021/10/15 * 個人住民税（特別徴収）
    Expenses:租税公課:地方税             (26,800 JPY /2) ; [2021/08/15]
    Expenses:租税公課:地方税             (26,800 JPY /2) ; [2021/09/15]
    Assets:Bank
```


### 補足説明 {#補足説明}

-   年金は2ヶ月に一度、偶数付きにその月より前の2ヶ月分が支払われます。各トランザクション内の金額の後ろにある `; [ ]` 内の日付はそのことを示しています。


## 給与明細書の転記 {#給与明細書の転記}

給与明細書には年金以上に多くの天引費目があります。最終的な振込額だけをもって収入とする記帳方法を取らないとすれば、この例のように社会保険料や所得税、積立預金などなどの項目を一つずつ独立のトランザクションにしておくことが、あとあとの正確な分析には必要だと思います。

そして、それらのトランザクションは毎月、手入力で転記するのではなく、
Ledgerの自動転記の機能を使うべきでしょう。

サラリーマンにそれをやらせないようにできるだけ複雑にしている

税負担を意識させない

社会保障負担を意識させない

消費税を内税化する方向にしているのと同じ。


## おまけ {#おまけ}

横棒グラフを描く方法のミソの部分を紹介する。


## Footnotes: {#footnotes}

[^fn:1]: この言葉はほんとうに **奇異** です。本来、自分のものである金を抜いている主体は **天(heaven)** ではありませんよね。国または地方の行政組織です。国民にサービスする機関のくせして、天とは生意気。「特別徴収」という語の「特別」も奇異。「無許可徴収」ですね
[^fn:2]: Ledgerを使い始めた最初の時期は、このような描き方をしていました。1ブロック化するようになったのは比較的最近になってからです。