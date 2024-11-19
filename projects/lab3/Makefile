IMG_C = 4
IMG_W = 1
IMG_H = 3
FILTER_NUM = 2
FILTER_SIZE = 1
DEBUG = 0

all: test

memory:
	python3 ./scripts/generate_mem.py $(IMG_C) $(IMG_W) $(IMG_H) $(FILTER_NUM) $(FILTER_SIZE) $(DEBUG)

test: sim
	python3 ./scripts/test.py $(IMG_C) $(IMG_W) $(IMG_H) $(FILTER_NUM) $(FILTER_SIZE)

sim: memory
	bash ./../../build.sh -e lab3 -b
	bash ./../../build.sh -e lab3 -s

clean:
	./../../build.sh -e lab3 -c
	if [ -f "mem/mem_init.txt" ]; then rm -rf mem/mem_init.txt; fi
	if [ -f "mem/mem_out.txt" ]; then rm -rf mem/mem_out.txt; fi
	if [ -f "mem/status" ]; then rm -rf mem/status; fi