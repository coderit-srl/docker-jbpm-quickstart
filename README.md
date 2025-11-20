# jBPM Server with Keycloak Integration

A comprehensive Docker-based setup for running jBPM (Business Process Management) with Keycloak authentication and PostgreSQL database.

## Overview

This project provides a fully containerized jBPM environment with:
- **jBPM Server** - Business process management platform based on Wildfly
- **Keycloak** - Identity and access management (IAM) for authentication
- **PostgreSQL** - Database backend for both jBPM and Keycloak

## Architecture

The system consists of three main services orchestrated via Docker Compose:

```
┌─────────────────┐
│   jBPM Server   │
│   Port: 8080    │ ──┐
│   Port: 9990    │   │
└─────────────────┘   │
                      │
┌─────────────────┐   │    ┌──────────────┐
│    Keycloak     │   ├───▶│  PostgreSQL  │
│   Port: 9080    │   │    │  Port: 5432  │
│   Port: 9443    │   │    └──────────────┘
└─────────────────┘   │
                      │
                    Network: jbpm-network
```

## Prerequisites

- Docker (version 20.10 or higher)
- Docker Compose (version 2.0 or higher)
- 4GB+ RAM available for containers
- Ports available: 5432, 8080, 8001, 9080, 9443, 9990

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd jbpm
   ```

2. **Configure hosts file for Keycloak SSO**

   Add the following entry to your hosts file to enable Keycloak SSO:

   **Linux/Mac:**
   ```bash
   sudo bash -c 'echo "127.0.0.1 keycloak.internal" >> /etc/hosts'
   ```

   **Windows (as Administrator):**
   ```powershell
   Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.1 keycloak.internal"
   ```

   Or manually edit:
   - Linux/Mac: `/etc/hosts`
   - Windows: `C:\Windows\System32\drivers\etc\hosts`

   Add this line:
   ```
   127.0.0.1 keycloak.internal
   ```

3. **Start all services**
   ```bash
   docker-compose up -d
   ```

4. **Wait for services to initialize**
   The first startup may take 2-3 minutes. Monitor with:
   ```bash
   docker-compose logs -f
   ```

5. **Access the applications**
   - jBPM Business Central: http://localhost:8080/business-central
   - jBPM Case Management: http://localhost:8080/jbpm-casemgmt
   - KIE Server: http://localhost:8080/kie-server
   - Keycloak Admin: http://localhost:9080

## User Accounts

### Keycloak Admin Console
Access: http://localhost:9080

| Username | Password | Description |
|----------|----------|-------------|
| admin | admin | Keycloak administrator |

### jBPM Applications
Access: http://localhost:8080/business-central

All jBPM users authenticate through Keycloak. The following pre-configured users are available:

| Username  | Password    | Roles                                             | Description                                   |
|-----------|-------------|---------------------------------------------------|-----------------------------------------------|
| wbadmin   | wbadmin     | admin, kiemgmt, rest-all, kie-server, realm-admin | Workbench administrator with full permissions |
| gio       | gio         | admin, kiemgmt, rest-all, kie-server              | General administrator user                    |
| kieserver | kieserver1! | admin, kiemgmt, rest-all, kie-server              | Service account for KIE Server operations     |

**Note**: Passwords are hashed in the Keycloak export. To reset passwords:
1. Log into Keycloak Admin Console (http://localhost:9080)
2. Navigate to: Realm: jbpm → Users
3. Select user → Credentials tab
4. Set new password

### Database Accounts

| Service          | Username | Password | Database |
|------------------|----------|----------|----------|
| jBPM             | jbpm     | jbpm     | jbpm     |
| Keycloak         | keycloak | keycloak | keycloak |
| PostgreSQL Admin | jbpm     | jbpm     | postgres |

## Service Details

### jBPM Server
- **Base Image**: `quay.io/kiegroup/jbpm-server-full:latest`
- **Port 8080**: Web applications (Business Central, Case Management, KIE Server)
- **Port 9990**: Wildfly management console
- **Port 8001**: SSH Git access (localhost only)

**Applications**:
- Business Central: Process authoring and management UI
- Case Management: Case-based process management
- KIE Server: Execution server with REST API

**Persistent Volumes**:
- `./data/wb_git` - Git repository for business assets
- `./data/jbpm_m2_repository` - Maven repository cache
- `./data/jbpm_data` - Runtime data

### Keycloak
- **Base Image**: `quay.io/keycloak/keycloak:18.0`
- **Port 9080**: HTTP interface
- **Port 9443**: HTTPS interface (self-signed certificate)
- **Realm**: jbpm

**Security Features**:
- JWT token-based authentication
- Basic auth support via Direct Access Grant
- Resource-based role mappings
- Self-signed SSL certificate for internal communication

**Client Applications**:
- `kie` - Business Central client
- `kie-execution-server` - KIE Server client
- `kie-git` - Git SSH authentication client

### PostgreSQL
- **Image**: `postgres:15-alpine`
- **Port**: 5432
- **Databases**: jbpm, keycloak

## Configuration Files

### Docker Configuration
- `docker-compose.yml` - Service orchestration
- `Dockerfile` - jBPM server custom build
- `keycloak.Dockerfile` - Keycloak custom build with SSL
- `.dockerignore` - Docker build exclusions

### jBPM Configuration
- `jbpm-config/kie-git.json` - Keycloak client config for Git SSH
- `scripts/start_jbpm-wb.sh` - Startup script with Keycloak integration
- `scripts/jbpm-keycloak-setup.cli` - Wildfly CLI for Keycloak adapter
- `scripts/custom.cli` - Custom Wildfly configuration
- `scripts/setup-wildfly.sh` - Wildfly setup helper

### Keycloak Configuration
- `keycloak-config/realms-export/jbpm-realm.json` - Realm definition
- `keycloak-config/realms-export/jbpm-users-0.json` - Pre-configured users
- `keycloak-config/keycloak.keystore` - SSL certificate (self-signed)

### Database Configuration
- `postgres-config/init-db.sql` - Database initialization script

## Environment Variables

### jBPM Server
```yaml
JBPM_DB_DRIVER: postgres
JBPM_DB_HOST: postgres
JBPM_DB_PORT: 5432
JBPM_DB_NAME: jbpm
JBPM_DB_USER: jbpm
JBPM_DB_PASSWORD: jbpm
KIE_SERVER_ID: jbpm-server
KEYCLOAK_URL: https://keycloak.internal:9443
JAVA_OPTS: -Xms1024m -Xmx2048m
```

### Keycloak
```yaml
KC_DB: postgres
KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
KC_DB_USERNAME: keycloak
KC_DB_PASSWORD: keycloak
KEYCLOAK_ADMIN: admin
KEYCLOAK_ADMIN_PASSWORD: admin
KC_HOSTNAME: localhost
```

## Network Architecture

All services communicate on the `jbpm-network` bridge network:

- **Hostname Resolution**:
  - `postgres` → PostgreSQL database
  - `keycloak`, `keycloak.internal` → Keycloak server
  - `jbpm` → jBPM server

- **SSL/TLS**: Keycloak uses self-signed certificates. jBPM trusts these via a custom keystore at `/opt/jboss/keycloak.keystore`

## Development Workflow

### Starting Services
```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d postgres
docker-compose up -d keycloak
docker-compose up -d jbpm

