CRYSTAL ?= crystal
CRYSTALFLAGS ?= --release

.PHONY: all package spec
all: bin_index bin_walk_tree
package: src/ext/myhtml-c/lib/static_libmyhtml.a

bin_index: src/*.cr src/**/*.cr examples/index.cr package
	$(CRYSTAL) build examples/index.cr $(CRYSTALFLAGS) -o $@

bin_walk_tree: src/*.cr src/**/*.cr examples/walk_tree.cr package
	$(CRYSTAL) build examples/walk_tree.cr $(CRYSTALFLAGS) -o $@

src/ext/myhtml-c/lib/static_libmyhtml.a:
	cd src/ext && make package

spec:
	crystal spec

.PHONY: clean
clean:
	rm -f bin_* src/ext/myhtml-c/lib/static_libmyhtml.a
