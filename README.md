# wp-ticktack-sync

Synchronize ticktack with WP-API data

This script will sync ticktack to whatever WordPress gives.

## How to run this script

* Use `WPCLI` environment variable to define where to find the WP-Cli command
line tool.
* Use `TICKTACK` environment variable to define where to find ticktack.
* Use `EVENTSLUG` environment variable to define which event to sync.

		$ WPCLI="docker exec ticker_wordpress_1 /usr/local/bin/wp --allow-root" TICKTACK="../ticktack/ticktack" EVENTSLUG="julafton2016" ./sync.sh

## Dependencies

* WP-Cli
* ticktack
* jq

