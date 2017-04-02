CRYSTAL ?= crystal
CRYSTALFLAGS ?= --release

.PHONY: all package spec
all: bin_usage bin_walk_tree bin_links bin_texts bin_encoding bin_normalize
package: src/ext/myhtml-c/lib/libmyhtml_static.a

bin_usage: src/*.cr src/**/*.cr examples/usage.cr package
	$(CRYSTAL) build examples/usage.cr $(CRYSTALFLAGS) -o $@

bin_walk_tree: src/*.cr src/**/*.cr examples/walk_tree.cr package
	$(CRYSTAL) build examples/walk_tree.cr $(CRYSTALFLAGS) -o $@

bin_links: src/*.cr src/**/*.cr examples/links.cr package
	$(CRYSTAL) build examples/links.cr $(CRYSTALFLAGS) -o $@

bin_texts: src/*.cr src/**/*.cr examples/texts.cr package
	$(CRYSTAL) build examples/texts.cr $(CRYSTALFLAGS) -o $@

bin_encoding: src/*.cr src/**/*.cr examples/encoding.cr package
	  $(CRYSTAL) build examples/encoding.cr $(CRYSTALFLAGS) -o $@

bin_normalize: src/*.cr src/**/*.cr examples/normalize.cr package
		$(CRYSTAL) build examples/normalize.cr $(CRYSTALFLAGS) -o $@

src/ext/myhtml-c/lib/libmyhtml_static.a:
	cd src/ext && make package

spec:
	crystal spec

.PHONY: clean
clean:
	rm -f bin_* src/ext/myhtml-c/lib/libmyhtml_static.a
	rm -rf ./src/ext/myhtml-c
