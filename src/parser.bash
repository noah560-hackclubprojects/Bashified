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
# "el" and replaces spaces with "es".
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

parse_function() {
    true
    call_text="$1"
}

escape() {
    val="$1"
    val="${val/e/el}"
    echo "${val/ /es}"
}

unescape() {
    val="$1"
    val="${val/el/e}"
    echo "${val/es/ }"
}

echo "" > "$parse_to"

state="toplevel"

current_definition=""

while IFS= read -r line; do
    case "$state" in
        toplevel)
            first_word=$(echo "$line" | cut -d " " -f1)
            second_word=$(echo "$line" | cut -d " " -f2)
            if [[ "$first_word" == "foreign" ]]; then
                # This is a foreign statement
                function_name=$(echo "$second_word" | cut -d "(" -f1)
                argument_count=$(echo "$second_word" | cut -d "(" -f2)
                if [[ "${argument_count: -1}" == ")" ]]; then
                    argument_count="${argument_count::-1}"
                fi

                current_definition="foreign $function_name $argument_count"
            elif [[ "$first_word" == "fn" ]]; then
                # This is a function definition
                function_name=$(echo "$second_word" | cut -d "(" -f1)
                argument_count=$(echo "$second_word" | cut -d "(" -f2)
                if [[ "${argument_count: -1}" == ")" ]]; then
                    argument_count="${argument_count::-1}"
                fi
                IFS="," read -r -a arguments <<< "$argument_count"
                argument_count=${#arguments[@]}

                IFS=" " argument_string=${arguments[*]}
                current_definition="fn $function_name $argument_count $argument_string"
            elif [[ "$first_word" == "include" ]]; then
                # Include another file
                included="$second_word"
                included="${included/.//}"
                "$built_path" parser "$included" "$parse_to"
            else
                echo -e "Invalid syntax in definition:\n    $line"
                exit 1
            fi
            ;;
        foreign)
            if [[ "$line" == "}" ]]; then
                state="toplevel"
                echo "$current_definition" >> "$parse_to"
                current_definition=""
            else
                clean_line=$(xargs <<< "$line")
                escaped_line=$(escape "$clean_line")
                current_definition="$current_definition $escaped_line"
            fi
            ;;
        fn)
            if [[ "$line" == "}" ]]; then
                state="toplevel"
                echo "$current_definition" >> "$parse_to"
                current_definition=""
            else
                if [[ "$line" == *"="* ]]; then
                    # This is a variable assignment
                    var_name=$(echo "$line" | cut -d "=" -f1 | xargs)
                    assigned_value=$(echo "$line" | cut -d "=" -f2 | xargs)
                    assigned_value=$(parse_function "$assigned_value")
                    assigned_value=$(escape "$assigned_value")
                    next_call="= 2 \"$var_name\" $assigned_value"
                    next_call=$(escape "$next_call")
                else
                    # This is a normal function call
                    next_call=$(parse_function "")
                fi
                current_definition="$current_definition $next_call"
            fi
            ;;
    esac
done < "$parse_from"
