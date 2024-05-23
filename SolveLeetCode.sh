#!/bin/bash

if [[ ! -z $1 ]]; then
    echo "Making Directory: $1"
    mkdir $1
    cd $1

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
    # echo -e '#include "iostream"\nusing namespace std;\n\nint main() {\n\tcout<<"\tSolve It With C++"<<endl;\n\n\treturn 0;\n}\n' >> main.cpp
    echo -e '#include <bits/stdc++.h>\n\nusing namespace std;\n\nint main(){cout<<"Hello, world! ~ C++"<<endl;return 0;}' >> cpp/main.cpp
    clang-format -i cpp/main.cpp -style=file:../.clang-format
    g++ cpp/main.cpp -o cpp/target/main && ./cpp/target/main

    echo "Creating Rust Repo"
    cargo new rust

    echo "Creating Go Repo"
    mkdir go
    cd go
    go mod init "go-$1"
    # echo -e 'package main\n\nimport "fmt"\n\nfunc main () {\n\tfmt.Println("Hello")\n}' >> src/main.go
    echo -e 'package main\n\nimport "fmt"\n\nfunc main () {\nfmt.Println("Hello, world! ~ GO")\n}' >> main.go
    go fmt main.go
    go run .
    cd ..

    echo "Creation JS Repo"
    mkdir js
    echo "console.log('Hello, world! ~ JS')" >> js/main.js
    node js/main.js

    echo "# $1" >> README.md
    
    echo "Commiting"
    git status --porcelain
    git add ./
    git status --porcelain
    git commit -m "Started: $1: Template Added"
    git push
else
    echo "Please Enter Folder Name"
fi
