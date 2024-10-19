local currentWeapons = {
    back = nil,
    belt = nil
}
local weaponObjects = {
    back = nil,
    belt = nil
}
local boneIndexBack = 24818
local boneIndexBelt = 11816

local backWeapons = {
    "WEAPON_ASSAULTRIFLE", 
    "WEAPON_CARBINERIFLE", 
    "WEAPON_SPECIALCARBINE", 
    "WEAPON_PUMPSHOTGUN", 
    "WEAPON_SMG",
    "WEAPON_COMBATPDW"
}

local beltWeapons = {
    "WEAPON_PISTOL",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL",
    "WEAPON_HEAVYPISTOL",
    "WEAPON_REVOLVER"
}

local function isWeaponBackCompatible(weapon)
    for _, backWeapon in ipairs(backWeapons) do
        if GetHashKey(backWeapon) == weapon then
            return true
        end
    end
    return false
end

local function isWeaponBeltCompatible(weapon)
    for _, beltWeapon in ipairs(beltWeapons) do
        if GetHashKey(beltWeapon) == weapon then
            return true
        end
    end
    return false
end

local function getWeaponModel(weaponHash)
    local weaponModel = nil

    if weaponHash == GetHashKey("WEAPON_ASSAULTRIFLE") then
        weaponModel = "w_ar_assaultrifle"
    elseif weaponHash == GetHashKey("WEAPON_CARBINERIFLE") then
        weaponModel = "w_ar_carbinerifle"
    elseif weaponHash == GetHashKey("WEAPON_SPECIALCARBINE") then
        weaponModel = "w_ar_specialcarbine"
    elseif weaponHash == GetHashKey("WEAPON_PUMPSHOTGUN") then
        weaponModel = "w_sg_pumpshotgun"
    elseif weaponHash == GetHashKey("WEAPON_SMG") then
        weaponModel = "w_sb_smg"
    elseif weaponHash == GetHashKey("WEAPON_COMBATPDW") then
        weaponModel = "w_sb_pdw"
    elseif weaponHash == GetHashKey("WEAPON_PISTOL") then
        weaponModel = "w_pi_pistol"
    elseif weaponHash == GetHashKey("WEAPON_COMBATPISTOL") then
        weaponModel = "w_pi_combatpistol"
    elseif weaponHash == GetHashKey("WEAPON_APPISTOL") then
        weaponModel = "w_pi_appistol"
    elseif weaponHash == GetHashKey("WEAPON_HEAVYPISTOL") then
        weaponModel = "w_pi_heavypistol"
    elseif weaponHash == GetHashKey("WEAPON_REVOLVER") then
        weaponModel = "w_pi_revolver"
    end

    return weaponModel
end

local function attachWeaponToPlayer(ped, weaponHash, position)
    local weaponModel = getWeaponModel(weaponHash)

    if weaponModel then
        RequestModel(weaponModel)
        while not HasModelLoaded(weaponModel) do
            Wait(100)
        end

        local weaponObject = CreateObject(GetHashKey(weaponModel), 1.0, 1.0, 1.0, true, true, false)

        if position == "back" then
            AttachEntityToEntity(weaponObject, ped, GetPedBoneIndex(ped, boneIndexBack), 0.1, -0.15, 0.05, 0.0, 180.0, 0.0, false, false, false, false, 2, true)
            weaponObjects.back = weaponObject
        elseif position == "belt" then
            AttachEntityToEntity(weaponObject, ped, GetPedBoneIndex(ped, boneIndexBelt), 0.15, 0.0, 0.19, 90.0, 0.0, 0.0, false, false, false, false, 2, true)
            weaponObjects.belt = weaponObject
        end

        return weaponObject
    end
    return nil
end

local function removeWeaponFromPosition(position)
    if position == "back" and DoesEntityExist(weaponObjects.back) then
        DeleteObject(weaponObjects.back)
        weaponObjects.back = nil
        currentWeapons.back = nil
    elseif position == "belt" and DoesEntityExist(weaponObjects.belt) then
        DeleteObject(weaponObjects.belt)
        weaponObjects.belt = nil
        currentWeapons.belt = nil
    end
end

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local currentWeaponHash = GetSelectedPedWeapon(playerPed)

        if currentWeaponHash == GetHashKey("WEAPON_UNARMED") then
            if currentWeapons.back and not DoesEntityExist(weaponObjects.back) then
                attachWeaponToPlayer(playerPed, currentWeapons.back, "back")
            end
            if currentWeapons.belt and not DoesEntityExist(weaponObjects.belt) then
                attachWeaponToPlayer(playerPed, currentWeapons.belt, "belt")
            end
        else
            if isWeaponBeltCompatible(currentWeaponHash) then
                if currentWeapons.belt == currentWeaponHash then
                    removeWeaponFromPosition("belt")
                else
                    currentWeapons.belt = currentWeaponHash
                end
            end

            if isWeaponBackCompatible(currentWeaponHash) then
                if currentWeapons.back == currentWeaponHash then
                    removeWeaponFromPosition("back")
                else
                    currentWeapons.back = currentWeaponHash
                end
            end
        end

        Citizen.Wait(500)
    end
end)

AddEventHandler('baseevents:onPlayerDied', function()
    removeWeaponFromPosition("back")
    removeWeaponFromPosition("belt")
end)

AddEventHandler('baseevents:onPlayerKilled', function()
    removeWeaponFromPosition("back")
    removeWeaponFromPosition("belt")
end)
