+++
title = "Ledger-cliのアカウント構造を樹状図にする"
author = ["YAMAGAMI"]
date = 2023-01-17T00:00:00+09:00
tags = ["ledger-cli", "複式簿記", "tree", "アカウント構造", "mkdir"]
categories = ["comp"]
draft = false
+++

2023年の新年早々、ふとしたことから こんな図が書きたくなりました。

{{< figure src="/1st-sample.png" width="70%" >}}

要するに ****ledger-cli**** のアカウント（勘定科目）構造を ****樹状図**** にするということ。

もしかしたらledger-cliに備え付けのコマンドとかオプションがあるかもしれないと思い、ちょっと検索してみましたが見当たりません。

ということで、この樹状図を書く方法を数日前から考えていました。基本的な考え方は：

-   アカウント一覧を表示するledger-cliの ****accounts**** を使う
-   表示されたアカウント構造を ****mkdir**** してディレクトリ構造にする
-   それを ****treeコマンド****[^fn:1] を使って表示する

途中で変なところではまったりして一時混乱していましたが、最終的には

-   Ledgerの ****accounts**** コマンドの出力を1行ずつ読む
-   各行ごとにコロンをスラッシュに変換する
-   それを配列か何かに格納しておいて ****mkdir -p**** する

という方針を採用しました。この方針にしてからは、コーディングの時間は1時間未満 :smile:

とても短く簡単なスクリプトができました。


## コード {#コード}

アイデア的には

-   任意の場所に ****ACCOUNT**** という親ディレクトリを作る
-   その配下にサブアカウント（下位勘定科目）名のサブディレクトリを作る
-   Ledger-cliの標準的な引数をそのまま流用して樹状図に書き出す範囲を絞り込む
-   ****tree**** を使って樹状図を書く

というもの。

```sh
#!/bin/bash
#
#  LedgerのA/C構造を樹状図にするスクリプト
#  Ledgerのパラメータがそのまま使える

base_dir="どこか任意のpath"

## 引数文字列受け
if [ $# = 0 ]; then
    echo "WARNING: Ledgerのオプションが使えます"
    echo "         引数なしだと樹状図が長大になります"
    read -n 1 -r -p "引数で絞りこみますか？ [y/n] : " keyin
    case $keyin in
	Y|y) echo -e
	     read -r -p "ledger --acounts オプション : " param ;;
	*) : ;;
    esac
else
    param=$*
fi

## accounts.datの取得・加工
ledger accounts ${param} --count\
       > ${base_dir}/accounts.dat

awk -i inplace  -F" " '{print $2}' ${base_dir}/accounts.dat

## ここから本体　これだけ
#      リセット ACCOUNT
cd ${base_dir} || exit 0
rm -rf ACCOUNT/
mkdir -p ACCOUNT
cd ACCOUNT || exit 0

while read -r line ; do
    dir_path=$(echo "${line}" | sed -e 's/:/\//g')
    mkdir -p "${dir_path[@]}"

done < ${base_dir}/accounts.dat
#   tree diagram drawing
cd ${base_dir} || exit 0
tree -d ACCOUNT

exit 0
```


## サンプル出力 {#サンプル出力}


#### 引数なしで起動したとき {#引数なしで起動したとき}

```sh
$ tree-it.sh
```

{{< figure src="/no-params.png" width="70%" >}}

ここで ****n**** を選んで ****絞り込み無し**** にすると、全期間にわたって全アカウントがアカウントの全深度について表示されます。情報量が多すぎて使い物になりません。

したがって基本的には、次の例のように起動時に引数で ****絞りこみ**** をする使い方になります。


#### 引数つきで起動した例１ {#引数つきで起動した例１}

期間を2022/12/01からに指定し、アカウント深度２で「支出 or 資産 or 負債」で絞り込んだ例：

```sh
$ tree-it.sh ^expenses or ^assets or ^liab -b 2022/12/01 --depth 2
```

{{< figure src="/exp-liab-ass..png" width="70%" >}}


#### 引数つきで起動した例２ {#引数つきで起動した例２}

期間を2022/06/01からに指定し、支出の中で外食(Meals) と 食料品(Grocery）をアカウント深度５で絞り込んだ例：

```sh
$ tree-it.sh ^Expenses and \( meals or grocery \) --depth 5 -b 2022/06/01
```

{{< figure src="/grc-and-meal.png" width="70%" >}}


## 今後の展望など {#今後の展望など}

****tree-it.sh**** では、Ledgerの ****accounts**** コマンドで ****--count**** オプションをつけています。これを使うと、クエリされたアカウントの出現頻度が得られますので、出現頻度で絞りこんでアカウントの樹状図を書くことができます。

このスクリプトでは、ほとんどの機能はledger-cliに ****おんぶに抱っこ**** 状態です。使えば使うほど、Ledger-cliの適用範囲の広さと奥深さを感じます。


## Footnotes: {#footnotes}

[^fn:1]: ubuntuには標準ではインストールされていないので apt install tree します。
