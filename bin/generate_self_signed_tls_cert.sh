#!/usr/bin/env bash
set -euo pipefail

CERT_DIR="${1:-./creds/tls}"
HOSTNAME="${2:-localhost}"
DAYS="365"

mkdir -p "$CERT_DIR"

openssl req -x509 -newkey rsa:4096 -sha256 -nodes \
  -keyout "$CERT_DIR/key.pem"\
  -out "$CERT_DIR/cert.pem" \
  -days "$DAYS" \
  -subj "/CN=$HOSTNAME" \
  -addext "subjectAltName=DNS:$HOSTNAME,DNS:localhost,IP:127.0.0.1"

chmod 600 "$CERT_DIR/key.pem"
chmod 644 "$CERT_DIR/cert.pem"

echo "Generated: $CERT_DIR/domain.crt and $CERT_DIR/domain.key"