# View logs
docker-compose logs -f jbpm
```

### Stopping Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: deletes all data)
docker-compose down -v
```

### Rebuilding Images
```bash
# Rebuild jBPM server
docker-compose build jbpm

# Rebuild Keycloak
docker-compose build keycloak

# Rebuild and restart
docker-compose up -d --build
```

### Accessing Containers
```bash
# Access jBPM container
docker exec -it jbpm-server bash

# Access Keycloak container
docker exec -it jbpm-keycloak bash

# Access PostgreSQL
docker exec -it jbpm-postgres psql -U jbpm -d jbpm
```

## Troubleshooting

### Services Won't Start
1. Check port availability: `netstat -an | grep -E "(5432|8080|9080|9443|9990)"`
2. Ensure Docker daemon is running
3. Check logs: `docker-compose logs`

### Keycloak Connection Issues
- Verify Keycloak is healthy: `docker-compose ps`
- Check certificate trust: `docker logs jbpm-server | grep -i ssl`
- Ensure hostname resolution: `docker exec jbpm-server ping keycloak.internal`

### Database Connection Failed
- Check PostgreSQL health: `docker-compose ps postgres`
- Verify credentials in docker-compose.yml
- Check database logs: `docker-compose logs postgres`

### jBPM Won't Authenticate
- Verify Keycloak realm is imported: `docker-compose logs keycloak | grep "jbpm"`
- Check client secrets match in:
  - `scripts/jbpm-keycloak-setup.cli`
  - `jbpm-config/kie-git.json`
  - Keycloak Admin Console → Clients

### Reset Everything
```bash
# Stop and remove all containers and volumes
docker-compose down -v

# Remove local data directories (optional)
rm -rf data/jbpm_data/* data/wb_git/* data/jbpm_m2_repository/*

# Restart
docker-compose up -d
```

## Security Considerations

## Technology Stack

- **jBPM**: Business Process Management platform (KIE group)
- **Wildfly**: Java EE application server
- **Keycloak 18.0**: Identity and Access Management
- **PostgreSQL 15**: Relational database
- **Docker & Docker Compose**: Containerization
- **Java**: Runtime environment

## Roles and Permissions

### jBPM Roles (Keycloak)
- `admin` - Full administrative access
- `kiemgmt` - KIE management permissions
- `rest-all` - Full REST API access
- `kie-server` - KIE Server execution permissions
- `realm-admin` - Keycloak realm administration (wbadmin only)

### Role Mappings
Roles are mapped at both realm and client levels in Keycloak. The configuration uses resource-level role mappings for fine-grained access control.

## License

Please refer to the upstream project licenses:
- jBPM: Apache License 2.0
- Keycloak: Apache License 2.0
- PostgreSQL: PostgreSQL License

## Support and Resources

- jBPM Documentation: https://docs.jbpm.org/
- Keycloak Documentation: https://www.keycloak.org/documentation
- Docker Compose: https://docs.docker.com/compose/

---

**Version**: 1.0
**Last Updated**: 2025-01-20
**Maintained by**: Development Team
