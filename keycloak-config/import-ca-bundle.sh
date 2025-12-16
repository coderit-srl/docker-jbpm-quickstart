#!/bin/bash

# Usage: ./import_certs.sh <bundle.crt> <keystore.jks> <keystore_password>

BUNDLE_FILE="$1"
JKS_FILE="$2"
JKS_PASSWORD="$3"

if [[ -z "$BUNDLE_FILE" || -z "$JKS_FILE" || -z "$JKS_PASSWORD" ]]; then
	echo "Usage: $0 <bundle.crt> <keystore.jks> <keystore_password>"
	exit 1
fi

if [[ ! -f "$BUNDLE_FILE" ]]; then
	echo "Error: Bundle file '$BUNDLE_FILE' not found"
	exit 1
fi

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Split certs - BSD awk compatible
awk -v dir="$TEMP_DIR" '/-----BEGIN CERTIFICATE-----/{n++; fname=dir"/cert-"n".pem"} n{print > fname}' "$BUNDLE_FILE"

CERT_COUNT=$(ls "$TEMP_DIR"/cert-*.pem 2>/dev/null | wc -l | tr -d ' ')

if [[ $CERT_COUNT -eq 0 ]]; then
	echo "Error: No certificates found"
	exit 1
fi

echo "Found $CERT_COUNT certificate(s) in bundle"

IMPORTED=0
for CERT_FILE in "$TEMP_DIR"/cert-*.pem; do
	[[ -f "$CERT_FILE" ]] || continue

	# macOS-compatible CN extraction
	CN=$(openssl x509 -in "$CERT_FILE" -noout -subject 2>/dev/null | sed -n 's/.*CN *= *\([^,\/]*\).*/\1/p' | tr ' ' '_')

	if [[ -z "$CN" ]]; then
		CN="cert"
	fi

	ALIAS="${CN}-${IMPORTED}"

	echo "[$((IMPORTED + 1))/$CERT_COUNT] Importing: $ALIAS"

	keytool -importcert \
		-noprompt \
		-trustcacerts \
		-alias "$ALIAS" \
		-file "$CERT_FILE" \
		-keystore "$JKS_FILE" \
		-storepass "$JKS_PASSWORD" 2>/dev/null

	if [[ $? -eq 0 ]]; then
		((IMPORTED++))
	else
		echo "  Skipped (duplicate or error)"
	fi
done

echo ""
echo "Done: imported $IMPORTED of $CERT_COUNT certificate(s)"
