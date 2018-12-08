#
# Run some trivial tests
#

VECC = /opt/nec/ve/bin/ncc
VEFTN = /opt/nec/ve/bin/nfort
VECOPTS = -g -shared -fpic -pthread

all: test test2 test3 test4 test5 test6 test7 test8 test9

test: libvesleep.so
	PYTHONPATH=.. python test-veo.py

test2: libvetest2.so
	PYTHONPATH=.. python test2-veo.py

test3: libvetest2.so
	PYTHONPATH=.. python test3-veo.py

test4: libvetest4.so
	PYTHONPATH=.. python test4-veo.py

test5: libvetest5.so
	PYTHONPATH=.. python test5-veo.py

test6: libvetest6.so
	PYTHONPATH=.. python test6-veo.py

test7: libvetest7.so
	PYTHONPATH=.. python test7-veo.py

test8: libvetest8.so
	PYTHONPATH=.. python test8-veo.py

test9: libvetest9.so
	PYTHONPATH=.. python test9-veo.py

libvesleep.so: libvesleep.c
	$(VECC) $(VECOPTS) -o libvesleep.so libvesleep.c

libvetest2.so: libvetest2.c
	$(VECC) $(VECOPTS) -o libvetest2.so libvetest2.c

libvetest4.so: libvetest4.c
	$(VECC) $(VECOPTS) -o libvetest4.so libvetest4.c

libvetest5.so: libvetest5.c
	$(VECC) $(VECOPTS) -o libvetest5.so libvetest5.c

libvetest6.so: libvetest6.c
	$(VECC) $(VECOPTS) -o libvetest6.so libvetest6.c

libvetest7.so: libvetest7.c
	$(VECC) $(VECOPTS) -o libvetest7.so libvetest7.c

libvetest8.so: libvetest8.c
	$(VECC) $(VECOPTS) -o libvetest8.so libvetest8.c

libvetest9.so: libvetest9.f90
	$(VEFTN) $(VECOPTS) -report-all -o $@ $^

clean:
	rm -f *.so

.PHONY: all clean test test2 test3 test4 test5 test6 test7
