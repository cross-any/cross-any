CC=g++
DEPS = hello.h
OBJ = hello.o main.o
STATIC-OBJ = static-hello.o static-main.o
FLAGS = -Os -ffunction-sections -fdata-sections -Wl,-Map=object.map,--cref,--gc-section

static-%.o: %.cpp $(DEPS)
	$(CC) -static -static-libstdc++ -static-libgcc -c $(FLAGS) -o $@ $<
%.o: %.cpp $(DEPS)
	$(CC) -c $(FLAGS) -o $@ $<
all: greet greet-static greet-static-stdcpp
greet-static: $(STATIC-OBJ)
	$(CC) -static -static-libstdc++ -static-libgcc $(FLAGS) -o $@ $^
greet-static-stdcpp: $(OBJ)
	$(CC) -static-libstdc++ -static-libgcc $(FLAGS) -o $@ $^
greet: $(OBJ)
	$(CC) $(FLAGS) -o $@ $^
strip: greet greet-static greet-static-stdcpp
	strip $^
clean:
	rm -rf greet greet-static greet-static-stdcpp *.o
