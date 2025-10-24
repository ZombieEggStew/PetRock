local playerObj = nil
local bodyDamage = nil

local cm = nil
local cf = nil

local interval = 1
local timeAcc = 0
local g_playerHeatSource = nil
local normalTemperature = 36.5
local DefaultRadius = 1

local TYPE_PETROCKS = {
    Diorite = "My_Diorite",
    Boulder = "My_Boulder",
    HeatRock = "My_HeatRock",
    StoneHatchEgg = "My_StoneHatchEgg"
}

local CONFIG_HEATROCK_TEMPERATURE = {
    Temperature_3 = 60,
    Temperature_2 = 40,
    Temperature_1 = 30,
    Temperature_0 = 20,
    Temperature_m1 = 10,
    Temperature_m2 = 0,
    Temperature_m3 = -20,
    Coeff = .1
}

local CONFIG_BAR_COLOR = {
    Red = { r = 1, g = 0, b = 0, a = 1 },
    Blue = { r = 0, g = 0, b = 1, a = 1 },
    Green = { r = 0, g = 1, b = 0, a = 1 },
}
local CONFIG_TEXT_COLOR = {
    Normal = { r = 0.6, g = 0.8, b = 0.5, a = 0.6 } -- 实际上是{ g , b , a , r }
}

local TEXTURE_HEATROCK = {
    HeatRockm3 = Texture.trygetTexture("item_HeatRockm3"),
    HeatRockm2 = Texture.trygetTexture("item_HeatRockm2"),
    HeatRock = Texture.trygetTexture("item_HeatRock"),
    HeatRock2 = Texture.trygetTexture("item_HeatRock2"),
    HeatRock3 = Texture.trygetTexture("item_HeatRock3"),
}

local ALLOWED_DISPLAY_CATEGORIES = {
    MyPetRock = true,   -- 例如：只允许你的宠物石分类
}
local ALLOWED_FULL_TYPES = {
    ["Base.My_Diorite"]   = true,
    ["Base.My_Boulder"]   = true,
    ["Base.My_HeatRock"]  = true,
    ["Base.My_StoneHatchEgg"]  = true,
    ["Base.My_Bandaid_1"] = true,
    ["Base.My_Bandaid_2"] = true,
    ["Base.My_Bandaid_3"] = true,
    ["Base.My_Bandaid_4"] = true,
    ["Base.My_Bandaid_5"] = true,
}

LuaEventManager.AddEvent("OnHeatRockUpdate")


function PetRock_FannyPackAccept(container, item)
    if not item then return false end

    -- 1) 按显示分类过滤
    local dc = item:getDisplayCategory() or nil
    if dc and ALLOWED_DISPLAY_CATEGORIES[dc] then
        return true
    end

    -- 2) 兜底：按完整类型白名单过滤（Base.Module.ItemName）
    local ft = item.getFullType and item:getFullType() or nil
    if ft and ALLOWED_FULL_TYPES[ft] then
        return true
    end

    -- 3) 若你用 Tags 做分类，也可这样判断：
    -- if item.hasTag and item:hasTag("MyPetRock") then return true end

    return false
end



Events.OnCreatePlayer.Add(function(playerNum,player)
    playerObj = player
    bodyDamage = player:getBodyDamage()
    if not bodyDamage then
        print("Error: bodyDamage is nil")
    end

    cm = getClimateManager()
    if not cm then
        print("Error: ClimateManager is nil")
        return
    end
    cf = cm:getClimateFloat(4)
    if not cf then
        print("Error: ClimateFloat is nil")
        return
    end
end)

local function checkModDataTemp(md)
    if md.My_Temperature == nil then
        md.My_Temperature = CONFIG_HEATROCK_TEMPERATURE.Temperature_0
    end
end

local function checkModDataTime(md)
    if md.My_LastTime == nil then
        md.My_LastTime = getGameTime():getWorldAgeHours() * 3600
    end
end

-- local function changeBodyTemperature(md)
--     if not playerObj then return end
--     if not bodyDamage then return end
--     local envTemp = getClimateManager():getAirTemperatureForCharacter(playerObj)
--     local bodyTemp = bodyDamage:getTemperature()
--     print(bodyTemp)

