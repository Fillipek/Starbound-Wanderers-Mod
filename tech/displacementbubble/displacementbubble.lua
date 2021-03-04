require "/scripts/util.lua"

function init ()
	self.maxSpeed = config.getParameter("maxSpeed", 15)
	self.acceleration = config.getParameter("acceleration", 40)
end

function update (args)
	if mcontroller.zeroG() then
		if args.moves["special1"] and not self.specialDown then
			if not self.isActive then
				activate()
			else
				deactivate()
			end
		end
		self.specialDown = args.moves["special1"]

		self.inputVector = getInputVector(args.moves)
		self.spaceDown = args.moves["jump"]

		if self.isActive then
			applyMove(args.dt)
			mcontroller.controlDown()
		end
	else
		uninit()
	end
end

function activate ()

	tech.setParentState("Stand")
	animator.playSound("activate")
	animator.setAnimationState("bubble", "activate")
	animator.setParticleEmitterActive("dashParticles", true)
	self.isActive = true

end

function deactivate ()

	tech.setParentState(nil)
	animator.playSound("deactivate")
	animator.setAnimationState("bubble", "deactivate")
	animator.setParticleEmitterActive("dashParticles", false)
	self.isActive = false

end

function getInputVector(moves)

	local x, y = 0, 0
	if moves["left"] then x = -1 end
	if moves["right"] then x = 1 end
	if moves["up"] then y = 1 end
	if moves["down"] then y = -1 end

	if x ~= 0 and y ~= 0 then
		x = x / math.sqrt(2)
		y = y / math.sqrt(2)
	end

	return { x,y }

end

function applyMove (dt)

	local signum = function (x) if x < 0 then return -1 else return 1 end end

	local dx = self.inputVector[1] * self.acceleration * dt
	local dy = self.inputVector[2] * self.acceleration * dt

	local currentVelocity = mcontroller.velocity()

	-- break down if spacebar is pressed
	if self.spaceDown then
		dx = -signum( currentVelocity[1] ) * self.acceleration * dt
		dy = -signum( currentVelocity[2] ) * self.acceleration * dt
	end

	local newVelocity = {
		currentVelocity[1] + dx,
		currentVelocity[2] + dy
	}

	local newSpeed = math.sqrt( newVelocity[1]^2 + newVelocity[2]^2 )

	if newSpeed >= self.maxSpeed then
		newVelocity = {
			newVelocity[1] / newSpeed * self.maxSpeed,
			newVelocity[2] / newSpeed * self.maxSpeed
		}
	end

	-- stop deccelarating if reaching speed 0
	if self.spaceDown then
		if newVelocity[1] * currentVelocity[1] <= 0 then newVelocity[1] = 0 end
		if newVelocity[2] * currentVelocity[2] <= 0 then newVelocity[2] = 0 end
	end

	mcontroller.setVelocity(newVelocity)

end

function uninit ()
	tech.setParentState(nil)
	animator.setAnimationState("bubble", "off")
	self.isActive = false
end
