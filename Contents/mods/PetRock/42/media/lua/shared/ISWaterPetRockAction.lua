--***********************************************************
--**                    Erasmus Crowley                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISWaterPetRockAction = ISBaseTimedAction:derive("ISWaterPetRockAction");

local function faceRock(character,rock)
	character:faceLocationF(rock:getWorldPosX(), rock:getWorldPosY())
end

function ISWaterPetRockAction:isValid()
    if isClient() and self.item then
        return self.character:getInventory():containsID(self.item:getID());
    else
        return self.character:getInventory():contains(self.item);
    end
end


function ISWaterPetRockAction:waitToStart()
	faceRock(self.character,self.rock)
	return self.character:shouldBeTurning()
end

function ISWaterPetRockAction:start()
	if isClient() and self.item then
		self.item = self.character:getInventory():getItemById(self.item:getID())
	end

    if self.item ~= nil then
	    self.item:setJobType(getText("IGUI_JobType_PourOut"));
	    self.item:setJobDelta(0.0);
		if instanceof(self.item, "DrainableComboItem") then
			self.startUsedDelta = self.item:getCurrentUsesFloat();
		elseif self.item:getFluidContainer() then
			self.startUsedDelta = self.item:getFluidContainer():getAmount();
		end
	
		self:setActionAnim(CharacterActionAnims.Pour);
		self:setAnimVariable("PourType", self.item:getPourType());
		self:setOverrideHandModels(self.item, nil);
		
		self.character:reportEvent("EventTakeWater");

		self.sound = self.character:playSound(self.item:getPourLiquidOnGroundSound())
    end


end

function ISWaterPetRockAction:update()
	if self.item ~= nil then
        self.item:setJobDelta(self:getJobDelta());
		
    end
end


function ISWaterPetRockAction:stop()
	self:stopSound()
    if self.item ~= nil then
        self.item:setJobDelta(0.0);
     end
    ISBaseTimedAction.stop(self);
end

function ISWaterPetRockAction:perform()
	self:stopSound()
	if self.item ~= nil then
        self.item:setJobDelta(0.0);
     end
    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISWaterPetRockAction:stopSound()
	if self.sound and self.character:getEmitter():isPlaying(self.sound) then
		self.character:stopOrTriggerSound(self.sound);
	end
end

function ISWaterPetRockAction:complete()
	if self.item ~= nil then
		self.item:getContainer():setDrawDirty(true);
		self.item:setJobDelta(0.0);
		if instanceof(self.item, "DrainableComboItem") then
			self.item:setUsedDelta(0.0);
			self.item:Use(false, false, true);
		elseif self.item:getFluidContainer() then
			-- self.item:getFluidContainer():Empty();
			self.item:getFluidContainer():removeFluid(self.amount)
		end
	end

	return true
end

function ISWaterPetRockAction:getDuration()
	return self.maxTime
end

function ISWaterPetRockAction:new (character, item ,amount, rockObj ,time)
	local o = ISBaseTimedAction.new(self, character)
	o.character = character;
	o.item = item;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	o.amount = amount;

	o.rock = rockObj;

	o.stopOnAim = false;

	return o
end
