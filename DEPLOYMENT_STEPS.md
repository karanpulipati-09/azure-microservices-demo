# Azure Microservices Deployment — Complete Steps

## Prerequisites
- Azure subscription (ID: `6e4ced83-d303-4f8f-ae15-4cdfad7d271a`)
- GitHub account with admin access to `karanpulipati-09/azure-microservices-demo`
- Azure CLI installed locally (or use Azure Portal)

---

## Step 1: Create Azure AD App Registration for GitHub OIDC

### Option A: Using Azure Portal

1. Go to [Azure Portal](https://portal.azure.com) → **Azure Active Directory** → **App registrations**
2. Click **+ New registration**
3. Fill in:
   - **Name**: `github-actions-aks` (or similar)
   - **Supported account types**: "Accounts in this organizational directory only"
4. Click **Register**
5. On the app overview page, note:
   - **Application (client) ID** → save as `AZURE_CLIENT_ID`
   - **Directory (tenant) ID** → save as `AZURE_TENANT_ID`

### Option B: Using Azure CLI

```bash
# Create app registration
az ad app create --display-name github-actions-aks

# Get Application ID
AZURE_CLIENT_ID=$(az ad app list --display-name github-actions-aks --query [].appId -o tsv)

# Get Tenant ID
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)

echo "AZURE_CLIENT_ID=$AZURE_CLIENT_ID"
echo "AZURE_TENANT_ID=$AZURE_TENANT_ID"
```

---

## Step 2: Add GitHub OIDC Federated Credential

### Using Azure Portal

1. In the app registration, go to **Certificates & secrets** → **Federated credentials**
2. Click **+ Add credential**
3. Select **GitHub Actions deploying Azure resources**
4. Fill in:
   - **Organization**: `karanpulipati-09`
   - **Repository**: `azure-microservices-demo`
   - **Entity type**: `Branch`
   - **GitHub ref**: `refs/heads/main`
5. Click **Add**

### Using Azure CLI

```bash
AZURE_CLIENT_ID="<your-client-id>"
AZURE_TENANT_ID="<your-tenant-id>"

# Create federated credential
az ad app federated-credential create \
  --id "$AZURE_CLIENT_ID" \
  --parameters '{
    "name": "github-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:karanpulipati-09/azure-microservices-demo:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

---

## Step 3: Grant IAM Roles to the App

### Using Azure Portal

1. Go to **Subscriptions** → select your subscription (`6e4ced83-d303-4f8f-ae15-4cdfad7d271a`)
2. Click **Access control (IAM)** → **+ Add** → **Add role assignment**
3. Select **Contributor** role (or **Owner** if you need to manage role assignments)
4. Go to **Members** tab → **+ Select members**
5. Search for your app name (`github-actions-aks`) and select it
6. Click **Review + assign**

### Using Azure CLI

```bash
AZURE_CLIENT_ID="<your-client-id>"
SUBSCRIPTION_ID="6e4ced83-d303-4f8f-ae15-4cdfad7d271a"

# Get the service principal object ID
OBJECT_ID=$(az ad app show --id "$AZURE_CLIENT_ID" --query id -o tsv)

# Assign Contributor role
az role assignment create \
  --role Contributor \
  --assignee "$OBJECT_ID" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

---

## Step 4: Add GitHub Repository Secrets

1. Go to GitHub repo: `https://github.com/karanpulipati-09/azure-microservices-demo`
2. Click **Settings** → **Secrets and variables** → **Actions** → **Repository secrets**
3. Click **New repository secret** and add:

   | Secret Name | Value |
   |---|---|
   | `AZURE_CLIENT_ID` | The Application (client) ID from Step 1 |
   | `AZURE_TENANT_ID` | The Directory (tenant) ID from Step 1 |
   | `AZURE_SUBSCRIPTION_ID` | `6e4ced83-d303-4f8f-ae15-4cdfad7d271a` |

4. Click **Add secret** for each

---

## Step 5: Trigger Terraform Apply Workflow

### Option A: Push to Main

```bash
# Clone and navigate to repo
git clone https://github.com/karanpulipati-09/azure-microservices-demo.git
cd azure-microservices-demo

# Make a minor commit to trigger workflows
echo "# Deployment started" >> README.md
git add README.md
git commit -m "chore: trigger deployment workflows"
git push origin main
```

### Option B: Manually Trigger via GitHub Actions

1. Go to GitHub repo → **Actions**
2. Click **Terraform Apply** workflow
3. Click **Run workflow** → **Run workflow**

---

## Step 6: Monitor Terraform Apply

1. Go to GitHub repo → **Actions**
2. Click the latest **Terraform Apply** run
3. Wait for all steps to complete:
   - ✓ Check for required secrets
   - ✓ Azure Login (OIDC)
   - ✓ Setup Terraform
   - ✓ Terraform Init
   - ✓ Terraform Apply

**Expected output:**
- Resource group created: `rg-aks-staging`
- AKS cluster created: `aks-staging` (3 nodes)
- ACR created: `aksstagingacr6e4ced83`
- Log Analytics workspace created

---

## Step 7: Verify Infrastructure

### Via Azure Portal

1. Go to **Resource groups** → **rg-aks-staging**
2. Verify resources are present:
   - AKS cluster: `aks-staging`
   - Container Registry: `aksstagingacr6e4ced83`
   - Log Analytics Workspace: `aks-staging-law`

### Via Azure CLI

```bash
SUBSCRIPTION_ID="6e4ced83-d303-4f8f-ae15-4cdfad7d271a"
RG_NAME="rg-aks-staging"

# Set subscription
az account set --subscription "$SUBSCRIPTION_ID"

# List resources in resource group
az resource list --resource-group "$RG_NAME" -o table

# Get AKS cluster info
az aks show --name aks-staging --resource-group "$RG_NAME" --query "{name, state: powerState.code}"

# Get ACR info
az acr show --name aksstagingacr6e4ced83 --resource-group "$RG_NAME" --query "{name, loginServer}"
```

---

## Step 8: Get Kubeconfig

### Via Azure CLI

```bash
az aks get-credentials \
  --resource-group rg-aks-staging \
  --name aks-staging \
  --file kubeconfig.yaml

# Verify connection
kubectl --kubeconfig=kubeconfig.yaml cluster-info
```

---

## Step 9: Deploy Helm Charts (Optional)

Once AKS is running and you have kubeconfig:

```bash
# Create namespaces and RBAC
kubectl apply -f k8s/namespaces-podsecurity.yaml
kubectl apply -f k8s/serviceaccounts-rbac.yaml
kubectl apply -f k8s/networkpolicy-default-deny.yaml

# Deploy frontend and API via Helm
helm install frontend ./helm/frontend -n frontend
helm install api ./helm/api -n api

# Verify deployments
kubectl get deployments -n frontend
kubectl get deployments -n api
```

---

## Troubleshooting

### Workflow fails: "Missing required secrets"
- **Cause**: GitHub secrets not configured
- **Fix**: Complete Step 4 above and verify secrets are present in repository settings

### Azure Login fails: "Not all values are present"
- **Cause**: OIDC federated credential not configured
- **Fix**: Complete Step 2 and ensure the GitHub ref matches exactly (e.g., `refs/heads/main`)

### Terraform Apply fails: "Insufficient permissions"
- **Cause**: App registration not granted IAM roles
- **Fix**: Complete Step 3 and ensure the Contributor role is assigned

### Terraform Apply fails: "subscription not found"
- **Cause**: Subscription ID mismatch or app doesn't have access
- **Fix**: Verify AZURE_SUBSCRIPTION_ID in GitHub secrets matches `6e4ced83-d303-4f8f-ae15-4cdfad7d271a`

---

## Next: CI/CD for Application Builds

Once infrastructure is ready:

1. Add `Dockerfile` files for frontend and api services to repo
2. Push to main → **Build and Push** workflow automatically builds & pushes images to ACR
3. Update Helm values with image tags from ACR
4. Deploy to AKS

---

## Support

Refer to:
- `bootstrap/github-oidc-setup.md` — Detailed OIDC setup
- `docs/SETUP.md` — Quick start guide
- `docs/AWS_AZURE_MAPPING.md` — AWS ↔ Azure equivalents
