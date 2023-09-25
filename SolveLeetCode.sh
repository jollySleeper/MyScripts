#!/bin/bash

if [[ ! -z $1 ]]; then
    echo "Making Directory: $1"
    mkdir $1;
    cd $1;
    echo "Creating C++ Repo"
    mkdir cpp-sol;
    cd cpp-sol;
    # echo -e '#include "iostream"\nusing namespace std;\n\nint main() {\n\tcout<<"\tSolve It With C++"<<endl;\n\n\treturn 0;\n}\n' >> main.cpp;
    echo -e '#include "iostream"\nusing namespace std;\nint main(){cout<<"Solve It With C++"<<endl;return 0;}' >> main.cpp;
    clang-format -style=llvm -dump-config > .clang-format;
    sed -i 's/IndentWidth:     2/IndentWidth:     4/' .clang-format;
    clang-format -i main.cpp;
    g++ main.cpp -o main;
    ./main;
    cd ..;
    echo "Creating Rust Repo"
    cargo new rust-sol;
else
    echo "Please enter file Name";
fi
