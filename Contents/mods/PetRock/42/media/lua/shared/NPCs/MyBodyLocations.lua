local MyLocations = {
    "MySatchel",
    "MyHat"
}

local group = BodyLocations.getGroup("Human")
for _, location in ipairs(MyLocations) do
    local bodyLocation = BodyLocation.new(group, location)
    group:getAllLocations():add(bodyLocation)
end