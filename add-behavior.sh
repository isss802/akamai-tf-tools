#!/bin/bash

# ディレクトリパスを引数から取得
BASE_DIR=$1

# 引数が指定されていない、またはディレクトリが存在しない場合はエラーメッセージを表示
if [[ -z "$BASE_DIR" || ! -d "$BASE_DIR" ]]; then
    echo "Invalid directory. Usage: $0 [directory path]"
    exit 1
fi

# JSON ファイルが配置されるディレクトリ
SOURCE_DIR="add-template/property-snippets"

# JSON ファイルをコピーし、main.json に追加する関数
copy_and_update() {
    local target_dir=$1
    local main_json="$target_dir/property-snippets/main.json"

    # JSON ファイルをコピー
    cp "$SOURCE_DIR"/*.json "$target_dir/property-snippets/"

    # main.json に追加するための一時ファイルを作成
    local temp_file=$(mktemp)

    # 各 JSON ファイル名を main.json に追加
    for file in "$SOURCE_DIR"/*.json; do
        filename=$(basename "$file")
        jq '.rules.children += ["#include:'$filename'"]' "$main_json" > "$temp_file" && mv "$temp_file" "$main_json"
    done

}

# 指定されたディレクトリ内の各サブディレクトリに対して処理を行う
for subdir in "$BASE_DIR"/*; do
    # 対象のサブディレクトリ内に property-snippets ディレクトリが存在する場合のみ処理
    if [[ -d "$subdir/property-snippets" ]]; then
        echo "Processing $subdir"
        copy_and_update "$subdir"
    fi
done

echo "Completed."
