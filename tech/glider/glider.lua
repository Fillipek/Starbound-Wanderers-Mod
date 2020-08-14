function init ()
  
end

function update (args)
  
  if self.isActive then
	if mcontroller.liquidMovement() then
	  techActiveWater()
	else
	  techActiveAir()
	end
  end
  
  if args.moves["special1"] and not self.specialDown then
    if self.isActive then
	  --switch off
	  deactivate()
	  self.isActive = false
    else
	  --switch on
	  activate()
      self.isActive = true
    end
  end
  
  self.specialDown = args.moves["special1"]
  
end

function techActiveWater()
  
  self.delta = world.distance(tech.aimPosition(), mcontroller.position())
  
  if self.delta[2] >= 0 then
    self.bodyAngle = math.acos( self.delta[1] / math.sqrt(self.delta[1]^2 + self.delta[2]^2) ) - math.pi / 2
  else
    self.bodyAngle = -1 * math.acos( self.delta[1] / math.sqrt(self.delta[1]^2 + self.delta[2]^2) ) - math.pi / 2
  end

  if self.delta[1] <= 0 then
	self.setFacingDirection = -1;
	mcontroller.controlFace(self.setFacingDirection)	
  else
	self.setFacingDirection = 1;
	mcontroller.controlFace(self.setFacingDirection)
  end
  
  if math.abs(self.delta[1]) < 5 and math.abs(self.delta[2]) < 5 then
    mcontroller.setVelocity( {0, 0} )
    mcontroller.setRotation(0)
	tech.setParentState(nil)
  else
    mcontroller.setVelocity(self.delta)
    mcontroller.setRotation(self.bodyAngle)
	tech.setParentState("swim")
  end
  
  animator.setAnimationState("gliderFront", "off")
  animator.setAnimationState("gliderBack", "off")
  animator.stopAllSounds("flap")
  
end

function techActiveAir()

  self.delta = world.distance(tech.aimPosition(), mcontroller.position())
  
  if self.delta[2] >= 0 then
    self.bodyAngle = math.acos( self.delta[1] / math.sqrt(self.delta[1]^2 + self.delta[2]^2) ) - math.pi / 2
  else
    self.bodyAngle = -1 * math.acos( self.delta[1] / math.sqrt(self.delta[1]^2 + self.delta[2]^2) ) - math.pi / 2
  end
  
  self.magnitude = math.sqrt(mcontroller.xVelocity()^2 + mcontroller.yVelocity()^2)
  
  --for correct wings animation
  if mcontroller.yVelocity() >= -7 or self.magnitude < 20 then
    animator.setAnimationState("gliderFront", "on")
    animator.setAnimationState("gliderBack", "on")
	animator.setSoundVolume("flap", 0.5, 0)
  else
    animator.setAnimationState("gliderFront", "dive")
    animator.setAnimationState("gliderBack", "dive")
	animator.setSoundVolume("flap", 0.0, 0.6)
  end

  if self.delta[1] <= 0 then
    self.gliderAngle = -1 * self.bodyAngle
    animator.setFlipped(true)
	self.setFacingDirection = -1;
	mcontroller.controlFace(self.setFacingDirection)	
  else
    animator.setFlipped(false)
	self.gliderAngle = self.bodyAngle
	self.setFacingDirection = 1;
	mcontroller.controlFace(self.setFacingDirection)
  end
  
  if math.abs(self.delta[1]) < 5 and math.abs(self.delta[2]) < 5 then
    mcontroller.setVelocity( {0, 0} )
	animator.rotateGroup("glider", 0)
    mcontroller.setRotation(0)
  else
    mcontroller.setVelocity(self.delta)
	animator.rotateGroup("glider", self.gliderAngle)
    mcontroller.setRotation(self.bodyAngle)
  end
  
  tech.setParentState(nil)
  status.addEphemeralEffect("hover")
  
end

function activate()
  tech.setToolUsageSuppressed(true)
  animator.playSound("activate")
  animator.setSoundVolume("flap", 0.5, 0)
  animator.playSound("flap", -1)
end

function deactivate()
  mcontroller.setRotation(0)
  tech.setToolUsageSuppressed(false)
  status.removeEphemeralEffect("hover")
  animator.setAnimationState("gliderFront", "off")
  animator.setAnimationState("gliderBack", "off")
  animator.stopAllSounds("flap")
  animator.playSound("deactivate")
  tech.setParentState(nil)
end