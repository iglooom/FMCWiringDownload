# FMCWiringDownload

### This tool is for backup purposes only. To legally access the wiring diagram, you need to buy a subscription on the FordServiceInfo website.

## Dependencies
- curl
- wkhtmltopdf
- inkscape
- cpdf

## Usage
Find interested ID in BOOK_IDS, for example `EKKE : 2019 KUGA EUROPE`

Run
``` 
./download.sh EKKE
./compile.sh EKKE
```

You can alter `index` file for correct bookmarks. The index slightly differs between cars.
