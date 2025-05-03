#!/bin/bash
BOOK=$@

if [ -z "${BOOK}" ]; then
echo "Specify BOOK id";
cat BOOK_IDS
exit
fi

MODELNAME=$(grep 'Modelname' ./${BOOK}/svg/003-01.svg | sed -E 's/(<Modelname>|<\/Modelname>|^[[:space:]]*)//g' | tr -d '\n\r')
MODELYEAR=$(grep 'Modelyear' ./${BOOK}/svg/003-01.svg | sed -E 's/(<Modelyear>|<\/Modelyear>|^[[:space:]]*)//g' | tr -d '\n\r')

mkdir -p ./${BOOK}/pdf/

for i in ./${BOOK}/svg/*.svg; do
   echo $i
   inkscape --export-type="pdf" -o "./${BOOK}/pdf/$(basename $i .svg).pdf" $i
   qalifier=$(grep '<Qualifier>' $i | sed -E 's/(<Qualifier>|<\/Qualifier>|^[[:space:]]*)//g' | tr -d '\n\r')
   if [[ -n "$qalifier" ]]; then
     cpdf -set-title "$(basename $i .svg) $qalifier" "./${BOOK}/pdf/$(basename $i .svg).pdf" -also-set-xmp -o "./${BOOK}/pdf/$(basename $i .svg).pdf"
   else
     cpdf -set-title "$(basename $i .svg)" "./${BOOK}/pdf/$(basename $i .svg).pdf" -also-set-xmp -o "./${BOOK}/pdf/$(basename $i .svg).pdf"
   fi
done

mkdir -p  ./${BOOK}/cells
cp -n index ./${BOOK}/index

for i in ./${BOOK}/pdf/*-01.pdf; do
 cell=$(echo $i | grep -Pio 'pdf/\K[\d]*')
 echo $cell
 cpdf -merge -merge-add-bookmarks -merge-add-bookmarks-use-titles -remove-duplicate-fonts ./${BOOK}/pdf/$cell-*.pdf -o ./${BOOK}/cells/$cell.pdf
 cpdf -set-title "$(grep $cell ./${BOOK}/index || echo $cell)" -also-set-xmp "./${BOOK}/cells/$cell.pdf" -o "./${BOOK}/cells/$cell.pdf"
done

cpdf -merge -merge-add-bookmarks -merge-add-bookmarks-use-titles -remove-duplicate-fonts -idir-only-pdfs -idir ./${BOOK}/conns/ -o ./${BOOK}/cells/150.pdf
cpdf -set-title "150 Connector Views" -also-set-xmp "./${BOOK}/cells/150.pdf" -o "./${BOOK}/cells/150.pdf"

cpdf -merge -merge-add-bookmarks -merge-add-bookmarks-use-titles -remove-duplicate-fonts ./${BOOK}/cells/*.pdf AND -remove-annotations -o ./${BOOK}/out.pdf

FILENAME=$(echo -n "${MODELNAME} ${MODELYEAR}" | sed 's/ /_/g' | sed 's/\//_/g')
cpdf -set-title "${MODELNAME} ${MODELYEAR}" ./${BOOK}/out.pdf AND \
   -add-text "${MODELNAME} ${MODELYEAR}" -bottomright 10 -underneath AND \
   -add-text "%Bookmark0 %Bookmark1" -bottomleft 10 -underneath AND \
   -set-producer "FMCWiringDL" -o ./Wiring_${FILENAME}.pdf

