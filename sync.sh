#!/bin/bash

if [ "$EVENTSLUG" = "" ]; then
  echo "Required environment variable: EVENTSLUG"
  exit 1
fi

DELTICKS="$($TICKTACK list | jq -r '.["+"] | .[].id' | grep wp)"

TICKS="$(curl "$WPAPI/wp/v2/live?filter%5Btaxonomy%5D=tickevents&filter%5Bterm%5D=$EVENTSLUG" | jq '.[].id')"
for ID in $TICKS; do
  TICKDATAURL="$WPAPI/wp/v2/live/$ID"
  TICKDATA="$(curl "$TICKDATAURL")"

  TICKDATE="$(echo "$TICKDATA" | jq -r .date_gmt)"
  TICKEPOCH="$(date -d "$TICKDATE" +'%s')"

  TICKCONTENT="$(echo "$TICKDATA" | jq -r .content.rendered)"
  FEATUREDMEDIA="$(echo "$TICKDATA" | jq -r '._links["wp:featuredmedia"][0].href')"
  MEDIAURL="null"
  if [ "$FEATUREDMEDIA" != "null" ]; then
    MEDIADATA="$(curl $FEATUREDMEDIA)"

    MEDIAURL="$(echo "$MEDIADATA" | jq -r '.media_details.sizes["ticker-sized"].source_url')"
    if [ "$MEDIAURL" = "null" ]; then
      MEDIAURL="$(echo "$MEDIADATA" | jq -r '.media_details.sizes["large"].source_url')"
    fi
    if [ "$MEDIAURL" = "null" ]; then
      MEDIAURL="$(echo "$MEDIADATA" | jq -r '.media_details.sizes["medium-large"].source_url')"
    fi
    if [ "$MEDIAURL" = "null" ]; then
      MEDIAURL="$(echo "$MEDIADATA" | jq -r '.media_details.sizes["post-thumbnail"].source_url')"
    fi
    if [ "$MEDIAURL" = "null" ]; then
      MEDIAURL="$(echo "$MEDIADATA" | jq -r '.media_details.sizes["thumbnail"].source_url')"
    fi
  fi

  MEDIAPARAM=""
  if [ "$MEDIAURL" != "null" ]; then
    MEDIAFILE="$(tempfile)"
    curl "$MEDIAURL" >$MEDIAFILE
    exiftool -all= $MEDIAFILE
    if [ "$(identify $MEDIAFILE | awk '{ print $2 }')" = "JPEG" ]; then
      MEDIAPARAM="--media $MEDIAFILE"
    fi
  fi

  ID="wp$ID"
  echo "$TICKTACK set --time $TICKEPOCH $MEDIAPARAM $ID"
  echo "$TICKCONTENT" | $TICKTACK set --time $TICKEPOCH $MEDIAPARAM $ID

  if [ "$MEDIAFILE" != "" ]; then
    rm "$MEDIAFILE"
  fi

  DELTICKS="$(echo "$DELTICKS" | grep -v $ID)"
done

for ID in $DELTICKS; do
  $TICKTACK del $ID
done
