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
   - Builds and starts all containers
   - Sets proper permissions on bind mounts
3. Access the Management Portal at the URLs above
4. To stop and clean up: ./cleanup.sh
   - Stops and removes all containers
   - Removes durable data directories
   - Cleans up log files

## LICENSE KEY PLACEMENT
---------------------
You MUST provide your own IRIS license key files for the containers to work. Place your iris.key files in the following locations:

  ./iris/data-server/iris.key  - For the data server instance
  ./iris/app-1/iris.key        - For application server 1
  ./iris/app-2/iris.key        - For application server 2

IMPORTANT: The iris.key files are intentionally excluded from git tracking for security.


## DEFAULT CREDENTIALS
-------------------
Default IRIS credentials (configured in docker-compose.yml):
  Username: superuser
  Password: SYS

The first time you access Management Portal, you will be prompted to set a new password for security. The provided CSP.ini uses CSPSystem/SYS to connect to IRIS. If you change CSPSystem's password in IRIS, update the server configuration in Web Gateway accordingly.

## PORT MAPPINGS
-------------
See docker-compose.yml for the complete external port mappings. Change these if needed to avoid conflicts with other containers or instances on your machine.

## CONFIGURATION
-------------
Ensure that you use a good IRIS kit version (set IRISTAG and WEBGTAG in .env file), that your Docker is up to date, and that Docker can read-write to the iris/ and webgateway/ subdirectories for durable storage.

The .env file contains:
  IRISTAG - IRIS container image tag
  WEBGTAG - Web Gateway container image tag

--------------------------------------------------------------------
