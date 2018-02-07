
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

test: libvesleep.o
	PYTHONPATH=. python test-veo.py

test2: libvetest2.o
	PYTHONPATH=. python test2-veo.py

test3: libvetest2.o
	PYTHONPATH=. python test3-veo.py

libvesleep.o: libvesleep.c
	/opt/nec/ve/bin/ncc -g -shared -fpic -pthread -o libvesleep.so libvesleep.c

libvetest2.o: libvetest2.c
	/opt/nec/ve/bin/ncc -g -shared -fpic -pthread -o libvetest2.so libvetest2.c

clean:
	rm -f *.so; rm -rf build

.PHONY: all clean test test2 test3
