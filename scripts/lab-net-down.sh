#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "run: sudo $0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lab-net.env
source "$SCRIPT_DIR/lab-net.env"

echo "Stopping dnsmasq..."
lab_net_stop_dnsmasq

echo "Flushing pf anchor $PF_ANCHOR..."
pfctl -a "$PF_ANCHOR" -F all 2>/dev/null || true

echo "Releasing pf token..."
if [[ -f "$PF_TOKEN_FILE" ]]; then
  token="$(tr -d '[:space:]' <"$PF_TOKEN_FILE")"
  if [[ -n "$token" ]]; then
    pfctl -X "$token" 2>/dev/null || true
  fi
  rm -f "$PF_TOKEN_FILE"
fi

echo "Disabling IP forwarding..."
if ! sysctl -w net.inet.ip.forwarding=0; then
  echo "error: sysctl net.inet.ip.forwarding=0 refused." >&2
  exit 1
fi

echo "Restoring DHCP on $LAB_IF..."
if SERVICE="$(lab_net_service_for_if "$LAB_IF")"; then
  networksetup -setdhcp "$SERVICE"
else
  echo "note: networksetup has no service for $LAB_IF. Skipping."
fi

echo "Done."
