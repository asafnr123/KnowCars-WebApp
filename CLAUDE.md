# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KnowCars is a three-tier car catalog web app: React SPA (S3) → Flask API (EKS) → MySQL (EKS StatefulSet on EBS). Infrastructure is fully managed via Terraform on AWS (eu-central-1).

## Common Commands

### Frontend (frontend_react/)
```bash
npm start          # Dev server on :3000 (proxies API to :5000)
npm run build      # Production build
npm exec eslint -- . --ext .js,.jsx --max-warnings=0  # Lint
```

### Backend (backend_api/)
```bash
python3 carAPI.py  # Run Flask API on :5000
```

### Testing
```bash
pytest                                   # Unit tests (mocked DB)
./tests/docker_integration_test.sh       # Integration tests (real MySQL via docker-compose)
```

### Local Dev (full stack)
```bash
docker compose up                        # MySQL + Flask with hot-reload
docker compose -f docker-compose-ci.yaml up  # CI integration environment
```

### Infrastructure
```bash
terraform init             # Init with S3 remote state
terraform plan -out=tfplan
terraform apply tfplan
terraform destroy
```

## Architecture

### Data Flow
```
Browser (S3 static site)
  → AWS CLB/NLB (:5000)
    → EKS Flask Deployment (flask-service)
      → MySQL StatefulSet (ClusterIP, EBS-backed)
```

### Key Files
- `backend_api/carAPI.py` — All Flask endpoints (`/api/cars`, `/api/health`, `/api/health/ready`, image serving)
- `backend_api/mysqlConnection.py` — DB connection, credentials from env vars
- `frontend_react/src/services/getData.js` — All API calls from React
- `terraform/main.tf` — All AWS resources (VPC, EKS, S3, IAM, OIDC)

### K8s Manifests
- `flask_deployment/` — Deployment + NLB LoadBalancer service; image tag uses `${SHORT_SHA}` placeholder substituted by `envsubst` in CD
- `mysql_statefulset/` — StatefulSet + ClusterIP service + EBS StorageClass
- `mysql_container/init.sql` — Schema for `knowCarsDB` (tables: `cars`, `carImages`), baked into MySQL Docker image

### Environment Variables
Flask needs: `MYSQL_USER`, `MYSQL_PASSWORD`, `DB_HOST`, `DB_PORT`, `CARS_DB`  
React needs: `REACT_APP_API_URL` (set at build time to the CLB DNS)

## CI/CD Pipelines

**CI.yaml** — triggers on PR to `develop`:
1. pytest → ESLint → build Docker images (Flask + MySQL tagged `:SHORT_SHA` + `:latest`) → integration tests → push to DockerHub → upload `SHORT_SHA` artifact

**CD.yaml** — manual `workflow_dispatch` (apply or destroy):
1. `validate-manifests` — kubeconform against K8s 1.29.0 schema
2. `terraform` — init/plan/apply or destroy (2-hour token for destroy)
3. `deploy-eks` — namespace, mysql-secret, apply manifests via `envsubst`, wait for rollouts, smoke test `GET /api/cars?include=image`
4. `deploy-frontend` — get CLB DNS from kubectl, build React with `REACT_APP_API_URL`, sync to S3 with `--delete`

### Required GitHub Secrets
`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD`, `AWS_GITHUB_ACTIONS_ROLE_ARN`, `AWS_REGION`, `EKS_CLUSTER_NAME`, `S3_FRONTEND_BUCKET`

AWS auth uses OIDC (no long-lived credentials stored).
