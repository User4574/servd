TARGET=servd
PREQS=server.o context.o

all: ${TARGET}

${TARGET}: ${PREQS}
	dmd -of$@ $^

%.o: %.d
	dmd -c $<

.PHONY: clean

clean:
	rm *.o servd
