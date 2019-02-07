#!/usr/bin/env bash

exclude_src_dir=git-exclude-files/
cd ${exclude_src_dir}
repo_dirs=(*/)
cd ..

for dir in "${repo_dirs[@]}" ; do
    exclude_dir=git-exclude/programming/${dir}.git/info
    mkdir -p ${exclude_dir}
    link ${exclude_src_dir}${dir}exclude ${exclude_dir}/exclude
done

