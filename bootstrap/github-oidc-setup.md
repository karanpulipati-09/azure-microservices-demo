# GitHub OIDC setup for Azure

1. Create an Azure AD App Registration. Note the Application (client) ID and Tenant ID.
2. In the app registration, add a Federated credential for GitHub Actions (subject: repo:<owner>/<repo>:ref:refs/heads/main).
3. Grant the app the minimum role required (e.g., Contributor on the subscription or a custom role scoped to the resource group).
4. In GitHub Actions workflows, use azure/login with the federated credentials (client-id + tenant) to authenticate via OIDC. Do NOT store long-lived secrets.
