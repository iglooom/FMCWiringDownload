#!/bin/bash
BOOK=$@

if [ -z "${BOOK}" ]; then
echo "Specify BOOK id";
cat BOOK_IDS
exit
fi

mkdir -p ${BOOK}/svg/

for cell in $(seq -w 001 155);
do
  for page in $(seq -w 01 60);
  do
    echo -n "${cell}:${page} "
    curl -f -s https://www.fordservicecontent.dealerconnection.com/ford_content/PublicationRuntimeRefreshPTS/wiring/svg/prod_1_3_3262025/0/~W${BOOK}/ENUSA/svg/$cell/0/$page.svg -o ./${BOOK}/svg/$cell-$page.svg

    if [ $? -eq 0 ]; then
      echo "ok"
    else
      echo "err"
      break
    fi
  done
done

mkdir -p ${BOOK}/conns

COUNT=$(grep 'faceview' ./${BOOK}/svg/*.svg | grep -Pio 'name="\K[^"]*' | sort | uniq | wc -l)
I=0
for connector in $(grep 'faceview' ./${BOOK}/svg/*.svg | grep -Pio 'name="\K[^"]*' | sort | uniq)
do
  echo "Download [${I}/${COUNT}] ${connector}"
  wkhtmltopdf -q --title "${connector}" "https://www.fordservicecontent.dealerconnection.com/ford_content/PublicationRuntimeRefreshPTS/wiring/face/?book=${BOOK}&vehicleId=0&vin=&cell=150&page=&item=${BOOK}cf${connector}&country=&bookType=svg&language=&languageCode=ENUSA" ./${BOOK}/conns/${connector}.pdf
  I=$((I + 1))
done
