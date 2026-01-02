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

**Security note:** change the Grafana admin password immediately after logging in (`docker compose exec grafana grafana-cli admin reset-admin-password <new>`). Expect the stack to consume ~2 vCPUs and 3–4GB RAM when ingestion is steady.

## CI smoke tests

The `observability_stack` job in `.github/workflows/portfolio.yml` runs:

1. `docker compose config` to validate YAML and environment substitutions.
2. `scripts/smoke-test.sh`, which brings the stack up, resolves dynamically assigned ports, and hits the Grafana and Prometheus health endpoints before tearing everything down.

## Customize scrapes and logs

- **Prometheus:** Add or adjust jobs under `config/prometheus/prometheus.yml`. Each item in `scrape_configs` maps to a target; set `static_configs` for local services or drop in `file_sd_configs` for cloud inventories.
- **Promtail:** Edit `config/promtail/promtail-config.yaml` to watch application logs. Point to Docker socket (`/var/lib/docker/containers/*/*.log`) or custom directories, then tag them with labels for Grafana Explore queries.
- **Grafana:** Duplicate dashboards under `config/grafana/dashboards` and update `/provisioning/datasources` if you want to point at remote Prometheus/Loki endpoints.

## Instrumentation ideas

- Drop JSON log files into `/var/log` and confirm they appear in Grafana's Explore tab via the Loki datasource.
- Add `alertmanager` and custom rules under `config/prometheus/` to simulate paging scenarios.
- Use this stack when showcasing operational runbooks—it's self-contained and easy to deploy to a single VM or EC2 instance.
