# ComputerCraft-Sandbox
A test bed for my other ComputerCraft projects.

# Getting set up.

Lua 5.2 isn't supported by MoonScript yet, so:

    sudo apt install lua5.1 luarocks
    sudo luarocks install moonscript busted

# Goals and direction.
I want to eventually port this to use pure MoonScript. To do that, I need a
unittesting framework to make sure my ports are working properly. So here's
what I need to do:

- Figure out what all my code does and comment it accordingly.

- Create a makefile that can compile from MoonScript to Lua.

- Find a good unittesting module out there somewhere and set up unittests for
  everything. Write in MoonScript because it's going to get ported anyway.

  - Subgoal: Make a fake turtle module that doesn't rely on the mod itself.
    Otherwise there's a lot of stuff we just can't unittest.

- Either find a good library that can handle stuff like tableCopy and tableAppend, or write unittests for my own functions and split them off into an ahtoLib.
