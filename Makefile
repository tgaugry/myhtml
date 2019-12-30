CRYSTAL ?= crystal
CRYSTALFLAGS ?=

.PHONY: all package spec
all: bin_usage bin_print_tree bin_links bin_texts bin_encoding bin_print_html bin_css_selectors1 bin_css_selectors2
package: src/ext/myhtml-c/lib/libmodest_static.a

src/ext/myhtml-c/lib/libmodest_static.a:
	cd src/ext && make package

spec:
	crystal spec

.PHONY: clean
clean:
	rm -f bin_* src/ext/modest-c/lib/libmodest_static.a
	rm -rf ./src/ext/modest-c
