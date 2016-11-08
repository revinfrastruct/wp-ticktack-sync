#!/bin/bash

if [ "$EVENTSLUG" = "" ]; then
  echo "Required environment variable: EVENTSLUG"
  exit 1
fi

DELTICKS="$($TICKTACK list | jq -r '. | keys | .[]')"

TICKS="$(curl "$WPAPI/wp/v2/live?filter%5Btaxonomy%5D=tickevents&filter%5Bterm%5D=test" | jq '.[].id')"
for ID in $TICKS; do
  TICKDATA="$(curl $WPAPI/wp/v2/live/$ID)"

  TICKDATE="$(echo "$TICKDATA" | jq -r .date_gmt)"
  TICKEPOCH="$(date -d "$TICKDATE" +'%s')"

  TICKCONTENT="$(echo "$TICKDATA" | jq -r .content.rendered)"
  echo "$TICKCONTENT" | $TICKTACK set --time $TICKEPOCH $ID

  DELTICKS="$(echo "$DELTICKS" | grep -v $ID)"
done

for ID in $DELTICKS; do
  $TICKTACK del $ID
done
