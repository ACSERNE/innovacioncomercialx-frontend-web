#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-visor.innovacioncomercialx.com}"
EXPECTED_CNAME="${2:-username.github.io}"

echo "Validating CNAME for $DOMAIN expecting $EXPECTED_CNAME"

# Use dig to check CNAME or A records
CNAME=$(dig +short CNAME "$DOMAIN" || true)
A_RECORDS=$(dig +short A "$DOMAIN" || true)

if [[ -n "$CNAME" ]]; then
  echo "Found CNAME: $CNAME"
  if [[ "$CNAME" == *"$EXPECTED_CNAME"* ]]; then
    echo "CNAME OK"
    exit 0
  else
    echo "CNAME mismatch. Expected contains: $EXPECTED_CNAME"
    exit 2
  fi
fi

if [[ -n "$A_RECORDS" ]]; then
  echo "Found A record(s): $A_RECORDS"
  echo "Please verify A records match GitHub Pages IPs or use CNAME method"
  exit 0
fi

echo "No DNS records found for $DOMAIN"
exit 3
