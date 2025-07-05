# n8n Docker Setup

Este proyecto contiene la configuración Docker para ejecutar n8n (workflow automation platform).

## Archivos incluidos

- `Dockerfile`: Configuración de la imagen Docker
- `docker-compose.yml`: Configuración de servicios con Docker Compose
- `.dockerignore`: Archivos excluidos del contexto de construcción

## Uso rápido

### Opción 1: Docker Compose (Recomendado)

```bash
# Construir y ejecutar
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down
```

### Opción 2: Docker Build + Run

```bash
# Construir la imagen
docker build -t mi-n8n .

# Ejecutar el contenedor
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  mi-n8n
```

### Opción 3: Imagen oficial directa

```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  docker.n8n.io/n8nio/n8n
```

## Acceso a n8n

Una vez ejecutado, accede a n8n en: http://localhost:5678

## Configuración con base de datos

Para usar PostgreSQL en lugar de SQLite, descomenta las secciones correspondientes en `docker-compose.yml`.

## Comandos útiles

```bash
# Ver contenedores ejecutándose
docker ps

# Ver volúmenes
docker volume ls

# Inspeccionar volumen de datos
docker volume inspect n8n_data

# Hacer backup del volumen
docker run --rm \
  -v n8n_data:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/n8n_backup.tar.gz /data

# Restaurar backup
docker run --rm \
  -v n8n_data:/data \
  -v $(pwd):/backup \
  ubuntu tar xzf /backup/n8n_backup.tar.gz -C /
```

## Variables de entorno disponibles

- `N8N_HOST`: Host de n8n (default: 0.0.0.0)
- `N8N_PORT`: Puerto de n8n (default: 5678)
- `N8N_PROTOCOL`: Protocolo (http/https)
- `NODE_ENV`: Entorno de Node.js
- `WEBHOOK_URL`: URL base para webhooks

## Troubleshooting

### Verificar logs
```bash
docker logs n8n
# o con docker-compose
docker-compose logs n8n
```

### Reiniciar servicio
```bash
docker restart n8n
# o con docker-compose
docker-compose restart n8n
```
