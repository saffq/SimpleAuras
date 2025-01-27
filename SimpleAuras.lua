local monitoredItems = {
    {name = "Zulian Coin", type = "Coin"},
    {name = "Hakkari Coin", type = "Coin"},
    {name = "Bijou of Mojo", type = "Bijou"},
    {name = "Bijou of Serenity", type = "Bijou"},
    {name = "Bijou of the Aurora", type = "Bijou"},
    {name = "Bijou of Greater Power", type = "Bijou"},
    {name = "Bijou of Magic", type = "Bijou"},
    {name = "Bijou of Darkness", type = "Bijou"},
    {name = "Bijou of the Eagle", type = "Bijou"},
}

local updateInterval = 1
local timeSinceLastUpdate = 0

local function OnLoad(self)
    print("SimpleAuras loaded!")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        UpdateAuras()
    end
end

local function IsInZulGurub()
    local zone = GetZoneText()
    return zone == "Zul'Gurub"
end

local function HasMonitoredItems()
    local itemCounts = {}
    for _, item in ipairs(monitoredItems) do
        itemCounts[item.name] = 0
    end

    for bag = 0, 4 do
        local numSlots = GetContainerNumSlots(bag)
        if numSlots then
            for slot = 1, numSlots do
                local itemLink = GetContainerItemLink(bag, slot)
                if itemLink then
                    local itemID = GetContainerItemID(bag, slot)
                    if itemID then
                        local itemName = GetItemInfo(itemID)
                        if itemName then
                            for _, monitoredItem in ipairs(monitoredItems) do
                                if itemName == monitoredItem.name then
                                    itemCounts[monitoredItem.name] = itemCounts[monitoredItem.name] + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return itemCounts
end

function UpdateAuras()
    local auraName = "Mark of the Wild"
    local hasAura = false

    for i = 1, 32 do
        local name = UnitBuff("player", i)
        if not name then break end
        if name == auraName then
            hasAura = true
            break
        end
    end

    if hasAura then
        SimpleAurasFrame:Show()
    else
        SimpleAurasFrame:Hide()
    end

    if IsInZulGurub() then
        local itemCounts = HasMonitoredItems()

        for _, item in ipairs(monitoredItems) do
            local frameName = item.name .. "Frame"
            local frame = _G[frameName]
            if not frame then
                frame = CreateFrame("Frame", frameName, UIParent)
                frame:SetSize(32, 32)
                local offsetX, offsetY = 0, 0

                if item.type == "Coin" then
                    offsetX = -100
                    offsetY = 150 - (table.getn(monitoredItems) * 10)
                elseif item.type == "Bijou" then
                    offsetX = 100
                    offsetY = 150 - (table.getn(monitoredItems) * 10)
                end

                frame:SetPoint("CENTER", UIParent, "CENTER", offsetX, offsetY)
                frame.texture = frame:CreateTexture(nil, "BACKGROUND")
                frame.texture:SetAllPoints(frame)
                if item.type == "Coin" then
                    frame.texture:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
                elseif item.type == "Bijou" then
                    frame.texture:SetTexture("Interface\\Icons\\INV_Jewelry_Talisman_01")
                end
                frame:Hide()
            end

            if itemCounts[item.name] > 0 then
                frame:Show()
            else
                frame:Hide()
            end
        end
    else
        for _, item in ipairs(monitoredItems) do
            local frameName = item.name .. "Frame"
            local frame = _G[frameName]
            if frame then
                frame:Hide()
            end
        end
    end
end

local f = CreateFrame("Frame", "SimpleAurasFrame", UIParent)
f:SetSize(32, 32)
f:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
f.texture = f:CreateTexture(nil, "BACKGROUND")
f.texture:SetAllPoints(f)
f.texture:SetTexture("Interface\\Icons\\Spell_Nature_Regeneration")
f:Hide()

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate >= updateInterval then
        UpdateAuras()
        timeSinceLastUpdate = 0
    end
end)
