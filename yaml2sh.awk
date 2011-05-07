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
