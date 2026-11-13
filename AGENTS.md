# AGENTS.md

Welcome agent! This file outlines key instructions, commands, patterns, and gotchas for working in the **UnB_RU** codebase on the current branch (`feature/basic-access-control`).

## Essential Commands

- **Setup**: `bin/setup` (Prepares database, installs dependencies, etc.)
- **Run CI suite / All checks**: `bin/ci` (Runs rubocop, bundler-audit, importmap audit, brakeman, and tests)
- **Run Unit/Controller/Integration Tests**: `bin/rails test`
- **Run RSpec Specs**: `bin/rspec` (or `bundle exec rspec`)
- **Run Cucumber Features (BDD)**: `bin/cucumber`
- **Run RuboCop (Linting)**: `bin/rubocop`
- **Run Brakeman (Security analysis)**: `bin/brakeman`
- **Run Development Server**: `bin/dev` or `bin/rails server`

## Application Architecture & Stack

- **Framework**: Ruby on Rails 8.1+
- **Database & Adapters**: SQLite3 with Solid Queue, Solid Cache, and Solid Cable adapters for background jobs, caching, and Action Cable.
- **Key Models & Components**:
  - `Restaurant`, `Turnstile`, `Account`, `Student`
  - Access Control & Sessions (`AdminSessions`, `OperatorSessions`, `StudentSessions`, `StudentPortal`)
- **Frontend Assets**: Propshaft, Importmap for modern JavaScript ESM, Hotwire (`turbo-rails` and `stimulus-rails`), SCSS stylesheets.
- **Deployment & Containers**: Kamal for containerized deployments, Dockerfile included.
- **Testing Approach**: 
  - Rails Minitest (`test/`)
  - RSpec (`spec/`)
  - Cucumber BDD features (`features/`) covering comprehensive BDD scenarios (access control, login, turnstiles, restaurants, fastpass, wallet, history, etc.).

## Code Conventions & Patterns

- Follow standard **Omakase Ruby styling** via `rubocop-rails-omakase`.
- Use built-in Rails Generators and MVC conventions.
- Custom step definitions and support modules under `features/support/` and `features/step_definitions/`.

## Gotchas & Tips

- Ensure bundle dependencies and database migrations are fully set up using `bin/setup` or `bin/rails db:migrate` before running tests or the application.
- Both Minitest (`bin/rails test`), RSpec (`bin/rspec`), and Cucumber (`bin/cucumber`) are available for testing.
