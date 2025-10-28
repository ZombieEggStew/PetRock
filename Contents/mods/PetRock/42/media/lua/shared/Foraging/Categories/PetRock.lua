require "Foraging/forageDefinitions";
require "Foraging/forageSystem";

local function generateMyStoneDefs()
    local stones = {
        My_Diorite = {
            type = "Base.My_Diorite", -- 确保这个 fullType 已定义或使用已有 Base 类型
            snowChance = -50,
            rainChance = 10,
            xp = 30,
            categories = { "Stones" }, -- 放入 Stones 类别
            zones = {
				BirchForest		= 5,
				PHForest		= 5,
				PRForest		= 5,
				DeepForest		= 5,
				FarmLand    	= 5,
				ForagingNav 	= 5,
				Forest      	= 5,
				OrganicForest	= 5,
				TownZone    	= 15,
				TrailerPark 	= 5,
				Vegitation  	= 5,
            },
        },
        My_Boulder = {
            type = "Base.My_Boulder", -- 确保这个 fullType 已定义或使用已有 Base 类型
            snowChance = -50,
            rainChance = 10,
            xp = 30,
            categories = { "Stones" }, -- 放入 Stones 类别
            zones = {
				BirchForest		= 5,
				PHForest		= 5,
				PRForest		= 5,
				DeepForest		= 5,
				FarmLand    	= 5,
				ForagingNav 	= 5,
				Forest      	= 5,
				OrganicForest	= 5,
				TownZone    	= 15,
				TrailerPark 	= 5,
				Vegitation  	= 5,
            },
        },
        My_HeatRock = {
            type = "Base.My_HeatRock", -- 确保这个 fullType 已定义或使用已有 Base 类型
            snowChance = -50,
            rainChance = 10,
            xp = 30,
            categories = { "Stones" }, -- 放入 Stones 类别
            zones = {
				BirchForest		= 5,
				PHForest		= 5,
				PRForest		= 5,
				DeepForest		= 5,
				FarmLand    	= 5,
				ForagingNav 	= 5,
				Forest      	= 5,
				OrganicForest	= 5,
				TownZone    	= 15,
				TrailerPark 	= 5,
				Vegitation  	= 5,
            },
            -- itemSizeModifier = 0.5,
			-- isItemOverrideSize = true,
            canBeAboveFloor = true,
        },
        My_StoneHatchEgg = {
            type = "Base.My_StoneHatchEgg", -- 确保这个 fullType 已定义或使用已有 Base 类型
            snowChance = -50,
            rainChance = 10,
            xp = 30,
            categories = { "Stones" }, -- 放入 Stones 类别
            zones = {
				BirchForest		= 5,
				PHForest		= 5,
				PRForest		= 5,
				DeepForest		= 5,
				FarmLand    	= 5,
				ForagingNav 	= 5,
				Forest      	= 5,
				OrganicForest	= 5,
				TownZone    	= 15,
				TrailerPark 	= 5,
				Vegitation  	= 5,
            },
        },
        My_BocchiTheRock = {
            type = "Base.My_BocchiTheRock", -- 确保这个 fullType 已定义或使用已有 Base 类型
            snowChance = -50,
            rainChance = 10,
            xp = 30,
            categories = { "Stones" }, -- 放入 Stones 类别
            zones = {
				BirchForest		= 5,
				PHForest		= 5,
				PRForest		= 5,
				DeepForest		= 5,
				FarmLand    	= 5,
				ForagingNav 	= 5,
				Forest      	= 5,
				OrganicForest	= 5,
				TownZone    	= 15,
				TrailerPark 	= 5,
				Vegitation  	= 5,
            },
        },
        My_Normal_Rock_1 = {
            type = "Base.My_Normal_Rock_1", -- 确保这个 fullType 已定义或使用已有 Base 类型
            snowChance = -50,
            rainChance = 10,
            xp = 30,
            categories = { "Stones" }, -- 放入 Stones 类别
            zones = {
				BirchForest		= 5,
				PHForest		= 5,
				PRForest		= 5,
				DeepForest		= 5,
				FarmLand    	= 5,
				ForagingNav 	= 5,
				Forest      	= 5,
				OrganicForest	= 5,
				TownZone    	= 15,
				TrailerPark 	= 5,
				Vegitation  	= 5,
            },
        },
        My_Normal_Rock_2 = {
            type = "Base.My_Normal_Rock_2", -- 确保这个 fullType 已定义或使用已有 Base 类型
            snowChance = -50,
            rainChance = 10,
            xp = 30,
            categories = { "Stones" }, -- 放入 Stones 类别
            zones = {
				BirchForest		= 5,
				PHForest		= 5,
				PRForest		= 5,
				DeepForest		= 5,
				FarmLand    	= 5,
				ForagingNav 	= 5,
				Forest      	= 5,
				OrganicForest	= 5,
				TownZone    	= 15,
				TrailerPark 	= 5,
				Vegitation  	= 5,
            },
        },
        My_Normal_Rock_3 = {
            type = "Base.My_Normal_Rock_3", -- 确保这个 fullType 已定义或使用已有 Base 类型
            snowChance = -50,
            rainChance = 10,
            xp = 30,
            categories = { "Stones" }, -- 放入 Stones 类别
            zones = {
				BirchForest		= 5,
				PHForest		= 5,
				PRForest		= 5,
				DeepForest		= 5,
				FarmLand    	= 5,
				ForagingNav 	= 5,
				Forest      	= 5,
				OrganicForest	= 5,
				TownZone    	= 15,
				TrailerPark 	= 5,
				Vegitation  	= 5,
            },
        },
        My_Normal_Rock_4 = {
            type = "Base.My_Normal_Rock_4", -- 确保这个 fullType 已定义或使用已有 Base 类型
            snowChance = -50,
            rainChance = 10,
            xp = 30,
            categories = { "Stones" }, -- 放入 Stones 类别
            zones = {
				BirchForest		= 5,
				PHForest		= 5,
				PRForest		= 5,
				DeepForest		= 5,
				FarmLand    	= 5,
				ForagingNav 	= 5,
				Forest      	= 5,
				OrganicForest	= 5,
				TownZone    	= 15,
				TrailerPark 	= 5,
				Vegitation  	= 5,
            },
        },
        My_Normal_Rock_5 = {
            type = "Base.My_Normal_Rock_5", -- 确保这个 fullType 已定义或使用已有 Base 类型
            snowChance = -50,
            rainChance = 10,
            xp = 30,
            categories = { "Stones" }, -- 放入 Stones 类别
            zones = {
				BirchForest		= 5,
				PHForest		= 5,
				PRForest		= 5,
				DeepForest		= 5,
				FarmLand    	= 5,
				ForagingNav 	= 5,
				Forest      	= 5,
				OrganicForest	= 5,
				TownZone    	= 15,
				TrailerPark 	= 5,
				Vegitation  	= 5,
            },
        },

        -- 可以继续添加更多定义...
    };

    for itemName, itemDef in pairs(stones) do
        forageSystem.addForageDef(itemName, itemDef);
    end;
end

generateMyStoneDefs();