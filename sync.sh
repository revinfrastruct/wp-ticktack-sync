#!/bin/bash

if [ "$EVENTSLUG" = "" ]; then
  echo "Required environment variable: EVENTSLUG"
  exit 1
fi

TICKS="$($WPCLI post list --post_type=livetick --post_status=publish --posts_per_page=10000 --format=json | jq '.[].ID')"
for ID in $TICKS; do
  TICKDATA="$($WPCLI post get $ID --format=json)"
  TICKCATEGORIES="$($WPCLI post term list $ID tickevents --format=json | jq -r .[].slug)"
  if [ "$(echo "$TICKCATEGORIES" | grep -E "^$EVENTSLUG\$")" = "$EVENTSLUG" ]; then

    TICKDATE="$(echo "$TICKDATA" | jq -r .post_date_gmt)"
    TICKCONTENT="$(echo "$TICKDATA" | jq -r .post_content)"
    TICKEPOCH="$(date -d "$TICKDATE" +'%s')"

    echo "$TICKTACK set --time $TICKEPOCH $ID"
    echo "$TICKCONTENT" | $TICKTACK set --time $TICKEPOCH $ID
  fi
done
