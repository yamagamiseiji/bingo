+++
title = "Ledger-cliのレジスターレポートのカラム崩壊を防止する"
author = ["YAMAGAMI"]
date = 2023-02-08T00:00:00+09:00
tags = ["ledger-cli", "複式簿記", "レジスターレポート", "列崩壊", "bash", "シェルスクリプト関数"]
categories = ["comp"]
draft = false
+++

****Ledger-cli**** では 勘定科目（account）名や支払い先（payees）名に
****日本語**** が含まれていると、レジスターレポートのカラムが乱れます[^fn:1]。

たとえば

```nil
$ ledger reg ^Expenses --begin 2023/02/03 --current
```

のように、 `regコマンド` でフォーマットを指定せずに支出（ `Expenses` ）に関するレポートを表示させると、結果は図1のようになります。勘定科目名と支払い金額、それから合計金額の列が ****崩壊**** します[^fn:2]。

{{< figure src="/no-format-reg-report.png" caption="<span class=\"figure-number\">&#22259;1:  </span>レジスターレポートのカラム崩壊" width="90%" >}}

Ledgerのフォーマット機能を使ってカラム指定しても、やっぱりマルチバイト文字では ****カラム崩壊**** を回避することはできません。

図2は、Ledgerのフォーマットで勘定科目名と支払い金額列の位置を逆にし、各項目の表示位置を指定しています。それでも事態は改善しません（図2）。

{{< figure src="/without-fixer.png" caption="<span class=\"figure-number\">&#22259;2:  </span>Ledgerフォーマット文で指定してもやっぱりカラム崩壊" width="90%" >}}

経理・会計の世界だけでなくどんな部門・領域でも、このようなカラム崩壊は許容されませんよね。しかしマルチバイトにきちんと対応するのは結構たいへんなようです。


## シェルスクリプト関数でカラム整列させる {#シェルスクリプト関数でカラム整列させる}

ここでは ****シェルスクリプト関数**** で
Ledge-cliのレジスターレポートのカラム崩壊を防止する一つの試みを紹介します。

これを使えば、 ****乱れた出力**** を整列させることができます（図3）。

{{< figure src="/fixer-applied.png" caption="<span class=\"figure-number\">&#22259;3:  </span>シェルスクリプト関数（カラム整列関数）を使って整列させた出力例" width="90%" >}}


## カラム整列関数の説明 {#カラム整列関数の説明}

関数を動かすためには、PC[^fn:3]に `SHIFT_JIS` ロケールを追加することが必要です[^fn:4]。

シェルスクリプトの要点はつぎのとおりです。

-   文字列操作は `export LC_ALL=ja_JP.sjis` と `export LC_ALL=ja_JP.utf8` とではさまれたパートで行います
-   ターミナルの横幅は80カラム（自由に変更可能です）
-   整列表示するのは、日付、支払い先、金額、最後に勘定科目の ****4項目**** です。合計金額は、80カラム内に収めるのは大変なので表示から外しています
-   Ledgerのレジスタークエリは関数の外から変数 `$QUERY` で与えます
-   `./out-dpamac.txt` に整列したテキストファイルが出力されます
-   勘定科目で長たらしいもの（主に英語のアカウント名）は、関数内で `sed` を使って短縮形に置換して表示します（ _e.g_ Expenses → Expns ）


## コード {#コード}


### func-dpaAC-column-fixer.sh 関数 {#func-dpaac-column-fixer-dot-sh-関数}

```sh
#!/bin/bash
#    date,payees,amount,A/C をカラム整列する関数
#
function dpaAC-column-fixer.sh(){
    # ターミナルの横幅=80用の設定
    DP_width=34 #date,payeeの幅
    AM_width=18 #amountの幅
    AC_width=26 #accountの幅
    #
    ledger reg --current ${QUERY}\
	   --no-revalued --real\
	   --format='%(format_date(date, "%Y/%m/%d"))&%(payee)&%(display_amount)&%(account)\n'\
	   > ./tmp-dpaAC.txt
    #
    if [ ! -s ./tmp-dpaAC.txt ]; then
	   echo "** No Expenses."
	   return
    fi
    ## payees,accountsを短縮するsedルールリスト
    sed -e "s/Assets/Ass/g;\
	     s/Balance/Bal/g;\
	     s/Expenses/Expns/g;\
	     s/Gardening/Gardn/g;\
	     s/Grocery/Groc/g;\
	     s/Household/HH/g;\
	     s/Income/Inc/g;\
	     s/Insurance/Ins/g;\
	     s/Liabilities/Liab/g;\
	     s/Reimbursement/Reimb/g;\
	     s/学習センター/学習CNTR/g"\
	   < ./tmp-dpaAC.txt > ./short-AC.txt

  # short-AC.txtを一旦SJISに変換し sjis.txt に
  iconv -c -f UTF-8 -t SHIFT_JISX0213 ./short-AC.txt\
		> ./sjis.txt
  # localeを一時的にSHIFT_JISに
  export LC_ALL=ja_JP.sjis
  #
  while read -r line; do
      DP=$(echo "${line}"\
	       | cut -d'&' -f 1-2\
	       | sed -e 's/&/ /g')
      AMOUNT=$(echo "${line}"\
		   | cut -d'&' -f 3)
      AC=$(echo "${line}"\
	       | cut -d'&' -f 4)
      printf "%-${DP_width}b%${AM_width}b  \e[34m%-${AC_width}b\e[m\n"\
			 "${DP:0:${DP_width}}"\
			 "${AMOUNT:0:${AM_width}}"\
			 "${AC:0:${AC_width}}"
  done < ./sjis.txt > ./out-sjis.txt

  # localeをUTFに戻す
  export LC_ALL=ja_JP.utf8
  # out-sjis.txt を UTF-8 変換してout-dpamac.txt に
  iconv -f SHIFT_JISX0213  -t UTF-8 ./out-sjis.txt\
	> ./out-dpamac.txt
  cat ./out-dpamac.txt
  # 一時ファイル削除
  rm tmp-*.txt ./sjis.txt ./out-sjis.txt ./short-AC.txt
}
```


