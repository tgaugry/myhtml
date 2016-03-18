.PHONY: package
package: ./myhtml-c/lib/static_libmyhtml.a

./myhtml-c:
	git clone --depth 1 https://github.com/lexborisov/myhtml.git ./myhtml-c

./myhtml-c/lib/static_libmyhtml.a: ./myhtml-c
	cd myhtml-c && make

.PHONY: clean
clean:
	rm -rf myhtml-c
