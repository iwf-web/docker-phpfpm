# Changelog

`8.2-5` (2023-11-09)
- increase value of max_input_vars to 1500

`8.2-4` (2023-10-24)
- update to Debian bookworm base image
- remove ruby packages
- uninstall netcat after startup
- install newest composer version

`8.2-3` (2023-06-08)
- install ca-certificates package

`8.2-2` (2023-03-17)
- install OS security updates on each build

`8.2-1` (2022-12-20)
- "fix" for GIT issue CVE-2022-24765 with local development

`8.2-0` (2022-12-09)
-- new PHP 8.2 branch

`8.0.1` (2021-12-16)
-- new PHP 8.1 branch

`8.0-3` (2021-10-07)
- add webp support

`8.0-2` (2021-10-07)
- "latest" tag fix

`8.0-1` (2021-10-07)
- new PHP 8.0 branch based on the latest 7.4.6 image

`7.4.6` (2021-03-01)
- get rid pf "sudo su" after container startup
- update `enable-xdebug-cli` script to be compatible with XDebug 3

`7.4.5` (2020-10-28)
- install composer 1 instead of the newest (2)

`7.4.4` (2020-07-20)
- set PHP memory_limit to -1 because we set memory limits through Docker

`7.4.3` (2020-04-15)
- add CLEAR_SESSIONS_IN

`7.4-2` (2020-03-06)
- Bugfix user-switch

`7.4-1` (2019-12-17)
- Initial releases for PHP 7.4


...
