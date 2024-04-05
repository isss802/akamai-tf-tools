#!/bin/bash

# ディレクトリが指定されているか確認
if [ "$#" -ne 1 ]; then
    echo "使用方法: $0 [ディレクトリ]"
    exit 1
fi

# 指定されたディレクトリ
DIR=$1

# ディレクトリが存在するか確認
if [ ! -d "$DIR" ]; then
    echo "ディレクトリが存在しません: $DIR"
    exit 1
fi

# 指定されたディレクトリ内のサブディレクトリを走査
for subdir in "$DIR"/*; do
    if [ -d "$subdir" ]; then
        # サブディレクトリ内のTerraform設定を適用
        echo "Terraformを適用中: $subdir"
        cd "$subdir"
        terraform apply -auto-approve
        cd - > /dev/null
    fi
done
