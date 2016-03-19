.PHONY: package
package: ./myhtml-c/lib/static_libmyhtml.a

./myhtml-c:
	git clone --depth 1 https://github.com/lexborisov/myhtml.git ./myhtml-c

./myhtml-c/lib/static_libmyhtml.a: ./myhtml-c
	cd myhtml-c && make MyHTML_BUILD_SHARED=OFF MyHTML_BUILD_WITHOUT_THREADS=YES

.PHONY: clean
clean:
	rm -rf myhtml-c
