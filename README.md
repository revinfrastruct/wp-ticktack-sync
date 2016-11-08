# wp-ticktack-sync

Synchronize ticktack with WP-API data

This script will sync ticktack to whatever WordPress gives.

## How to run this script

* Use `WPAPI` environment variable to define the base URL for WP-API.
* Use `TICKTACK` environment variable to define where to find ticktack.
* Use `EVENTSLUG` environment variable to define which event to sync.

		$ WPAPI="http://127.0.0.1:8080/wp-json" TICKTACK="../ticktack/ticktack" EVENTSLUG="julafton2016" ./sync.sh

## Dependencies

* WP-Cli
* ticktack
* curl
* jq

