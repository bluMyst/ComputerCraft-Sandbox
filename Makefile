# All of the lua files that come from *.moon files.
to_compile = unittest/turtle.lua

all: $(to_compile)

test: test.moon $(to_compile)
	busted $<

%.lua: %.moon
	moonc $<
	# moonc $< -o $@ # moonc doesn't like the -o flag for some reason.
