#!/bin/sh

for PNG in assets/*.png
do
  NAME=`basename $PNG .png`
  echo $NAME

  convert $PNG assets/${NAME}.jpg
  rm $PNG
done
