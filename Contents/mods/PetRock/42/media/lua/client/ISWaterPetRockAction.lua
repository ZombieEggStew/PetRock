--***********************************************************
--**                    Erasmus Crowley                    **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISWaterPetRockAction = ISBaseTimedAction:derive("ISWaterPetRockAction");

function ISWaterPetRockAction:isValid()
    if isClient() and self.item then
        return self.character:getInventory():containsID(self.item:getID());
    else
        return self.character:getInventory():contains(self.item);
    end
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
		self.character:faceLocation(self.sq:getX(), self.sq:getY())
		self.character:reportEvent("EventTakeWater");

		self.sound = self.character:playSound(self.item:getPourLiquidOnGroundSound())
    end
end

function ISWaterPetRockAction:updateDumpingWater()
    local progress
    if not isServer() then
        progress = self:getJobDelta()
    else
        progress = self.netAction:getProgress()
    end
    if instanceof(self.item, "DrainableComboItem") then
        self.item:setUsedDelta(self.startUsedDelta * (1 - progress));
    elseif self.item:getFluidContainer() then
        self.item:getFluidContainer():removeFluid(self.startUsedDelta / self.maxTime);
    end
end

function ISWaterPetRockAction:update()
	if self.item ~= nil then
        self.item:setJobDelta(self:getJobDelta());
		
        if not isClient() then
            -- self:updateDumpingWater();
        end
    end
end

function ISWaterPetRockAction:animEvent(event, parameter)
	if isServer() then
		if event == 'DumpingWaterUpdate' then
			self:updateDumpingWater()
			sendItemStats(self.item)
		end
	end
end

function ISWaterPetRockAction:serverStart()
	emulateAnimEvent(self.netAction, 100, "DumpingWaterUpdate", nil)
	if self.item then
	    if instanceof(self.item, "DrainableComboItem") then
            self.startUsedDelta = self.item:getCurrentUsesFloat();
        elseif self.item:getFluidContainer() then
            self.startUsedDelta = self.item:getFluidContainer():getAmount();
        end
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
-- function ISWaterPetRockAction:getDuration()
-- 	if self.character:isTimedActionInstant() then
-- 		return 1;
-- 	end
-- 	local maxTime = 10;
-- 	if instanceof(self.item, "DrainableComboItem") then
-- 		maxTime = self.item:getCurrentUses() * 10;
-- 	elseif self.item:getFluidContainer() then
-- 		maxTime = self.item:getFluidContainer():getAmount();
-- 	end
-- 	if maxTime > 150 then
-- 		maxTime = 150;
-- 	end
-- 	if maxTime < 30 then
-- 		maxTime = 30;
-- 	end

-- 	return maxTime
-- end

function ISWaterPetRockAction:new (character, item ,amount, sq ,time)
	local o = ISBaseTimedAction.new(self, character)
	o.character = character;
	o.item = item;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	o.amount = amount;

	o.sq = sq;

	return o
end
