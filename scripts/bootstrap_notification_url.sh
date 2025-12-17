#!/bin/sh
set -e

echo "🔎 Buscando URL do ngrok..."

NGROK_URL=$(curl -s http://ngrok:4040/api/tunnels \
  | grep -o '"public_url":"https:[^"]*"' \
  | head -n 1 \
  | sed 's/"public_url":"//;s/"//')

if [ -z "$NGROK_URL" ]; then
  echo "❌ Não foi possível obter a URL do ngrok"
  exit 1
fi

echo "✅ URL do ngrok encontrada: $NGROK_URL"

export MERCADOPAGO_NOTIFICATION_URL="$NGROK_URL"

echo "MERCADOPAGO_NOTIFICATION_URL=$NGROK_URL" > /app/.env.ngrok