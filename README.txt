DEMO: DOCKER-COMPOSE IRIS AND WEB GATEWAY WITH NO PRIVATE WEB SERVER
--------------------------------------------------------------------

OVERVIEW
--------
This Docker Compose setup demonstrates a multi-instance InterSystems IRIS environment with dedicated Web Gateway containers:

* iris-data-server - Main IRIS data server instance (ports 8881, 52773)
* iris-app-1 - IRIS application server instance 1 (ports 8884, 52774)
* iris-app-2 - IRIS application server instance 2 (ports 8885, 52775)
* webgateway-data - Web Gateway for data server (ports 9080, 9443)
* webgateway-app-1 - Web Gateway for app server 1 (ports 9081, 9444)
* webgateway-app-2 - Web Gateway for app server 2 (ports 9082, 9445)

This configuration allows you to access the Management Portal through the Web Gateway without relying on IRIS's private web server.

ACCESS POINTS
-------------
Data Server Management Portal:
  HTTP:  http://localhost:9080/csp/sys/UtilHome.csp
  HTTPS: https://localhost:9443/csp/sys/UtilHome.csp

App Server 1 Management Portal:
  HTTP:  http://localhost:9081/csp/sys/UtilHome.csp
  HTTPS: https://localhost:9444/csp/sys/UtilHome.csp

App Server 2 Management Portal:
  HTTP:  http://localhost:9082/csp/sys/UtilHome.csp
  HTTPS: https://localhost:9445/csp/sys/UtilHome.csp

(Replace localhost with the name or IP address of the host machine if needed.)

QUICK START
-----------
1. Place your IRIS license keys (see "LICENSE KEY PLACEMENT" section below)
2. Run: ./setup.sh
   - Builds and starts all containers
   - Sets proper permissions on bind mounts
3. Access the Management Portal at the URLs above
4. To stop and clean up: ./cleanup.sh
   - Stops and removes all containers
   - Removes durable data directories
   - Cleans up log files

LICENSE KEY PLACEMENT
---------------------
You MUST provide your own IRIS license key files for the containers to work. Place your iris.key files in the following locations:

  ./iris/data-server/iris.key  - For the data server instance
  ./iris/app-1/iris.key        - For application server 1
  ./iris/app-2/iris.key        - For application server 2

IMPORTANT: The iris.key files are intentionally excluded from git tracking for security.

SSL CERTIFICATES (OPTIONAL)
---------------------------
Users may supply their own valid SSL certificates and keys. Name and place these files as follows.

For %SuperServer, under iris/:
* sslauth.pem (CA certificate)
* sslcert.pem (server certificate)
* sslkey.pem (private key)

For Web Gateway to IRIS connections, under webgateway/:
* sslcliauth.pem (CA certificate)
* sslclicert.pem (client certificate)
* sslclikey.pem (private key)

For browser to Web Gateway connections, under webgateway/:
* sslwebcert.pem (web server certificate)
* sslwebkey.pem (web server key)

If SSL is not desired, remove the SSL-related sections from these files:
* setup.sh (everything after the docker-compose commands)
* webgateway/CSP.ini (under the LOCAL section, Connection_Security_Level and all the SSLCC_* fields)
* webgateway/CSP.conf (everything under the SSL section)

DEFAULT CREDENTIALS
-------------------
Default IRIS credentials (configured in docker-compose.yml):
  Username: superuser
  Password: sys

The first time you access Management Portal, you will be prompted to set a new password for security. The provided CSP.ini uses CSPSystem/SYS to connect to IRIS. If you change CSPSystem's password in IRIS, update the server configuration in Web Gateway accordingly.

PORT MAPPINGS
-------------
See docker-compose.yml for the complete external port mappings. Change these if needed to avoid conflicts with other containers or instances on your machine.

CONFIGURATION
-------------
Ensure that you use a good IRIS kit version (set IRISTAG and WEBGTAG in .env file), that your Docker is up to date, and that Docker can read-write to the iris/ and webgateway/ subdirectories for durable storage.

The .env file contains:
  IRISTAG - IRIS container image tag
  WEBGTAG - Web Gateway container image tag

--------------------------------------------------------------------

NOTES FOR PODMAN:

If using podman in lieu of docker, the demo works similarly, but requires the following special considerations for setup:

- Podman must either use netavark as its backend or have the dnsname plugin installed for the cni backend.
- Run "podman unshare chown 51773:51773" on the iris/ subdirectory to support durable sys. Alternatively, omit durable sys.
- If SELinux is enforcing security on RHEL, add (uncomment) the "privileged: true" flag for each service in the docker-compose file.

You will also need podman-compose/podman commands instead of docker-compose/docker in the setup and cleanup scripts, unless you use docker-to-podman aliasing.

--------------------------------------------------------------------

SECURITY NOTE:

This demo is simplified and for demonstration purposes only. It does not have production-level security as-is. For a more secure setup, users should make, at minimum, the following changes:

- Do not use "*.*.*.*" for System_Manager; this grants all IP addresses access to Web Gateway Management.
- Set a password other than "SYS" for all IRIS users, including CSPSystem.

See Documentation (docs.intersystems.com) for further security guidance. In particular, look up Web Gateway security and IRIS container passwords, or follow these links:

IRIS containers and password authentication: 
https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=ADOCK#ADOCK_iris_images_password_auth
 
Web Gateway security:
https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=ADOCK#ADOCK_iris_webgateway_security
 

