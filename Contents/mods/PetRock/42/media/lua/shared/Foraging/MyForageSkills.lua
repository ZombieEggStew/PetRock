require "Foraging/forageDefinitions"

function DoRockHatCheck(_character, _skillDef, _bonusEffect)
    local wornItem = _character:getWornItem("MyHat")
    local wornItem2 = _character:getWornItem("MyHat2")
    if _bonusEffect == "specialisations" then
        if wornItem and wornItem:getType() == "My_PetrifiedPoop_Down" then

            return true
        elseif wornItem2 and wornItem2:getType() == "My_PetrifiedPoop_Up" then

            return true
        else

            return false
        end
    end
    if _bonusEffect == "visionBonus" then
        if wornItem and wornItem:getType() == "My_BocchiTheRock" then
            return true
        else
            return false
        end
    end
end

MyRockSkills = {
    rock = {
        name = "rock",
        type = "trait",
        visionBonus = 1.0,
        weatherEffect = 0,
        darknessEffect = 0,
        specialisations = {
            ["Stones"] = 100,
        },
        testFuncs = { DoRockHatCheck },
    },
}


for skillName, skillDef in pairs(MyRockSkills) do
    table.insert(forageSystem.forageSkillDefinitions, skillDef);
end
