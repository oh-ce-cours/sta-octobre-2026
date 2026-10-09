CC = gcc
CFLAGS = $(shell python-config --cflags)
LDFLAGS = $(shell python-config --ldflags)


simple.o: simple.c
	$(CC) $(CFLAGS) -c simple.c -o simple.o

simple_error.o: simple_error.c
	$(CC) $(CFLAGS) -c simple_error.c -o simple_error.o

run_script.o: run_script.c
	$(CC) $(CFLAGS) -c run_script.c -o run_script.o

run_script_string.o: run_script.c
	$(CC) $(CFLAGS) -c run_script_string.c -o run_script_string.o


simple: simple.o
	$(CC) simple.o $(LDFLAGS) -o simple
	./simple

simple_error: simple_error.o
	$(CC) simple_error.o $(LDFLAGS) -o simple_error
	./simple_error

run_script: run_script.o
	$(CC) run_script.o $(LDFLAGS) -o run_script

run_script_string: run_script_string.o
	$(CC) run_script_string.o $(LDFLAGS) -o run_script_string




.PHONY : clean
clean :
	rm -f *.o simple simple_error run_script