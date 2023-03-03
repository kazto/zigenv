#!/bin/bash

mkdir -p zigenv

cd nodenv
FILES=$(git ls-files)
DIRS=$(git ls-files | xargs dirname | sort | uniq)

# echo $FILES
# echo $DIRS

cd ../zigenv

mkdir -p $(echo $DIRS | sed 's/nodenv/zigenv/g')

copy2zig() {
    from_file=$1
    to_file=$(echo $from_file | sed 's/nodenv/zigenv/g')

    # copy with rewrite
    cat ../nodenv/$from_file | \
        sed 's/NODENV/ZIGENV/g; s/nodenv/zigenv/g; s/\bNode\b/Zig/g; s/\.node-version/.zig-version/g' \
        > $to_file
    
    echo "cp ../nodenv/${from_file} ${to_file}"
}

for v in $FILES
do
    copy2zig $v
done

chmod +x bin/*
chmod +x libexec/*
