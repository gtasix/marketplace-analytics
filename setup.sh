set -euo pipefail
cd "$(dirname "$0")"

# --- 0. Проверки -------------------------------------------------------------
docker info >/dev/null 2>&1 || { echo "Docker не запущен: открой Docker Desktop и повтори."; exit 1; }
[ -f .env ] || { echo "Нет .env (скопируй из .env.example)"; exit 1; }

# --- 1. Данные ---------------------------------------------------------------
FILES="olist_orders_dataset.csv olist_order_items_dataset.csv olist_order_reviews_dataset.csv"
need=0; for f in $FILES; do [ -f "data/$f" ] || need=1; done
if [ "$need" = 1 ]; then
  ZIP=""
  for z in ~/Downloads/archive.zip ~/Downloads/brazilian-ecommerce.zip ~/Downloads/archive*.zip; do
    [ -f "$z" ] && { ZIP="$z"; break; }
  done
  [ -n "$ZIP" ] || { echo "Не нашёл архив Olist в ~/Downloads (archive.zip). Скачай датасет с Kaggle."; exit 1; }
  unzip -o -j "$ZIP" $FILES -d data
fi

# --- 2. Контейнеры -----------------------------------------------------------
docker compose pull

if [ ! -f .redash_db_created ]; then
  docker compose up -d redash-postgres redis
  sleep 8
  docker compose run --rm server create_db
  touch .redash_db_created
fi
docker compose up -d

# --- 3. Загрузка данных ------------------------------------------------------
until docker compose exec -T db pg_isready -U analyst -d olist >/dev/null 2>&1; do sleep 2; done
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U analyst -d olist -f /sql/00_load.sql

# --- 4. Redash ---------------------------------------------------------------
for i in $(seq 1 120); do
  curl -s http://localhost:5050/ping | grep -q PONG && break
  sleep 3
done
curl -s http://localhost:5050/ping | grep -q PONG || { echo "Redash не ответил. Смотри: docker compose logs server"; exit 1; }
open http://localhost:5050 2>/dev/null || true
