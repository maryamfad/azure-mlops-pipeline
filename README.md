# Azure MLOps Pipeline: Credit Default Prediction

An end-to-end MLOps project on Microsoft Azure: data in ADLS Gen2, training and tracking in
Azure Machine Learning with MLflow, automated deployment to a managed online endpoint,
CI/CD with GitHub Actions, and infrastructure defined as code.

> **Status:** 🚧 In progress. See the [roadmap](#roadmap) for what's done.

## Problem

Predict whether a credit card client will default on next month's payment, using the
[UCI Default of Credit Card Clients](data/README.md) dataset (30,000 clients, 23 features).
The model itself is intentionally simple; the focus of this project is the **production
system around it**: reproducible training, versioned models, safe deployment and monitoring.

## Architecture

_Diagram coming in Week 10._

Planned flow: **ADLS Gen2** (raw data) → **Azure ML pipeline** (prep → train → evaluate) →
**MLflow model registry** → **managed online endpoint** (blue/green) → **Azure Monitor**,
all triggered by **GitHub Actions**.

## Tech stack

| Area | Tools |
|---|---|
| Cloud | Microsoft Azure |
| Data | Azure Data Lake Storage Gen2 |
| Training & tracking | Azure Machine Learning (SDK v2 / CLI v2), MLflow |
| Serving | Azure ML managed online endpoints |
| CI/CD | GitHub Actions with OIDC (no stored secrets) |
| Infrastructure | PowerShell + Azure CLI → Bicep (Week 7) |
| Security | Microsoft Entra ID, RBAC, managed identities |

## Repository structure

```
.
├── .github/workflows/   # CI/CD pipelines (Week 7)
├── data/                # Dataset notes; raw data is git-ignored
├── docs/                # Architecture diagrams and design notes
├── infra/               # Create / tear down Azure resources
├── notebooks/           # Exploration only; production code lives in src/
├── pipelines/           # Azure ML job and pipeline definitions (YAML)
├── scripts/             # Helper scripts (data download, etc.)
├── src/                 # Training, scoring and data-prep code
└── tests/               # Unit tests
```

## Getting started

### Prerequisites

- An Azure subscription and the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- Python 3.10+
- PowerShell (Windows) or PowerShell 7 (macOS/Linux)

### 1. Install dependencies and download the data

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1          # macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
python scripts/download_data.py
```

### 2. Create the Azure resources

```powershell
az login
.\infra\setup.ps1
```

This creates a resource group, an ADLS Gen2 storage account, grants you data access
through Entra ID (no account keys), and uploads the dataset.

### 3. Tear everything down

```powershell
.\infra\teardown.ps1
```

## Cost

Everything is created in one resource group so a single command removes it. Current
resources (storage only) cost well under $1 per month. Costs for compute and endpoints
will be documented here as they're added.

## Roadmap

- [x] **Week 1:** Repo structure, dataset, create/teardown scripts
- [ ] **Week 3:** Training job on Azure ML compute
- [ ] **Week 4:** MLflow tracking and model registry
- [ ] **Week 5:** Multi-step Azure ML pipeline
- [ ] **Week 6:** Managed online endpoint with blue/green deployment
- [ ] **Week 7:** GitHub Actions CI/CD and Bicep infrastructure
- [ ] **Week 10:** Tests, architecture diagram, final documentation

## Results

_Model metrics and screenshots will be added as the project progresses._

## Design decisions

- **Identity-based data access instead of storage keys:** no secrets to leak or rotate;
  access is granted and removed with RBAC.
- **ADLS Gen2:** hierarchical namespace for fast folder operations and folder-level ACLs,
  matching how production data lakes are built.
- **Deterministic resource names:** the storage account name includes part of the
  subscription ID, so scripts are repeatable without manual edits.
