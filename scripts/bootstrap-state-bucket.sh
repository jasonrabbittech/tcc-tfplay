#!/usr/bin/env bash
###############################################################################
# Bootstrap a Tencent Cloud COS bucket for Terraform state.
#
# This script is the one-time chicken-and-egg solution: Terraform stores state
# in a bucket, but the bucket itself can't be managed by Terraform until it
# already exists. Run this once per new account to bootstrap the state backend.
#
# Usage:
#   export TENCENTCLOUD_SECRET_ID="..."
#   export TENCENTCLOUD_SECRET_KEY="..."
#   ./scripts/bootstrap-state-bucket.sh <bucket-name-without-appid> <appid> [region]
#
# Example:
#   ./scripts/bootstrap-state-bucket.sh tfstate-tcctfplay-identity 100123456789
#
# Requires: coscli (https://www.tencentcloud.com/document/product/436/43161)
###############################################################################
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <bucket-name-without-appid> <appid> [region]" >&2
  echo "Example: $0 tfstate-tcctfplay-identity 100123456789" >&2
  exit 1
fi

BUCKET_BASE="$1"
APPID="$2"
REGION="${3:-ap-hongkong}"
BUCKET="${BUCKET_BASE}-${APPID}"

if [[ -z "${TENCENTCLOUD_SECRET_ID:-}" || -z "${TENCENTCLOUD_SECRET_KEY:-}" ]]; then
  echo "ERROR: TENCENTCLOUD_SECRET_ID and TENCENTCLOUD_SECRET_KEY must be exported." >&2
  exit 1
fi

echo "Bootstrapping Terraform state bucket:"
echo "  Bucket : ${BUCKET}"
echo "  Region : ${REGION}"
echo

if ! command -v coscli >/dev/null 2>&1; then
  echo "ERROR: coscli not found. Install from https://www.tencentcloud.com/document/product/436/43161" >&2
  exit 1
fi

# 1. Create bucket
echo "Creating bucket..."
coscli mb "cos://${BUCKET}" -r "${REGION}" \
  --secret-id "${TENCENTCLOUD_SECRET_ID}" \
  --secret-key "${TENCENTCLOUD_SECRET_KEY}"

# 2. Enable versioning (required to recover corrupted state)
echo "Enabling versioning..."
coscli bucket-versioning --method put "cos://${BUCKET}" --status Enabled \
  --secret-id "${TENCENTCLOUD_SECRET_ID}" \
  --secret-key "${TENCENTCLOUD_SECRET_KEY}"

# 3. Enable server-side encryption (SSE-COS)
echo "Enabling SSE-COS encryption..."
coscli bucket-encryption --method put "cos://${BUCKET}" --algorithm AES256 \
  --secret-id "${TENCENTCLOUD_SECRET_ID}" \
  --secret-key "${TENCENTCLOUD_SECRET_KEY}" || \
  echo "  (encryption may need to be enabled via console if coscli flag is unsupported)"

echo
echo "Done. Update your environments/<env>/provider.tf:"
echo "  backend \"cos\" {"
echo "    region = \"${REGION}\""
echo "    bucket = \"${BUCKET}\""
echo "    prefix = \"terraform/<env>\""
echo "  }"
