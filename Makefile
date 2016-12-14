all: %.lua

%.lua: %.moon
	moonc $< -o $@
