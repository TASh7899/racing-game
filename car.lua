local Car = {}
Car.__index = Car

function Car:new(x, y, image)
	local self = setmetatable({}, Car)
	self.x = x
	self.y = y
	self.angle = 0
	self.speed = 0
	self.image = image
	self.width = image:getWidth()
	self.height = image:getHeight()

	self.baseAcceleration = 200
	self.baseMaxSpeed = 300
	self.braking = 350
	self.friction = 100

	self.steering = 0
	self.steeringSpeed = 4
	self.steeringReturnSpeed = 5
	self.turnPower = 4.5

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
	-- turning
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

	local turnRatio = 1.0 - (self.speed / self.baseMaxSpeed)

	turnRatio = math.max(0.7, turnRatio)

	local currentTurnPower = self.turnPower * turnRatio

	if self.speed ~= 0 then
		self.angle = self.angle + (self.steering * currentTurnPower * dt)
	end

	-- acceleration
	if love.keyboard.isDown("up") then
		self.speed = self.speed + (self.acceleration * dt)
	elseif love.keyboard.isDown("down") then
		self.speed = self.speed - (self.braking * dt)
	else
		if self.speed > 0 then
			self.speed = self.speed - (self.friction * dt)
		elseif self.speed < 0 then
			self.speed = self.speed + (self.friction * dt)
		end

		if math.abs(self.speed) < 10 then
			self.speed = 0
		end
	end

	-- clamp speed
	if self.speed > self.maxSpeed then
		self.speed = self.maxSpeed
	end

	if self.speed < -self.maxSpeed / 2 then
		self.speed = -self.maxSpeed / 2
	end

	-- 4. Update Position using trigonometry
	-- this will move player in direction of current angle
	self.x = self.x + (math.cos(self.angle) * self.speed * dt)
	self.y = self.y + (math.sin(self.angle) * self.speed * dt)
end

function Car:draw()
	love.graphics.draw(self.image, self.x, self.y, self.angle, 1, 1, self.width / 2, self.height / 2)
end

return Car
