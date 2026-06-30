# BSX VOICE - Project Overview

BSX VOICE is a voice AI platform for building and deploying conversational AI agents with telephony and WebRTC support.

## Project Structure

```
├── api/              # Backend - FastAPI application
├── ui/               # Frontend - Next.js application
├── scripts/          # Helper scripts for local development
├── deploy/           # Deployment configs (e.g. Hostinger)
├── pipecat/          # Pipecat framework (git submodule)
├── docker-compose.yaml       # Production/OSS deployment
├── docker-compose-local.yaml # Local development services
```

## Tech Stack

- **Backend**: Python with FastAPI
- **Frontend**: Next.js 15 with React 19, TypeScript, Tailwind CSS
- **Database**: PostgreSQL with SQLAlchemy (async)
- **Cache/Queue**: Redis with ARQ for background tasks
- **Storage**: MinIO (S3-compatible) for audio files

## Local Development

```bash
docker compose -f docker-compose-local.yaml up -d
source venv/bin/activate && bash scripts/start_services_dev.sh
cd ui && npm run dev
```

## Environment Configuration

- `api/.env` - Backend environment variables
- `api/.env.test` - Test-only environment variables
- `ui/.env` - Frontend environment variables

Typical test invocation:

```bash
source venv/bin/activate && set -a && source api/.env.test && set +a && python -m pytest api/tests/...
```
