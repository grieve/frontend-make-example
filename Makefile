# Location of the installed npm and node binaries
BIN=node_modules/.bin

# Let's automatically find all JS files so we can depend on them
JS_SOURCES=$(shell find src/js/ -type f -name '*.js')

# But we'll explicitly define our output webpack bundles.
# YES using entries in webpack.config.js would be more efficient generally
# speaking, but we're demonstrating make here, not webpack ;)
define JS_BUNDLES
bld/js/index.js
endef

# Now define our output CSS bundles
define CSS_BUNDLES
bld/css/main.css
endef

define ASSETS
bld/fonts/empty.txt
endef

# Listing all HTML files is boring, let's find them automatically
HTML_SOURCES=$(shell find src/html -type f -name '*.html')
# And then use pattern substitution to create the output paths!
HTML_OUTPUTS=$(patsubst src/html/%.html, bld/%.html, $(HTML_SOURCES))

# Let's do that same now for images
IMAGE_SOURCES=$(shell find src/img/ -type f -name '*.png')
IMAGE_OUTPUTS=$(patsubst src/img/%.png, bld/img/%.png, $(IMAGE_SOURCES))



# The build rule! It just depends on all the individual rules
build: lint styles scripts images html assets

# The lint rule! Ensure linters are installed and then lint our list of sources
lint: node_modules/jshint node_modules/jscs
	$(BIN)/jshint $(JS_SOURCES)
	$(BIN)/jscs $(JS_SOURCES)

# Ensure tools are installed and then call all of the JS bundles
scripts: node_modules node_modules/webpack $(JS_BUNDLES)

# Ensure tools are installed and then call all of the CSS bundles
styles: node_modules/node-sass $(CSS_BUNDLES)

# Ensure tools are installed and then call all of the output images
images: node_modules/imagemin-cli $(IMAGE_OUTPUTS)

# HTML and other assets are straight copied
html: $(HTML_OUTPUTS)
assets: $(ASSETS)

# Build and serve the application
serve: build
	cd bld; python -m SimpleHTTPServer 5000


# Node magic: if we depend  on `node_modules/X` then run `npm install X`
node_modules/%:
	npm cache clean;
	npm set progress=false;
	npm install $(notdir $@);

# Simply install everything is package.json has changed
node_modules:
	npm cache clean;
	npm set progress=false;
	npm install;
	touch node_modules;



# This is where the real magic happens. % is a pattern matcher in make, so, for
# example, if we tried to build `bld/css/main.css` it would depend upon
# `src/scss/main.scss`. 
bld/css/%.css: src/scss/%.scss
	mkdir -p $(dir $@)
	$(BIN)/node-sass $< > $@;

# Same as above but with PNGs
bld/img/%.png: src/img/%.png
	mkdir -p $(dir $@)
	$(BIN)/imagemin $< > $@

# Same as above for JS, but to be extra sure we always build when we need to, we
# depend on ALL JS sources, but use the pattern match as the entry point.
bld/js/%.js: src/js/%.js $(JS_SOURCES)
	mkdir -p $(dir $@)
	$(BIN)/webpack -d $< $@

# N.B. Inside a make rule, `$<` will always refer to the input dependecy, in 
# this last case that is `src/js/%.js` and `$@` will always refer to the rule
# target itself, `bld/js/%.js`

# Copy all HTML sources. Note we remove the 'html' from the folder, so that
# these are in root
bld/%.html: src/html/%.html
	mkdir -p $(dir $@)
	cp $< $@;

# Simple catch all copy rule for non-transformed assets. Anything that isn't
# dealt with in a specific rule above is copied.
bld/%: src/%
	mkdir -p $(dir $@)
	cp $< $@;


# The .PHONY rule is a special case that lets make know these rules are "meta"
# and either just trigger other rules or have another side effect indirectly
# controlled by make. This ensure they always run even if their "target" exists
.PHONY: build lint scripts styles images node_modules