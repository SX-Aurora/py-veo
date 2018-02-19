
#
# required packages
#   veoffload
#   protobuf-c
#   log4c
#

veo.so: veo.pyx libveo.pxd
	CFLAGS="-I/opt/nec/ve/veos/include" \
	LDFLAGS="-L/opt/nec/ve/veos/lib64 -Wl,-rpath=/opt/nec/ve/veos/lib64" \
	python setup.py build_ext -i

test: veo.so
	$(MAKE) -C examples

clean:
	rm -f *.so; rm -rf build

.PHONY: all clean test
