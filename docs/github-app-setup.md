# GitHub App setup for cross-repo deploy dispatch

Replace the personal access token (`INFRA_REPO_DISPATCH_TOKEN`) with a GitHub App for least-privilege cross-repo access.

## 1. Create the app

1. GitHub → **Settings** → **Developer settings** → **GitHub Apps** → **New GitHub App**
2. Name: `mhcet-deploy-bot`
3. Homepage: your repo URL
4. Uncheck **Webhook** → **Active**
5. Permissions → **Repository**:
   - **Actions**: Read and write
   - **Contents**: Read and write (required for `repository_dispatch`)
   - **Metadata**: Read-only (default)
6. **Where can this app be installed?** → Only on this account
7. Create app → **Generate a private key** (download `.pem`)

## 2. Install the app

Install on both repositories:

- `Shreyas-Yadav/mhcet`
- `Shreyas-Yadav/mhcet-infra`

## 3. Configure `mhcet` (app repo)

| Type | Name | Value |
|------|------|-------|
| Variable | `GH_APP_ID` | App ID from app settings page |
| Secret | `GH_APP_PRIVATE_KEY` | Full contents of the `.pem` file |

After this works, remove `INFRA_REPO_DISPATCH_TOKEN` (optional but recommended).

## 4. Verify

Push to `dev` in `mhcet`. The build workflow should dispatch `deploy-app-dev` without the PAT fallback warning.

## Permissions summary

| Permission | Access | Why |
|------------|--------|-----|
| Contents | Read and write | Required to call `POST /repos/.../dispatches` |
| Actions | Read and write | Required for the triggered workflow to run |
| Metadata | Read-only | Default; required for API access |

After changing app permissions, open **Install App** → your account → **Configure** → review and **Accept new permissions** if prompted.
