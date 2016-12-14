# All of the lua files that come from *.moon files.
to_create = unittest/turtle.lua

all: $(to_create)

test: test.moon $(to_create)
	busted $<

%.lua: %.moon
	moonc $<
	# moonc $< -o $@ # moonc doesn't like the -o flag for some reason.
