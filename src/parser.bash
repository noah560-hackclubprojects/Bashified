# Parses the code from Bashified code to
# a new file where each line represents
# a definition. Definitions include:
#  - include statements (because they
#    import definitions from other
#    files or libraries)
#  - foreign statements (because they
#    define bash code accessible by
#    the Bashified code)
#  - functions (because they directly
#    define a unit of Bashified code
#    to be executed)
# For lines that represent functions
# and foreign statements, an encoding
# is used for converting a line with
# spaces to a line without spaces. This
# encoding replaces the letter e with
# "ee" and replaces spaces with "es".
# Include statements really just copy
# in the parser output from the library
# they import.
# Each line of the parsed data looks like
# one of these:
#  - foreign statements: the word foreign
#    followed by a space and then the name
#    of the function, another space, the
#    number of required arguments, another
#    space, and then each encoded line
#    separated by spaces
#    ex: foreign print 1 eechoes"$1"
#  - functions: fn followed by a space,
#    then the function name, the number
#    of arguments, the arguments,
#    and then function calls separated
#    by spaces, each encoded using the
#    encoding, where variable assignments
#    also count as functions where the
#    first argument is the variable name
#    in double quotes and the second
#    argument is what the variable is
#    set to. Return also acts as a function
#    with one argument. Each function call,
#    before being encoded, consists of the
#    name, a space, the number of arguments,
#    another space, and the arguments separated
#    by spaces. For the example below,
#    parentheses represent encoded data
#    ex: fn double 1 number (return 1 (add 2 number number))

parse_from="$2"
parse_to="$3"

echo "" > "$parse_to"

state="toplevel"

while IFS= read -r line; do
    case "$state" in
        toplevel)
            ;;
        foreign)
            ;;
        fn)
            ;;
    esac
done < "$parse_from"
