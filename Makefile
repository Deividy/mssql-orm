REPORTER=spec
# Mocha path
MOCHA=./node_modules/mocha/bin/mocha
# Specs path
TEST=specs/*.spec.coffee

test:
	$(MOCHA) \
		--reporter $(REPORTER) \
		--require should \
		--compilers coffee:coffee-script \
		--slow 20ms \
		--timeout 10000 \
		$(TEST)

.PHONY: test
