#!/bin/bash

SCRIPTDIR=`dirname $0`
SLIDEDIR=slides
INDEXFILE=index.html
INDEXTARGET=show
SLIDEINDEX=$SLIDEDIR/slide.index
SLIDESHOWNAME=RiakTalk
RIAKHOST=127.0.0.1
RIAKPORT=8091
RIAKURL=http://$RIAKHOST:$RIAKPORT
SLIDESHOWURIBASE=/riak/$SLIDESHOWNAME
SLIDESHOWURI=$SLIDESHOWURIBASE/$INDEXTARGET
SLIDEURIBASE=$SLIDESHOWURIBASE/slide-
UPLOADDIRS=(css images js)
ROOTUPLOADS=(favicon.ico)

TYPE_HTML=text/html
TYPE_JSON=application/json
TYPE_JSON=text/plain
TYPE_JS=text/javascript
TYPE_CSS=text/css
TYPE_JPG=image/jpeg
TYPE_PNG=image/png
TYPE_GIF=image/gif
TYPE_ICON=image/x-icon

ALLOWED_TYPES=(jpg jpeg png gif ico js css html json)

declare -A file_to_content_type
file_to_content_type["jpg"]=$TYPE_JPG
file_to_content_type["jpeg"]=$TYPE_JPG
file_to_content_type["png"]=$TYPE_PNG
file_to_content_type["gif"]=$TYPE_GIF
file_to_content_type["ico"]=$TYPE_ICON
file_to_content_type["js"]=$TYPE_JS
file_to_content_type["css"]=$TYPE_CSS
file_to_content_type["html"]=$TYPE_HTML
file_to_content_type["json"]=$TYPE_JSON

declare -A content_type_to_data_flag
content_type_to_data_flag[$TYPE_HTML]=--data-binary
content_type_to_data_flag[$TYPE_JSON]=--data-binary
content_type_to_data_flag[$TYPE_JS]=--data-binary
content_type_to_data_flag[$TYPE_CSS]=--data-binary
content_type_to_data_flag[$TYPE_JPG]=--data-binary
content_type_to_data_flag[$TYPE_PNG]=--data-binary
content_type_to_data_flag[$TYPE_GIF]=--data-binary
content_type_to_data_flag[$TYPE_ICON]=--data-binary

store()
{
  local uri="$1"
  local file="$2"
  local content_type="$3"
  local target=${RIAKURL}${uri}
  local data_flag="${content_type_to_data_flag["$content_type"]}"

  local extra=()

  shift 3
  while (( "$#" )); do
    extra=("${extra[@]}" "$1")
    shift
  done

  echo "Storing $file ($content_type) in $target ..."

  if [ "$extra" ]; then
    curl -X PUT "$target" -H "Content-type: $content_type" $data_flag @${file} "${extra[@]}" > /dev/null 2>&1
  else
    curl -X PUT "$target" -H "Content-type: $content_type" $data_flag @${file} > /dev/null 2>&1
  fi

  if [ $? -ne 0 ]; then
    echo "*** Writing content to Riak failed."
    echo "*** Stoppping."
    exit 1
  fi
}

store_slide()
{
  local links=("<$SLIDESHOWURI>; riaktag=\"deck\"")

  if [ "$3" ]; then
    links=("${links[@]}, $3; riaktag=\"prev\"")
  fi
  if [ "$4" ]; then
    links=("${links[@]}, $4; riaktag=\"next\"")
  fi

  local extra=(-H "Link: ${links[@]}")

  store "$1" "$2" $TYPE_JSON "${extra[@]}"
}

create_deck_links()
{
  local links=("$1; riaktag=\"start\"")
  links=("${links[@]}, $1; riaktag=\"deck\"")
  shift
  
  while (( "$#" )); do
    links=("${links[@]}, $1; riaktag=\"deck\"")
    shift
  done

  echo "${links[@]}"
}

