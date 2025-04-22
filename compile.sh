#!/bin/bash
BOOK=$@

if [ -z "${BOOK}" ]; then
echo "Specify BOOK id";
cat BOOK_IDS
exit
fi

mkdir -p ./${BOOK}/pdf/

for i in ./${BOOK}/svg/*.svg; do
   inkscape --export-type="pdf" -o "./${BOOK}/pdf/$(basename $i .svg).pdf" $i
   qalifier=$(grep '<Qualifier>' $i | sed -E 's/(<Qualifier>|<\/Qualifier>|^[[:space:]]*)//g')
   if [[ -n "$qalifier" ]]; then
    exiftool -overwrite_original -Title="$(basename $i .svg) $qalifier" "./${BOOK}/pdf/$(basename $i .svg).pdf"
   else
    exiftool -overwrite_original -Title="$(basename $i .svg)" "./${BOOK}/pdf/$(basename $i .svg).pdf"
   fi
done

mkdir -p  ./${BOOK}/cells
cp -n index ./${BOOK}/index

for i in ./${BOOK}/pdf/*-01.pdf; do
 cell=$(echo $i | grep -Pio 'pdf/\K[\d]*')
 echo $cell
 cpdf -merge -merge-add-bookmarks -merge-add-bookmarks-use-titles -remove-duplicate-fonts ./${BOOK}/pdf/$cell-*.pdf -o ./${BOOK}/cells/$cell.pdf

 exiftool -overwrite_original -Title="$(grep $cell ./${BOOK}/index || echo $cell)" "./${BOOK}/cells/$cell.pdf"
done

cpdf -merge -merge-add-bookmarks -merge-add-bookmarks-use-titles -remove-duplicate-fonts ./${BOOK}/conns/*.pdf -o ./${BOOK}/cells/150.pdf
exiftool -overwrite_original -Title="150 Connector Views" "./${BOOK}/cells/150.pdf"

cpdf -merge -merge-add-bookmarks -merge-add-bookmarks-use-titles -remove-duplicate-fonts ./${BOOK}/cells/*.pdf -o ./${BOOK}/out.pdf

cpdf -remove-annotations ./${BOOK}/out.pdf -o ./${BOOK}.pdf

