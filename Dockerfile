# Stage 1: Build React frontend
FROM node:18-alpine AS frontend
WORKDIR /frontend
COPY package*.json ./
RUN npm install --production
COPY . .
RUN npm run build

# Stage 2: Python backend
FROM python:3.11-slim
WORKDIR /app

# Copy backend code
COPY kavach-backend/ ./kavach-backend/
COPY kavach-agents/ ./kavach-agents/

# Copy built frontend into backend's static folder
COPY --from=frontend /frontend/dist ./kavach-backend/static

# Install Python dependencies
RUN pip install --no-cache-dir -r kavach-backend/requirements.txt \
    && pip install --no-cache-dir -r kavach-agents/requirements.txt

ENV PORT=8080
EXPOSE 8080

# Run backend (make sure it serves static files from ./kavach-backend/static)
CMD ["python", "kavach-backend/main.py"]
