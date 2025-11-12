RockEnthusiastTrait = {}

RockEnthusiastTrait.DoTraits = function()

    local RockEnthusiast = TraitFactory.addTrait(
        "rock",
        "RockEnthusiast",
        0,
        "you love rocks",
        false
    )

    TraitFactory.sortList()
end


Events.OnGameBoot.Add(RockEnthusiastTrait.DoTraits)
