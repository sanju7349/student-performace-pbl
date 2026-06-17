# Predictive Learning Analytics Platform

Production-style monorepo for a predictive student performance platform.

## Structure

- `frontend/` - React + Vite application with JWT auth, dashboards, charts, and protected routes
- `backend/` - Django + DRF APIs for auth, students, predictions, dashboard analytics, and Gemini insights
- `ml-service/` - FastAPI service with a `RandomForestRegressor`, training script, sample dataset, and `/predict` endpoint
- `docs/` - setup and deployment notes

## Quick start

Follow [docs/setup.md](docs/setup.md).
