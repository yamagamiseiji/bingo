#!/bin/bash
set -eu
#

for file in  "$(find ./ -name "*.org" -print)"
do
#      grep -i "#+TAGS" blog-peace  ${file}
    sed -i 's/#+TAGS:/#+hugo_tags:/g' ${file}
done
