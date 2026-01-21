# Stop and remove all containers
docker-compose down

# Remove all durable data directories
rm -rf iris/*/durable
rm -rf webgateway/*/durable

# Clean up any log files or temporary data
find iris webgateway -type f \( -name "*.log" -o -name "*.lck" \) -delete 2>/dev/null || true