upload_file()
{
  local file=$1
  local target=$2
  local filewithoutpath=$(basename $file)
  local ext="${filewithoutpath##*.}"
  local lext="${ext,,}"
  local file_content_type="${file_to_content_type["$lext"]}"

  if [ "$target" = "" ]; then
    target="${filewithoutpath%.}"
  fi

  local ltarget="${target,,}"
  store "$SLIDESHOWURIBASE/$target" "$file" "$file_content_type"
}

upload_folder()
{
  local folder="$1"
  for file_type in ${ALLOWED_TYPES[@]}; do
    local files=(`find $folder -mindepth 1 -name "*.$file_type" -type f -exec echo '{}' +`)
    for file in ${files[@]}; do
      upload_file $file
    done
  done
}

echo "**************************************************"
echo "* Deploying:     $SLIDESHOWNAME"
echo "* Riak Instance: $RIAKURL"
echo "**************************************************"

cd $SCRIPTDIR/..

echo ""
echo "Checking for Riak Connectivity ..."
curl -X GET $RIAKURL > /dev/null 2>&1
if [ $? = 0 ]; then
  echo "$RIAKURL appears to be functional."
else
  echo "*** $RIAKURL is not responding."
  echo "*** Stopping."
  exit 1
fi

echo ""
if [ -f "$INDEXFILE" ]; then
  echo "$INDEXFILE present. Continuing ..."
else
  echo "*** $INDEXFILE is missing."
  echo "*** Stopping."
  exit 1
fi

echo ""
if [ -f "$SLIDEINDEX" ]; then
  echo "Parsing $SLIDEINDEX ..."
else
  echo "*** $SLIDEINDEX is missing."
  echo "*** Stopping."
  exit 1
fi

index=(`cat $SLIDEINDEX`)
slides=()
slide_uris=()
slide_links=()
master_links=()

for file in ${index[@]}; do
  if [ -f "$SLIDEDIR/$file" ]; then
    echo "   $file found ..."

    slides=("${slides[@]}" "$SLIDEDIR/$file")
    slide_uris=("${slide_uris[@]}" "$SLIDEURIBASE$file")
    slide_links=("${slide_links[@]}" "<$SLIDEURIBASE$file>")
  else
    echo " * $file doesn't exist or is not a file. Skipping ..."
  fi
done

echo ""
let count=${#slides[@]}
if [ $count = 0 ]; then
  echo "*** Slide index empty or contains files that don't exist."
  echo "*** Stopping."
  exit 1
fi

echo "The following slides will be included in the order shown:"
echo "${slides[@]}"

echo ""
echo "Writing slides to Riak ..."
if [ $count = 0 ]; then
  store_slide ${slide_uris[0]} ${slides[0]} "" ""
else
  if [ $count -gt 1 ]; then
    store_slide ${slide_uris[0]} ${slides[0]} "" "${slide_links[1]}"
    let p=0
    let n=0

    for (( i=1,p=0,n=2; i<$count-1; i++,p++,n++ )); do
      store_slide ${slide_uris[$i]} ${slides[$i]} "${slide_links[$p]}" "${slide_links[$n]}"
    done
    store_slide ${slide_uris[$i]} ${slides[$i]} "${slide_links[$p]}" ""
  fi
fi

echo ""
echo "Generating deck info and writing the index to Riak ..."
deck_links=(-H "Link: `create_deck_links ${slide_links[@]}`")
store "$SLIDESHOWURIBASE/$INDEXTARGET" "$INDEXFILE" "$TYPE_HTML" "${deck_links[@]}"

echo ""
echo "Writing other markup, javascript, images and styles to Riak ..."
for f in ${ROOTUPLOADS[@]}; do
  upload_file $f
done
for a in ${UPLOADDIRS[@]}; do
  upload_folder $a
done

echo ""
echo "**************************************************"
echo "* Successfully deployed $SLIDESHOWNAME"
echo "* URL: $RIAKURL$SLIDESHOWURI"
echo "**************************************************"
