# Azure Infrastructure

This repository contains Infrastructure as Code (IaC) for deploying secure, compliant Azure infrastructure suitable for UK Financial Services Institutions (FSI). The solution implements PRA/FCA requirements for cloud outsourcing and operational resilience.

## 📋 Overview

The infrastructure deploys:
- **Resource Group** in UK Azure regions (UK South/UK West)
- **App Service** (Linux) for Node.js applications with VNet integration
- **Azure SQL Database** with private endpoints and advanced security
- **Cosmos DB** with private endpoints and geo-replication
- **Virtual Network** with subnets, NSGs, and private DNS zones
- **Log Analytics & Monitoring** with comprehensive alerting
- **RBAC** implementation for Azure AD groups

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Resource Group (UK)                     │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Virtual Network (10.0.0.0/16)            │  │
│  │  ┌──────────────┐  ┌───────────┐  ┌──────────────┐    │  │
│  │  │ App Subnet   │  │ PE Subnet │  │  DB Subnet   │    │  │
│  │  │ (Delegated)  │  │           │  │ (Endpoints)  │    │  │
│  │  └──────────────┘  └───────────┘  └──────────────┘    │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────┐         ┌─────────────────────────────┐   │
│  │  App Service │◄────────┤   Application Insights      │   │
│  │  (Node.js)   │         └─────────────────────────────┘   │
│  └──────┬───────┘                                           │
│         │                                                   │
│         ▼                                                   │
│  ┌────────────────────┐        ┌────────────────────────┐   │
│  │  SQL Database      │        │    Cosmos DB           │   │
│  │  (Private Endpoint)│        │  (Private Endpoint)    │   │
│  └────────────────────┘        └────────────────────────┘   │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Log Analytics Workspace + Azure Sentinel              │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🔒 Security & Compliance Features

### PRA/FCA Compliance
- ✅ **Data Residency**: All resources deployed in UK regions only
- ✅ **Access Control**: RBAC with Azure AD integration
- ✅ **Encryption**: TLS 1.2+ enforced, data encryption at rest
- ✅ **Network Security**: Private endpoints, NSGs, VNet integration
- ✅ **Monitoring & Audit**: Comprehensive logging and alerting
- ✅ **Backup & Recovery**: Geo-redundant backups, PITR enabled
- ✅ **Vulnerability Management**: SQL vulnerability assessments
- ✅ **Operational Resilience**: Zone redundancy, autoscaling

### Security Controls
1. **Network Isolation**
   - Private endpoints for databases
   - VNet integration for App Service
   - NSG rules restricting traffic
   - No public database access

2. **Identity & Access**
   - Managed identities for resources
   - Azure AD authentication
   - Role-based access control
   - Least privilege principle

3. **Data Protection**
   - TLS 1.2 minimum version
   - Transparent Data Encryption (SQL)
   - Encrypted backups
   - Secure key management

4. **Monitoring & Compliance**
   - 90-day log retention
   - Security alerts and notifications
   - Azure Sentinel integration
   - Audit logging enabled

## 📁 Repository Structure

```
.
├── terraform/
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output values
│   ├── modules/
│   │   ├── resource-group/     # Resource group module
│   │   ├── networking/         # VNet, subnets, NSGs
│   │   ├── app-service/        # App Service with autoscaling
│   │   ├── sql-database/       # SQL with private endpoint
│   │   ├── cosmos-db/          # Cosmos DB with replication
│   │   ├── monitoring/         # Log Analytics & alerts
│   │   └── rbac/               # Role assignments
│   └── environments/
│       ├── dev/                # Development configuration
│       ├── staging/            # Staging configuration
│       └── prod/               # Production configuration
│
│
└── docs/
    ├── TERRAFORM_DEPLOYMENT.md
    ├── OPERATIONS_GUIDE.md
    └── COMPLIANCE_GUIDE.md
```

## 🚀 Quick Start

### Prerequisites

**For Terraform:**
- Terraform >= 1.5.0
- Azure CLI >= 2.50.0
- Azure subscription with appropriate permissions

