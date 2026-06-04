# Dev load testing (Terraform + Cloud Run Job)

Distributed stress test for the dev API: **17 parallel tasks × 300 requests ≈ 5100 total** (adjust via Terraform variables).

## Architecture

```text
Terraform (dev) → Cloud Run Job `dev-mhcet-load-test`
                 → 17 tasks in parallel (each runs stress.sh)
                 → HTTPS → Load Balancer → Cloud Armor → dev backend
```

Each task is a separate Cloud Run Job execution with its own egress IP (not guaranteed unique, but many more IPs than a laptop).

## One-time setup

### 1. Build the stress-test container

Push changes under `stress-test/` to `dev`, or run **Actions → Build Stress Test Image Dev → Run workflow**.

Image tags:

- `stress-test:dev-latest`
- `stress-test:dev-<sha>`

### 2. Enable in Terraform (dev only)

Edit `terraform/environments/dev/terraform.tfvars` (not committed — use your real tfvars):

```hcl
stress_test_enabled            = true
stress_test_runner_members     = ["user:you@example.com"]

# Optional: let most requests reach the backend during the test
rate_limit_requests_per_minute = 5000
```

Defaults (no tfvars override):

| Variable | Default | Meaning |
|----------|---------|---------|
| `stress_test_task_count` | 17 | Parallel tasks |
| `stress_test_requests_per_task` | 300 | Requests per task |
| **Total** | **5100** | Approximate load |
| `stress_test_concurrency` | 25 | Parallel curls per task |
| `rate_limit_requests_per_minute` | 100 | Cloud Armor per IP |

Apply via push to `infra` `dev` (`terraform/**`) or **Deploy Infra Dev** workflow.

### 3. Build image before first apply

The job references `…/stress-test:dev-latest`. Run the build workflow **once** before enabling `stress_test_enabled`, or the job will fail to start until the image exists.

## Run the test

### Option A — GitHub Actions

**Actions → Execute Stress Test Dev → Run workflow**

### Option B — gcloud

```bash
gcloud run jobs execute dev-mhcet-load-test \
  --project=mhcet-app \
  --region=asia-south1
```

After apply, Terraform prints the exact command:

```bash
cd terraform/environments/dev
terraform output stress_test_execute_command
terraform output stress_test_total_requests
```

### Logs

Cloud Console → **Logging** → filter:

```text
resource.type="cloud_run_job"
resource.labels.job_name="dev-mhcet-load-test"
```

Each task logs status code counts and `summary: ok=… limited=… unavailable=…`.

## Watch the backend during the test

- Cloud Run → `dev-mhcet-backend` → Metrics (latency, instances, CPU)
- `https://api-dev.shri.software/actuator/metrics` (after traffic)

## After the test

1. Set `rate_limit_requests_per_minute = 100` (if you raised it).
2. Optionally set `stress_test_enabled = false` to destroy the job and save cost.
3. Re-apply Terraform.

## Prod

Do **not** enable `stress_test` in prod. The module is wired only in `environments/dev`.

## Customize load

In `terraform.tfvars`:

```hcl
stress_test_task_count          = 20
stress_test_requests_per_task   = 250   # 20 × 250 = 5000 exactly
stress_test_parallelism         = 20
stress_test_api_path            = "/districts"
```

## Related app repo scripts

Local/manual testing (single IP, hits Armor quickly):

- `mhcet/scripts/stress-test-load.sh`
- `mhcet/scripts/stress-test-rate-limit.sh`
