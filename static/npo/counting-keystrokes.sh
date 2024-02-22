#!/bin/bash
#                             Time-stamp: <2024-02-20 12:30:43 yamagami>
#  Ledger postings でaliasを使用したファイルと、それを展開したファイルとの
#  キーストローク数比較をするためのスクリプト ver.3

#  スタートは aliased.ledger ファイル
#
### 下ごしらえ
# 1. expanded.ledger を生成
ledger print --init-file init.dat -f aliased.ledger\
    > expanded.ledger

# 2. expanded.leger から空行を削除し、連続するSPCを１つにする
sed '/^$/d' expanded.ledger |\
    sed -e 's/  */ /g'\
    > expanded.txt

# 3. aliased.ledgerからコメント行と空行を削除し、連続するSPCを１つにする
sed '/;/d' aliased.ledger\
    | sed '/^$/d'\
    | sed -e 's/  */ /g'\
    > aliased.txt

### aliased.txt, expanded.txt をループで回す
fn_list=(
    "aliased.txt"
    "expanded.txt"
)
#
for fname in "${fn_list[@]}"; do
    stem=${fname%.*}

    ## 半角英数を削除し全角のみにしてローマ字化し文字数をカウント
    cat ${fname}\
	| sed -e 's/[0-9a-zA-Z]//g'\
	      -e 's/[[:punct:]]//g'\
	      > "${stem}"-zenkaku.txt

    ## kakasiで漢字--> ローマ字変換し文字数をカウント
    cat "${stem}-zenkaku.txt" \
	| kakasi -Ja -Ha -Ka -i utf-8 -o utf-8 -S\
	> "${stem}-roman.txt"

    ## 再度空行を削除
    sed -n -i '/\S/p' "${stem}-roman.txt"
    wc -c "${stem}-roman.txt"

    ## 全角を削除し半角のみにして文字数をカウント
    LANG=C sed 's/[\x80-\xFF]//g' "${fname}"\
        > "${stem}-hankaku.txt"

    ## 再度空行を削除
    sed -n -i '/\S/p' "${stem}-hankaku.txt"
    wc -c "${stem}-hankaku.txt"

done
exit 0
