# ---------- Stage 1: Build Frontend ----------
FROM node:18-alpine AS frontend

WORKDIR /frontend

COPY kavach_frontend/package*.json ./
RUN npm install

COPY kavach_frontend/ .
RUN npm run build


# ---------- Stage 2: Backend ----------
FROM python:3.11-slim

WORKDIR /app

COPY kavach_backend/ ./kavach_backend/
COPY --from=frontend /frontend/dist ./kavach_backend/static

RUN pip install --no-cache-dir -r kavach_backend/requirements.txt

ENV PORT=8080
EXPOSE 8080

WORKDIR /app/kavach_backend

# ✅ Use uvicorn directly (better than python main.py)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
