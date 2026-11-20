# Examples
I made these examples before starting work
on the code for the language for the purpose
of making sure I know what the language will
be like.

## Hello World
This code prints the text "Hello, World" to
the console:
```Bashified
include std.text_io

fn main() {
    print("Hello, World")
}
```
If you like to do things yourself, you can
do it like this:
```Bashified
foreign print(1) {
    echo $1
}

fn main() {
    print("Hello, World")
}
```

## What is your name
The following code is a simple example of
getting user input:
```Bashified
include std.text_io
include std.concat;

fn main() {
    name = input("What is your name? ")
    print(concat("Hello, ", name))
}
```
You can also replace the include statements
with the following:
```Bashified
foreign input(1) {
    read -r -p $1 input
    echo $input
}
foreign print(1) {
    echo $1
}
foreign concat(2) {
    echo "$1$2"
}
```

## Comments
You may include comments in your Bashified
code using `//` like in Rust, C, C++, etc.
Comments may only be on their own lines.
These comments may only be included in
functions. For foreign statements,
use `#` in your bash code.

## Data Types
Bashified only has one data type: the string.
This is because it fits well with compiling
to Bash. You can use other data, of course,
but it has to be represented as a string.
