#!/bin/sh
set -eu
test_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# Source only the service definitions, without rc.common or host network access.
. "$test_dir/../openwrt-bandix-plus/files/bandix-plus.init"
logger() { :; }
ubus() { printf '{"bandix-plus":{"instances":{"bandix-plus":{"pid":%s}}}}\n' "$process_test_pid"; }
jsonfilter() { printf '%s\n' "$process_test_pid"; }
sleep 30 &
process_test_pid=$!
trap 'kill "$process_test_pid" 2>/dev/null || true' EXIT
stop_service
test "$BANDIX_STOP_PID" = "$process_test_pid"
(sleep 0.2; kill "$process_test_pid") &
service_stopped
if kill -0 "$process_test_pid" 2>/dev/null; then
	echo 'service_stopped returned before the old process exited' >&2
	exit 1
fi
BANDIX_STOP_PID=''
service_stopped
echo 'init lifecycle waits for the captured old process: PASS'
