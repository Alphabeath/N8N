# Dockerfile para n8n
FROM docker.n8n.io/n8nio/n8n:latest

# Metadatos
LABEL maintainer="bryan@ejemplo.com"
LABEL version="1.0"
LABEL description="n8n workflow automation platform"

# Variables de entorno
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV NODE_ENV=production
ENV WEBHOOK_URL=http://localhost:5678

# Crear usuario y directorio de trabajo
WORKDIR /home/node/.n8n

# Configurar permisos
USER node

# Crear volumen para persistencia de datos
VOLUME ["/home/node/.n8n"]

# Exponer puerto
EXPOSE 5678

# Configurar healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5678/healthz || exit 1

# Comando por defecto
CMD ["n8n", "start"]
