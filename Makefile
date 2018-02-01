

veo.so: veo.pyx libveo.pxd
	CFLAGS="-I/opt/nec/ve/veos/include" \
	LDFLAGS="-L/opt/nec/ve/veos/lib64" \
	python setup.py build_ext -i

test:
	PYTHONPATH=. python test-veo.py

clean:
	rm -f $(OBJECTS) $(TARGET)

.PHONY: all clean
