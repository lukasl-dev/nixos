#!/usr/bin/env nu

mkdir -p ./flat

ls **/* | where type == file | each { |it|
    let original_path = $it.name
    let flattened_name = ($original_path | str replace -a '/' '_')
    cp $original_path $"./flat/($flattened_name)"
}

echo "All files have been flattened and copied to ./flat/"
