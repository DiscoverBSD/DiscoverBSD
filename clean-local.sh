#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "🧹 Clearing compiled packs and cache..."
rm -rf "${ROOT_DIR}/public/packs" \
	"${ROOT_DIR}/public/packs-test" \
	"${ROOT_DIR}/tmp/cache/webpacker"

echo "🧼 Removing node_modules..."
rm -rf "${ROOT_DIR}/node_modules"

echo "📦 Reinstalling dependencies..."
yarn install

echo "⚙️  Rebuilding webpack bundles..."
"${ROOT_DIR}/bin/webpack"

echo "✅ Local asset cache refreshed."