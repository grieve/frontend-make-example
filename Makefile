# Location of the installed node binaries
BIN=node_modules/.bin

# Let's automatically find all JS files so we can depend on them
JS_SOURCES=$(shell find src/js/ -type f -name '*.js')

# But we'll explicitly define our output webpack bundles
define JS_BUNDLES
bld/js/index.js
endef

# Now define our output CSS bundles
define CSS_BUNDLES
bld/css/main.css
endef

# Listing all images is laborious, let's use find to get a list of them all
INPUT_PNG_FILES=$(shell find src/img/ -type f -name '*.png')

# And then use make's own pattern substitution to get the output paths
OUTPUT_PNG_FILES=$(patsubst src/img/%.png, bld/img/%.png, $(INPUT_PNG_FILES))



# The build rule! It just depends on all the individual rules
build: lint images styles scripts

# The lint rule! Ensure linters are installed and then lint our list of sources
lint: node_modules/jshint node_modules/jscs
	$(BIN)/jshint $(JS_SOURCES)
	$(BIN)/jscs $(JS_SOURCES)

# Ensure dirs are made and then call all of the JS bundles
scripts: dirs $(JS_BUNDLES)

# Ensure dirs are made and then call all of the CSS bundles
styles: dirs $(CSS_BUNDLES)

# Ensure dirs are made and then call all of the output images
images: dirs $(OUTPUT_PNG_FILES)



# This is just a little helper rule to ensure that output dirs exist
dirs: 
	mkdir -p bld/js
	mkdir -p bld/css
	mkdir -p bld/img



# Node magic: if we depend  on `node_modules/X` then run `npm install X`
node_modules/%:
	npm set progress=false;
	-npm install $(notdir $@);

# Simply install everything is package.json has changed
node_modules: package.json
	npm set progress=false;
	npm install
	touch node_modules



# This is where the real magic happens. % is a pattern matcher in make, so, for
# example, if we tried to build `bld/css/main.css` it would depend upon
# `src/scss/main.scss`. 
bld/css/%.css: src/scss/%.scss node_modules/node-sass
	$(BIN)/node-sass $< > $@;

# Same as above but with PNGs
bld/img/%.png: src/img/%.png node_modules/imagemin-cli node_modules/imagemin
	$(BIN)/imagemin $< > $@

# Same as above for JS, but to be extra sure we always build when we need to, we
# depend on ALL JS sources, but use the pattern match as the entry point.
bld/js/%.js: src/js/%.js $(JS_SOURCES) node_modules
	$(BIN)/webpack -d $< $@

# N.B. Inside a make rule, `$<` will always refer to the input dependecy, in 
# this last case that is `src/js/%.js` and `$@` will always refer to the rule
# target itself, `bld/js/%.js`



# The .PHONY rule is a special case that lets make know these rules are "meta"
# and either just trigger other rules or have another side effect indirectly
# controlled by make. This ensure they always run even if their "target" exists
.PHONY: build lint scripts styles images dirs