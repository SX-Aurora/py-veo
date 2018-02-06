
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

test:
	/opt/nec/ve/bin/ncc -g -shared -fpic -pthread -o libvesleep.so libvesleep.c
	PYTHONPATH=. python test-veo.py

test2:
	/opt/nec/ve/bin/ncc -g -shared -fpic -pthread -o libvetest2.so libvetest2.c
	PYTHONPATH=. python test2-veo.py

clean:
	rm -f *.so; rm -rf build

.PHONY: all clean test test2
