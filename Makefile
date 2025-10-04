.PHONY: setup db.create db.migrate db.rollback db.reset test lint lint.fix console clean

## — Setup ——————————————————————————————————————————————

setup: ## Install dependencies and prepare the database
	bundle install
	bundle exec rake db:create db:migrate

## — Database ———————————————————————————————————————————

db.create: ## Create the test database
	bundle exec rake db:create

db.migrate: ## Run pending migrations
	bundle exec rake db:migrate

db.rollback: ## Rollback the last migration
	bundle exec rake db:rollback

db.reset: ## Drop, create and migrate the database
	bundle exec rake db:drop db:create db:migrate

## — Quality —————————————————————————————————————————————

test: ## Run the full test suite
	bundle exec rspec

test.focus: ## Run only focused specs (fdescribe/fit/focus: true)
	bundle exec rspec --tag focus

lint: ## Run rubocop checks
	bundle exec rubocop

lint.fix: ## Run rubocop with auto-correct
	bundle exec rubocop -A

## — Development —————————————————————————————————————————

console: ## Open a Rails console via the dummy app
	bundle exec rails console -e test

clean: ## Remove generated files and logs
	rm -rf spec/dummy/db/*.sqlite3 spec/dummy/log/*.log spec/dummy/tmp

## — Help ————————————————————————————————————————————————

help: ## Show this help
	@grep -E '^[a-zA-Z_.]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
