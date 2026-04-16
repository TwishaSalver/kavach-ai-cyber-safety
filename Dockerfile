# ---------- Stage 1: Build Frontend ----------
FROM node:18-alpine AS frontend

WORKDIR /frontend

# Install dependencies
COPY kavach_frontend/package*.json ./
RUN npm install

# Copy frontend code
COPY kavach_frontend/ .

# Build frontend (creates dist/)
RUN npm run build


# ---------- Stage 2: Backend ----------
FROM python:3.11-slim

WORKDIR /app

# Copy backend code
COPY kavach_backend/ ./kavach_backend/

# Copy built frontend into backend static folder
COPY --from=frontend /frontend/dist ./kavach_backend/static

# Install Python dependencies
RUN pip install --no-cache-dir -r kavach_backend/requirements.txt

# Set environment variable for port
ENV PORT=8080
EXPOSE 8080

# Move into backend directory
WORKDIR /app/kavach_backend

# Start backend
CMD ["python", "main.py"]
