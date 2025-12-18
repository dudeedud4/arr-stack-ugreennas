# Quick Reference: URLs, Commands, Network

## Services & Network (192.168.100.x)

| Service | IP | Port | Notes |
|---------|----|----|-------|
| Traefik | .2 | 80, 443 | Reverse proxy |
| **Gluetun** | **.3** | — | VPN gateway (qBit/Sonarr/Radarr/Prowlarr run here) |
| ↳ qBittorrent | via .3 | 8085 | Download client |
| ↳ Sonarr | via .3 | 8989 | TV shows |
| ↳ Radarr | via .3 | 7878 | Movies |
| ↳ Prowlarr | via .3 | 9696 | Indexer manager |
| Jellyfin | .4 | 8096 | Media server |
| Pi-hole | .5 | 8081 | DNS ad-blocking (`/admin`) |
| WireGuard | .6 | 51820/udp | Remote VPN access |
| Jellyseerr | .8 | 5055 | Request management |
| Bazarr | .9 | 6767 | Subtitles |
| FlareSolverr | .10 | 8191 | Cloudflare bypass |

**Optional** (utilities.yml / cloudflared.yml):

| Service | IP | Port | Notes |
|---------|----|----|-------|
| Cloudflared | .12 | — | Tunnel (no ports exposed) |
| Uptime Kuma | .13 | 3001 | Monitoring |
| duc | — | 8838 | Disk usage |

### Service Connection Guide

**VPN-protected services** (qBittorrent, Sonarr, Radarr, Prowlarr) share Gluetun's network via `network_mode: service:gluetun`. This means:

| From | To | Use | Why |
|------|-----|-----|-----|
| Sonarr | qBittorrent | `localhost:8085` | Same network stack |
| Radarr | qBittorrent | `localhost:8085` | Same network stack |
| Prowlarr | Sonarr | `localhost:8989` | Same network stack |
| Prowlarr | Radarr | `localhost:7878` | Same network stack |
| Prowlarr | FlareSolverr | `flaresolverr:8191` | Docker DNS works |
| Jellyseerr | Sonarr | `gluetun:8989` | Must go through gluetun |
| Jellyseerr | Radarr | `gluetun:7878` | Must go through gluetun |
| Jellyseerr | Jellyfin | `jellyfin:8096` | Both have own IPs |
| Bazarr | Sonarr | `gluetun:8989` | Must go through gluetun |
| Bazarr | Radarr | `gluetun:7878` | Must go through gluetun |

> **Why `gluetun` not `sonarr`?** Services sharing gluetun's network don't get their own Docker DNS entries. Jellyseerr/Bazarr must use `gluetun` hostname (or `192.168.100.3`) to reach them.

## Common Commands

```bash
# All commands below run on your NAS via SSH

# View all containers
docker ps

# View logs
docker logs -f <container_name>

# Restart service
docker compose -f docker-compose.arr-stack.yml restart <service_name>

# Pull repo updates then redeploy
git pull origin main
docker compose -f docker-compose.arr-stack.yml down
docker compose -f docker-compose.arr-stack.yml up -d

# Update container images
docker compose -f docker-compose.arr-stack.yml pull
docker compose -f docker-compose.arr-stack.yml up -d

# Stop everything
docker compose -f docker-compose.arr-stack.yml down
```

## Networks

| Network | Subnet | Purpose |
|---------|--------|---------|
| traefik-proxy | 192.168.100.0/24 | Service communication |
| vpn-net | 10.8.1.0/24 | Internal VPN routing (WireGuard peers) |
