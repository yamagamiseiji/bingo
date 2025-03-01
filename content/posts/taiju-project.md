+++
title = "1byone 体組成計のCSVデータから体重変化チャートをプロットする"
author = ["YAMAGAMI"]
date = 2025-01-06T00:00:00+09:00
tags = ["bash", "gnuplot", "health", "weight", "CSV"]
categories = ["comp"]
draft = false
+++

<div class="ox-hugo-toc toc">

<div class="heading">&#30446;&#27425;</div>

- [ここでは](#ここでは)
- [サンプル出力](#サンプル出力)
- [解説](#解説)
    - [1. BFSデータファイル選択](#1-dot-bfsデータファイル選択)
    - [2. 分析対象とする期間（period）を入力](#2-dot-分析対象とする期間-period-を入力)
    - [3. 体重推移データファイルの作成・保存](#3-dot-体重推移データファイルの作成-保存)
    - [4. 移動平均データファイルの作成・保存](#4-dot-移動平均データファイルの作成-保存)
    - [5. Gnuplotで描出](#5-dot-gnuplotで描出)
- [まとめ](#まとめ)
- [参考資料](#参考資料)
    - [シェルスクリプトtaiju_plotter.sh のダイアグラム](#シェルスクリプトtaiju-plotter-dot-sh-のダイアグラム)

</div>
<!--endtoc-->



## ここでは {#ここでは}

```text
1byone 体組成計からエクスポートされたCSVデータを
bashシェルスクリプトとgnuplotを使って折れ線グラフにする方法を紹介します
```

1byone 体組成計から **CSVデータを取得する方法** については
[CSVデータをエクスポートできる家庭用体組成計 -- 1byone smart scale](https://bred-in-bingo.netlify.app/posts/1byone-taijukei/)
をごらんください。


## サンプル出力 {#サンプル出力}

{{< figure src="/out-taiju.svg" caption="<span class=\"figure-number\">&#22259;1:  </span>過去3か月間の1日ごとの体重変化と7日間の移動平均チャート" width="80%" >}}

このようなチャートを描くためのスクリプト `taiju_plotter.sh` のダイアグラムを巻末の[参考資料](#参考資料)に掲載しました。

ダイアグラムで背景が **薄く黄色** に着色された5つのブロックについて、以下に説明します。


## 解説 {#解説}


### 1. BFSデータファイル選択 {#1-dot-bfsデータファイル選択}

**BFS** は **Body Fat Scale** の略です。<br />
`~/ダウンロード/` ディレクトリ内から文字列 `BodyFatScale` を含むファイルを最新順に表示し、そのリスト内から一つを選択します。<br />
**空のエンター** （デフォルト）が入力されたら、一番上＝最新のファイルを選択、それ以外のファイルを選択するときには、リスト中から **コピー** して入力プロンプトに **ペースト** します。

```sh
#
#  処理対象とするBodyFatScale データファイルを取得する
#  （BodyFatScaleファイルをfind検索・表示・入力する）
hit_list=$(find ~/ダウンロード/ -name 'BodyFatScale*.csv' -print0\
	       | xargs -0 ls -at\
	       | cut -d'/' -f 4- )

echo -e "** 候補ファイル（最新順） \n${hit_list}"
echo -e "\nエンターで最新ファイルを選択, それ以外ならコピペして下に貼り付ける"
read -r -p "Which BodyFatScale date file?  " which

# エンターかコピペファイ名取得かを選択する
if [ -z "${which}" ]; then
    bodyfatscale_path=$(echo "${hit_list}" | head -1 )
else
    bodyfatscale_path=$(echo "${which}")
fi
#
bfs_fname=${bodyfatscale_path}
echo -e "\n処理対象の BodyFatScale file= ~/${bfs_fname}"
```


### 2. 分析対象とする期間（period）を入力 {#2-dot-分析対象とする期間-period-を入力}

体重プロットのX軸（期間）を、1週、1か月、3か月、6か月、1年、2年の中から一つ選択します。デフォルトは１か月。

```sh
#  Period 入力プロンプト
if [[ $# == 0 ]]; then
    read -r -p 'Range?  [w]eek, [m]onth, [3] months, [6] months, [y]ear, or [2y]ear/[24m[onths] : '  keyin
    if [[ -z $keyin ]]; then
	keyin="m" # default goes to month
    fi
else
    keyin=$1
fi
```


### 3. 体重推移データファイルの作成・保存 {#3-dot-体重推移データファイルの作成-保存}

データの日付、時間を絞り込むために `dateutils.dgrep` を使っています。ubuntuで `dateutils.dgrep` を使うには **dateutils** パッケージのインストールが必要です。

```sh
#
# 体重推移データファイルを作り保存する
#
# ヘッダー行を削除し、日時と体重を抽出してtmp-date-taiju.csv生成(全期間）
sed -e '1d' ~/"${bfs_fname}"\
    |cut -d',' -f1,2\
     > ${tmp_dir}/tmp-date-taiju.csv

#  tmp-date-taiju.csvから午前のデータ（ <12:00:00 行）を抽出し
#  tmp-AM-date-taiju.csv に格納
dateutils.dgrep "<=12:00:00"\
		< ${tmp_dir}/tmp-date-taiju.csv\
		> ${tmp_dir}/tmp-AM-date-taiju.csv

# 上のAMデータからperiod の指定日from_dateよりも新しい日付を含む行をgrep抽出
from_date=$(date -d "${period} ago"  '+%Y-%m-%d')
dateutils.dgrep ">=${from_date}"\
		< ${tmp_dir}/tmp-AM-date-taiju.csv\
		> ${tmp_dir}/tmp-in-period.csv
```


### 4. 移動平均データファイルの作成・保存 {#4-dot-移動平均データファイルの作成-保存}

このパートでは、MA（moving average;移動平均）のデータファイルを作成します。<br />

-   移動平均を計算するために自前の関数（ `moving-average.sh` ）を使っています。この関数のソースコードは「[ローソク足と移動平均をgnuplotで描く](https://bred-in-bingo.netlify.app/posts/maandcandlesticks/)」の記事中の「参考資料」節をご覧ください。

<!--listend-->

```sh
#  MA（移動平均）計算用の補助データファイルを生成
#   日にちに余裕をもたせてwindows_size+5にする
aux_days=$(( window_size + 5 ))
aux_period_date=$(date '+%Y-%m-%d' -d "${from_date} - ${aux_days} days" )

dateutils.dgrep ">${aux_period_date}"\
		< ${tmp_dir}/tmp-AM-date-taiju.csv\
		> ${tmp_dir}/tmp-aux-period.csv

#  csvファイルをsortし、時刻とカンマを削除
target_file_arr=(
    "${tmp_dir}/tmp-aux-period.csv"
    "${tmp_dir}/tmp-in-period.csv")

for file in "${target_file_arr[@]}"; do
    # 日付の古いものから昇順にsort
    sort -u ${file} -o ${file}
    # 時刻部分とその後ろのカンマを削除する
    sed -E -i  's/[0-9]{2}:[0-9]{2}:[0-9]{2},//g' ${file}
done

#  tmp-aux-period.csv について移動平均を計算する
#  移動平均関数をコール： 引数1=データファイル名, 引数2=列の位置, 引数3=窓サイズ
#                        出力は ./tmp-MA-out.dat
moving-average "${tmp_dir}/tmp-aux-period.csv" 2 7

#  date-taiju-MA生成（date-taiju.csv に tmp-MA-out.dat をjoin）
join -a 1 ${tmp_dir}/tmp-in-period.csv ${tmp_dir}/tmp-MA-out.dat\
     > ${tmp_dir}/date-taiju-MA.dat
```


### 5. Gnuplotで描出 {#5-dot-gnuplotで描出}

Gnuplotのスクリプトはシェルスクリプト内の **ヒアドキュメント** にしています。

-   gnuplotで使用する変数（$xrange1, $xrange3, $title_from_date, $title_to_date, $out_file, $data_to_plotなど）の値は、このヒアドキュメントの前に定義しています。

<!--listend-->

```sh
gnuplot <<EOF
  set terminal pdfcairo transparent enhanced font 'Arial, 12'
  set datafile separator " "

  # 図のタイトル/STATS
  set title "体重推移と移動平均（${title_from_date} - ${title_to_date}）" font 'Arial, 14'
  stats "${tmp_dir}/date-taiju-MA.dat" using 1:2 nooutput

  # yrange の最大最小を取得する
  ymax=ceil((STATS_max_y + 0.1) *10) /10.0
  ymin=floor((STATS_min_y -0.1) *10) /10.0

  # X軸設定
  set xdata time
  set timefmt "%Y-%m-%d"
  set format x "%01m/%01d"
  set xrange ["${xrange1}":"${xrange3}"]

  # Y軸設定
  set ylabel "体重（kg）" font 'Arial,14'
  set yrange [ymin:ymax]
  set y2range [ymin:ymax]
  set format y  "%3.1f"
  set format y2 "%3.1f"
  set y2tics
  set grid ytics

  set output "${out_file}"
  plot "${data_to_plot}"\
	 u 1:2 w linespoint title "体重（kg）" lc rgb "blue"\
		lt 7 ps 0.3 lw 1.0,\
      '' u 1:3 w linespoint title "移動平均(7日)" lc rgb "#FF7D7D"\
		ps 0.3 lw 3.5
  set output
EOF
```


## まとめ {#まとめ}

作成した体重推移の折れ線グラフをAndroidタブレットのJoplinで見えるようにするために、PDFをSVGに変換し、Dropbox内の `Joplin/pics/` ディレクトリに保存しています（ダイアグラムの最後のブロック＝「後始末」）。

体重以外の体組成データも、これと同じ方法で可視化できますが、今のところはこれで満足しています :smile:


## 参考資料 {#参考資料}


### シェルスクリプトtaiju_plotter.sh のダイアグラム {#シェルスクリプトtaiju-plotter-dot-sh-のダイアグラム}

背景が薄黄色のブロックについて本文中で解説しました[^fn:1]。

{{< figure src="/colored-taiju-daiagram.svg" caption="<span class=\"figure-number\">&#22259;1:  </span>taiju_plotter.sh のダイアグラム" width="70%" >}}

[^fn:1]: このダイアグラムは[Mermaid](https://mermaid.js.org/) を使って書きました。
