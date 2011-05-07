#!/bin/awk -f

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
/^[a-zA-Z][a-zA-Z0-9]*: \[.+\]$/ {
    gsub(/[ \t]/, "");
    gsub(/,/, " ");
    sub(/\[/, "( ");
    sub(/\]/, " )");
    sub(/:/, "=");

    print $0;
    next;
}

/^[a-zA-Z][a-zA-Z0-9]*:[ \t]*$/ {
    sub(/:/, "");
    name = $0;
    list = "";

    while (getline)
    {
        if ($1 == "-")
        {
            list = list " " $2 $3;
        }
        else if ($0 ~ /^[ \t]+[a-zA-Z][a-zA-Z0-9]*: .+$/)
        {
            list = list "|" $1 $2;
        }
        else
        {
            break;
        }
    }

    print name "=(" list " )";
    print "";
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
