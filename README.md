# Tailscale DERP Node Docker Deployment

[中文文档](README_ZH.md) | [English](README.md)

---

Docker-based deployment solution for Tailscale DERP (Detected Encrypted Relay Protocol) with automatic self-signed certificate generation for IP addresses.

## Features

- Built from Tailscale official derper source code
- Statically linked binary, supports multiple architectures (x86_64, ARM64, etc.)
- Automatic self-signed certificate generation for IP addresses
- Client connection verification to prevent unauthorized usage
- One-click deployment with Docker Compose
- Persistent certificate storage

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/jokerknight/docker-tailscale-derp.git
cd docker-tailscale-derp
```

### 2. Configure Environment Variables

Copy the example environment file and modify it:

```bash
cp example.env .env
```

Edit `.env` file and set `DERP_HOSTNAME` and `DERP_PORT`:

```env
DERP_HOSTNAME=your.server.ip
DERP_PORT=3478
```

### 3. Start the Service

**Option 1: Use Docker Hub image directly (Recommended)**

```bash
docker compose up -d
```

**Option 2: Build locally**

If you need custom builds or use override files:

```bash
docker compose up -d --build
```

Or use Make commands:

```bash
make buildup  # Build and start
```

**Option 3: Use Make shortcuts**

```bash
make up      # Start service
make down    # Stop service
make logs    # View logs
```

**Note:** This project enforces `--verify-clients` client verification. You must install and run Tailscale client on the host machine first, otherwise the service will not start properly. Client verification is an essential security mechanism to prevent unauthorized DERP nodes from being abused.

**Network Optimization in China:**

If you encounter network issues when building in China, configure Docker mirror accelerators:

```bash
# Create or edit Docker daemon configuration
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.mirrors.ustc.edu.cn",
    "https://docker.1panel.live"
  ]
}
EOF

# Restart Docker service
sudo systemctl daemon-reload
sudo systemctl restart docker
```

A sample `daemon.json` file is also provided in the project root for reference.

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DERP_HOSTNAME` | (none) | Server IP address or domain name |
| `DERP_PORT` | `3478` | DERP service listening port |
| `DERP_CERTDIR` | `/ssl` | Certificate storage directory |

### Port Mapping

Automatically mapped based on `DERP_PORT` configuration, default to:
- `3478` - DERP HTTP/HTTPS port
- `3478/udp` - DERP UDP port

### Volumes

- `./certs:/ssl` - Certificate directory for persisting auto-generated certificates
- `/var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock` - Tailscale client connection verification

## IP Address Mode

This solution supports using IP addresses as hostname. The program automatically generates a self-signed certificate for the IP. On startup, the program outputs configuration information in logs, for example:

```
Using self-signed certificate for IP address "1.2.3.4". Configure it in DERPMap using: (https://tailscale.com/s/custom-derp)
  {"Name":"custom","RegionID":900,"HostName":"1.2.3.4","CertName":"sha256-raw:..."}
```

## Configuring DERP Node in Tailscale

1. Create or edit Tailscale ACL configuration file
2. Add your custom DERP node in `derpMap`:

```json
{
  "derpMap": {
    "OmitDefaultRegions": false,
    "Regions": {
      "900": {
        "RegionID": 900,
        "RegionCode": "custom",
        "RegionName": "Custom DERP",
        "Nodes": [
          {
            "Name": "custom",
            "RegionID": 900,
            "HostName": "your.server.ip",
            "DERPPort": 3478,  // Port number, must match DERP_PORT in .env
            "CertName": "sha256-raw:xxxx"  // Copy from startup logs
          }
        ]
      }
    }
  }
}
```

3. Upload configuration to Tailscale console or apply using `tailscale up`

## Building Docker Image

**Using Docker command:**

```bash
docker build -t docker-tailscale-derp .
```

**Using Make commands:**

```bash
make build    # Local build (current architecture)
make push     # Multi-arch build and push to Docker Hub
make release  # One-click release
```

## FAQ

### Q: Why use IP instead of domain name?

A: Using IP addresses avoids the complexity of DNS configuration and domain certificate management. The program automatically generates self-signed certificates for IPs, making deployment simpler.

### Q: Will the certificate expire?

A: The auto-generated self-signed certificate is valid for 1 year. The program will automatically update it when needed.

### Q: How to verify if DERP node is working?

A: Connect using Tailscale client and check logs, or view connection status in Tailscale console.

### Q: Which architectures are supported?

A: Due to static compilation, all mainstream architectures are supported: x86_64, ARM64, ARMv7, etc.

### Q: How to verify if DERP node is working?

A: Use a machine with Tailscale installed and run `tailscale netcheck`. If the configured DERP nodes appear and can ping each other, the configuration is successful.

## License

Apache License 2.0

## Contributing

Issues and Pull Requests are welcome!