--     bodyDamage:setTemperature(bodyTemp + (normalTemperature - bodyTemp) * .1 )
--     print(bodyDamage:getTemperature())
-- end

local function addOrUpdatePlayerHeatSource(tempC)
    if not playerObj then return end
    local cell = getCell()
    if not cell then return end
    local sq = playerObj:getSquare()
    if not sq then return end

    local x,y,z = sq:getX(), sq:getY(), sq:getZ()
    if g_playerHeatSource then
        -- 若位置变化则移除重建
        if g_playerHeatSource:getX() ~= x or g_playerHeatSource:getY() ~= y or g_playerHeatSource:getZ() ~= z then
            cell:removeHeatSource(g_playerHeatSource)
            g_playerHeatSource = nil
        end
    end

    if not g_playerHeatSource then
        g_playerHeatSource = IsoHeatSource.new(x, y, z, DefaultRadius, math.floor(tempC))
        cell:addHeatSource(g_playerHeatSource)

    else
        g_playerHeatSource:setTemperature(math.floor(tempC))
        g_playerHeatSource:setRadius(DefaultRadius)
    end
end

local function removePlayerHeatSource()
    if not g_playerHeatSource then return end

    getCell():removeHeatSource(g_playerHeatSource)
    g_playerHeatSource = nil
end

local onHeatRockUpdateFunc = function(_item)
    -- print("test")
    if _item:getType() ~= TYPE_PETROCKS.HeatRock then return end
    local md = _item:getModData()
    if not md then return end
    checkModDataTemp(md)

    if CONFIG_HEATROCK_TEMPERATURE.Temperature_2 < md.My_Temperature and md.My_Temperature <= CONFIG_HEATROCK_TEMPERATURE.Temperature_3 then
        _item:setIcon(TEXTURE_HEATROCK.HeatRock3)
    elseif CONFIG_HEATROCK_TEMPERATURE.Temperature_1 < md.My_Temperature and md.My_Temperature <= CONFIG_HEATROCK_TEMPERATURE.Temperature_2 then
        _item:setIcon(TEXTURE_HEATROCK.HeatRock2)
    elseif CONFIG_HEATROCK_TEMPERATURE.Temperature_m1 < md.My_Temperature and md.My_Temperature <= CONFIG_HEATROCK_TEMPERATURE.Temperature_1 then
        _item:setIcon(TEXTURE_HEATROCK.HeatRock)
    elseif CONFIG_HEATROCK_TEMPERATURE.Temperature_m2 < md.My_Temperature and md.My_Temperature <= CONFIG_HEATROCK_TEMPERATURE.Temperature_m1 then
        _item:setIcon(TEXTURE_HEATROCK.HeatRockm2)
    elseif CONFIG_HEATROCK_TEMPERATURE.Temperature_m3 <= md.My_Temperature and md.My_Temperature <= CONFIG_HEATROCK_TEMPERATURE.Temperature_m2 then
        _item:setIcon(TEXTURE_HEATROCK.HeatRockm3)
    end
end

local function isInFridgeAndPowered(container)
    if container:getType() == "fridge" or container:getType() == "freezer" then
        return container:isPowered()
    end
end

local function isInStoveAndLit(container)
    if container:getType() == "stove" then
        local stoveObj = container:getParent()
        if stoveObj and stoveObj:Activated() then
            return true
        end
    elseif container:getType() == "woodstove" then
        local woodstoveObj = container:getParent()
        if woodstoveObj and woodstoveObj:isLit() then
            return true
        end
    elseif container:getType() == "campfire" then
        local campfireSquare = container:getParent():getSquare()
        if campfireSquare and campfireSquare:hasLitCampfire() then
            return true
        end
    end
    return false
end


