TARGET=servd
PREQS=server.o serverutils.o context.o

all: ${TARGET}

${TARGET}: ${PREQS}
	dmd -of$@ $^

%.o: %.d
	dmd -c $<