#### 補足説明 {#補足説明}

Ledgerのフォーマットでは、出力項目（日付や支払先など）の区切記号として `&` を使っています。通常はスペースまたはタブですが、支払先の中にスペースが含まれている場合がありますので、スペースを項目の区切に使うことはできません[^fn:5]。


### 上の関数を呼び出すシェルスクリプト例 {#上の関数を呼び出すシェルスクリプト例}

```sh
#!/bin/bash
#
#   dpaAC-column-fixer.sh  コールテスト
#
source "./func-dpaAC-column-fixer.sh"
#
if [ -n "$*" ]; then
    QUERY=$*
else
    # default to
    QUERY="^Expenses -p today"
fi
#
dpaAC-column-fixer.sh
exit 0
```


## 今後の展望など {#今後の展望など}

かつて（2020/01/30）当ブログの「[ぼちぼちですが可視化してます](https://bred-in-bingo.netlify.app/posts/%E5%8F%AF%E8%A6%96%E5%8C%96/) 」の「おまけ」節で紹介した `today` というシェルスクリプトがありますが、 `today` の中で、このカラム崩壊防止関数を使おうと思っています。

じつは `today` では、かれこれ3年間もカラム崩壊したレジスターレポートをそのまま使っていました。もっぱら自分の転記作業をチェックするだけの用途なので、多少列が壊れていても良しとしていました。

ところで現在、この `today` の出力をウェブに流し込んで「いつでも、どこでも」（タブレットなどから）当日の支出をひと目で確認できるように改訂することを計画しています。すでに `today` では

1.  当月の月始めから当日までの ****支出予算と累積支出額**** とをプロット `budget-watch` チャート[^fn:6]

2.  当月の月始めから当日までの ****クレジットカード負債残高**** をプロットした `credit-cards-balance-tracking` チャート

の2枚も表示するようにしています。

カラム崩壊した支出レポートを、そのままウエッブ化すると、上の（プリティな :wink: ）チャートとの釣り合いが悪いので、この際 本気でカラム崩壊をなんとかしたいと思って作ったのがこのシェルスクリプト関数、という次第です。


## Footnotes: {#footnotes}

[^fn:1]: このカラム崩壊はマルチバイト文字特有の症状です。英文字だけの場合にはとても美しくカラムが整列します。なお、LedgerのバージョンはLedger 3.1.3-20190331です。
[^fn:2]: シングルバイト文字だけのトランザクションだと、Ledgerはかなり頭が良くて、ターミナルの幅を斟酌して支払い先の名称や勘定科目名を自動的に短縮形にして列が崩壊するのを防止してくれます。
[^fn:3]: PCはThinkPad X230, Ubuntu20.04です。
[^fn:4]: 「[LinuxでシフトJISが使えた](https://zenn.dev/tmtms/articles/202205-locale)」などのサイトをご覧ください。
[^fn:5]: 区切を `@` や `|` にすると、SJISのコードがぶつかって混乱を起こしかねません。
[^fn:6]: 「支出予算と累積支出額」のサンプルチャート。架空の金額でプロットしました。うすピンクの直線が ****予算線**** 、緑の折れ線が ****累積支出**** 、差額領域は予算以下なら<span style="color: blue">青</span>、予算オーバなら<span style="color: red">赤</span>にペイントされます。

    {{< figure src="/budget-daily-watch.svg" caption="<span class=\"figure-number\">&#22259;4:  </span>「支出予算と累積支出額」のサンプルチャート" width="80%" >}}