local org_transferAction = ISInventoryTransferAction.perform
function ISInventoryTransferAction:perform()
    if self.item:getType() ~= TYPE_PETROCKS.HeatRock then
        org_transferAction(self)
        return
    end

    -- print("perform transfer action")
    -- if self.item then
    --     print("item: " .. self.item:getType())
    -- end

    -- if self.destContainer then
    --     print("destContainer: " .. self.destContainer:getType())
    --     if self.destContainer:getType() == "woodstove" then
    --         local woodstoveObj = self.destContainer:getParent()
    --         if woodstoveObj and woodstoveObj:isLit() then
    --             print("lit")
    --         else
    --             print("unlit")
    --         end
    --     elseif self.destContainer:getType() == "campfire" then
    --         local campfireObj = self.destContainer:getParent()
    --         local square = campfireObj:getSquare()
    --         if square and square:hasLitCampfire() then
    --             print("lit")
    --         else
    --             print("unlit")
    --         end
    --     elseif self.destContainer:getType() == "stove" then
    --         local stoveObj = self.destContainer:getParent()
    --         if stoveObj and stoveObj:Activated() then
    --             print("lit")
    --         else
    --             print("unlit")
    --         end
    --     elseif self.destContainer:getType() == "fridge" then
    --         if self.destContainer:isPowered() then
    --             print("on")
    --         else
    --             print("off")
    --         end
    --     elseif self.destContainer:getType() == "freezer" then
    --         if self.destContainer:isPowered() then
    --             print("on")
    --         else
    --             print("off")
    --         end
    --     end
    -- end

    if isInFridgeAndPowered(self.destContainer) then
        local md = self.item:getModData()
        md.My_LastTime = getGameTime():getWorldAgeHours() * 3600
        md.My_isInFridge = true
        print("set in fridge")
    else
        local md = self.item:getModData()
        md.My_isInFridge = false
        print("set not in fridge")
    end

    if isInStoveAndLit(self.destContainer) then
        local md = self.item:getModData()
        md.My_LastTime = getGameTime():getWorldAgeHours() * 3600
        md.My_isInStove = true
        print("set in stove")
    else
        local md = self.item:getModData()
        md.My_isInStove = false
        print("set not in stove")
    end

    org_transferAction(self)
end

-- TO DO ： 改为每帧遍历身边的所有火炉和冰箱
-- Hook ISInventoryPane 的 render 方法
local originalRender = ISInventoryPane.render
function ISInventoryPane:render()
    originalRender(self)
    local container = self.inventory
    if not container then return end
    --print("container type: " .. tostring(container:getType()))
    if container:getType() == "fridge" or container:getType() == "freezer" then
        local t = container:FindAll(TYPE_PETROCKS.HeatRock)

        for i = 0, t:size() - 1 do
            local item = t:get(i)
            local md = item:getModData()

            if md.My_isInFridge then
                checkModDataTemp(md)
                checkModDataTime(md)

                if md.My_Temperature ~= CONFIG_HEATROCK_TEMPERATURE.Temperature_m3 then
                    local temp = md.My_Temperature -
                        (getGameTime():getWorldAgeHours() * 3600 - md.My_LastTime) * CONFIG_HEATROCK_TEMPERATURE.Coeff
                    md.My_Temperature = math.max(temp, CONFIG_HEATROCK_TEMPERATURE.Temperature_m3)
                    md.My_LastTime = getGameTime():getWorldAgeHours() * 3600
                    triggerEvent("OnHeatRockUpdate", item)
                end

                if not isInFridgeAndPowered(container)then
                    md.My_isInFridge = false
                end
            else
                if isInFridgeAndPowered(container)then
                    md.My_LastTime = getGameTime():getWorldAgeHours() * 3600
                    md.My_isInFridge = true
                end
            end
        end
    elseif container:getType() == "stove" or container:getType() == "woodstove" or container:getType() == "campfire" then
        local t = container:FindAll(TYPE_PETROCKS.HeatRock)

        for i = 0, t:size() - 1 do
            local item = t:get(i)
            local md = item:getModData()

            if md.My_isInStove then
                checkModDataTemp(md)
                checkModDataTime(md)

                if md.My_Temperature ~= CONFIG_HEATROCK_TEMPERATURE.Temperature_3 then
                    local temp = md.My_Temperature +
                        (getGameTime():getWorldAgeHours() * 3600 - md.My_LastTime) * CONFIG_HEATROCK_TEMPERATURE.Coeff
                    md.My_Temperature = math.min(temp, CONFIG_HEATROCK_TEMPERATURE.Temperature_3)
                    md.My_LastTime = getGameTime():getWorldAgeHours() * 3600
                    triggerEvent("OnHeatRockUpdate", item)
                end

                if not isInStoveAndLit(container)then
                    md.My_isInStove = false
                end
            else
                if isInStoveAndLit(container)then
                    md.My_LastTime = getGameTime():getWorldAgeHours() * 3600
                    md.My_isInStove = true
                end
            end
        end
    end
