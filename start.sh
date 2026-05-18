#!/bin/bash
set -e
echo "🚀 TFI Bagundali setup..."
docker compose up -d postgres redis
echo "⏳ Waiting for PostgreSQL..."
until docker exec tfi_postgres pg_isready -U tfi_user -d tfibagundali &>/dev/null; do sleep 1; done
cd server
cp ../.env.example .env 2>/dev/null || true
export DATABASE_URL="${DATABASE_URL:-postgresql://tfi_user:tfi_pass@localhost:5432/tfibagundali}"
export JWT_SECRET="${JWT_SECRET:-dev_jwt_secret_change_in_prod_256bit_minimum}"
export JWT_REFRESH_SECRET="${JWT_REFRESH_SECRET:-dev_refresh_secret_change_in_prod_256bit}"
npm run migrate
npm run seed
cd ..
echo ""
echo "✅ Ready! Run:"
echo "  cd server && npm run dev"
echo "  cd mobile && flutter pub get && flutter run -d chrome"
