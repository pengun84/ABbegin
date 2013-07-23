function love.load()
love.physics.setMeter(64) --the height of a meter our worlds will be 64px
world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
world:setCallbacks(beginContact, endContact, preSolve, postSolve)
text       = ""   -- we'll use this to put info text on the screen later
persisting = 0 

bear = {x = love.graphics.getWidth( )/2, y = love.graphics.getHeight( )/2, width = 50, height = 100}
bear.rotation = 0
bear.xspeed = 50
bear.yspeed = 70
bear.image = love.graphics.newImage("bear.png")
bear.b = love.physics.newBody(world,bear.x,bear.y , "dynamic")
bear.s = love.physics.newRectangleShape(0,0,50, 100)
bear.f = love.physics.newFixture(bear.b, bear.s)
bear.f:setUserData("bear")

bulletf = {}
bulletforce = 250

objects = {}
objects.blocks = {}
objects.blocks.body = love.physics.newBody(world,  love.graphics.getWidth( )/2 , love.graphics.getHeight( ) - 50  , "static")
objects.blocks.shape = love.physics.newRectangleShape(0, 0,600, 50)
objects.blocks.fixture = love.physics.newFixture(objects.blocks.body, objects.blocks.shape, 5)
objects.blocks.fixture:setUserData("blocks")
timer1 = 0
timerjump = 0
end

function love.draw()
  	love.graphics.setColor(128, 128, 128)
	 love.graphics.print(text.."Testing", 10, 10)
    love.graphics.draw(bear.image, bear.x, bear.y,0,1,1,bear.width/2,bear.height/2)

	
	
	
	--draw bullet
	for i,v in ipairs(bulletf) do
        love.graphics.circle("fill", v["x"], v["y"], 10)
    end
	
	 love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
		love.graphics.polygon("fill", objects.blocks.body:getWorldPoints(objects.blocks.shape:getPoints()))
	
   end
   
function love.update(dt)

world:update(dt)
---bullet portion
	 for i,v in ipairs(bulletf) do
	 v["b"]:applyForce(v["dx"],v["dy"])
	 v["x"],v["y"] = v["b"]:getPosition()
	end
	


   if bear.x > bear.width  and love.keyboard.isDown("left") then   -- reduce the value
	 bear.b:applyForce(-1000,0)
	 bear.b:setLinearDamping(2.5)
	 bear.rotation = 180
   end
   if bear.x < 800 and love.keyboard.isDown("right") then   -- increase the value
	  bear.b:applyForce(1000,0)
	  bear.b:setLinearDamping(2.5)
	  bear.rotation = 0
   end

   if bear.y > bear.height  and love.keyboard.isDown("up") and timerjump == 0 then   -- reduce the value
   bear.b:applyLinearImpulse(0,-1000)
   bear.b:setLinearDamping(2.5)
   timerjump = 50
   end
   
   if bear.y < 600 and love.keyboard.isDown("down") then   -- increase the value
   end
   
   
   
   bear.x, bear.y = bear.b:getPosition()
if timer1 ~= 0 then 
timer1 = timer1 - 1
end
if timer1 == 0 then 
timer1 = 0
end

if timerjump ~= 0 then 
timerjump = timerjump - 1
end
if timerjump == 0 then 
timerjump = 0
end

if love.keyboard.isDown("d") and timer1 == 0 then
        local startX = bear["x"] + ((bear.width/2 + 20) * math.cos(math.rad(bear.rotation)))
        local startY = bear["y"] + ((bear.height/2 + 20)* math.sin(math.rad(bear.rotation)))
		
		local bulletfDx = bulletforce * math.cos(math.rad(bear.rotation))
        local bulletfDy = bulletforce * math.sin(math.rad(bear.rotation))
				
		local b = love.physics.newBody(world,startX,startY, "dynamic")
        local s = love.physics.newCircleShape(3)
		local f = love.physics.newFixture(b, s)
		
		
		table.insert(bulletf, {x = startX, y = startY, b = b,  s = s, f = f, z = f:setUserData("bulletf"), dx = bulletfDx, dy = bulletfDy})
		
		
		timer1 = 30
    end
   
end
   
   
function beginContact(a, b, coll)
    x,y = coll:getNormal()
    text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
end

function endContact(a, b, coll)
    persisting = 0
    text = text.."\n"..a:getUserData().." uncolliding with "..b:getUserData()
end

function preSolve(a, b, coll)
    if persisting == 0 then    -- only say when they first start touching
        text = text.."\n"..a:getUserData().." touching "..b:getUserData()
    elseif persisting < 20 then    -- then just start counting
        text = text.." "..persisting
    end
    persisting = persisting + 1    -- keep track of how many updates they've been touching for
end

function postSolve(a, b, coll)
end