### Terraform Deployment

```bash
# Navigate to Terraform directory
# Initialize Terraform
terraform init

# Select environment
cd environments/dev  # or staging/prod

# Review planned changes
terraform plan -var-file=terraform.tfvars

# Deploy infrastructure
terraform apply -var-file=terraform.tfvars

# View outputs
terraform output
```

## 🌍 Environment Configurations

### Development
- **Purpose**: Development and testing
- **Cost Optimization**: Basic/B-series SKUs
- **Redundancy**: Single region, no zone redundancy
- **Backup**: 7-day retention
- **Scaling**: Limited autoscaling (1-2 instances)

### Staging
- **Purpose**: Pre-production validation
- **Configuration**: Production-like setup
- **Redundancy**: Single region with geo-backup
- **Backup**: 14-day retention
- **Scaling**: Moderate autoscaling (2-4 instances)

### Production
- **Purpose**: Production workloads
- **Configuration**: Premium SKUs
- **Redundancy**: Zone redundant, multi-region
- **Backup**: 35-day retention + LTR
- **Scaling**: Full autoscaling (3-10 instances)

## 🔧 Configuration

### Required Variables

**Essential Configuration:**
- `project_name`: Project identifier (3-20 chars)
- `environment`: Environment name (dev/staging/prod)
- `location`: Azure region (uksouth/ukwest)
- `alert_email`: Email for monitoring alerts

**Security Configuration:**
- `sql_admin_password`: SQL Server admin password (secure)
- `azureAdAdminObjectId`: Azure AD admin object ID
- Azure AD group IDs for RBAC (optional)

### Optional Enhancements

1. **Custom Domain**: Add custom domain to App Service
2. **Key Vault Integration**: Store secrets in Key Vault
3. **Application Gateway**: Add WAF protection
4. **DDoS Protection**: Enable DDoS standard
5. **Azure Front Door**: Add global load balancing

## 📊 Monitoring & Alerts

### Built-in Alerts
- App Service CPU/Memory > 80%
- HTTP 5xx errors > 10/5min
- SQL DTU consumption > 80%
- SQL deadlocks detected
- Cosmos DB availability < 99%
- Cosmos DB high latency
- Security configuration changes

### Log Analytics Queries
Access pre-configured queries for:
- Security events
- Performance metrics
- Application logs
- Database operations
- Compliance auditing

## 🔐 RBAC Roles

### Pre-configured Groups
1. **Developers**: Contributor on resource group
2. **DBAs**: SQL Security Manager + Cosmos DB contributor
3. **Operations**: Monitoring + Website contributor
4. **Auditors**: Reader + Log Analytics reader

### Application Identities
- App Service → SQL Database (SQL DB Contributor)
- App Service → Cosmos DB (Cosmos DB Account Reader)

## 💰 Cost Optimization

### Development Environment
- Estimated: £150-250/month
- App Service: B2 (£58/month)
- SQL: Basic (£4/month)
- Cosmos DB: Serverless (usage-based)

### Production Environment
- Estimated: £800-1200/month
- App Service: P2v3 (£160/month)
- SQL: BC_Gen5_4 (£650/month)
- Cosmos DB: Autoscale (usage-based)

**Cost Reduction Tips:**
1. Use dev/test pricing for non-production
2. Enable autoscaling to scale down during off-hours
3. Use reserved instances for production
4. Regular review of unused resources


## ⚠️ Important Notes

1. **Secrets Management**: Never commit secrets to repository. Use Azure Key Vault or environment variables.
2. **State Management**: Configure remote state storage for production (Azure Storage Account).
3. **Cost Monitoring**: Set up budgets and cost alerts in Azure portal.

## 🔗 Useful Links

- [PRA Supervisory Statement SS2/21](https://www.bankofengland.co.uk/prudential-regulation/publication/2021/march/outsourcing-and-third-party-risk-management-ss)
- [Azure UK regions](https://azure.microsoft.com/en-gb/explore/global-infrastructure/geographies/#geographies)
- [Azure Security Best Practices](https://docs.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---
