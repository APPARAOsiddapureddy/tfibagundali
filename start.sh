#!/bin/bash
# TFI Bagundali — Quick Start Script
set -e

echo "🚀 Starting TFI Bagundali..."

# Check Docker
if ! command -v docker &> /dev/null; then
  echo "❌ Docker not found. Install Docker Desktop first."
  exit 1
fi

# Start infrastructure
echo "📦 Starting PostgreSQL + Redis..."
docker-compose up -d postgres redis

# Wait for postgres
echo "⏳ Waiting for PostgreSQL..."
until docker exec tfi_postgres pg_isready -U tfi_user -d tfibagundali &>/dev/null; do sleep 1; done
echo "✅ PostgreSQL ready"

# Run migrations
echo "🔄 Running migrations..."
cd server
cp ../.env.example .env 2>/dev/null || true
# Override DATABASE_URL and REDIS_URL for local docker
export DATABASE_URL="postgresql://tfi_user:tfi_pass@localhost:5432/tfibagundali"
export REDIS_URL="redis://localhost:6379"
export JWT_SECRET="dev_jwt_secret_change_in_prod_256bit_minimum"
export JWT_REFRESH_SECRET="dev_refresh_secret_change_in_prod_256bit"
node src/config/migrate.js
echo "🌱 Seeding database..."
node seeds/dev.js
cd ..

echo ""
echo "✅ Setup complete! Now run in TWO separate terminals:"
echo ""
echo "  Terminal 1 (Server):"
echo "    cd server && DATABASE_URL=postgresql://tfi_user:tfi_pass@localhost:5432/tfibagundali REDIS_URL=redis://localhost:6379 JWT_SECRET=dev_jwt_secret JWT_REFRESH_SECRET=dev_refresh_secret npm run dev"
echo ""
echo "  Terminal 2 (Client):"
echo "    cd client && npm run dev"
echo ""
echo "  App: http://localhost:5173"
echo "  API: http://localhost:3001"
