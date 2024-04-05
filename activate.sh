#!/bin/bash

# 引数の数をチェック
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <network>"
    exit 1
fi

# 引数からディレクトリとネットワークを取得
directory="$1"
network="$2"

# 指定されたディレクトリ内の名前を取得し、各ディレクトリ名に対してコマンドを実行
for dir in "$directory"/*; do
    if [ -d "$dir" ]; then
        dir_name=$(basename "$dir")
        # コマンドを実行
	echo -e "---------------------------------------------"
	echo -e "Property : " $dir_name 
	echo -e "Network : " $network
	echo -e "---------------------------------------------"
	echo -e ""
        akamai -s default property-manager activate-version --property "$dir_name" --network "$network"
    fi
done
