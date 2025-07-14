# N8N Docker Setup con Tunnel

Este proyecto configura N8N usando Docker Compose con soporte para tunnel, basado en la documentación oficial de N8N.

## ¿Qué es el Tunnel de N8N?

El tunnel de N8N es una funcionalidad que permite:
- Crear un túnel seguro desde internet hacia tu instancia local de N8N
- Recibir webhooks de servicios externos sin configurar port forwarding
- Probar integraciones durante el desarrollo
- Acceso público temporal sin configurar SSL o dominios

⚠️ **ADVERTENCIA**: El tunnel está diseñado para desarrollo y testing. **NO** se recomienda para producción.

## Características

- ✅ Configuración completa con tunnel habilitado
- ✅ Soporte para PostgreSQL (opcional)
- ✅ Configuración de timezone
- ✅ Variables de entorno organizadas
- ✅ Volúmenes persistentes
- ✅ Red Docker personalizada
- ✅ Autenticación básica opcional
- ✅ Encriptación configurable

## Requisitos Previos

- Docker
- Docker Compose

## Instalación y Uso

1. **Clona o descarga los archivos**:
   ```bash
   git clone <tu-repositorio>
   cd Automatizacion
   ```

2. **Configura las variables de entorno**:
   ```bash
   cp .env.example .env
   nano .env
   ```

3. **Inicia N8N**:
   ```bash
   docker-compose up -d
   ```

4. **Accede a N8N**:
   - Local: http://localhost:5678
   - Tunnel: Se mostrará la URL del tunnel en los logs

5. **Ver logs y URL del tunnel**:
   ```bash
   docker-compose logs n8n
   ```

## Configuración

### Variables de entorno principales

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `N8N_TUNNEL` | Habilita el tunnel | `true` |
| `N8N_TUNNEL_SUBDOMAIN` | Subdominio personalizado | `mi-n8n-tunnel` |
| `GENERIC_TIMEZONE` | Zona horaria | `Europe/Madrid` |

### Usando PostgreSQL

Para usar PostgreSQL en lugar de SQLite:

1. Descomenta las líneas de PostgreSQL en `docker-compose.yml`
2. Configura las variables de PostgreSQL en `.env`
3. Reinicia los servicios:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Seguridad (recomendado para producción)

1. **Habilitar autenticación básica**:
   ```env
   N8N_BASIC_AUTH_ACTIVE=true
   N8N_BASIC_AUTH_USER=admin
   N8N_BASIC_AUTH_PASSWORD=tu-password-seguro
   ```

2. **Configurar clave de encriptación**:
   ```env
   N8N_ENCRYPTION_KEY=tu-clave-de-32-caracteres-aqui
   ```

## Comandos Útiles

### Gestión del servicio
```bash
# Iniciar servicios
docker-compose up -d

# Parar servicios
docker-compose down

# Ver logs
docker-compose logs -f n8n

# Reiniciar N8N
docker-compose restart n8n

# Actualizar a la última versión
docker-compose pull
docker-compose up -d
```

### Backup y restauración
```bash
# Crear backup
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-backup.tar.gz -C /data .

# Restaurar backup
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar xzf /backup/n8n-backup.tar.gz -C /data
```

## Desarrollo

### Montar archivos locales
Puedes montar una carpeta local para archivos personalizados:
```yaml
volumes:
  - ./local-files:/files
```

### Variables adicionales de desarrollo
```env
# Para desarrollo
NODE_ENV=development
N8N_LOG_LEVEL=debug
```

## Solución de Problemas

### El tunnel no funciona
1. Verifica que `N8N_TUNNEL=true` esté configurado
2. Revisa los logs: `docker-compose logs n8n`
3. Asegúrate de que el puerto 5678 no esté siendo usado

### Problemas de conexión a base de datos
1. Verifica que PostgreSQL esté corriendo: `docker-compose ps`
2. Revisa las credenciales en `.env`
3. Verifica la conectividad: `docker-compose exec n8n ping postgres`

### Pérdida de datos
- Los datos se persisten en volúmenes Docker
- Hacer backups regulares en producción
- No eliminar volúmenes sin backup

## URLs Importantes

- **Interfaz local**: http://localhost:5678
- **API**: http://localhost:5678/api/v1/
- **Documentación N8N**: https://docs.n8n.io/
- **Community**: https://community.n8n.io/

## Licencia

N8N utiliza la Sustainable Use License. Consulta la documentación oficial para más detalles.

## Soporte

- [Documentación oficial](https://docs.n8n.io/)
- [GitHub Issues](https://github.com/n8n-io/n8n/issues)
- [Community Forum](https://community.n8n.io/)
