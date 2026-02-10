# PRA/FCA Compliance Settings — WSB Azure Infrastructure

This document describes the security and compliance controls implemented across the WSB Azure infrastructure to align with **PRA (Prudential Regulation Authority)** and **FCA (Financial Conduct Authority)** regulatory requirements for UK Financial Services Institutions.

---

## 1. UK Data Residency

All resources are deployed exclusively to UK Azure regions to satisfy data sovereignty requirements.

| Setting | Where Configured | Value |
|---|---|---|
| Resource Group location | `variables.tf` — `location` validation | `uksouth` or `ukwest` only |
| Primary region | `terraform.tfvars` | `uksouth` |
| Cosmos DB failover region | `terraform.tfvars` — `cosmos_failover_location` | `ukwest` |
| SQL geo-backup storage | `sql_database/main.tf` — `storage_account_type` | `Geo` (UK region pair) |
| Cosmos DB backup storage | `cosmos_db/main.tf` — `backup.storage_redundancy` | `Geo` (UK region pair) |
| SQL audit storage replication | `sql_database/main.tf` — `account_replication_type` | `GRS` (Geo-Redundant) |
| Compliance tag on all resources | `main.tf` — `common_tags` | `DataResidency = "UK"` |

---

## 2. Encryption in Transit

All services enforce TLS 1.2 as the minimum transport layer security version, preventing the use of older, vulnerable protocols.

| Resource | Setting | Value | File |
|---|---|---|---|
| SQL Server | `minimum_tls_version` | `1.2` | `sql_database/main.tf` |
| App Service | `minimum_tls_version` | `1.2` | `app_service/main.tf` |
| App Service SCM | `scm_minimum_tls_version` | `1.2` | `app_service/main.tf` |
| App Service | `https_only` | `true` | `app_service/main.tf` |
| App Service | `ftps_state` | `Disabled` | `app_service/main.tf` |
| SQL Audit Storage | `min_tls_version` | `TLS1_2` | `sql_database/main.tf` |
| SQL Audit Storage | `https_traffic_only_enabled` | `true` | `sql_database/main.tf` |

---

## 3. Encryption at Rest

| Resource | Mechanism | Details |
|---|---|---|
| SQL Database | Transparent Data Encryption (TDE) | Enabled by default on Azure SQL |
| Cosmos DB | Service-managed encryption | Enabled by default on Cosmos DB |
| Key Vault | Software-protected keys | HSM-backed vault (`standard` SKU) |
| SQL Audit Storage | Azure Storage Service Encryption | Enabled by default |

---

## 4. Network Isolation

All data services are isolated behind private endpoints, removing public internet exposure. Traffic flows over the Azure backbone via Private Link.

### 4.1 Private Endpoints

| Service | Private Endpoint | Private DNS Zone | File |
|---|---|---|---|
| SQL Server | `sql-pe` | `privatelink.database.windows.net` | `sql_database/main.tf` |
| Cosmos DB | `cosmos-pe` | `privatelink.documents.azure.com` | `cosmos_db/main.tf` |
| Key Vault | `kv-pe` | `privatelink.vaultcore.azure.net` | `key_vault/main.tf` |

### 4.2 Public Access Disabled

| Resource | Setting | Value | File |
|---|---|---|---|
| SQL Server | `public_network_access_enabled` | `false` | `sql_database/main.tf` |
| Cosmos DB | `public_network_access_enabled` | `false` | `cosmos_db/main.tf` |
| SQL Audit Storage | `allow_nested_items_to_be_public` | `false` | `sql_database/main.tf` |

### 4.3 Network Segmentation

The VNet is segmented into dedicated subnets with Network Security Groups (NSGs) enforcing traffic rules:

| Subnet | Purpose | NSG | Key Rules |
|---|---|---|---|
| App subnet | App Service integration | `nsg_app` | Allow HTTPS/HTTP inbound, deny all else |
| PE subnet | Private Endpoints | — | Isolated for private connectivity |
| DB subnet | Database services | `nsg_db` | Allow SQL (1433) and Cosmos (443) from App subnet only, deny all else |

**Production hardening**: The production `nsg_app_rules` only permit HTTPS (port 443) — HTTP (port 80) is not allowed, unlike dev/staging.

### 4.4 Default Deny

All NSGs include a final **Deny-All-Inbound** rule at priority 4096, implementing a default-deny posture.

### 4.5 Key Vault Network ACLs

| Setting | Value | Purpose |
|---|---|---|
| `bypass` | `AzureServices` | Allow trusted Azure services |
| `default_action` | Configurable per environment | `Allow` for PoC, `Deny` recommended for production |
| `ip_rules` | Configurable | Restrict to known IP ranges |

---

## 5. Secret Management

Secrets are managed centrally in Azure Key Vault rather than being hardcoded or generated in-line.

