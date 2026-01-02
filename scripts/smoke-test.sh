#!/usr/bin/env bash
set -euo pipefail

trap 'docker compose down' EXIT

docker compose up -d

HOST_ADDR=${HOST_ADDR:-127.0.0.1}

resolve_port() {
  local service=$1
  local internal_port=$2
  local mapping
  mapping=$(docker compose port "$service" "$internal_port" | head -n1 | tr -d '\r') || true
  if [ -z "$mapping" ]; then
    echo "$HOST_ADDR:$internal_port"
  else
    echo "$mapping"
  fi
}

PROM_ADDR=${PROM_ADDR:-$(resolve_port prometheus 9090)}
GRAFANA_ADDR=${GRAFANA_ADDR:-$(resolve_port grafana 3000)}

curl --fail --silent --show-error --ipv4 "http://$PROM_ADDR/-/ready"
curl --fail --silent --show-error --ipv4 "http://$GRAFANA_ADDR/api/health"
