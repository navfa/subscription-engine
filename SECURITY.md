# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in SubsEngine, please report it responsibly.

**Do NOT open a public GitHub issue.**

Instead, email **navfastudios@proton.me** with:

- A description of the vulnerability
- Steps to reproduce
- Potential impact

You will receive an acknowledgment within **48 hours** and a detailed response within **5 business days**.

## Scope

This policy covers:

- The SubsEngine gem code (`app/`, `lib/`, `config/`)
- Stripe webhook signature verification
- Authorization policies (Pundit)
- Any handling of API keys or secrets

Out of scope:

- The dummy/demo app (`spec/dummy/`)
- Dependencies (report those to the respective maintainers)

## Supported Versions

| Version | Supported |
|---------|-----------|
| 0.7.x   | Yes       |
| < 0.7   | No        |
