#!/bin/bash
#
# RHCSA: Cron Audit and One‑off Scheduler
# Purpose: List current cron entries, inspect environment variables used by cron
#          and schedule a one‑time job using `at`.
# Usage: run as a normal user to audit your own crontab; root may audit others.

# Show current user and crontab
echo "[+] Auditing crontab for user: $(whoami)"
if crontab -l >/dev/null 2>&1; then
  echo "\n[Current crontab entries]"
  crontab -l
else
  echo "[INFO] No crontab found for $(whoami)"
fi

# Inspect cron environment by running a job that dumps env vars
TMPDIR=$(mktemp -d)
TESTSCRIPT="$TMPDIR/envdump.sh"
echo "#!/bin/sh" > "$TESTSCRIPT"
echo "env > $TMPDIR/cron_env.log" >> "$TESTSCRIPT"
chmod +x "$TESTSCRIPT"

# Schedule job 1 minute from now
run_time="$(date -d "+1 minute" +"%H:%M")"
echo "[+] Scheduling environment dump via at for $run_time" 
echo "$TESTSCRIPT" | at "$run_time" 2>/dev/null

echo "[+] Waiting 90 seconds for the at job to run..."
sleep 90

if [[ -f "$TMPDIR/cron_env.log" ]]; then
  echo "\n[cron environment variables]"
  cat "$TMPDIR/cron_env.log"
else
  echo "[WARN] Expected cron environment file not found (job may not have executed)"
fi

# Clean up temporary files
rm -rf "$TMPDIR"
echo "[✓] Cron audit complete"