#!/bin/bash

if [ "$EVENTSLUG" = "" ]; then
  echo "Required environment variable: EVENTSLUG"
  exit 1
fi

DELTICKS="$($TICKTACK list | jq -r '. | keys | .[]')"

TICKS="$(curl "$WPAPI/wp/v2/live?filter%5Btaxonomy%5D=tickevents&filter%5Bterm%5D=$EVENTSLUG" | jq '.[].id')"
for ID in $TICKS; do
  TICKDATA="$(curl $WPAPI/wp/v2/live/$ID)"

  TICKDATE="$(echo "$TICKDATA" | jq -r .date_gmt)"
  TICKEPOCH="$(date -d "$TICKDATE" +'%s')"

  TICKCONTENT="$(echo "$TICKDATA" | jq -r .content.rendered)"
  FEATUREDMEDIA="$(echo "$TICKDATA" | jq -r '._links["wp:featuredmedia"][0].href')"
  if [ "$FEATUREDMEDIA" != "null" ]; then
    MEDIADATA="$(curl $FEATUREDMEDIA)"
    MEDIAURL="$(echo "$MEDIADATA" | jq -r .source_url)"
    MEDIAFILE="$(tempfile)"
    curl "$MEDIAURL" >$MEDIAFILE
    echo "$TICKCONTENT" | $TICKTACK set --time $TICKEPOCH --media $MEDIAFILE $ID
    rm $MEDIAFILE
  else
    echo "$TICKCONTENT" | $TICKTACK set --time $TICKEPOCH $ID
  fi

  DELTICKS="$(echo "$DELTICKS" | grep -v $ID)"
done

for ID in $DELTICKS; do
  $TICKTACK del $ID
done
