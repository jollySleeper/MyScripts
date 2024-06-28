#!/bin/bash

create_cpp_files () {
    echo "Creating C++ Repo"
    # Special Case for This Repo otherwise Create .clang-format in 'cpp' Foler
    if [[ ! -f ../.clang-format ]]; then
        cd ..
        echo "Creating Clang Format File"
        clang-format -style=llvm -dump-config > .clang-format
        sed -i 's/IndentWidth:     2/IndentWidth:     4/' .clang-format
        cd $1
    fi
    mkdir -p cpp/target
    cat > cpp/main.cpp << EOF
#include <bits/stdc++.h>

using namespace std;

int main() {
cout<<"Hello, world! ~ C++"<<endl;
// Solution solutionObject;

return 0;
}
EOF
    clang-format -i cpp/main.cpp -style=file:../.clang-format
    g++ cpp/main.cpp -o cpp/target/main && ./cpp/target/main
}

create_rust_files () {
    echo "Creating Rust Repo"
    cargo new 'rust' && cd rust
    cat > src/main.rs << EOF
pub struct Solution;

fn main() {
    println!("Hello, world! ~ Rust");
}
EOF
    rustfmt --force src/main.rs
    cargo run
    cd ..
}

create_go_files () {
    echo "Creating Go Repo"
    mkdir go && cd go
    go mod init "go-$1"
    cat > main.go << EOF
package main

import "fmt"

func main () {
    fmt.Println("Hello, world! ~ GO")
}
EOF
    go fmt main.go
    go run .
    cd ..
}

create_js_files () {
    echo "Creation JS Repo"
    mkdir js
    echo "console.log('Hello, world! ~ JS')" >> js/main.js
    node js/main.js
}

generate_readme () {
    # TODO: Add Source & Other Meta Data
    echo "# $1" >> README.md
}

if [[ ! -z $1 ]]; then
    echo "Making Directory: $1"
    mkdir $1
    cd $1

    create_cpp_files $1

    create_rust_files

    create_go_files $1

    create_js_files

    generate_readme $1
    
    echo "Commiting"
    git status --porcelain
    git add ./
    git status --porcelain
    git commit -m "Started: $(echo $1 | sed 's/[^-]*/\u&/g'): Template Added"
    git push
else
    echo "Please Enter Folder Name"
fi
