local MyLocations = {
    "MySatchel",
    "MyHat",
    "MyHat2"
}

local group = BodyLocations.getGroup("Human")
for _, location in ipairs(MyLocations) do
    local bodyLocation = BodyLocation.new(group, location)
    group:getAllLocations():add(bodyLocation)
end