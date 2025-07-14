# Script de utilidades para N8N Docker
#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}N8N Docker Management Script${NC}"
    echo -e "${BLUE}============================${NC}"
    echo ""
    echo "Uso: ./n8n.sh [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  start       - Iniciar N8N"
    echo "  stop        - Parar N8N"
    echo "  restart     - Reiniciar N8N"
    echo "  logs        - Ver logs en tiempo real"
    echo "  status      - Ver estado de los servicios"
    echo "  update      - Actualizar N8N a la última versión"
    echo "  backup      - Crear backup de datos"
    echo "  restore     - Restaurar backup de datos"
    echo "  tunnel-url  - Mostrar URL del tunnel"
    echo "  clean       - Limpiar volúmenes y datos (¡CUIDADO!)"
    echo "  help        - Mostrar esta ayuda"
    echo ""
}

# Función para verificar si Docker está corriendo
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}❌ Error: Docker no está corriendo${NC}"
        exit 1
    fi
}

# Función para verificar si docker-compose está disponible
check_compose() {
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Error: docker-compose no está instalado${NC}"
        exit 1
    fi
}

# Función para iniciar N8N
start_n8n() {
    echo -e "${BLUE}🚀 Iniciando N8N...${NC}"
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ N8N iniciado correctamente${NC}"
        echo -e "${YELLOW}📝 Accede a N8N en: http://localhost:5678${NC}"
        echo -e "${YELLOW}📝 Para ver la URL del tunnel, ejecuta: ./n8n.sh tunnel-url${NC}"
    else
        echo -e "${RED}❌ Error al iniciar N8N${NC}"
        exit 1
    fi
}

# Función para parar N8N
stop_n8n() {
    echo -e "${BLUE}🛑 Parando N8N...${NC}"
    docker-compose down
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ N8N parado correctamente${NC}"
    else
        echo -e "${RED}❌ Error al parar N8N${NC}"
        exit 1
    fi
}

# Función para reiniciar N8N
restart_n8n() {
    echo -e "${BLUE}🔄 Reiniciando N8N...${NC}"
    docker-compose restart
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ N8N reiniciado correctamente${NC}"
    else
        echo -e "${RED}❌ Error al reiniciar N8N${NC}"
        exit 1
    fi
}

# Función para ver logs
show_logs() {
    echo -e "${BLUE}📋 Mostrando logs de N8N (Ctrl+C para salir)...${NC}"
    docker-compose logs -f n8n
}

# Función para ver estado
show_status() {
    echo -e "${BLUE}📊 Estado de los servicios:${NC}"
    docker-compose ps
}

# Función para actualizar
update_n8n() {
    echo -e "${BLUE}🔄 Actualizando N8N...${NC}"
    docker-compose pull
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ N8N actualizado correctamente${NC}"
    else
        echo -e "${RED}❌ Error al actualizar N8N${NC}"
        exit 1
    fi
}

# Función para crear backup
create_backup() {
    BACKUP_FILE="n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    echo -e "${BLUE}💾 Creando backup: ${BACKUP_FILE}${NC}"
    
    docker run --rm \
        -v automatizacion_n8n_data:/data \
        -v $(pwd):/backup \
        alpine tar czf /backup/${BACKUP_FILE} -C /data .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Backup creado: ${BACKUP_FILE}${NC}"
    else
        echo -e "${RED}❌ Error al crear backup${NC}"
        exit 1
    fi
}

# Función para restaurar backup
restore_backup() {
    echo -e "${YELLOW}📁 Archivos de backup disponibles:${NC}"
    ls -la *.tar.gz 2>/dev/null || echo "No se encontraron archivos de backup"
    echo ""
    read -p "Introduce el nombre del archivo de backup: " BACKUP_FILE
    
    if [ ! -f "$BACKUP_FILE" ]; then
        echo -e "${RED}❌ Archivo de backup no encontrado: ${BACKUP_FILE}${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}⚠️  ADVERTENCIA: Esto sobrescribirá todos los datos actuales${NC}"
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}📥 Restaurando backup: ${BACKUP_FILE}${NC}"
        
        docker run --rm \
            -v automatizacion_n8n_data:/data \
            -v $(pwd):/backup \
            alpine tar xzf /backup/${BACKUP_FILE} -C /data
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Backup restaurado correctamente${NC}"
            echo -e "${YELLOW}🔄 Reinicia N8N para aplicar los cambios${NC}"
        else
            echo -e "${RED}❌ Error al restaurar backup${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}❌ Restauración cancelada${NC}"
    fi
}

# Función para obtener URL del tunnel
get_tunnel_url() {
    echo -e "${BLUE}🌐 Obteniendo URL del tunnel...${NC}"
    
    # Buscar en los logs la URL del tunnel
    TUNNEL_URL=$(docker-compose logs n8n 2>/dev/null | grep -o 'https://[a-zA-Z0-9-]*\.loca\.lt' | tail -1)
    
    if [ -n "$TUNNEL_URL" ]; then
        echo -e "${GREEN}✅ URL del Tunnel: ${TUNNEL_URL}${NC}"
    else
        echo -e "${YELLOW}⚠️  No se encontró URL del tunnel en los logs${NC}"
        echo -e "${BLUE}💡 Verifica que N8N esté corriendo y el tunnel habilitado${NC}"
        echo -e "${BLUE}📋 Logs recientes:${NC}"
        docker-compose logs --tail=10 n8n
    fi
}

# Función para limpiar datos
clean_data() {
    echo -e "${RED}⚠️  ADVERTENCIA: Esto eliminará TODOS los datos de N8N${NC}"
    echo -e "${RED}⚠️  Incluyendo workflows, credenciales y configuraciones${NC}"
    echo ""
    read -p "¿Estás completamente seguro? Escribe 'DELETE' para confirmar: " CONFIRM
    
    if [ "$CONFIRM" = "DELETE" ]; then
        echo -e "${BLUE}🗑️  Parando servicios y eliminando datos...${NC}"
        docker-compose down -v
        docker volume rm automatizacion_n8n_data 2>/dev/null || true
        
        echo -e "${GREEN}✅ Datos eliminados correctamente${NC}"
    else
        echo -e "${YELLOW}❌ Limpieza cancelada${NC}"
    fi
}

# Script principal
main() {
    # Verificar prerrequisitos
    check_docker
    check_compose
    
    # Procesar comando
    case "${1:-help}" in
        "start")
            start_n8n
            ;;
        "stop")
            stop_n8n
            ;;
        "restart")
            restart_n8n
            ;;
        "logs")
            show_logs
            ;;
        "status")
            show_status
            ;;
        "update")
            update_n8n
            ;;
        "backup")
            create_backup
            ;;
        "restore")
            restore_backup
            ;;
        "tunnel-url")
            get_tunnel_url
            ;;
        "clean")
            clean_data
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Ejecutar script principal
main "$@"
