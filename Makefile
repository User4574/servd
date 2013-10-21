TARGET=server
PREQS=server.o serverutils.o

all: ${TARGET}

${TARGET}: ${PREQS}
	dmd -of$@ $^

%.o: %.d
	dmd -c $<
