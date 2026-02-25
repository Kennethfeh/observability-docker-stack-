# Observability Docker Stack

Self-contained Docker Compose stack bundling Prometheus, Grafana, Loki, and Promtail. Perfect for spinning up observability tooling on a laptop or single VM before moving to managed services.

## Stack diagram

```
┌────────────┐        ┌────────────┐
│ Promtail   │  --->  │   Loki     │  (log storage)
└────────────┘        └────────────┘
       │                      │
       │                      └──────────┐
       ▼                                 ▼
┌────────────┐        ┌─────────────────────────┐
│ Prometheus │  --->  │ Grafana (dashboards)    │
└────────────┘        └─────────────────────────┘
```

## Repository layout

| File | Description |
| --- | --- |
| `docker-compose.yml` | Orchestrates Prometheus, Grafana, Loki, and Promtail containers with named volumes and health checks. |
| `config/prometheus/prometheus.yml` | Base scrape configuration; add static targets, relabel configs, and alerting rules here. |
| `config/grafana/` | Datasource + dashboard provisioning so Grafana comes online with Prometheus + Loki already wired. |
| `config/loki/config.yaml` | Loki storage + retention settings. |
| `config/promtail/promtail-config.yaml` | Defines which host/container logs are tailed and how labels are attached. |
| `scripts/smoke-test.sh` | CI-friendly script that brings the stack up, confirms Grafana and Prometheus health endpoints, then tears everything down. |

## Quick start

```bash
docker compose up -d

# Login credentials
grafana: http://localhost:3000 (admin / admin)
prometheus: http://localhost:9090
```

Stop and clean up:

```bash
docker compose down -v
```

> _Tip:_ change the Grafana admin password immediately after first login: `docker compose exec grafana grafana-cli admin reset-admin-password <new>`.

## Customising the stack

- **Prometheus** – Add jobs under `scrape_configs` for your services or plug in `file_sd_configs` to scrape Kubernetes endpoints exported from ServiceMonitors.
- **Promtail** – Watch Docker container logs by uncommenting the Docker job inside `promtail-config.yaml` and mounting `/var/lib/docker/containers`.
- **Grafana** – Drop dashboard JSON files into `config/grafana/dashboards/` and reference them via `provisioning/dashboards/dashboards.yaml`.
- **Loki** – Tune retention/compaction settings and configure S3/GCS object storage if you move beyond local volumes.

## CI smoke test

`observability_stack` job in `.github/workflows/portfolio.yml` executes:

1. `docker compose config` for YAML validation.
2. `scripts/smoke-test.sh` which:
   - Spins the stack up with temporary project name.
   - Discovers mapped ports.
   - Hits Grafana `/api/health` and Prometheus `/-/ready`.
   - Tears everything down and removes volumes.

Reuse the script locally to confirm port collisions or configuration issues before committing.

## Resource considerations

- Expect ~2 vCPUs and 3–4 GB RAM when everything is ingesting data.
- Loki stores logs on the `loki-data` volume; prune it periodically or mount to persistent disks.
- Prometheus retention defaults to `15d` in `prometheus.yml`. Adjust if disk space is limited.

## Extending the stack

- Add Alertmanager + rules files to simulate paging workflows.
- Mount a `datasources.yaml` entry that points Grafana at remote Prometheus/Loki endpoints.
- Use this stack as the control plane for demos: drop your application into the same Compose project and update `prometheus.yml` + `promtail-config.yaml` to scrape/ship metrics and logs instantly.

With this repo you can bootstrap a trustworthy observability sandbox in minutes and iterate safely before codifying the same primitives in Kubernetes or cloud-managed offerings.
