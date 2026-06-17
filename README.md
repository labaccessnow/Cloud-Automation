# Cloud Automation

Multi-cloud automation and operations across AWS, Azure, GCP, and Oracle Cloud — provisioned as
code, monitored, and kept on a budget. Backed by 10+ cloud certifications.

## What it looks like in practice

Cost discipline belongs *in the code*, not in a monthly surprise. Tag everything on creation and
set a budget that pages you before the invoice does:

```hcl
provider "aws" {
  default_tags { tags = { owner = "netops", project = "lab", env = "nonprod" } }
}

resource "aws_budgets_budget" "monthly" {
  name         = "lab-monthly"
  budget_type  = "COST"
  limit_amount = "20"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
}
```

The same instinct on the ops side — a quick inventory of what's actually running (and billable)
across a tenancy:

```bash
oci search resource structured-search \
  --query-text "query instance resources where lifeCycleState = 'RUNNING'" \
  --query 'data.items[].\"display-name\"' --output table
```

## Best practices I follow
- **Everything as code; no console snowflakes.** Multi-account / landing zones from the start.
- **Least-privilege, short-lived credentials.** Scoped roles over standing admin keys.
- **Cost is attributable.** Tags + allocation so any resource answers "who owns this and what's
  it costing," and right-size continuously.
- **Observability and a status page next to the workload**, not bolted on after an outage.

## Lessons learned
- **"Always free" has teeth.** Oracle cut its free ARM (A1) allocation account-wide and *enforced*
  it — go over the cap and instances get reclaimed. I keep footprints under the limit and watch the
  quotas, because "free" is a moving target someone else controls.
- **Tag at creation or it's archaeology later.** The first untagged resource is the moment you lose
  the ability to answer a cost question cleanly.
- **A long-lived admin key in CI is a breach waiting for a log leak.** Short-lived, scoped tokens,
  every time.

## Where the field went (dated)
- **2023–2024:** multi-cloud shifts from risk-hedging to a deliberate architecture choice;
  **platform engineering** rises (Internal Developer Platforms run as products).
- **2024–2025:** **FinOps** goes mainstream — by the 2026 State of FinOps, nearly all practitioners
  manage **AI/GenAI spend** as part of cloud cost (up from roughly a third two years earlier).
- **2025–2026:** context-aware, AI-assisted cost optimization becomes table stakes.
