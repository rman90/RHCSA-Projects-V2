#!/bin/bash
#
# RHCSA: Process Management Lab
# This script launches several sample workloads, demonstrates backgrounding,
# changing niceness, listing jobs and cleaning them up.
#

set -euo pipefail

echo "[+] Starting workload..."
sleep 600 &
SLEEP_PID=$!
echo "  • Started long sleep with PID $SLEEP_PID"

dd if=/dev/zero of=/dev/null bs=1M &
DD1_PID=$!
echo "  • Started dd (1) with PID $DD1_PID"

dd if=/dev/zero of=/dev/null bs=1M &
DD2_PID=$!
echo "  • Started dd (2) with PID $DD2_PID"

echo
echo "Current jobs:"
jobs -l

echo
echo "[+] Adjusting niceness of dd tasks..."
renice -n 10 -p "$DD1_PID"
renice -n 15 -p "$DD2_PID"

echo
echo "Updated process priorities:"
ps -o pid,ni,comm -p "$DD1_PID","$DD2_PID"

echo
echo "Use 'top -p $DD1_PID,$DD2_PID' in another terminal to observe CPU usage."
echo "Press Enter to terminate all jobs..."
read -r

echo "[+] Cleaning up..."
kill "$SLEEP_PID" "$DD1_PID" "$DD2_PID" || true
wait || true
echo "[✓] All sample processes terminated."
