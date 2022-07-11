+++
title = "Dropbox内ファイルの直リンクをCUIで取得する"
author = ["YAMAGAMI"]
date = 2022-07-11T00:00:00+09:00
tags = ["Dropbox", "CUI", "direct_link", "sharelink"]
categories = ["comp"]
draft = false
+++

とてもベーシックな内容ですがもっぱら自分の備忘のためにメモしました。


## 準備 {#準備}

**`dropbox.py`** をDrobpoxの[公式ページ](https://www.dropbox.com/download?dl=packages/dropbox.py)からダウンロードします[^fn:1]。


### やることは・・・ {#やることは}

> 1.  `dropbox.py` をつかって、CUIでDropbox内のファイル名から ****共有リンク**** を取得します
> 2.  `sed` をつかって、共有リンクから ****直リンク**** を作ります

手数は少ないのでBashのターミナルからコマンドを叩いても問題はありませんが、この手順をスクリプトにしておくと何かと便利です。

というか、ちょっと間を置くと、すぐにやり方を忘れてしまうのです :sweat:

スクリプト名は `direct-link_getter.sh` 、コードは [こちら](#code)です。


## 使い方 {#使い方}

1.  スクリプト起動時に、Dropbox内にあるファイルで、直リンクが必要なファイル名を引数として与えます。正規表現もOKです。たとえば：

    ```sh
    $ direct-link_getter.sh garden*
    ```
2.  引数の正規表現にマッチしたDropbox内のファイル一覧が、アップデートの新しい順にリストされます。

    ```sh
    ** 候補ファイル（最新順）
    Dropbox/org/journal/pics/gardenレーキ−.jpg
    Dropbox/org/journal/pics/garden20210508.jpg
    Dropbox/org/journal/record_archives/pics/garden-table-20200921-2.jpg
    Dropbox/org/journal/record_archives/pics/garden-table-20200921.jpg
    Dropbox/org/journal/record_archives/pics/garden-tableサンディングdone.jpg

    エンターで最新ファイルを選択, それ以外なら下にコピペして貼り付ける
    Which direct_link you want?
    ```
3.  リストのトップにあげられているファイル（最新のファイル）の直リンクを得たいなら、「空でエンター」を叩きます。
4.  それ以外のファイルの直リンクを得たいときには、その行を（ダブルクリックして）コピーし入力プロンプトの後ろにペーストし、エンターを叩きます。
5.  ファイルの **直リンクURL** が表示されます。

    ```sh
    gardenレーキ−.jpg

    ** 直リンクURL
    https://dl.dropboxusercontent.com/s/ahkxyz8ht3n36ef/garden%E3%83%AC%E3%83%BC%E3%82%AD%E2%88%92.jpg
    ```

    [注]上の直リンクURLはアクセス防止のために改ざんしています。あしからず・・・

6.  これを必要な場所にコピペして使います。


## コード {#code}

スクリプトは
`dropbox.py sharelink` を利用して共有リンク(share link)を取得し、
`sed` でそれを直リンク(direct link)に書き換えるだけです。スクリプト名は
`direct-link_getter.sh`
です。

```sh
#!/bin/bash
set -eu  # Time-stamp: <2022-07-11 09:12:13 yamagami>
#
# Dropboxファイルの共有リンクから
#     直リンク(https://dl.dropboxusercontent....)を得る
#
case $# in
    1) file_name=$1 ;;
    0) read -r  -p "** Input file name : " file_name ;;
    *) echo "** Error! Do it again."
       exit 1 ;;
esac
#
hit_list=$(find ~/Dropbox -name "${file_name}" -print0\
	       | xargs -0 ls -at\
	       | cut -d"/" -f 4-
	   )
echo -e "** 候補ファイル（最新順） \n${hit_list}"
#
echo -e "\nエンターで最新ファイルを選択, それ以外ならコピペして下に貼り付ける"
read -r -p "Which direct link you want?  " which
if [ -z "${which}" ]; then
    drop_file_path=$(echo "${hit_list}" | head -1 )
    echo "${drop_file_path##*/}"
else
    drop_file_path=$(echo "${which}")
fi
#
cd "$HOME" || exit
#
share_link=$(dropbox.py sharelink "${drop_file_path}")
direct_link=$(echo "${share_link}"\
  | sed -e 's/www/dl/g'\
	-e 's/dropbox/dropboxusercontent/g'\
	-e 's/?dl=0//g'
	   )
echo -e "\n** 直リンクURL"
echo "${direct_link}"
exit 0
```


## まとめ {#まとめ}

Dropbox内の画像データを１つか２つホームページで公開するのであれば、GUI＝手動で直リンクURLを取得してもぜんぜん問題はありません。むしろそれが普通だと思います。

けれども、多数の画像ファイルを公開する必要が生じた場合には、こうしたCUIによる方法が便利です。この方法を使えば、公開したい画像ファイル名をデータファイルにリストして、それらの直リンクURLを一気に取得することができます。


## Footnotes: {#footnotes}

[^fn:1]: インストールの方法などは、ネット上によい紹介記事がたくさんあります。そちらをごらんください。
