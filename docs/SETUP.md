# Azure setup quickstart

1. Configure GitHub OIDC federation (see bootstrap/github-oidc-setup.md).
2. Merge Terraform workflows to main to allow GitHub Actions to provision resources.
3. Build and push images to ACR, then deploy Helm charts to AKS.
