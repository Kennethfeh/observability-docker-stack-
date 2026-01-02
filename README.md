# Observability Docker Stack

Docker Compose bundle for Prometheus, Grafana, Loki, and Promtail. It mirrors how I bootstrap observability in greenfield environments before moving workloads into managed services.

## Components

- **Prometheus** – Scrape configuration lives under `config/prometheus/prometheus.yml`. Add more targets or alerting rules here.
- **Grafana** – Pre-provisioned datasources + dashboards via `config/grafana/provisioning` and `config/grafana/dashboards`.
- **Loki** – Stores logs on a Docker volume (`loki-data`) with configuration in `config/loki/config.yaml`.
- **Promtail** – Ships host logs (`/var/log/*.log`) into Loki; edit `config/promtail/promtail-config.yaml` for other paths.

## Usage

```bash
docker compose up -d
open http://localhost:3000   # Grafana (admin/admin)
open http://localhost:9090   # Prometheus
```

Stop with `docker compose down`. Data persists locally inside the `loki-data` volume.

## CI smoke tests

The `observability_stack` job in `.github/workflows/portfolio.yml` runs:

1. `docker compose config` to validate YAML and environment substitutions.
2. `scripts/smoke-test.sh`, which brings the stack up, resolves dynamically assigned ports, and hits the Grafana and Prometheus health endpoints before tearing everything down.

## Instrumentation ideas

- Drop JSON log files into `/var/log` and confirm they appear in Grafana's Explore tab via the Loki datasource.
- Add `alertmanager` and custom rules under `config/prometheus/` to simulate paging scenarios.
- Use this stack when showcasing operational runbooks—it's self-contained and easy to deploy to a single VM or EC2 instance.
