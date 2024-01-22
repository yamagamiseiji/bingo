#!/bin/bash
#                         Time-stamp: <2024-01-22 10:05:46 yamagami>
#  NPO 活動計算書 貸借対照表 表示・印刷  financial-statements.sh
#
config_dir="./configs"
#commodity="JPY"
commodity=""
#
active_title="活動計算書"
bal_title="貸借対照表"
npo_name="NPO法人名：XYZ"
hiduke=$(date +'%Y/%m/%d')
from_date="2021/04/01"
to_date="2022/03/31"
comm_note="(単位:円)"
table_width="45"

#  第2列の数値は`--depth`用
ACNT_arr=(
    "経常収益 2 income"
    "経常費用 4 expns"
    "資産 4 assets"
    "負債 3 liab"
)
###############################################
#  本体ループ
###############################################
for ACNT in "${ACNT_arr[@]}"; do
    account=$(echo $ACNT | cut -d' ' -f 1)
    depth=$(echo $ACNT | cut -d' ' -f 2)
    f_name=$(echo $ACNT | cut -d' ' -f 3)

    if [[ ${account} = "負債" || ${account} = "経常収益" ]]; then
	fugo="-"
    else
	fugo=""
    fi

    # カラムの乱れ（列崩壊）を直し整列させる
    ledger bal ${account} --init-file ${config_dir}/init-npo.dat\
	   --depth ${depth} --sort -account\
	   --balance-format "%(! options.flat ? depth_spacer : \"\")%(ansify_if(partial_account(options.flat), blue if color))|%(justify(scrub(${fugo}display_total), 20, -1, true, color))\n%/%\$1\n" \
	   -o ./column-broken-${f_name}.dat
    # 
    iconv -f UTF-8 -t SHIFT-JIS ./column-broken-${f_name}.dat\
	  > ./sjis-${f_name}.dat
    export LC_ALL=ja_JP.sjis
    #
    while IFS= read -r line; do
	account=$(echo -n "${line}" | cut -d"|" -f 1 )
	amount=$(echo "${line}" | cut -d"|" -f 2 | sed 's/ JPY//g' )
	printf "%-20b%20b\n" "${account:0:20}" "${amount:0:20}"
    done < ./sjis-${f_name}.dat > ./pretty-sjis-${f_name}.dat

    export LC_ALL=ja_JP.utf8
    #
    nkf -w pretty-sjis-${f_name}.dat > utf-pretty-${f_name}.dat
done
#
cat utf-pretty-income.dat utf-pretty-expns.dat > activity-statement.txt
cat utf-pretty-assets.dat utf-pretty-liab.dat  > balance-sheet.txt

#
# 活動計算書、貸借対照表の最下段にある「正味財産」パート計算
#
################################################
# 1. 基本4アカウントのbalance総額を算出し変数に
#    格納(income,expns,assets,liab)
################################################
for acnt in "${ACNT_arr[@]}"; do
    kw=$(echo $acnt | cut -d ' ' -f1)
    str=$(echo $acnt | cut -d ' ' -f3)
    eval $str=$(ledger bal ${kw}\
		   -J --init-file ${config_dir}/init-npo.dat\
		   -f ./sample-npo-data.ledger --depth 1\
		     | cut -d' ' -f 2 | sed 's/-//g')
done
#
################################################
# 2. 変数などの準備
# ＜変数名 定義＞
#  NW : net worth/wealth  正味財産増減額 (Assets - Liab)
#  NI : net income  当期正味財産増減額 ( Income - Expenses )
#  COFY : CarryOver From prior Year  前期繰越
#  CONY : CarryOver to Next Year 次期繰越
#  NW : net worth/wealth  正味財産 ( NW = COFY + NI )
################################################
ni=$(( income - expns ))
NI=$(printf "%'d%s\n" "$ni" " ${commodity}")
cofy="50000" # 本来前年度から引き取る金額
COFY=$(printf "%'d%s\n" "${cofy}" " ${commodity}")
cony=$(( ni + cofy ))
CONY=$(printf "%'d%s\n" "${cony}" " ${commodity}")
Liab_NW_total=$(printf "%'d%s\n" "${assets}" " ${commodity}")

###################################################
# 3. 活動計算書 activity-statement.txt の作成
###################################################
# ヘッダー
{
    printf "%*s\n" $(( ($table_width + $(printf "$active_title" | wc -c)) / 2)) "$active_title"
    printf "%*s\n" $(( ($table_width + $(printf "$npo_name" | wc -c)) / 2 )) "$npo_name"

    active_date=$(echo "$from_date〜$to_date  $comm_note" )
    printf "%*s\n\n" $(( ($table_width + $(printf "$active_date" | wc -c)) / 2 )) "$active_date"

    cat utf-pretty-income.dat utf-pretty-expns.dat

} > activity-statement.txt

# 正味財産パート
#
{
    printf "%-20s%23s\n" "　当期正味財産増減" "${NI}"
    printf "%-20s%23s\n" "　前期繰越正味財産" "${COFY}"
    printf "%-20s%23s\n\n\n" "　次期繰越正味財産" "${CONY}"
} >> activity-statement.txt
#
###################################################
# 4. 貸借対照表 balance sheet の作成
###################################################
# ヘッダー
shomi_zaisan=$(( cofy + ni ))
shomi_zaisan=$(printf "%'d%s\n" "$shomi_zaisan" " ${commodity}")

{
    printf "%*s\n" $(( ($table_width + $(printf "$bal_title" | wc -c)) / 2)) "$bal_title"
    printf "%*s\n" $(( ($table_width + $(printf "$npo_name" | wc -c)) / 2 )) "$npo_name"

    bal_date=$(echo "$hiduke　　  $comm_note" )
    printf "%*s\n\n" $(( ($table_width + $(printf "$bal_date" | wc -c)) / 2 )) "$bal_date"

    cat utf-pretty-assets.dat utf-pretty-liab.dat
} > balance-sheet.txt

# 正味財産パート
#
{
    echo -e "\n正味財産"
    printf "%-20s%21s\n" "　　前期繰越正味財産"  "${COFY}"
    printf "%-20s%19s\n" "　　当期正味財産増減額" "${NI}"
    printf "%-20s%27s\n" "　正味財産合計"        "${shomi_zaisan}"
    printf "%-20s%19s\n" "　負債及び正味財産合計"  "${Liab_NW_total}"
} >> balance-sheet.txt

#####################################
# 5. 活動計算書＋貸借対照表
#####################################
cat activity-statement.txt  balance-sheet.txt > out-all.txt
#
cat out-all.txt

# 一時ファイル削除
rm column-broken-*.dat  ./pretty-sjis*.dat  sjis-*.dat utf-pretty-*.dat
