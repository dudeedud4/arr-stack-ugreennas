# Media Automation Stack for Ugreen NAS

A complete, production-ready Docker Compose stack for automated media management with VPN routing, SSL certificates, and remote access.

**Specifically designed and tested for Ugreen NAS DXP4800+** with comprehensive documentation covering deployment, configuration, troubleshooting, and production best practices.

> **Note**: Tested on Ugreen NAS DXP4800+. Should work on other Ugreen models and Docker-compatible NAS devices, but may require adjustments.

## Legal Notice

This project provides configuration files for **legal, open-source software** designed for managing personal media libraries. All included tools have legitimate purposes - see **[LEGAL.md](docs/LEGAL.md)** for details on intended use, user responsibilities, and disclaimer.

---

## Getting Started

**[Setup Guide](docs/SETUP.md)** - Complete step-by-step instructions for deployment.

<details>
<summary>Using Claude Code for guided setup (optional)</summary>

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) can walk you through deployment step-by-step, executing commands and troubleshooting as you go.

**VS Code / Cursor:** Install the Claude extension, open this folder, and start a chat.

**Terminal:**
```bash
npm install -g @anthropic-ai/claude-code
cd arr-stack-ugreennas && claude
```

Ask Claude to help deploy the stack - it reads the [`.claude/instructions.md`](.claude/instructions.md) file automatically.

</details>

---

## Features

- **VPN-protected networking** via Gluetun + Surfshark for privacy
- **Auto-recovery** - VPN-dependent services automatically restart when VPN reconnects (via deunhealth)
- **Automated SSL/TLS** certificates via Traefik + Cloudflare
- **Media library management** with Sonarr, Radarr, Prowlarr, Bazarr
- **Media streaming** with Jellyfin (or Plex - see below)
- **Request management** with Jellyseerr (or Overseerr for Plex)
- **Remote access** via WireGuard VPN
- **Ad-blocking DNS** with Pi-hole
- **Service monitoring** with Uptime Kuma

## Services Included

| Service | Description | Local Port | Domain URL |
|---------|-------------|------------|------------|
| **Traefik** | Reverse proxy with automatic SSL | 8080 | traefik.yourdomain.com |
| **Gluetun** | VPN gateway for network privacy | - | Internal |
| **qBittorrent** | BitTorrent client (VueTorrent UI included) | 8085 | qbit.yourdomain.com |
| **Sonarr** | TV show library management | 8989 | sonarr.yourdomain.com |
| **Radarr** | Movie library management | 7878 | radarr.yourdomain.com |
| **Prowlarr** | Search aggregator | 9696 | prowlarr.yourdomain.com |
| **Bazarr** | Subtitle management | 6767 | bazarr.yourdomain.com |
| **Jellyfin** | Media streaming server | 8096 | jellyfin.yourdomain.com |
| **Jellyseerr** | Media request system | 5055 | jellyseerr.yourdomain.com |
| **Pi-hole** | DNS + Ad-blocking | 53, 80 | pihole.yourdomain.com |
| **WireGuard** | VPN server for remote access | 51820/udp | wg.yourdomain.com |
| **Uptime Kuma** | Service monitoring | 3001 | uptime.yourdomain.com |
| **FlareSolverr** | CAPTCHA solver | 8191 | Internal |
| **deunhealth** | Auto-restart on VPN recovery | - | Internal |

> **Prefer Plex?** See `docker-compose.plex-arr-stack.yml` for an untested Plex/Overseerr variant.

## Deployment Options

### Option A: Remote Access (Recommended)

Access your services from anywhere - phone on mobile data, travelling, etc. Requires a cheap domain (~$10/year):
- **Remote access** from anywhere via Cloudflare Tunnel
- **SSL/HTTPS** with automatic certificates
- **Pretty URLs** like `jellyfin.yourdomain.com`
- **WireGuard VPN** for secure access to your home network

**Requirements:** Domain name, Cloudflare account (free), VPN subscription

> **Cloudflare:** This stack is configured for Cloudflare (DNS + Tunnel). Other DNS providers work but you'll need to modify `docker-compose.traefik.yml` and `traefik/traefik.yml`. See [Traefik ACME docs](https://doc.traefik.io/traefik/https/acme/).
>
> **VPN:** Configured for Surfshark but Gluetun supports 30+ providers (NordVPN, PIA, Mullvad, etc.). See [Gluetun providers](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers).

### Option B: Local Network Only (No Domain)

Skip the domain and access services directly via IP:port. All services work out of the box:
- `http://NAS_IP:8096` → Jellyfin
- `http://NAS_IP:5055` → Jellyseerr
- `http://NAS_IP:8989` → Sonarr
- `http://NAS_IP:7878` → Radarr
- `http://NAS_IP:9696` → Prowlarr
- `http://NAS_IP:8085` → qBittorrent
- `http://NAS_IP:6767` → Bazarr
- `http://NAS_IP:3001` → Uptime Kuma
- `http://NAS_IP:53` → Pi-hole DNS

**What works:** All media automation, VPN-protected downloads, Pi-hole DNS, local streaming

**What you lose:** Remote access, HTTPS, subdomain routing, WireGuard remote VPN

**To deploy local-only:**
1. Skip `docker-compose.traefik.yml` and `docker-compose.cloudflared.yml`
2. Deploy: `docker compose -f docker-compose.arr-stack.yml up -d`
3. Access via `http://NAS_IP:PORT`


## Updating

```bash
# Pull latest images
docker compose -f docker-compose.arr-stack.yml pull

# Recreate containers
docker compose -f docker-compose.arr-stack.yml up -d
```

## Security

- All services use HTTPS with automatic SSL certificates
- Network traffic routed through VPN for privacy
- Pi-hole provides DNS-level ad-blocking
- WireGuard enables secure remote access

### IMPORTANT: Configure Authentication

**Many services default to NO authentication!** After deployment, you MUST enable authentication on:

| Service | Default Auth | Action Required |
|---------|--------------|-----------------|
| Bazarr | Disabled (exposes API key!) | Enable Forms auth, regenerate API key |
| Sonarr/Radarr/Prowlarr | Disabled for Local Addresses | Set to Forms + Enabled |
| qBittorrent | Bypass localhost | Disable bypass, change default password |
| Uptime Kuma | None | Create admin account (forced on first access) |

**Why this matters with Cloudflare Tunnel**: Traffic through the tunnel appears to come from localhost, bypassing "Disabled for Local Addresses" authentication!

See the [Security section](docs/SETUP.md#59-security-enable-authentication) in the Setup Guide for detailed instructions.

## Resources

- [Setup Guide](docs/SETUP.md) - Full deployment instructions
- [Servarr Wiki](https://wiki.servarr.com/) - Sonarr, Radarr, Prowlarr
- [Gluetun Wiki](https://github.com/qdm12/gluetun-wiki) - VPN container
- [Traefik Docs](https://doc.traefik.io/) - Reverse proxy

## License

Provided as-is for personal use. See individual components for their licenses.

## Acknowledgments

Forked from [TheRealCodeVoyage/arr-stack-setup-with-pihole](https://github.com/TheRealCodeVoyage/arr-stack-setup-with-pihole). Thanks to [@benjamin-awd](https://github.com/benjamin-awd) for VPN config improvements.
