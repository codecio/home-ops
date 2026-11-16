#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "run: sudo $0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lab-net.env
source "$SCRIPT_DIR/lab-net.env"

REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DNSMASQ_CONF_PATH="$REPO_ROOT/$DNSMASQ_CONF"

lab_ip_assigned() {
  ifconfig "$LAB_IF" 2>/dev/null | grep -q "inet $LAB_IP "
}

echo "Checking $LAB_IF..."
if ! ifconfig "$LAB_IF" >/dev/null 2>&1; then
  echo "error: $LAB_IF does not exist. Connect the USB Ethernet adapter." >&2
  exit 1
fi
if ! SERVICE="$(lab_net_service_for_if "$LAB_IF")"; then
  echo "error: networksetup has no service for $LAB_IF." >&2
  exit 1
fi

echo "Detecting default-route uplink..."
UPLINK="$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')"
if [[ -z "$UPLINK" ]]; then
  echo "error: no default route. Connect the Mac to the internet first." >&2
  exit 1
fi
if [[ "$UPLINK" == "$LAB_IF" ]]; then
  echo "error: default route uses $LAB_IF. The lab interface cannot be the uplink." >&2
  exit 1
fi
UPLINK_IP="$(ipconfig getifaddr "$UPLINK" || true)"
echo "Uplink: $UPLINK (${UPLINK_IP:-no IPv4})"

echo "Setting static IP on \"$SERVICE\"..."
networksetup -setmanual "$SERVICE" "$LAB_IP" "$LAB_MASK"
for _ in $(seq 1 50); do
  lab_ip_assigned && break
  sleep 0.1
done
if ! lab_ip_assigned; then
  echo "error: $LAB_IF does not show inet $LAB_IP. Is \"$SERVICE\" disabled?" >&2
  exit 1
fi

echo "Enabling IP forwarding..."
if ! sysctl -w net.inet.ip.forwarding=1; then
  echo "error: sysctl net.inet.ip.forwarding=1 refused." >&2
  exit 1
fi

echo "Checking pf nat-anchor..."
if ! pfctl -s nat 2>/dev/null | grep -q 'nat-anchor "com.apple/\*"'; then
  echo "error: the system pf ruleset has no nat-anchor \"com.apple/*\"." >&2
  exit 1
fi

echo "Loading NAT rule into $PF_ANCHOR..."
if ! echo "nat on $UPLINK inet from $LAB_NET to any -> ($UPLINK)" | pfctl -a "$PF_ANCHOR" -f -; then
  echo "error: pfctl failed to load anchor rules." >&2
  exit 1
fi

echo "Enabling pf..."
if [[ -s "$PF_TOKEN_FILE" ]] && pfctl -s info 2>/dev/null | grep -q 'Status: Enabled'; then
  echo "pf is already enabled with token $(cat "$PF_TOKEN_FILE")."
else
  if ! token="$(pfctl -E 2>&1 | awk '/^Token/ {print $3}')"; then
    echo "error: pfctl -E failed." >&2
    exit 1
  fi
  if [[ -z "$token" ]]; then
    echo "error: pfctl -E printed no token." >&2
    exit 1
  fi
  echo "$token" >"$PF_TOKEN_FILE"
fi

echo "Checking iPXE..."
tftp_root="$(awk -F= '/^tftp-root=/ {print $2}' "$DNSMASQ_CONF_PATH")"
ipxe_file="$tftp_root/snponly.efi"
if [[ "$(cat "$ipxe_file.url" 2>/dev/null)" != "$IPXE_URL" ]]; then
  echo "Downloading $IPXE_URL..."
  mkdir -p "$tftp_root"
  curl -fsSL "$IPXE_URL" | tar -xzOf - ipxeboot/x86_64/snponly.efi >"$ipxe_file.part"
  mv "$ipxe_file.part" "$ipxe_file"
  echo "$IPXE_URL" >"$ipxe_file.url"
fi

echo "Starting dnsmasq..."
lab_net_stop_dnsmasq
"$DNSMASQ_BIN" --test --conf-file="$DNSMASQ_CONF_PATH"
"$DNSMASQ_BIN" --conf-file="$DNSMASQ_CONF_PATH" --pid-file="$DNSMASQ_PID_FILE"
dnsmasq_pid="$(cat "$DNSMASQ_PID_FILE" 2>/dev/null || true)"
if [[ -z "$dnsmasq_pid" ]] || ! kill -0 "$dnsmasq_pid" 2>/dev/null; then
  echo "error: dnsmasq pid file missing or process not running." >&2
  exit 1
fi

echo ""
echo "Lab network is up."
echo "  $LAB_IF: $LAB_IP ($SERVICE)"
echo "  NAT: $LAB_NET -> $UPLINK"
echo ""
echo "Verify:"
echo "  ifconfig $LAB_IF"
echo "  pgrep -lf dnsmasq"
echo "  sudo pfctl -a $PF_ANCHOR -s nat"
