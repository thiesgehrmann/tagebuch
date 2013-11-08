#!/bin/sh

delim='============================';

###############################################################################

mktex() {
  if [ -z "$1" ]; then
    return
  fi

  latex "${1}.tex" && dvipdf -dAutoRotatePages=/None "${1}.dvi"
}

###############################################################################

function prep_chunk_datum(){

  while read -r l; do
    echo "$l" | sed -e 's/\[.*[^\t ]\]/{\\color{red} & }/g' \
                    -e 's/ß/{\\ss}/g' \
                    -e 's/ö/\\"{o}/g' \
                    -e 's/Ö/\\"{O}/g' \
                    -e 's/ü/\\"{u}/g' \
                    -e 's/Ü/\\"{U}/g' \
                    -e 's/ä/\\"{a}/g' \
                    -e 's/Ä/\\"{A}/g' \
                    -e 's/\([^$]\)_\([^$]\)/\1{\\_}\2/g' \
                    -e 's/\$\([^\$]*\)\$/\\begin{math}\1\\end{math}/g' \
                    -e 's/\$/{\\$}/g'
  done

}

###############################################################################

function prep_chunk(){

  while read -r l; do
    echo "$l" | sed -e 's/\[.*\]/{\\color{red} & }/g' \
                    -e 's/ß/{\\ss}/g' \
                    -e 's/ö/\\"{o}/g' \
                    -e 's/Ö/\\"{O}/g' \
                    -e 's/ü/\\"{u}/g' \
                    -e 's/Ü/\\"{U}/g' \
                    -e 's/ä/\\"{a}/g' \
                    -e 's/Ä/\\"{A}/g' \
                    -e 's/http:\/\/[^]\t ]*/\\url{&}/g' \
                    -e 's/\([^$]\)_\([^$]\)/\1{\\_}\2/g' \
                    -e 's/\$\([^\$]*\)\$/\\begin{math}\1\\end{math}/g' \
                    -e 's/\$/{\\$}/g'
  done

}

###############################################################################

function prep_file(){

  local fin="$1";
  local fout="$2";

  local datum=`head -n1 "$fin" | prep_chunk_datum`;

  echo "\def\day{$datum}"      >  "$fout";
  echo "\mktitle"               >> "$fout"; 
  tail -n+2 "$fin" | prep_chunk >> "$fout";
  echo "\clearpage"             >> "$fout";

}

###############################################################################

fin="$1";
dir="$2";

if [ ! -e "$dir" ]; then
  mkdir "$dir";
fi

page=0
fout="tag.raw";
rm $fout $fout.tmp
cat $fin | while read -r line; do
  fout="tag.raw";
  if [ "$line" == "$delim" ]; then
    sed '/./,$!d' "$fout.tmp" >> "$fout";
    number=`printf '%03d' "$page"`;
    texfile="$dir/${number}.tex";
    prep_file "$fout" "$texfile";
    echo "\input{$texfile}";
    rm "$fout" "$fout.tmp";
    page=$((page + 1));
    continue;
  fi
  echo "$line" >> "$fout.tmp"
done


