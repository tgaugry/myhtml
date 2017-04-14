REV := 20472e608da29f0cd422937dd810dbde623d5c86

.PHONY: package
package: ./myhtml-c/lib/libmyhtml_static.a

./myhtml-c:
	git clone https://github.com/lexborisov/myhtml.git ./myhtml-c
	cd myhtml-c && git reset --hard $(REV)

./myhtml-c/lib/libmyhtml_static.a: ./myhtml-c
	cd myhtml-c && make library MyHTML_BUILD_SHARED=OFF MyCORE_BUILD_WITHOUT_THREADS=YES PROJECT_OPTIMIZATION_LEVEL=-O3

.PHONY: clean
clean:
	rm ./myhtml-c/lib/libmyhtml_static.a
	rm -rf ./mhtml-c
