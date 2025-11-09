local Car = {}
Car.__index = Car

function Car:new(x, y, image)
	local self = setmetatable({}, Car)
	self.x = x
	self.y = y
	self.angle = 0
	self.vx = 0
	self.vy = 0
	self.image = image
	self.width = image:getWidth()
	self.height = image:getHeight()

	self.baseAcceleration = 200
	self.baseMaxSpeed = 300
	self.braking = 350

	self.drag = 0.1
	self.grip = 5.0

	self.steering = 0
	self.steeringSpeed = 4
	self.steeringReturnSpeed = 5
	self.turnPower = 4
	self.currentSpeed = 0

	self.currentGear = 1
	self.maxGear = 5

	self.gearRatio = {
		[1] = { accel = 1.0, speed = 0.25 },
		[2] = { accel = 0.8, speed = 0.45 },
		[3] = { accel = 0.6, speed = 0.65 },
		[4] = { accel = 0.45, speed = 0.85 },
		[5] = { accel = 0.35, speed = 1.0 },
	}

	self:updateGearStats()

	return self
end

function Car:updateGearStats()
	local gearData = self.gearRatio[self.currentGear]
	self.acceleration = self.baseAcceleration * gearData.accel
	self.maxSpeed = self.baseMaxSpeed * gearData.speed
end

function Car:shiftUp()
	if self.currentGear < self.maxGear then
		self.currentGear = self.currentGear + 1
		self:updateGearStats()
	end
end

function Car:shiftDown()
	if self.currentGear > 1 then
		self.currentGear = self.currentGear - 1
		self:updateGearStats()
	end
end

function Car:update(dt)
	self.currentSpeed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
	-- turning --

	if love.keyboard.isDown("left") then
		self.steering = self.steering - (self.steeringSpeed * dt)
	elseif love.keyboard.isDown("right") then
		self.steering = self.steering + (self.steeringSpeed * dt)
	else
		if self.steering > 0 then
			self.steering = self.steering - (self.steeringReturnSpeed * dt)
			if self.steering < 0 then
				self.steering = 0
			end
		elseif self.steering < 0 then
			self.steering = self.steering + (self.steeringReturnSpeed * dt)
			if self.steering > 0 then
				self.steering = 0
			end
		end
	end

	self.steering = math.max(-1, math.min(1, self.steering))

	local turnRatio = 1.0 - (self.currentSpeed / self.baseMaxSpeed)
	turnRatio = math.max(0.5, turnRatio)
	local currentTurnPower = self.turnPower * turnRatio

	if self.currentSpeed > 1 then
		self.angle = self.angle + (self.steering * currentTurnPower * dt)
	end

	local fwdX = math.cos(self.angle)
	local fwdY = math.sin(self.angle)
	local rightX = -fwdY
	local rightY = fwdX

	local forwardSpeed = self.vx * fwdX + self.vy * fwdY
	local sidewaysSpeed = self.vx * rightX + self.vy * rightY

	local accelForce = 0
	if love.keyboard.isDown("up") then
		accelForce = self.acceleration
	elseif love.keyboard.isDown("down") then
		accelForce = -self.braking
	end

	local forceX = fwdX * accelForce
	local forceY = fwdY * accelForce

	forceX = forceX - rightX * sidewaysSpeed * self.grip
	forceY = forceY - rightY * sidewaysSpeed * self.grip

	forceX = forceX - self.vx * self.drag
	forceY = forceY - self.vy * self.drag

	self.vx = self.vx + forceX * dt
	self.vy = self.vy + forceY * dt

	self.currentSpeed = math.sqrt(self.vx * self.vx + self.vy * self.vy)

	if self.currentSpeed > self.maxSpeed then
		local scale = self.maxSpeed / self.currentSpeed
		self.vx = self.vx * scale
		self.vy = self.vy * scale
		self.currentSpeed = self.maxSpeed
	end

	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt
end

function Car:draw()
	love.graphics.draw(self.image, self.x, self.y, self.angle, 1, 1, self.width / 2, self.height / 2)
end

return Car
