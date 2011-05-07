#!/usr/bin/awk -f

# This script will read a simple subset of yaml
# and outputs text that can be sourced by a
# shell. Any keys set in the yaml file will be
# used verbatim in the output. The supported
# yaml constructs are:
# 
# - properties (key: value)
#
# - inline lists (key: [value1, value2, ...]
#
# - simple lists:
#       key:
#           -value1
#           -value2
#           ...
#
# - lists with multiple values:
#       key:
#           -subkey1: value)
#               subsubkey1: value
#               subsubkey2: value
#
#           -subkey2
#               subsubkey3: value
#
# For more information and documentation, see:
# https://github.com/mstade/shelp/yaml2sh/

function trim(s) {
    sub(/^[ \t]+/, "", s);
    sub(/[ \t]+$/, "", s);

    return s;
}

NR == 1 {
    "pwd" | getline cwd;
    "date" | getline date;

    print "# FILE: " cwd "/" FILENAME;
    print "# DATE: " date;
    print "";
}

# Preserve new lines
NF == 0 {
    print $0;
    next;
}

# Comments, no pun intended
/^#/ {
    print $0;
    next;
}

/#/ {
    sub(/#.*/, "");
}

# Lists
function printList(name, values, count) {
    list = "";

    for (i = 1; i <= count; i++)
    {
        value = trim(values[i]);
        list = list " \"" value "\"";
    }

    print name "=( " trim(list) " )";
}

/^[a-zA-Z][a-zA-Z0-9]*: \[.+\]$/ {
    sub(/:/, "");
    sub(/\[[ ]*/, "");
    sub(/[ ]*\]/, "");

    values = substr($0, length($1) + 1);
    count = split(values, tokens, ",");

    printList($1, tokens, count);
    next;
}


/^[a-zA-Z][a-zA-Z0-9]*:[ \t]*$/ {
    sub(/:/, "");
    name = $0;
    count = 0;
    delete items;

    while (getline)
    {
        if ($1 == "-")
        {
            items[++count] = $2 $3;
        }
        else if ($0 ~ /^[ \t]+[a-zA-Z][a-zA-Z0-9]*: .+$/)
        {
            items[count] = items[count] " " $1 $2;
        }
        else
        {
            break;
        }
    }

    printList(name, items, count);
    next;
}

# Properties
/^[a-zA-Z][a-zA-Z0-9]*: .+$/ {
    sub(/:/, "");

    print $1 "=\"" $2 "\"";
    next;
}

# Anything not understood will be printed as comments
{
    print "#:" NR " " $0;
}
