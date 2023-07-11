CC=gcc
DEPS = hello.h
OBJ = hello.o main.o
STATIC-OBJ = static-hello.o static-main.o
FLAGS = -Os -ffunction-sections -fdata-sections -Wl,-Map=object.map,--cref,--gc-section

static-%.o: %.c $(DEPS)
	$(CC) -static -static-libstdc++ -static-libgcc -c $(FLAGS) -o $@ $<
%.o: %.c $(DEPS)
	$(CC) -c $(FLAGS) -o $@ $<

all: greet greet-static
greet-static: $(STATIC-OBJ)
	$(CC) -static -static-libstdc++ -static-libgcc $(FLAGS) -o $@ $^
greet: $(OBJ)
	$(CC)  $(FLAGS) -o $@ $^
strip: greet greet-static
	strip $^
clean:
	rm -rf greet greet-static *.o
