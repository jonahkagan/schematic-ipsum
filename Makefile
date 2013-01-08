.PHONY: all clean test heroku
SRCDIR = src
SRC = $(shell find src -name "*.coffee")
OUTDIR = bin
OUT = $(SRC:src/%.coffee=bin/%.js)
TESTDIR = test
TESTGREP = ""
COFFEE = ./node_modules/.bin/coffee 
CFLAGS = -c -o $(OUTDIR)
MOCHA = ./node_modules/.bin/mocha \
				-R spec \
				--compilers coffee:coffee-script \
				--ignore-leaks \
				--timeout 5s

all: $(OUT)
	
$(OUT): $(SRC)
	@mkdir -p $(OUTDIR)
	$(COFFEE) $(CFLAGS) $(SRCDIR)

test: all
	$(MOCHA) $(TESTDIR) --grep $(TESTGREP)

clean:
	rm -rf $(OUTDIR)

scrape:
	$(COFFEE) scraper/scraper.coffee

heroku: all
	cp Procfile heroku
	cp package.json heroku
	cp README.md heroku
	cp -R bin heroku
	cp -R data heroku

	cd front && ./build
	cp -R front/public heroku

	cd heroku && npm install --production
	cd heroku && git add .  && git commit -m "update"
