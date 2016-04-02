.PHONY: package
package: ./myhtml-c/lib/static_libmyhtml.a

./myhtml-c:
	git clone --depth 1 https://github.com/lexborisov/myhtml.git ./myhtml-c
	# cd myhtml-c && git reset --hard 4849ceecc34b33ddd662f108cabc9d35cb08b261

./myhtml-c/lib/static_libmyhtml.a: ./myhtml-c
	cd myhtml-c && make MyHTML_BUILD_SHARED=OFF MyHTML_BUILD_WITHOUT_THREADS=YES MyHTML_OPTIMIZATION_LEVEL=-O3

.PHONY: clean
clean:
	rm -rf myhtml-c
