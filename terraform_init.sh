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

# 元のディレクトリを記憶
ORIGINAL_DIR=$(pwd)

# 指定されたディレクトリ内のサブディレクトリを走査
for subdir in "$DIR"/*; do
    if [ -d "$subdir" ] && [ -f "$subdir/import.sh" ]; then
        # サブディレクトリに移動
        cd "$subdir"
        echo "実行中: $subdir/import.sh"
        # import.shを実行
        bash "./import.sh"
        # 元のディレクトリに戻る
        cd "$ORIGINAL_DIR"
    fi
done
