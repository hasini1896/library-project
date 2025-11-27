#!/bin/bash

FILE="library.csv"

# ---------- SEARCH BOOKS (AWK) ----------
search_book() {
    query="$1"
    echo "Searching for: $query"
    awk -F, -v q="$query" 'BEGIN{IGNORECASE=1} $2 ~ q || $3 ~ q {print}' "$FILE"
}

# ---------- CHECK AVAILABILITY (GREP) ----------
check_availability() {
    query="$1"
    echo "Checking availability for: $query"
    grep -i "$query" "$FILE" | grep -i "available"
}

# ---------- BORROW BOOK (SED) ----------
borrow_book() {
    id="$1"
    due_date=$(date -d "+14 days" +"%Y-%m-%d")

    if grep -q "^$id,.*available" "$FILE"; then
        sed -i "s/^$id,\(.*\),available,/&$due_date/; s/^$id,\(.*\),available,/\\1borrowed,$due_date/" "$FILE"
        echo "Book $id borrowed. Due date: $due_date"
    else
        echo "Book $id is not available."
    fi
}

# ---------- RETURN BOOK (SED) ----------
return_book() {
    id="$1"

    if grep -q "^$id,.*borrowed" "$FILE"; then
        sed -i "s/^$id,\(.*\),borrowed,.*/$id,\1,available,/" "$FILE"
        echo "Book $id returned successfully."
    else
        echo "Book $id is not currently borrowed."
    fi
}

# ---------- OVERDUE REPORT (AWK) ----------
overdue_report() {
    today=$(date +"%Y-%m-%d")
    echo "Overdue Books (Due before $today):"
    awk -F, -v t="$today" '$4=="borrowed" && $5 < t {print}' "$FILE"
}

# ---------- MENU HANDLING ----------
case "$1" in
    search) search_book "$2" ;;
    check) check_availability "$2" ;;
    borrow) borrow_book "$2" ;;
    return) return_book "$2" ;;
    overdue) overdue_report ;;
    *)
        echo "Usage:"
        echo "./library.sh search \"title/author\""
        echo "./library.sh check \"title\""
        echo "./library.sh borrow <BookID>"
        echo "./library.sh return <BookID>"
        echo "./library.sh overdue"
        ;;
esac
