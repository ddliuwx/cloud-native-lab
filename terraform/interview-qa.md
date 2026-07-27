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

---

## Q: How does AWS OIDC integrate with GitHub Actions, and what's the underlying authentication flow?

OIDC lets GitHub Actions authenticate to AWS without storing any long-lived
access keys. On the AWS side, I configure an IAM OpenID Connect provider
that trusts GitHub's token issuer, plus an IAM role whose trust policy only
allows `AssumeRoleWithWebIdentity` if the token's audience is
`sts.amazonaws.com` and its subject claim matches a specific repo and
branch.

At runtime, the workflow requests a signed JWT from GitHub's OIDC endpoint,
using the `id-token: write` permission. That JWT is sent to AWS STS via
`AssumeRoleWithWebIdentity`. STS verifies the token's signature against the
registered provider and checks it against the role's trust policy
conditions. If everything matches, STS issues short-lived temporary
credentials, typically valid under an hour, which the runner uses for the
rest of the job.

This is more secure than static access keys — nothing long-lived is ever
stored in GitHub, trust is scoped to one repo and branch, and credentials
expire automatically with nothing to rotate or revoke.

**Key terms**: OIDC, federated identity, JWT, claims (`sub`/`aud`/`iss`),
`AssumeRoleWithWebIdentity`, JWKS

See [`phase9-cicd/diagrams/oidc_auth_flow.svg`](phase9-cicd/diagrams/oidc_auth_flow.svg)
for the full flow diagram.
