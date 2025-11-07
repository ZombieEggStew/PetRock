require "TimedActions/ISBaseTimedAction"
-- ...existing code...
ISDropPetRockAction = ISBaseTimedAction:derive("ISDropPetRockAction")

function ISDropPetRockAction:isValid()
    return true
end

function ISDropPetRockAction:start()
    -- if isClient() and self.item then
    --     self.item = self.character:getInventory():getItemById(self.item:getID())
    -- end
    self.item:setJobDelta(0.0);


    -- local addToWorld = ISTransferAction:removeItemOnCharacter(self.character, self.item)
    -- if addToWorld then
    --     local dropX,dropY,dropZ = ISTransferAction.GetDropItemOffset(self.character, sq, self.item)
	--     sq:AddWorldInventoryItem(self.item, dropX, dropY, dropZ)
    -- end




    -- self.item:setJobDelta(0.0)
    -- 可选：设置播放的动作/动画名（常用 "Loot" "LootHeavy" "Read" 等）
    -- 如果动画名无效只是读条也可
    self:setActionAnim("Loot")
end

function ISDropPetRockAction:complete()

	local worldItem = self.sq:AddWorldInventoryItem(self.item, self.xoffset, self.yoffset, self.zoffset, false)
	if worldItem then
		worldItem:setWorldZRotation(self.rotation);
		if worldItem:getWorldItem() then
			worldItem:getWorldItem():setIgnoreRemoveSandbox(true); -- avoid the item to be removed by the SandboxOption WorldItemRemovalList
            worldItem:getWorldItem():setExtendedPlacement(false)
            worldItem:getWorldItem():transmitCompleteItemToClients();
		end
	end
    self.character:getInventory():Remove(self.item);
	sendRemoveItemFromContainer(self.character:getInventory(), self.item);

    return true
end

function ISDropPetRockAction:update()
    -- self.item:setJobDelta(self.action:getJobDelta());
    -- 每帧调用：可以在这里做朝向/保持位置等
    -- self.character:faceLocation(x,y) 等
end

function ISDropPetRockAction:stop()
    -- self.item:setJobDelta(0.0)
    ISBaseTimedAction.stop(self)
end

function ISDropPetRockAction:perform()
    -- self.item:setJobDelta(0.0)
    -- 动作完成时调用：在这里写完成逻辑（或留空）
    
    ISBaseTimedAction.perform(self)
end


---@param func ?function -- 完成后回调函数
function ISDropPetRockAction:new(character,item,sq,func, time)
    local o = ISBaseTimedAction.new(self, character)
    o.character = character
    o.item = item
    o.onStart = func                  -- 可选：完成后调用的函数
    o.maxTime = time or 50           -- 调整读条时长

    o.sq = sq;

    o.xoffset = .5;
	o.yoffset = .5;
	o.zoffset = 0;
	o.rotation = 0;

    o.stopOnWalk = true               -- 移动会取消
    o.stopOnRun = true
    o.stopOnAim = true
    return o
end
-- ...existing code...