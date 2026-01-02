#!/bin/bash
#
# Safe stack restart - NEVER uses 'down' which kills Pi-hole DNS
#
# Usage:
#   ./scripts/restart-stack.sh           # Restart all compose files
#   ./scripts/restart-stack.sh arr       # Restart arr-stack only
#   ./scripts/restart-stack.sh traefik   # Restart traefik only
#   ./scripts/restart-stack.sh utilities # Restart utilities only
#

set -euo pipefail
cd "$(dirname "$0")/.."

restart_compose() {
    local file="$1"
    local name="$2"
    echo "♻️  Restarting $name..."
    docker compose -f "$file" up -d --force-recreate
    echo "✅ $name restarted"
}

case "${1:-all}" in
    arr|arr-stack)
        restart_compose docker-compose.arr-stack.yml "arr-stack"
        ;;
    traefik)
        restart_compose docker-compose.traefik.yml "traefik"
        ;;
    cloudflared|tunnel)
        restart_compose docker-compose.cloudflared.yml "cloudflared"
        ;;
    utilities|utils)
        restart_compose docker-compose.utilities.yml "utilities"
        ;;
    all)
        restart_compose docker-compose.traefik.yml "traefik"
        restart_compose docker-compose.arr-stack.yml "arr-stack"
        restart_compose docker-compose.cloudflared.yml "cloudflared"
        restart_compose docker-compose.utilities.yml "utilities"
        echo ""
        echo "✅ All stacks restarted"
        ;;
    *)
        echo "Usage: $0 [arr|traefik|cloudflared|utilities|all]"
        exit 1
        ;;
esac
