# Let's Encrypt setup bootstrap

> **⚠️ Archived.** This was used successfully for a lot of years, and it might be
> useful to you — but I've moved on to other solutions (currently using
> [Traefik](https://traefik.io/), which includes the certificate maintenance).
> I've archived the repo.

A simple, dependency-light setup to manage all your Let's Encrypt certificates
using the [lego](https://go-acme.github.io/lego/) ACME client, with DNS-01
validation via any of lego's supported DNS providers.

More details at [https://www.simplicidade.org/survival/lets_encrypt/].

## How it works

- Each certificate is one directory under `specs/` containing a `spec.sh`
  (`DOMAIN=...`, plus any overrides) and an optional `extra-domains.txt` (one SAN
  per line).
- `./bin/update.sh [spec ...]` issues or renews each certificate with `lego run`
  (which self-skips renewals that aren't due yet), commits the results to git,
  and — if anything changed — runs an optional `./hooks/deploy.sh`.
- Global settings live in `global_defs.sh`; provider **secrets** go in a
  gitignored `.env` (see `.env.example`), which is sourced and auto-exported so
  lego can read them.

## Quick start

1. Install [lego](https://go-acme.github.io/lego/).
2. Edit `global_defs.sh`: set `EMAIL`, your `PROVIDER`, and (per certificate or
   globally) `ENVIRONMENT` (`staging` while testing, `production` when ready).
3. Copy `.env.example` to `.env` and fill in your provider's credentials
   (`lego dnshelp -c <provider>` lists them).
4. Create a spec: `mkdir -p specs/example.com && echo 'DOMAIN=example.com' > specs/example.com/spec.sh`
5. Run it: `./bin/update.sh specs/example.com` (or `./bin/update.sh` for all).

Tip: start with `ENVIRONMENT=staging` (Let's Encrypt staging has generous rate
limits) or `DRY_RUN=yes` to see the commands without executing them.
