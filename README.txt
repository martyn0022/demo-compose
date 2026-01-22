DEMO: DOCKER-COMPOSE IRIS AND WEB GATEWAY WITH NO PRIVATE WEB SERVER
OVERVIEW

This Docker Compose setup demonstrates a multi-instance InterSystems IRIS environment with dedicated Web Gateway containers:

iris-data-server - Main IRIS data server instance (ports 8881, 52773)

iris-app-1 - IRIS application server instance 1 (ports 8884, 52774)

iris-app-2 - IRIS application server instance 2 (ports 8885, 52775)

webgateway-data - Web Gateway for data server (ports 9080, 9443)

webgateway-app-1 - Web Gateway for app server 1 (ports 9081, 9444)

webgateway-app-2 - Web Gateway for app server 2 (ports 9082, 9445)

This configuration allows you to access the Management Portal through the Web Gateway without relying on IRIS's private web server.

ACCESS POINTS

Data Server Management Portal:
HTTP: http://localhost:9080/csp/sys/UtilHome.csp

HTTPS: https://localhost:9443/csp/sys/UtilHome.csp

App Server 1 Management Portal:
HTTP: http://localhost:9081/csp/sys/UtilHome.csp

HTTPS: https://localhost:9444/csp/sys/UtilHome.csp

App Server 2 Management Portal:
HTTP: http://localhost:9082/csp/sys/UtilHome.csp

HTTPS: https://localhost:9445/csp/sys/UtilHome.csp

(Replace localhost with the name or IP address of the host machine if needed.)

PREREQUISITES

Docker Desktop installed and running

Access to InterSystems Container Registry: https://containers.intersystems.com/contents/containers

IRIS license keys (iris.key) for each IRIS instance

QUICK START (GENERAL)

Log in to your container repository via:
https://containers.intersystems.com/contents/containers

(copy the provided docker login command and run it in your terminal)

Create 3 folders named:

data-server

app-1

app-2
under the iris folder

Place your IRIS license keys (see LICENSE KEY PLACEMENT section below)

Run:
./setup.sh
This will:
Build and start all containers
Set proper permissions on bind mounts
Access the Management Portal at the URLs listed above

To stop and clean up, run:
./cleanup.sh
This will:
Stop and remove all containers
Remove durable data directories
Clean up log files

WINDOWS-SPECIFIC INSTRUCTIONS
A) Recommended terminal options

Use one of the following:
PowerShell (Windows Terminal)
Git Bash (recommended for running .sh scripts)
WSL (if available)

B) Log in to InterSystems Container Registry
Go to: https://containers.intersystems.com/contents/containers
Copy the docker login command shown on the page
Run it in PowerShell:

docker login containers.intersystems.com

C) Create required folder structure
From the repo root in PowerShell:
New-Item -ItemType Directory -Force -Path iris\data-server, iris\app-1, iris\app-2 | Out-Null

D) Run setup and cleanup scripts
Option 1 (Recommended): Git Bash

Open Git Bash in the repo root and run:
./setup.sh

To stop and clean up:
./cleanup.sh

Option 2: PowerShell

If you have Git for Windows installed (includes bash), run:
bash setup.sh

To stop and clean up:
bash cleanup.sh

Notes for Windows:

Ensure Docker Desktop file sharing is enabled for the drive/folder containing this repo

Ensure scripts use LF line endings (Git Bash handles this best; if scripts fail, check line endings in your editor)

MAC-SPECIFIC INSTRUCTIONS

A) Log in to InterSystems Container Registry

Go to: https://containers.intersystems.com/contents/containers

Copy the docker login command shown on the page

Run it in Terminal:
docker login containers.intersystems.com

B) Create required folder structure
From the repo root:
mkdir -p iris/data-server iris/app-1 iris/app-2

C) Ensure scripts are executable
From the repo root:
chmod +x setup.sh cleanup.sh

D) Run setup and cleanup scripts
Run setup:
./setup.sh

Stop and clean up:
./cleanup.sh

LICENSE KEY PLACEMENT

You MUST provide your own IRIS license key files for the containers to work. Place your iris.key files in the following locations:

./iris/data-server/iris.key - For the data server instance
./iris/app-1/iris.key - For application server 1
./iris/app-2/iris.key - For application server 2

IMPORTANT: The iris.key files are intentionally excluded from git tracking for security.

DEFAULT CREDENTIALS

Default IRIS credentials (configured in docker-compose.yml):
Username: superuser
Password: SYS

The first time you access Management Portal, you will be prompted to set a new password for security. The provided CSP.ini uses CSPSystem/SYS to connect to IRIS. If you change CSPSystem's password in IRIS, update the server configuration in Web Gateway accordingly.

PORT MAPPINGS

See docker-compose.yml for the complete external port mappings. Change these if needed to avoid conflicts with other containers or instances on your machine.

CONFIGURATION

Ensure that you use a good IRIS kit version (set IRISTAG and WEBGTAG in .env file), that your Docker is up to date, and that Docker can read-write to the iris/ and webgateway/ subdirectories for durable storage.

The .env file contains:
IRISTAG - IRIS container image tag
WEBGTAG - Web Gateway container image tag