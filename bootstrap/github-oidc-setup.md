# GitHub OIDC setup for Azure

## Prerequisites
- Azure subscription with Owner or Contributor access
- GitHub repo admin access to add secrets and configure OIDC

## Steps

### 1. Create an Azure AD App Registration

1. Go to Azure Portal → Azure Active Directory → App Registrations → New registration
2. Enter app name (e.g., `github-actions-aks`)
3. Under "Supported account types", select "Accounts in this organizational directory only"
4. Click Register
5. Note the **Application (client) ID** and **Directory (tenant) ID** — you'll need these

### 2. Add Federated Credentials for GitHub OIDC

1. In the app registration, go to Certificates & secrets → Federated credentials
2. Click "Add credential"
3. Select "GitHub Actions deploying Azure resources"
4. Fill in:
   - **Organization**: `karanpulipati-09`
   - **Repository**: `azure-microservices-demo`
   - **Entity type**: `Environment` or `Branch`
   - **GitHub ref**: `refs/heads/main`
5. Click Add

### 3. Grant IAM Roles

1. Go to Subscriptions → select your subscription
2. Click "Access control (IAM)" → "+ Add" → "Add role assignment"
3. Select **Contributor** role (or a custom role scoped to the resource group `rg-aks-staging`)
4. Go to "Members" tab → "+ Select members" → search for your app name and select it
5. Click "Review + assign"

### 4. Add GitHub Secrets

In the GitHub repo settings (Settings → Secrets and variables → Actions → Repository secrets), add:

- `AZURE_CLIENT_ID`: Value from App Registration (client ID)
- `AZURE_TENANT_ID`: Value from App Registration (tenant ID)
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID (`6e4ced83-d303-4f8f-ae15-4cdfad7d271a`)

### 5. Verify Workflows

- The `terraform-plan.yml` workflow will run on PRs to validate infrastructure changes
- The `terraform-apply.yml` workflow will run on merges to `main` to apply changes
- The `build-push.yml` workflow will build and push Docker images to ACR using OIDC authentication

No long-lived secrets are stored; all authentication uses GitHub OIDC workload identity federation.