| Control | Implementation | File |
|---|---|---|
| SQL admin password | Generated via `random_password`, stored in Key Vault | `key_vault/main.tf` |
| Password complexity | 32 characters, special characters included | `main.tf` — Key Vault `secrets` block |
| Password persistence | Stored in Key Vault; `keepers` block prevents regeneration | `key_vault/main.tf` |
| Soft delete | 90-day retention | `key_vault/main.tf` — `soft_delete_retention_days = 90` |
| Purge protection | Enabled in production (`var.environment == "production"`) | `main.tf` |
| Sensitive outputs | `sensitive = true` on all secret-containing outputs | Various `outputs.tf` files |

---

## 6. Identity and Access Management

### 6.1 Managed Identities (Zero-credential services)

All application services use **System-Assigned Managed Identities**, eliminating the need for stored credentials:

| Resource | Identity Type | File |
|---|---|---|
| App Service | `SystemAssigned` | `app_service/main.tf` |
| SQL Server | `SystemAssigned` | `sql_database/main.tf` |
| Cosmos DB | `SystemAssigned` | `cosmos_db/main.tf` |

### 6.2 Azure AD Authentication for SQL

| Setting | Value | File |
|---|---|---|
| `azuread_administrator` | Configured on SQL Server | `sql_database/main.tf` |

### 6.3 RBAC Role Assignments (when enabled)

The `rbac` module implements least-privilege access following separation of duties:

| Group | Role | Scope | Principle |
|---|---|---|---|
| App Service → Cosmos | Cosmos DB Account Reader | Cosmos DB account | Service-to-service |
| App Service → SQL | SQL DB Contributor | SQL Server | Service-to-service |
| Developers | Contributor | Resource Group | Development access |
| DBAs | SQL Security Manager | SQL Server | Database administration |
| DBAs | DocumentDB Account Contributor | Cosmos DB | Database administration |
| Operations | Monitoring Contributor | Resource Group | Operational monitoring |
| Operations | Website Contributor | App Service | Application management |
| Auditors | Reader | Resource Group | Read-only audit access |
| Auditors | Log Analytics Reader | Resource Group | Log review for compliance |

A **custom role** (`app-db-role`) is also defined for least-privilege application-to-database access, restricting actions to only the specific read/write operations needed.

---

## 7. Monitoring, Logging, and Alerting

Comprehensive monitoring satisfies PRA requirements for operational resilience and incident detection.

### 7.1 Centralised Logging

| Component | Retention | File |
|---|---|---|
| Log Analytics Workspace | 90 days | `monitoring/main.tf` |
| Application Insights | 90 days | `logging/main.tf` |
| SQL Audit Logs | 90 days | `sql_database/main.tf` |

### 7.2 Security Solutions

| Solution | Purpose | File |
|---|---|---|
| `Security` (OMSGallery) | Security event analysis | `monitoring/main.tf` |
| `SecurityInsights` (Azure Sentinel) | SIEM / threat detection | `monitoring/main.tf` |

### 7.3 Diagnostic Settings

Detailed logs are shipped to Log Analytics for all key services:

| Service | Log Categories | File |
|---|---|---|
| App Service | HTTPLogs, ConsoleLogs, AppLogs, **AuditLogs** | `logging/main.tf` |
| SQL Database | SQLInsights, AutomaticTuning, QueryStore, Errors, Timeouts, Blocks, **Deadlocks** | `sql_database/main.tf` |
| Cosmos DB | DataPlaneRequests, QueryRuntimeStatistics, PartitionKeyStatistics, **ControlPlaneRequests** | `cosmos_db/main.tf` |

### 7.4 Metric Alerts

| Alert | Metric | Threshold | Severity | File |
|---|---|---|---|---|
| CPU usage | `CpuPercentage` | > 80% | 2 (Warning) | `monitoring/main.tf` |
| Memory usage | `MemoryPercentage` | > 80% | 2 (Warning) | `monitoring/main.tf` |
| HTTP 5xx errors | `Http5xx` | > 10 | 1 (Error) | `monitoring/main.tf` |
| SQL DTU usage | `dtu_consumption_percent` | > 80% | 2 (Warning) | `monitoring/main.tf` |
| SQL deadlocks | `deadlock` | > 1 | 1 (Error) | `monitoring/main.tf` |
| Cosmos availability | `ServiceAvailability` | < 99% | 0 (Critical) | `monitoring/main.tf` |
| Cosmos latency | `ServerSideLatency` | > 1000ms | 2 (Warning) | `monitoring/main.tf` |

### 7.5 Activity Log Alerts

| Alert | Category | Scope | Purpose |
|---|---|---|---|
| Security events | `Security` | Subscription-wide | Detect security configuration changes |

### 7.6 Alert Notifications

All alerts route to an **Action Group** with email notification, ensuring the operations team is informed of incidents.

---

## 8. SQL Database Security

### 8.1 Advanced Threat Protection

| Control | Setting | File |
|---|---|---|
| Threat detection | `state = "Enabled"` | `sql_database/main.tf` |
| Email admins on threat | `email_account_admins = "Enabled"` | `sql_database/main.tf` |
| Threat log retention | 90 days | `sql_database/main.tf` |

### 8.2 Vulnerability Assessments

| Control | Setting | File |
|---|---|---|
| Recurring vulnerability scans | `enabled = true` | `sql_database/main.tf` |
| Email admins on scan results | `email_subscription_admins = true` | `sql_database/main.tf` |
| Scan results storage | Private storage account (HTTPS-only, TLS 1.2, GRS) | `sql_database/main.tf` |

