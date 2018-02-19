#
# Run some trivial tests
#

VECC = /opt/nec/ve/bin/ncc
VECOPTS = -g -shared -fpic -pthread

all: test test2 test3 test4

test: libvesleep.o
	PYTHONPATH=.. python test-veo.py

test2: libvetest2.o
	PYTHONPATH=.. python test2-veo.py

test3: libvetest2.o
	PYTHONPATH=.. python test3-veo.py

test4: libvetest4.o
	PYTHONPATH=.. python test4-veo.py

libvesleep.o: libvesleep.c
	$(VECC) $(VECOPTS) -o libvesleep.so libvesleep.c

libvetest2.o: libvetest2.c
	$(VECC) $(VECOPTS) -o libvetest2.so libvetest2.c

libvetest4.o: libvetest4.c
	$(VECC) $(VECOPTS) -o libvetest4.so libvetest4.c

clean:
	rm -f *.so

.PHONY: all clean test test2 test3 test4