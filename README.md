### Private AKS on Azure with Terraform managed by azd

This project deploys a secure, private Azure Kubernetes Service (AKS) cluster using Terraform, orchestrated end-to-end by the Azure Developer CLI (azd). It includes hub/spoke networking, a Log Analytics workspace, Azure Key Vault, and a private AKS control plane with user-defined routing.

---

### Prerequisites

- **Tools**
  - Azure Developer CLI (azd)
  - Azure CLI (az)
  - Terraform (matches version in CI: 1.13.x)

- **Azure setup**
  - An active Azure subscription with Owner/Contributor rights.
  - CI/CD authentication:
    - Recommended: GitHub OIDC federated credentials with the following repository/environment variables configured: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_LOCATION`, `AZURE_ENV_NAME`, `RS_RESOURCE_GROUP`, `RS_STORAGE_ACCOUNT`, `RS_CONTAINER_NAME`.
    - Alternative: A Service Principal JSON in a `AZURE_CREDENTIALS` secret (not used in current workflows but supported by azd/az).

---

### Repository structure

- `azure.yaml`: azd manifest. Declares Terraform as the infra provider and the project name `private-aks-cluster`.
- `infra/`: Terraform root (resource group, networking, AKS, Key Vault, Log Analytics, etc.).
  - `providers.tf`: Terraform version and backend (Azurerm remote state).
  - `main.tf`: Top-level modules and resources.
  - `variables.tf`: Inputs with sensible defaults (location, AKS sizing, networking, features).
  - `modules/*`: Reusable Terraform modules for AKS, VNet, node pools, LA workspace, Key Vault, etc.
- `.github/workflows/`
  - `azure-dev.yml`: Provisions on push to `main` (and manual dispatch) using azd + OIDC.
  - `azure-dev-down.yml`: Destroys on manual dispatch using azd.

---

### Configuration with azd

- Primary configuration lives in `azure.yaml` and the azd environment files created per environment.
- Create/select an environment:

```bash
azd env new <env-name>
# or
azd env select <env-name>
```

- Remote state: `infra/providers.tf` uses an Azurerm backend with names defined in code. Ensure the resource group, storage account, container, and key exist and match your environment. If you change backend names, update `infra/providers.tf` accordingly (or override during `terraform init` per your workflow).

---

### Deploy and destroy

- **Local (using azd)**

```bash
# Login (device code or browser)
azd auth login

# Provision infrastructure
azd up

# Destroy infrastructure
azd down
```

- **GitHub Actions (CI/CD)**
  - Provision: Automatically runs on push to `main` via `azure-dev.yml`. You can also trigger it manually (workflow_dispatch).
  - Destroy: Manually trigger `azure-dev-down.yml` (workflow_dispatch) to run `azd down` in CI.

Required repository/environment variables for CI:

```
AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID, AZURE_LOCATION, AZURE_ENV_NAME
```

---

### Connecting to the private AKS cluster

This AKS control plane is private; standard `kubectl` from the public internet will not work unless your client resolves the private FQDN and has network access to the VNet (e.g., via VPN/ExpressRoute/jump host). The most straightforward way to interact without direct network access is to use `az aks command invoke`, which executes `kubectl` server-side:

```bash
az aks command invoke \
  --resource-group <your-rg-name> \
  --name <your-aks-name> \
  --command "kubectl get nodes -o wide"
```

If you do have private network access and name resolution to the cluster’s private FQDN, you can use standard credentials:

```bash
az aks get-credentials --resource-group <your-rg-name> --name <your-aks-name> --admin --overwrite-existing
kubectl get nodes
```

The cluster’s private FQDN and other outputs are available from Terraform outputs in `infra/modules/aks/outputs.tf` (e.g., `private_fqdn`).

---

### Notable defaults and features

- Private cluster enabled with user-defined routing.
- Log Analytics integration with diagnostic categories enabled (API server, audit, scheduler, controller manager, autoscaler, defender/guard).
- Optional features toggled via variables: Azure Policy, Workload Identity and OIDC, KEDA, VPA, OSM, Image Cleaner.
- Separate user/system node pools; additional node pool module included.

---

### Troubleshooting tips

- Ensure remote state backend resources exist and the identity running Terraform has access.
- Confirm CI variables are set for OIDC login and backend (`RS_*`).
- Private access: If `kubectl` hangs/timeouts, use `az aks command invoke` or connect via a host within the VNet.


