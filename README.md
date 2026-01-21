# DEMO: Docker Compose — IRIS + Web Gateway (No Private Web Server)

## Overview
This Docker Compose setup demonstrates a **multi-instance InterSystems IRIS environment** with **dedicated Web Gateway containers**:

- **`iris-data-server`** — Main IRIS data server instance *(ports: 8881, 52773)*
- **`iris-app-1`** — IRIS application server instance 1 *(ports: 8884, 52774)*
- **`iris-app-2`** — IRIS application server instance 2 *(ports: 8885, 52775)*
- **`webgateway-data`** — Web Gateway for data server *(ports: 9080, 9443)*
- **`webgateway-app-1`** — Web Gateway for app server 1 *(ports: 9081, 9444)*
- **`webgateway-app-2`** — Web Gateway for app server 2 *(ports: 9082, 9445)*

This configuration allows you to access the **Management Portal via the Web Gateway**, without relying on IRIS’s **private web server**.

---

## Access Points

### Data Server Management Portal
- HTTP:  `http://localhost:9080/csp/sys/UtilHome.csp`
- HTTPS: `https://localhost:9443/csp/sys/UtilHome.csp`

### App Server 1 Management Portal
- HTTP:  `http://localhost:9081/csp/sys/UtilHome.csp`
- HTTPS: `https://localhost:9444/csp/sys/UtilHome.csp`

### App Server 2 Management Portal
- HTTP:  `http://localhost:9082/csp/sys/UtilHome.csp`
- HTTPS: `https://localhost:9445/csp/sys/UtilHome.csp`

> Replace `localhost` with the hostname/IP of your Docker host machine if needed.

---

## Quick Start

1. Place your IRIS license keys (see **License Key Placement** below)
2. Run:
   ```bash
   ./setup.sh
