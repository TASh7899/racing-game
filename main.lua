local Car = require("car")

function love.load()
	camera = require("lib/camera")
	sti = require("lib/sti")
	gameMap = sti("maps/test.lua")
	love.window.setTitle("Love racing game")
	love.graphics.setBackgroundColor(0.2, 0.7, 0.2)
	love.graphics.setDefaultFilter("nearest", "nearest")

	uiFont = love.graphics.newFont(18)

	CarSprite = love.graphics.newImage("assets/car-red.png")
	Car = Car:new(400, 300, CarSprite)

	cam = camera()
	cam:zoomTo(3)
end

function love.update(dt)
	Car:update(dt)
	cam:lookAt(Car.x, Car.y)
end

function love.draw()
	cam:attach()
	gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
	Car:draw()
	love.graphics.setColor(1, 1, 1)
	cam:detach()

	love.graphics.setFont(uiFont)
	love.graphics.print("Speed: " .. math.floor(Car.speed), 10, 10)
	love.graphics.print("Gear: " .. Car.currentGear, 10, 55)
	love.graphics.print(string.format("speed: %.1f", Car.speed), 10, 25)
	love.graphics.print(string.format("Max Speed: %.1f", Car.maxSpeed), 10, 40)
end

function love.keypressed(key)
	if key == "x" then
		Car:shiftUp()
	elseif key == "z" then
		Car:shiftDown()
	end
end
