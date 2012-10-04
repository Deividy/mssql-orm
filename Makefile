REPORTER = spec
# Mocha path
MOCHA=mocha
# Specs path
TEST=./specs/*.spec.coffee

test:
	$(MOCHA) \
		--compilers coffee:coffee-script \
		--require should \
		--reporter $(REPORTER) \
		--slow 20ms \
		--timeout 10000 \
		$(TEST) 

.PHONY: test
