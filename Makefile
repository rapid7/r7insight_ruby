.PHONY: test
.DEFAULT_GOAL := test

test:
	bundle exec rake --trace
