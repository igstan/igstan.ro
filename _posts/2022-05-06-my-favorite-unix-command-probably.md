---
title: join — My Favorite Unix Command, Probably
author: Ionuț G. Stan
date: May 06, 2022
---

Consider the following case. We have two files storing some data about artists
and their countries of origin:

```bash
$ ls
artists.txt   countries.txt
```

There are 15 artists and 6 countries:

```
$ tail artists.txt countries.txt
==> artists.txt <==
4 Γεωργία Νταγάκη
3 L.E.J
5 Lykke Li
1 Moonlight Breakfast
7 Irina Rimes
2 Jake Bugg
3 ZAZ
8 Lana Del Rey
8 Jackson C. Frank
4 Αλκίνοος Ιωαννίδης

==> countries.txt <==
France 3
Greece 4
Romania 1
Russia 6
Sweden 5
UK 2
```

The two files are related by means of the leading and trailing numbers, which
represent country IDs (made up solely for the purpose of this blog post). Thus
"3 L.E.J" relates to "France 3", meaning that L.E.J are from France.

Now, we don't have a lot of data here, it's just 15 artists, but it's already
quite hard to see which artists are from where. If these had been records in a
relational database we could have easily written an SQL `INNER JOIN` query to
reveal the associations we're after:

```sql
SELECT artist.name, country.name
  FROM artist, country
 WHERE artist.country_id = country.id
```

We could maybe start an SQLite session, create the tables, import the data and
finally execute the query. This may even be a viable approach, but it doesn't
fit the plan for this blog post. However, if you're on an Unix system, there's
a hidden gem of a command, aptly named `join`, that can do precisely what the
above SQL query can, only it doesn't need a database, just regular files. So,
how could we use `join` to reproduce the above query?

## Inner Joins — Where are These Artists From?

```bash
$ join -t: -22 -o1.2 -o2.1 \
    <( sort         artists.txt   | sed 's/ /:/' ) \
    <( sort --key=2 countries.txt | sed 's/ /:/' ) \
    ;
```
```
Moonlight Breakfast:Romania
Adele:UK
Dido:UK
Jake Bugg:UK
Clio:France
Jain:France
L.E.J:France
Stromae:France
ZAZ:France
Γεωργία Νταγάκη:Greece
Αλκίνοος Ιωαννίδης:Greece
Lykke Li:Sweden
```

## Left Joins - Artists without a Country

```bash
$ join -a1 -t: -22 -o1.2 -o2.1 \
    <( sort     artists.txt   | sed 's/ /:/' ) \
    <( sort -k2 countries.txt | sed 's/ /:/' ) \
  | grep --extended-regexp ':$' \
  ;
```
```
Irina Rimes:
Jackson C. Frank:
Lana Del Rey:
```

## Right Joins - Countries without Artists

```bash
$ join -a2 -t: -22 -o1.2 -o2.1 \
    <( sort     artists.txt   | sed 's/ /:/' ) \
    <( sort -k2 countries.txt | sed 's/ /:/' ) \
  | grep -E '^:' \
  ;
```
```
:Russia
```

## Full Joins — Artists and Countries, Both Unlinked

```bash
$ join -a1 -a2 -t: -22 -o1.2 -o2.1 \
    <( sort     artists.txt   | sed 's/ /:/' ) \
    <( sort -k2 countries.txt | sed 's/ /:/' ) \
  | grep -E '(^:)|(:$)' \
  ;
```

```
:Russia
Irina Rimes:
Jackson C. Frank:
Lana Del Rey:
```

## Tabular Display

```bash
$ join -a1 -a2 -t: -22 -o2.1 -o1.2 \
    <( sort     artists.tx    | sed 's/ /:/' ) \
    <( sort -k2 countries.txt | sed 's/ /:/' ) \
  | sed -E 's/^:/𝐍𝐔𝐋𝐋:/; s/:$/:𝐍𝐔𝐋𝐋/' \
  | ( echo "  #:COUNTRY:ARTIST"
      echo "===:=======:======"
      sort -k1 -t: | awk -vOFS=: '{ print sprintf("%3d", NR), $0 }'
    ) \
  | column -ts: \
  ;
```

```
  #  COUNTRY  ARTIST
===  =======  ======
  1  France   Clio
  2  France   Jain
  3  France   L.E.J
  4  France   Stromae
  5  France   ZAZ
  6  Greece   Γεωργία Νταγάκη
  7  Greece   Αλκίνοος Ιωαννίδης
  8  Romania  Moonlight Breakfast
  9  Russia   𝐍𝐔𝐋𝐋
 10  Sweden   Lykke Li
 11  UK       Adele
 12  UK       Dido
 13  UK       Jake Bugg
 14  𝐍𝐔𝐋𝐋    Irina Rimes
 15  𝐍𝐔𝐋𝐋    Jackson C. Frank
 16  𝐍𝐔𝐋𝐋    Lana Del Rey
```

## Refactored

```bash
# Our internal delimiter, needed because the artist names in our records
# contain spaces. This conflicts with the default separator(s) of all the
# commands below: spaces or tabs. It should be safe to embed in regexes.
declare -r delim=:

redelimited() {
  # Replaces the *first* space with our delimiter. This works wonderfully
  # for the datasets we have, but it would fail miserably if added a country
  # whose name contains a whitespace, such as "Sierra Leone".
  #
  # So... exercise for the reader: handle whitespaces in country names.
  sed "s/ /$delim/" "$1"
}

sort-by() {
  sort -k"$1" -t"$delim"
}

full-join() {
  join -a1 -a2 -t"$delim" -22 -o2.1 -o1.2 \
    <( redelimited artists.txt   | sort-by 1 ) \
    <( redelimited countries.txt | sort-by 2 ) \
    ;
}

show-nulls() {
  # Prepend/append 𝐍𝐔𝐋𝐋 to rows starting/ending with our delimiter.
  sed -E "s/^($delim)/𝐍𝐔𝐋𝐋\1/; s/($delim)$/\1𝐍𝐔𝐋𝐋/"
}

headers() {
  echo "  #${delim}COUNTRY${delim}ARTIST"
  echo "===${delim}=======${delim}======"
}

number-rows() {
  awk -vOFS="$delim" '{ print sprintf("%3d", NR), $0 }'
}

tabulate() {
  column -ts"$delim"
}

full-join | show-nulls | sort-by 1 | ( headers; number-rows ) | tabulate
```

<!-- <div class="highlight">
  <pre><code>  #  COUNTRY  ARTIST
===  =======  ======
  1  France   <a href="#">Clio</a>
  2  France   <a href="#">Jain</a>
  3  France   <a href="#">L.E.J</a>
  4  France   <a href="#">Stromae</a>
  5  France   <a href="#">ZAZ</a>
  6  Greece   <a href="#">Γεωργία Νταγάκη</a>
  7  Greece   <a href="#">Αλκίνοος Ιωαννίδης</a>
  8  Romania  <a href="#">Moonlight Breakfast</a>
  9  Russia   𝐍𝐔𝐋𝐋
 10  Sweden   <a href="#">Lykke Li</a>
 11  UK       <a href="#">Adele</a>
 12  UK       <a href="#">Dido</a>
 13  UK       <a href="#">Jake Bugg</a>
 14  𝐍𝐔𝐋𝐋    <a href="#">Irina Rimes</a>
 15  𝐍𝐔𝐋𝐋    <a href="#">Jackson C. Frank</a>
 16  𝐍𝐔𝐋𝐋    <a href="#">Lana Del Rey</a></code></pre>
</div>
 -->
