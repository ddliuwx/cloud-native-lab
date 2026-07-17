# Terraform / IaC Interview Q&A

Polished, interview-ready answers built up while working through the
learning plan in [`CLAUDE.md`](CLAUDE.md). Each answer is written to be
spoken in under ~1 minute.

---

## Q: If someone changes an infrastructure resource manually through the cloud console, how does Terraform handle it?

If someone changes an infrastructure resource manually through the cloud
console, Terraform doesn't detect it immediately because it doesn't
continuously monitor resources. The next time I run `terraform plan` or
`terraform apply`, Terraform refreshes the resource state by querying the
cloud provider's API and compares the actual infrastructure with the
configuration in my code. If there's any drift, Terraform plans to bring
the infrastructure back to the desired state defined in the code. If the
manual change is intentional, the correct approach is to update the
Terraform configuration to match the new desired state before applying. In
production environments, teams usually enforce Infrastructure as Code and
avoid manual console changes to prevent unexpected drift and accidental
overwrites.

**Key terms**: drift, refresh, desired state vs. actual state, `-refresh-only`