### 8.3 Auditing

| Control | Setting | File |
|---|---|---|
| Extended auditing | `log_monitoring_enabled = true` | `sql_database/main.tf` |
| Audit retention | 90 days | `sql_database/main.tf` |
| Audit storage container | `container_access_type = "private"` | `sql_database/main.tf` |

### 8.4 Backup and Recovery

| Setting | Dev | Staging | Production |
|---|---|---|---|
| Short-term retention | 7 days | 14 days | 35 days |
| Long-term weekly | 4 weeks | 4 weeks | 4 weeks |
| Long-term monthly | 12 months | 12 months | 12 months |
| Long-term yearly | 7 years | 7 years | 7 years |
| Geo-redundant backup | No (cost saving) | Yes | Yes |

---

## 9. Cosmos DB Security

| Control | Setting | File |
|---|---|---|
| Automatic failover | `automatic_failover_enabled = true` | `cosmos_db/main.tf` |
| VNet filtering | `is_virtual_network_filter_enabled = true` | `cosmos_db/main.tf` |
| Public access | `public_network_access_enabled = false` | `cosmos_db/main.tf` |
| IP range filter | Empty (private endpoint only) | `cosmos_db/main.tf` |
| Backup type | Periodic | `cosmos_db/main.tf` |
| Backup geo-redundancy | `storage_redundancy = "Geo"` | `cosmos_db/main.tf` |

### Cosmos DB Backup Retention by Environment

| Setting | Dev | Staging | Production |
|---|---|---|---|
| Backup interval | 1440 min (24h) | 480 min (8h) | 240 min (4h) |
| Backup retention | 168 hrs (7d) | 336 hrs (14d) | 720 hrs (30d) |

---

## 10. Resource Tagging for Governance

Every resource is tagged with a standard set of governance metadata for cost management, ownership tracking, and compliance auditing:

| Tag | Purpose | Example Value |
|---|---|---|
| `Environment` | Identify deployment environment | `dev`, `staging`, `prod` |
| `ManagedBy` | Infrastructure management tool | `Terraform` |
| `Project` | Project identifier | `wsb` |
| `Compliance` | Regulatory framework | `PRA-FCA` |
| `DataResidency` | Data sovereignty region | `UK` |
| `CostCenter` | Billing allocation | `WSB-Infrastructure-Production` |
| `BusinessUnit` | Owning business unit | `Technology` |
| `Criticality` | Workload criticality | `Medium` / `High` / `Critical` |
| `Owner` | Responsible team | `Platform Team` |
| `DataClassification` | Data sensitivity (prod) | `Confidential` |

---

## 11. Infrastructure as Code Controls

| Control | Implementation |
|---|---|
| All infrastructure defined in Terraform | Prevents configuration drift |
| Resource group deletion protection | `prevent_deletion_if_contains_resources = true` |
| Key Vault soft delete protection | 90-day retention on deleted vaults and secrets |
| Purge protection | Enabled in production to prevent permanent deletion |
| State management | Backend configurable for remote state with locking |

---

## 12. Environment Differentiation

The infrastructure scales security controls based on environment criticality:

| Control | Dev | Staging | Production |
|---|---|---|---|
| Criticality tag | Medium | High | Critical |
| App Service SKU | F1 (Free) | S1 (Standard) | S1 (Standard) |
| App Service min instances | 1 | 2 | 3 |
| SQL SKU | Basic | GP_Gen5_2 | BC_Gen5_4 |
| SQL geo-backup | Disabled | Enabled | Enabled |
| SQL backup retention | 7 days | 14 days | 35 days |
| Cosmos max throughput | 1,000 RU/s | 4,000 RU/s | 10,000 RU/s |
| Cosmos backup interval | 24 hours | 8 hours | 4 hours |
| NSG HTTP allowed | Yes | Yes | **No (HTTPS only)** |
| Key Vault purge protection | Disabled | Disabled | **Enabled** |
| Data classification tag | — | — | **Confidential** |

---

## Summary

This infrastructure implements defence-in-depth with multiple overlapping controls:

1. **Data never leaves the UK** — All resources in `uksouth`/`ukwest` with geo-redundancy within UK region pairs
2. **All traffic encrypted** — TLS 1.2 minimum everywhere, HTTPS-only, FTPS disabled
3. **No public internet exposure** — Private endpoints for all data services, default-deny NSGs
4. **Secrets managed centrally** — Azure Key Vault with soft delete and purge protection
5. **Zero stored credentials** — Managed Identities for service-to-service authentication
6. **Comprehensive audit trail** — 90-day log retention, security solutions, diagnostic settings on all services
7. **Proactive threat detection** — SQL Advanced Threat Protection, vulnerability assessments, metric alerts
8. **Least-privilege access** — RBAC with separation of duties and custom roles
9. **Full governance tagging** — Every resource tagged for compliance, cost, and ownership tracking
10. **Immutable infrastructure** — All configuration managed via Terraform to prevent drift

