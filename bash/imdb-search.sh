
#!/bin/bash
request="$@"
file="imdb_dump.html"

wget -U Firefox "http://www.google.com/search?q=$request site:imdb.com&btnI=I\`m Feeling Lucky" -O "$file"

title=$(grep "<title>" "$file" | sed -e 's/<[^ ]*>//g')
rating=$(grep -A1 "<b>User Rating:</b>" "$file" | grep -o '[0-9][0-9./]*')
votes=$(grep -o '[0-9,]* votes' "$file")
genre=$(grep -A1 "<h5>Genre:</h5>" "$file" | grep -o ">[A-Z][a-zA-Z]*<" \
               | sed -e 's/[<>]//g' | paste - - - - - - - - - | sed -e 's/[ \t]*$//' -e 's/\t/,/g')
url=http://www.imdb.com/$(grep -o 'title/tt[0-9]*' "$file" | head -1)

echo "$request|$title|$url|$genre|$rating|$votes" | tee -a movies.csv
