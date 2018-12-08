
#
# required packages
#   veoffload
#   protobuf-c
#   log4c
#

veo.so: src/veo.pyx src/libveo.pxd src/conv_i64.pxi
	CFLAGS="-I/opt/nec/ve/veos/include" \
	LDFLAGS="-L/opt/nec/ve/veos/lib64 -Wl,-rpath=/opt/nec/ve/veos/lib64" \
	python setup.py build_ext -i --use-cython

test: veo.so
	$(MAKE) -C examples

install:
	CFLAGS="-I/opt/nec/ve/veos/include" \
	LDFLAGS="-L/opt/nec/ve/veos/lib64 -Wl,-rpath=/opt/nec/ve/veos/lib64" \
	python setup.py install

sdist:
	CFLAGS="-I/opt/nec/ve/veos/include" \
	LDFLAGS="-L/opt/nec/ve/veos/lib64 -Wl,-rpath=/opt/nec/ve/veos/lib64" \
	python setup.py sdist --use-cython

rpm: veo.so
	CFLAGS="-I/opt/nec/ve/veos/include" \
	LDFLAGS="-L/opt/nec/ve/veos/lib64 -Wl,-rpath=/opt/nec/ve/veos/lib64" \
	python setup.py bdist_rpm

clean:
	rm -f *.so; rm -rf build; make -C examples clean

.PHONY: all clean test
