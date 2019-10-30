.PHONY: test build bump-major bump-minor bump-patch help
.DEFAULT_GOAL := help

test: ## Run the unit tests
	bundle exec rake --trace

build: ## Build the ruby gem
	gem build r7insight.gemspec

bump-major: ## Bump the major version (1.0.0 -> 2.0.0)
	@which bump || (echo "You do not have 'bump' installed or in your PATH.\n" \
		"Please run 'gem install bump'\n" "GitHub: https://github.com/gregorym/bump" && false)
	@bump major

bump-minor: ## Bump the minor version (0.1.0 -> 0.2.0)
	@which bump || (echo "You do not have 'bump' installed or in your PATH.\n" \
		"Please run 'gem install bump'\n" "GitHub: https://github.com/gregorym/bump" && false)
	@bump minor

bump-patch: ## Bump the patch version (0.0.1 -> 0.0.2)
	@which bump || (echo "You do not have 'bump' installed or in your PATH.\n" \
		"Please run 'gem install bump'\n" "GitHub: https://github.com/gregorym/bump" && false)
	@bump patch

help: ## Shows help
	@IFS=$$'\n' ; \
    help_lines=(`fgrep -h "##" ${MAKEFILE_LIST} | fgrep -v fgrep | sed -e 's/\\$$//'`); \
    for help_line in $${help_lines[@]}; do \
        IFS=$$'#' ; \
        help_split=($$help_line) ; \
        help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        printf "%-30s %s\n" $$help_command $$help_info ; \
    done
