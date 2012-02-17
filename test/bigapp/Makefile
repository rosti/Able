all: test1

subd/test2.o :
	cd subd; $(MAKE)

test1.o : test1.c

test1 : test1.o subd/test2.o
