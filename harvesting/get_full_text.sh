#!/bin/sh
# -----------------------------------------------------------
# This script parses an xml file from OJS downloaded via OAI
# and downloads the associated PDF files for each article.
# It then adds the .pdf file extension to the files and moves
# the xml file into the directory with the PDFs.
#
# usage:
# ./getfulltext.sh ojsfile.xml journalname
# -----------------------------------------------------------

XML_FILE=$1
PDF_DIR=$2

# OJS 3 DC metadata format
#fil=`grep -o "<dc\:relation>\(.*\)</dc\:relation>" $XML_FILE |sed 's/<dc\:relation>//'|sed 's/<\/dc\:relation>//'|sed 's/view/download/'`

# OJS 2 NLM metadata format
#fil=`grep "<self-uri content-type=\"application\/pdf\"" $XML_FILE |sed 's/<self-uri content-type\=\"application\/pdf\" xlink:href=\"//'|sed 's/\"\/>//'|sed 's/view/download/'`

# OJS 3 JATS metadata format
fil=`grep -o '\"application\/pdf\" xlink:href="[^"]\+"' $XML_FILE | sed 's/\"application\/pdf\"//' | sed 's/xlink:href=\"//' | sed 's/\"//' | sed 's/view/download/'`

# We've seen some journals that have different xml formatting for JATS. If the statement above doesn't return anything, try an alternative.
if [[ -z "$fil" ]]; then
  fil=`grep -o '\"application\/pdf\">[^"]\+' $XML_FILE | sed 's/\"application\/pdf\">//' | sed 's/<\/.*//' | sed 's/view/download/'`
fi

# If harvest URL still not set above, then skip this journal.
if [[ -z "$fil" ]]; then
  echo "Harvest URL not set. Skipping this journal."
  exit 0
fi

if [[ -n "$XML_FILE" && -n "$PDF_DIR" ]]; then
  echo $fil
  wget --no-check-certificate -c -P $PDF_DIR/ $fil

  for i in $PDF_DIR/*;
  do
    echo $i;
    if [[ $(file --mime-type -b "$i") == application/pdf ]]; then
      mv "$i" "$i".pdf;
    else
      echo "Removing file; not a PDF: $i"; # Remove non-PDF files by default
      rm $i;
    fi
  done

  mv $XML_FILE $PDF_DIR/
else
  echo "Missing variables. Please use the command as follows: ./get_full_text.sh file.xml directory"
fi
