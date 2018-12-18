
#
# required packages
#   veoffload
#   protobuf-c
#   log4c
#

veo/_veo.so: veo/_veo.pyx veo/libveo.pxd veo/conv_i64.pxi
	python setup.py build_ext -i --use-cython

test: veo/_veo.so
	$(MAKE) -C examples

install:
	python setup.py install

sdist:
	python setup.py sdist --use-cython

py-veo.spec: py-veo.spec.in setup.py
	PKGVERS=`python setup.py --version 2>/dev/null`; \
	sed -e "s,@VERSION@,$$PKGVERS,g" < py-veo.spec.in > py-veo.spec

#
# All this mess is needed in order to be able to build the SRPM inside
# a virtualenv with numpy and cython
# Build the RPMs by: rpmbuild --rebuild <SRPM>
# but do it ouside of any virtualenv!
#
srpm: sdist py-veo.spec
	PKG=`python setup.py --fullname 2>/dev/null`; \
	cd dist; tar xzvf $$PKG.tar.gz; cp ../py-veo.spec $$PKG; \
	tar czf $$PKG.tar.gz $$PKG; cd ..; \
	rpmbuild -ts dist/$$PKG.tar.gz; mv $$HOME/rpmbuild/SRPMS/$$PKG-*.src.rpm dist

clean:
	rm -f veo/*.so veo/_veo.c py-veo.spec; rm -rf build; make -C examples clean

.PHONY: all clean test
