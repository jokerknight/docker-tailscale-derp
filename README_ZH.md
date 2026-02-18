# Tailscale DERP 节点 Docker 部署

[中文文档](README_ZH.md) | [English](README.md)

---

基于 Tailscale DERP (Detected Encrypted Relay Protocol) 的 Docker 化部署方案，支持使用 IP 地址自动生成自签名证书。

## 功能特性

- 基于 Tailscale 官方 derper 源码编译
- 静态链接二进制文件，支持多架构（x86_64、ARM64 等）
- 支持使用 IP 地址自动生成自签名证书
- 客户端连接验证，防止未授权使用
- Docker Compose 一键部署
- 证书持久化存储

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/yourusername/docker-tailscale-derp.git
cd docker-tailscale-derp
```

### 2. 配置环境变量

复制示例环境变量文件并修改：

```bash
cp example.env .env
```

编辑 `.env` 文件，修改 `DERP_HOSTNAME` 为您的服务器 IP 地址：

```env
DERP_HOSTNAME=your.server.ip
```

### 3. 启动服务

```bash
docker-compose up -d
```

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `DERP_HOSTNAME` | 无 | 服务器 IP 地址或域名 |
| `DERP_ADDR` | `:3478` | DERP 服务监听端口 |
| `DERP_CERTDIR` | `/ssl` | 证书存储目录 |

### 端口映射

- `3478` - DERP HTTP/HTTPS 端口
- `3478/udp` - DERP UDP 端口

### 数据卷

- `./certs:/ssl` - 证书目录，持久化保存自动生成的证书
- `/var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock` - Tailscale 客户端连接验证

## IP 地址模式

本方案支持使用 IP 地址作为 hostname，程序会自动为该 IP 生成自签名证书。程序启动时会在日志中输出配置信息，例如：

```
Using self-signed certificate for IP address "1.2.3.4". Configure it in DERPMap using: (https://tailscale.com/s/custom-derp)
  {"Name":"custom","RegionID":900,"HostName":"1.2.3.4","CertName":"sha256-raw:..."}
```

## 在 Tailscale 中配置 DERP 节点

1. 创建或编辑 Tailscale ACL 配置文件
2. 在 `derpMap` 中添加您的自定义 DERP 节点：

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
            "CertName": "sha256-raw:xxxx"  // 从启动日志中复制
          }
        ]
      }
    }
  }
}
```

3. 将配置上传到 Tailscale 控制台或使用 `tailscale up` 应用

## 构建 Docker 镜像

```bash
docker build -t docker-tailscale-derp .
```

## 常见问题

### Q: 为什么使用 IP 而不是域名？

A: 使用 IP 地址可以避免 DNS 配置和域名证书管理的复杂性，程序会自动为 IP 生成自签名证书，部署更简单。

### Q: 证书会过期吗？

A: 自动生成的自签名证书有效期为 1 年，程序会在需要时自动更新。

### Q: 如何验证 DERP 节点是否正常工作？

A: 使用 Tailscale 客户端连接并检查日志，或在 Tailscale 控制台查看连接状态。

### Q: 支持哪些架构？

A: 由于使用静态编译，支持所有主流架构：x86_64、ARM64、ARMv7 等。

## 许可证

Apache License 2.0

## 贡献

欢迎提交 Issue 和 Pull Request！
