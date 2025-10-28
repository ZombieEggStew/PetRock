--***********************************************************
--**                    THE INDIE STONE                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISPetRockAction = ISBaseTimedAction:derive("ISPetRockAction");

local function faceRock(character,rock)
	character:faceLocationF(rock:getWorldPosX(), rock:getWorldPosY())
end

function ISPetRockAction:isValid()
	return self.character:getSquare():DistTo(self.rock:getSquare()) < 3;
end

function ISPetRockAction:waitToStart()
	faceRock(self.character,self.rock)
	return self.character:shouldBeTurning()
end

function ISPetRockAction:update()
	self.character:setIsAiming(false);
	faceRock(self.character,self.rock)
end

function ISPetRockAction:start()
	forceDropHeavyItems(self.character)
	self:setOverrideHandModels(nil, nil)
	self.character:setVariable("AnimalSizeX", 0.01);
	self.character:setVariable("AnimalSizeY", .001);

	self.character:setVariable("petanimal", true)

	if self.rock:getWorldPosZ() > self.character:getZ() then
		self.character:setVariable("animal", "cow")
	else
		self.character:setVariable("animal", "rabbuck")
	end
	

	

	-- self.character:setVariable("animal", "cockerel")
	-- self.character:setVariable("animal", "lamb")
	-- self.character:setVariable("animal", "chick")
	-- self.character:setVariable("animal", "chick")
	
	
	-- self.character:setVariable("animal", "ram")

	

end

function ISPetRockAction:forceStop()
	self.character:setVariable("petanimal", false)

	self.action:forceStop();
end

function ISPetRockAction:stop()
	self.character:setVariable("petanimal", false)

    ISBaseTimedAction.stop(self);
end

function ISPetRockAction:perform()
	self.character:setVariable("petanimal", false)

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISPetRockAction:complete()

	return true
end

function ISPetRockAction:getDuration()

	return 400
end


function ISPetRockAction:animEvent(event, parameter)
	if event == "pettingFinished" then

		if not isServer() then
			self:forceStop()
		end
	end
end

function ISPetRockAction:new(character, rockObj)
	local o = ISBaseTimedAction.new(self, character)
	o.rock = rockObj;
	o.maxTime = o:getDuration()
	o.useProgressBar = false;
	o.stopOnAim = false;
	return o;
end
