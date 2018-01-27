PYLIBDIR = $(shell python-config --exec-prefix)/lib
LIBS = -L$(PYLIBDIR) $(shell python-config --libs) -lboost_python
INC = $(shell python-config --include)
VEOLIB = /opt/nec/ve/veos/lib64
VEOINC = -I/opt/nec/ve/veos/include
INC += $(VEOINC)
LIBS += -L$(VEOLIB) -lveo
CFLAGS = -O2 -fPIC
CFLAGS += -std=c++11
LDFLAGS = -Wl,-rpath,$(PYLIBDIR) -Wl,-rpath,$(VEOLIB) -shared
CC = g++
LD = gcc

TARGET = veo.so
SOURCES = $(wildcard *.cpp)
OBJECTS = $(patsubst %cpp,%o,$(SOURCES))
INCLUDES = $(patsubst %cpp,%hpp,$(SOURCES))

all: $(TARGET)

veo.o: $(INCLUDES) Makefile

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) $(LIBS) $^ -o $@

%.o: %.cpp %.hpp Makefile
	$(CC) -c $(INC) $(CFLAGS) $< -o $@

clean:
	rm -f $(OBJECTS) $(TARGET)

.PHONY: all clean
