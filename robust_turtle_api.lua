--Robust Turtle API by SpeedR

--Digging with gravel/sand detection
function dig()
  local tries = 0
  while turtle.detect() do
    turtle.dig()
    sleep(0.4)
    tries = tries + 1
    if tries>500 then
      print("Error: dug for too long.")
      return false
    end
  end
  return true
end

function digUp()
  local tries = 0
  while turtle.detectUp() do
    turtle.digUp()
    sleep(0.4)
    tries = tries + 1
    if tries>500 then
      print("Error: dug up for too long.")
      return false
    end
  end
  return true
end

function digDown()
  local tries = 0
  while turtle.detectDown() do
    turtle.digDown()
    sleep(0.4)
    tries = tries + 1
    if tries>500 then
      print("Error: dug down for too long.")
      return false
    end
  end
  return true
end


--Traveling: Goes in the direction no matter what (almost)
--Will not be stopped by blocks or mobs
function forward(l)
  l=l or 1
  for i=1,l do
    local tries = 0
    while turtle.forward() ~= true do
      turtle.dig()
      turtle.attack()
      sleep(0.2)
      tries = tries + 1
      if tries>500 then
        print("Error: can't move forward.")
        return false
      end
    end
  end
  return true
end

function up(l)
  l=l or 1
  for i=1,l do
    local tries = 0
    while turtle.up() ~= true do
      turtle.digUp()
      turtle.attackUp()
      sleep(0.2)
      tries = tries + 1
      if tries>500 then
        print("Error: can't move up.")
        return false
      end
    end
  end
  return true
end

function down(l)
  l=l or 1
  for i=1,l do
    local tries = 0
    while turtle.down() ~= true do
      turtle.digDown()
      turtle.attackDown()
      sleep(0.2)
      tries = tries + 1
      if tries>500 then
        print("Error: can't move down.")
        return false
      end
    end
  end
  return true
end

function back(l)
  l=l or 1
  for i=1,l do
    if turtle.back() ~= true then
      turnAround()
      forward()
      turnAround()
    end
  end
end


--Place blocks
--Does not place when there's already the right block.
function place(block)
  turtle.select(block)
  if turtle.compare()==false then
    if turtle.getItemCount(block)==0 then
      outOfResource(block)
    end
    dig()
    turtle.place()
  end
end

function placeUp(block)
  turtle.select(block)
  if turtle.compareUp()==false then
    if turtle.getItemCount(block)==0 then
      outOfResource(block)
    end
    digUp()
    turtle.placeUp()
  end
end

function placeDown(block)
  turtle.select(block)
  if turtle.compareDown()==false then
    if turtle.getItemCount(block)==0 then
      outOfResource(block)
    end
    digDown()
    turtle.placeDown()
  end
end

local function outOfResource()
  print("Ran out of a resource. Block: ",block , ".")
  print("Refill, then say something to proceed.")
  read()
end

function placeRight(block)
  turtle.turnRight()
  place(block)
  turtle.turnLeft()
end

function placeLeft(block)
  turtle.turnLeft()
  place(block)
  turtle.turnRight()
end

function placeBack(block)
  turnAround()
  place(block)
  turnAround()
end

--place row     e.g. placeRow(up, marble, forward, 15)
function placeRow(placeDir, block, travelDir, l) 
  l=l or 1
  for i=1,l do
    if placeDir == "forward" then
      place(block)
    elseif placeDir == "up" then
      placeUp(block)
    elseif placeDir == "down" then
      placeDown(block)
    elseif placeDir == "right" then
      placeRight(block)
    elseif placeDir == "left" then
      placeLeft(block)
    elseif placeDir == "back" then
      placeBack(block)
    else
      print('"', placeDir, '" is not a valid direction!')
      return false
    end
    if travelDir == "forward" then
      forward()
    elseif travelDir == "up" then
      up()
    elseif travelDir == "down" then
      down()
    elseif travelDir == "right" then
      strafeRight()
    elseif travelDir == "left" then
      strafeLeft()
    elseif travelDir == "back" then
      back()
    else
      print('"', travelDir, '" is not a valid direction!')
      return false
    end
  end
  return true
end


--Turning
function turnAround()
  turtle.turnRight()
  turtle.turnRight()
end

function right()
  turtle.turnRight()
end

function left()
  turtle.turnLeft()
end

function goRight(l)
  l=l or 1
  turtle.turnRight()
  forward(l)
end

function goLeft(l)
  l=l or 1
  turtle.turnLeft()
  forward(l)
end

function strafeRight(l)
  l=l or 1
  goRight(l)
  turtle.turnLeft()
end

function strafeLeft(l)
  l=l or 1
  goLeft(l)
  turtle.turnRight()
end