end

-- local org_transferStartAction = ISInventoryTransferAction.start
-- function ISInventoryTransferAction:start()
--     org_transferStartAction(self)
--     print(#self.queueList)
-- end




--TO DO: 优化计算公式 使用沙盒设置控制最高和最低温度
local tempX = nil
local tempY = nil
local function my_func(x)
    x = math.floor(x)
    if x ~= tempX then
        tempY = ((x - 20) / 40) ^ .2 * 45
        tempX = x
    end
    --print("input temp: " .. tostring(x) .. " -> output temp: " .. tostring(tempY))
    return tempY
end

local function my_func2(x)
    local y = ((x - 20) / 40) ^ .2 * 45
    --print("input temp: " .. tostring(x) .. " -> output temp: " .. tostring(y))
    return y
end



local function changeTemperature(item)
    local md = item:getModData()
    checkModDataTemp(md)
    local airTemp = getClimateManager():getAirTemperatureForCharacter(playerObj)
    local baseTemp = cm:getBaseTemperature()
    local playerTemp = bodyDamage:getTemperature()

    if md.My_Temperature >= CONFIG_HEATROCK_TEMPERATURE.Temperature_0 then
        -- print(md.My_Temperature)
        cf:setEnableOverride(false)
        addOrUpdatePlayerHeatSource(my_func(md.My_Temperature))

    else
        removePlayerHeatSource()
        cf:setEnableOverride(true)

        cf:setOverride(baseTemp + (0.5 * (md.My_Temperature - 20)), 1)

    end

    md.My_Temperature = md.My_Temperature -
        (md.My_Temperature - airTemp) * CONFIG_HEATROCK_TEMPERATURE.Coeff * 0.01
    triggerEvent("OnHeatRockUpdate", item)
end

local function playerCheck()
    if not playerObj then return end
    if not bodyDamage then return end
    if not cm then return end
    if not cf then return end
    -- print(bodyDamage:getTemperature())


    local inv = playerObj:getInventory()
    local t = inv:FindAll(TYPE_PETROCKS.HeatRock)

    if t:size() == 0 then
        -- cf:setEnableOverride(false)
    else
        changeTemperature(t:get(0))  -- 只影响第一个宠物石
        return
    end


    local worn = playerObj:getWornItems()
    --print(t2:contains(TYPE_PETROCKS.HeatRock))
    for i = 0 , worn:size() - 1 do
        local it = worn:getItemByIndex(i)
        -- local location = worn:getLocation(it)
        -- if location == "FannyPackFront" or location == "FannyPackBack" then
        -- end
        local type = it:getType()
        -- print(type)
        if type == "My_Bag_FannyPackFront" or type == "My_Bag_FannyPackBack" then
            local container = it:getItemContainer()
            if container then
                local t2 = container:FindAll(TYPE_PETROCKS.HeatRock)

                if t2:size() == 0 then
                    cf:setEnableOverride(false)
                else
                    changeTemperature(t2:get(0))  -- 只影响第一个宠物石
                end
            end
        end
    end
end








-- *************** UI ********************








-- 技术力不足，无法在tooltip中添加自定义内容
-- local originalToolTipRender = ISToolTipInv.render
-- function ISToolTipInv:render()
--     originalToolTipRender(self) -- 保留原有渲染

--     local tooltip = self.tooltip
--     if not tooltip then return end
--     local item = self.item
--     if not item then return end
--     if item:getType() ~= TYPE_PETROCKS.HeatRock then return end


--     -- 你的自定义内容
--     local md = item:getModData()
--     local temp = md and md.My_Temperature or 0
--     local font = tooltip:getFont() or UIFont.Small
--     --local text = "温度: " .. tostring(temp)
--     local text = "test:"
--     local x = 10
--     -- 计算新行的y坐标（在原有内容下方）
--     local y = tooltip:getHeight() + 4

--     -- 绘制自定义文本
--     tooltip:DrawText(font, text, x, y, 1, 0.5, 0.2, 1)

--     -- 让tooltip宽度自适应
--     tooltip:adjustWidth(x, text)
--     -- 让tooltip高度自适应
--     tooltip:setHeight(y + getTextManager():getFontHeight(font) + 40)


-- end

local org_drawItemDetails = ISInventoryPane.drawItemDetails
function ISInventoryPane:drawItemDetails(item, y, xoff, yoff, red)
    if item:getType() ~= TYPE_PETROCKS.HeatRock then
        org_drawItemDetails(self, item, y, xoff, yoff, red)
        return
    end
    local top = self.headerHgt + y * self.itemHgt + yoff
    local md = item:getModData()
    local fraction = 0
    local barColor = CONFIG_BAR_COLOR.Green
    checkModDataTemp(md)
    -- print("Temperature: " .. tostring(md.My_Temperature))


    if md.My_Temperature >= CONFIG_HEATROCK_TEMPERATURE.Temperature_0 then
        barColor = CONFIG_BAR_COLOR.Red
        fraction = (md.My_Temperature - CONFIG_HEATROCK_TEMPERATURE.Temperature_0)
            / (CONFIG_HEATROCK_TEMPERATURE.Temperature_3 - CONFIG_HEATROCK_TEMPERATURE.Temperature_0)
    else
        barColor = CONFIG_BAR_COLOR.Blue
        fraction = (md.My_Temperature - CONFIG_HEATROCK_TEMPERATURE.Temperature_0)
            / (CONFIG_HEATROCK_TEMPERATURE.Temperature_m3 - CONFIG_HEATROCK_TEMPERATURE.Temperature_0)
    end


    self:drawTextAndProgressBar(getText("IGUI_HeatRock_Temperature") .. ":", fraction, xoff, top,
        CONFIG_TEXT_COLOR.Normal, barColor)
end

-- 配置：武器 fullType -> 要播放的音效名（FMOD 事件名）
local WEAPON_SFX = {
    ["Base.My_Boulder"] = "NPC_Killed_2",
    ["Base.My_Boulder2"] = "NPC_Killed_2",
    -- 按需继续添加
}

local lastHit = {}

local function onHitZombie(zombie, attacker, bodyPart, weapon)
    if not zombie or not attacker or not instanceof(attacker, "IsoPlayer") then return end
    local wType = weapon and weapon:getFullType()
    if not wType then return end
    lastHit[zombie] = { attacker = attacker, weaponType = wType }
end

local function onZombieDead(zombie)
    local info = lastHit[zombie]
    if not info then return end
    lastHit[zombie] = nil

    local sfx = WEAPON_SFX[info.weaponType]
    if not sfx then return end

    -- 只在击杀者本地客户端播放，避免多人游戏重复播放
    local killer = info.attacker
    if killer and killer:isLocalPlayer() then
        killer:playSound(sfx)
    end
end

Events.OnHitZombie.Add(onHitZombie)
Events.OnZombieDead.Add(onZombieDead)

Events.OnHeatRockUpdate.Add(onHeatRockUpdateFunc)

Events.OnTick.Add(function ()

    local dt = getGameTime():getMultipliedSecondsSinceLastUpdate()
    timeAcc = timeAcc + dt
    if timeAcc >= interval then
        timeAcc = timeAcc - interval
        playerCheck()
    end
end)

--TO DO: 添加更多液体选项
local function isFluidContainerWithWater(item , amount)
    if instanceof(item, "DrainableComboItem") then
        print("old container detected, not supported")
        return false
    end
    if not (item and item.getFluidContainer) then return false end
    local fc = item:getFluidContainer()
    if not fc then return false end

    if not fc.getAmount then return false end
    -- print("fluid amount: " .. tostring( fc:getAmount() ))
    if fc:getAmount() < amount then return false end

    local t = fc:getPrimaryFluid():getFluidType()

    if not t then
        print("fluid type is nil")
        return false
    end
    print("fluid type: " .. t:toStringLower())

    if t:toStringLower() == "water" then
        return true
    end
end



local fun1 = function(_playerNum,_context,_worldObjects)
    if not playerObj then return end

    for i = 1 , #_worldObjects do
        local obj = _worldObjects[i]

        if instanceof(obj, "IsoWorldInventoryObject")then
            local item = obj:getItem()
            print("object type: " .. tostring(item:getType()))


            for _,v in pairs(TYPE_PETROCKS) do
                if item:getType() == v then
                    local petRockOption = _context:addOptionOnTop(getText("IGUI_" .. v) , nil , function ()
                        print("test")
                    end)
                    petRockOption.iconTexture = item:getIcon()
                end
            end
            _context:addOption("Test Option", nil, function()
                -- print("You clicked the test option on " .. tostring(item:getType()))
                local waterItem = playerObj:getInventory():FindAndReturn("Base.WaterBottle")

                local waterItem2 = playerObj:getInventory():FindAndReturn("Base.WateredCan")

                if not waterItem then
                    --print("No WateredCan found in inventory.")
                    return
                end

                if isFluidContainerWithWater(waterItem , .01) then
                    print("Found waterBottle with at least 10ml units of water.")
                else
                    print("No waterBottle with enough water found in inventory.")
                end
                local walkAction = ISWalkToTimedAction:new(playerObj, obj:getSquare())
                local action = ISWaterPetRockAction:new(playerObj, waterItem , 0.01 ,obj:getSquare() , 150)
                --local action2 = ISWaterPlantAction:new(playerObj, waterItem2 , 10 , obj:getSquare() , 200)

                ISTimedActionQueue.add(walkAction)
                ISTimedActionQueue.add(action)
            end)
        end


    end

end

Events.OnFillWorldObjectContextMenu.Add(fun1)

-- local og_ISHealthPanel_doBodyPartContextMenu = ISHealthPanel.doBodyPartContextMenu
-- function ISHealthPanel:doBodyPartContextMenu(bodyPart, x, y)
--     og_ISHealthPanel_doBodyPartContextMenu(self, bodyPart, x, y)
--     if not playerObj then return end

--     local cm = getClimateManager()
--     if not cm then return end
--     local cf = cm:getClimateFloat(4)

--     local newOverride = cf:getOverride()

--     local playerNum = self.otherPlayer and self.otherPlayer:getPlayerNum() or self.character:getPlayerNum()

--     local context = getPlayerContextMenu(playerNum)

--     if not context then
--         print("no context")
--         return
--     end

--     context:bringToTop()
--     context:setVisible(true)
--     context:addOption(getText("test"), nil, function()
--         -- bodyPart:setTemperature(50)
--         -- cm:setTemperature(50)
--         cf:setEnableOverride(false)
--         print(cm:getTemperature())
--         cf:setEnableOverride(true)

--         cf:setOverride(-50, 1)
--         --print(cm:getBaseTemperature())
--     end)
--     context:addOption(getText("test2"), nil, function()
--         -- bodyPart:setTemperature(50)
--         -- cm:setTemperature(50)
--         cf:setEnableOverride(false)
--         print(cm:getTemperature())
--     end)
-- end

local function delayedExec(func, delayInSeconds)
    local timeLeft = delayInSeconds
    local timerFunc
    
    timerFunc = function()
        timeLeft = timeLeft - getGameTime():getRealworldSecondsSinceLastUpdate()
        
        if timeLeft <= 0 then
            Events.OnTick.Remove(timerFunc)
            if func then
                func()
            end
        end
    end
    
    Events.OnTick.Add(timerFunc)
end

local function MyOnPlayerBump(character, currentState, pre)
    if not playerObj then return end
    if character ~= playerObj then return end
    if not character:isBumpFall() then return end
    
    print("test1")
    
    delayedExec(function()
        print("test3")
        local sq = character:getCurrentSquare()
        if not sq then return end
        
        local worn = playerObj:getWornItems()
        if not worn then return end
        
        for i = 0, worn:size() - 1 do
            local wornItem = worn:getItemByIndex(i)
            if wornItem and wornItem:getType() == "My_Bag_Satchel" then
                local container = wornItem:getItemContainer()
                if container then
                    local items = container:getItems()
                    -- 从后往前遍历,避免删除时索引错乱
                    for j = items:size() - 1, 0, -1 do
                        local item = items:get(j)
                        -- 50% 概率掉落
                        if ZombRand(100) < 50 then
                            sq:AddWorldInventoryItem(item, ZombRand(0, 80) / 100, ZombRand(0, 80) / 100, 0)
                            container:Remove(item)
                        end
                    end
                end
            end
        end
    end, 1)
end

Events.OnAIStateChange.Add(MyOnPlayerBump)

