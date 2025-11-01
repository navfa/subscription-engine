# Contributing to SubsEngine

Thanks for your interest in contributing! Here's how to get started.

## Setup

```bash
git clone https://github.com/navfa/subs_engine.git
cd subs_engine
make setup       # Install gems + create/migrate database
make db.seed     # Load demo data
make test        # Verify everything passes
```

## Development Workflow

1. Fork the repo and create a feature branch from `main`
2. Write your code
3. Add/update tests
4. Run `make test` and `make lint`
5. Open a PR against `main`

## Code Conventions

- **Services** return `Success` or `Failure` (dry-monads). No exceptions for business logic.
- **Services with DI deps** use `extend Dry::Initializer` + `option`. Without deps, only `include Dry::Monads[:result]`.
- **Repositories** return `Maybe` monads for nil-safe lookups.
- **Controllers** are thin — delegate to services, extract results with pattern matching.
- **Monetary values** are stored as integers in the smallest currency unit (cents).
- **State constants** live in `SubscriptionStateMachine` — no magic strings.

## Running Tests

```bash
make test        # Full suite with SimpleCov (85% minimum)
make test.focus  # Only focused specs (fdescribe/fit)
make lint        # RuboCop
make lint.fix    # RuboCop with auto-correct
```

## PR Guidelines

- Keep PRs focused — one concern per PR
- Follow the PR template
- Ensure CI passes before requesting review
- Migrations must be backward-compatible

## Reporting Bugs

Use the [bug report template](https://github.com/navfa/subs_engine/issues/new?template=bug_report.md).

## Security

See [SECURITY.md](SECURITY.md) for vulnerability reporting.
