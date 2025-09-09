local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentJobPlayerTargets = {}  
local currentJobVehicleTargets = {} 
local DebugMode = false  

local function debugPrint(msg)
    if DebugMode then
        print("^2[Target Debug]^7: "..msg)
    end 
end
 
local function setupGeneralPlayerTargets()
    debugPrint("Algemene speler-targets toevoegen...")

    exports.ox_target:addGlobalPlayer({
        { 
            name = 'General_KidnapPlayer', 
            icon = 'fas fa-handcuffs', 
            label = 'KidnapPlayer', 
            onSelect = function(data)
                local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                debugPrint("KidnapPlayer geactiveerd voor playerID: "..playerID)
                TriggerEvent('police:client:KidnapPlayer', data.entity)
         end 
        },
        { 
            name = 'General_EscortPlayer', 
            icon = 'fas fa-handcuffs', 
            label = 'EscortPlayer', 
            onSelect = function(data)
                local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                debugPrint("EscortPlayer geactiveerd voor playerID: "..playerID)
                TriggerEvent('police:client:EscortPlayer', data.entity)
        end 
        },
        { 
            name = 'General_CuffPlayerSoft', 
            icon = 'fas fa-handcuffs', 
            label = 'Boeien / unboeien', onSelect = function(data)
                local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                debugPrint("Boeien / unboeien geactiveerd voor playerID: "..playerID)
                TriggerEvent('police:client:CuffPlayerSoft', data.entity)
        end 
        },
        { 
            name = "General_lbphone-share-contact", 
            icon = "fa-regular fa-address-book", 
            label = "Deel je contact", items = "phone",
            canInteract = function() return not exports["lb-phone"]:IsDisabled() end,
            onSelect = function(data)
                local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                debugPrint("Deel je contact geactiveerd voor playerID: "..playerID)
                TriggerServerEvent("lb-phone:addon:shareContact", playerID)
            end
        }
    })
end

local function setupGeneralVehicleTargets()
    debugPrint("Algemene voertuig-targets toevoegen...")
    exports.ox_target:addGlobalVehicle({
        { 
            name = 'Vehicle_PutPlayerInVehicle', 
            icon = 'fa-solid fa-car', 
            label = 'Plaats persoon in het voertuig', onSelect = function(data)
                local veh = data.entity
                debugPrint("Plaats persoon in voertuig geactiveerd, model: "..GetEntityModel(veh)..", plate: "..GetVehicleNumberPlateText(veh))
                TriggerEvent('police:client:PutPlayerInVehicle', veh)
        end 
        },
        { name = 'Vehicle_SetPlayerOutVehicle', icon = 'fa-solid fa-car', label = 'Haal persoon uit het voertuig', onSelect = function(data)
                local veh = data.entity
                debugPrint("Haal persoon uit voertuig geactiveerd, model: "..GetEntityModel(veh)..", plate: "..GetVehicleNumberPlateText(veh))
                TriggerEvent('police:client:SetPlayerOutVehicle', veh)
        end },
        { 
            name = 'Vehicle_GetInTrunk', 
            icon = 'fa-solid fa-car', 
            label = 'Ga in kofferbak', onSelect = function(data)
                local veh = data.entity
                debugPrint("Ga in kofferbak geactiveerd, model: "..GetEntityModel(veh)..", plate: "..GetVehicleNumberPlateText(veh))
                TriggerEvent('qb-trunk:client:GetIn', veh)
        end 
        },
                { 
            name = 'Vehicle_flipVehicle', 
            icon = 'fa-solid fa-car', 
            label = 'Flip voertuig', onSelect = function(data)
                local veh = data.entity
                debugPrint("flip voertuig geactiveerd, model: "..GetEntityModel(veh)..", plate: "..GetVehicleNumberPlateText(veh))
                TriggerEvent('radialmenu:flipVehicle', veh)
        end 
        },
        { 
            name = 'Vehicle_Impound', 
            icon = 'fa-solid fa-car', 
            label = 'Neem voertuig in beslag', 
            canInteract = function(entity, distance, data)
                local PlayerJob = QBCore.Functions.GetPlayerData().job.name
                return PlayerJob == 'police' or PlayerJob == 'mechanic'
            end,
            onSelect = function(data)
                local veh = data.entity
                debugPrint("Impound voertuig geactiveerd, model: "..GetEntityModel(veh)..", plate: "..GetVehicleNumberPlateText(veh))
                TriggerEvent('jg-advancedgarages:client:ImpoundVehicle', veh)
            end
        },
                { 
            name = 'Vehicle_clothing', 
            icon = 'fa-solid fa-car', 
            label = 'Kleding menu', 
            canInteract = function(entity, distance, data)
                local PlayerJob = QBCore.Functions.GetPlayerData().job.name
                return PlayerJob == 'police' or PlayerJob == 'ambulance' or PlayerJob == 'mechanic'
            end,
            onSelect = function(data)
                local veh = data.entity
                debugPrint("KLEDING IN AUTO geactiveerd, model: "..GetEntityModel(veh)..", plate: "..GetVehicleNumberPlateText(veh))
                TriggerEvent('illenium-apearance:client:outfitsCommand', veh)
            end
        }
    })
end

local function removeCurrentJobPlayerTargets()
    for _, name in ipairs(currentJobPlayerTargets) do
        exports.ox_target:removeGlobalPlayer(name)
    end
    currentJobPlayerTargets = {}
end

local function removeCurrentJobVehicleTargets()
    for _, name in ipairs(currentJobVehicleTargets) do
        exports.ox_target:removeGlobalVehicle(name)
    end
    currentJobVehicleTargets = {}
end

local JobTargets = {
    police = {
        player = {
            { 
                name = 'Police_CuffPlayerSoft', 
                icon = 'fas fa-handcuffs', 
                label = 'Boeien (kan lopen)', onSelect = function(data)
                    local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                    debugPrint("Boeien (kan lopen) geactiveerd voor playerID: "..playerID)
                    TriggerEvent('police:client:CuffPlayerSoft', data.entity)
            end 
            },
            { 
                name = 'Police_CuffPlayer', 
                icon = 'fas fa-handcuffs', 
                label = 'Boeien (kan niet lopen)', onSelect = function(data)
                    local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                    debugPrint("Boeien (kan niet lopen) geactiveerd voor playerID: "..playerID)
                    TriggerEvent('police:client:CuffPlayer', data.entity)
            end 
            },
            { 
                name = 'Police_SearchPlayer', 
                icon = 'fa-solid fa-user', 
                label = 'Speler fouilleren', onSelect = function(data)
                    local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                    debugPrint("Speler fouilleren geactiveerd voor playerID: "..playerID)
                    TriggerEvent('police:client:SearchPlayer', data.entity)
            end 
            },
            { 
                name = 'Police_RobPlayer', 
                icon = 'fas fa-sack-dollar', 
                label = 'Beroof speler', onSelect = function(data)
                    local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                    debugPrint("Beroof speler geactiveerd voor playerID: "..playerID)
                    TriggerEvent('police:client:RobPlayer', data.entity)
            end 
            },
            { 
                name = 'Police_JailPlayer', 
                icon = 'fas fa-gavel', 
                label = 'Stuur speler naar gevangenis', onSelect = function(data)
                    local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                    debugPrint("Stuur speler naar gevangenis geactiveerd voor playerID: "..playerID)
                    TriggerEvent('police:client:JailPlayer', data.entity)
            end 
            },
        },
        vehicle = {}
    },
    ambulance = {
        player = {
            { 
                name = 'Ambulance_CheckStatus', 
                icon = 'fa-solid fa-heart-pulse', 
                label = 'Speler status controleren', onSelect = function(data)
                    local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                    debugPrint("Speler status controleren geactiveerd voor playerID: "..playerID)
                    TriggerEvent('hospital:client:CheckStatus', data.entity)
            end 
            },
            { 
                name = 'Ambulance_RevivePlayer', 
                icon = 'fa-solid fa-kit-medical', 
                label = 'Speler reanimeren', onSelect = function(data)
                    local playerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
                    debugPrint("Speler reanimeren geactiveerd voor playerID: "..playerID)
                    TriggerEvent('hospital:client:RevivePlayer', data.entity)
            end 
            },
        },
        vehicle = {}
    },
    mechanic = {
        player = {},
        vehicle = {
            { 
                name = 'Mechanic_TowVehicle', 
                icon = 'fa-solid fa-truck-pickup', 
                label = 'Sleep voertuig', onSelect = function(data)
                    local veh = data.entity
                    debugPrint("Sleep voertuig geactiveerd, model: "..GetEntityModel(veh)..", plate: "..GetVehicleNumberPlateText(veh))
                    TriggerEvent('qb-tow:client:TowVehicle', veh)
            end 
            },
        }
    }
}

local function setupJobTargets(jobName)
     debugPrint("Targets instellen voor baan: "..tostring(jobName))

    removeCurrentJobPlayerTargets()
    removeCurrentJobVehicleTargets()

    local job = JobTargets[jobName]
    if job then
        for _, target in ipairs(job.player) do
            exports.ox_target:addGlobalPlayer(target)
            table.insert(currentJobPlayerTargets, target.name)
        end
        for _, target in ipairs(job.vehicle) do
            exports.ox_target:addGlobalVehicle(target)
            table.insert(currentJobVehicleTargets, target.name)
        end
    end
end

Citizen.CreateThread(function()
    
    while not QBCore.Functions.GetPlayerData() or not QBCore.Functions.GetPlayerData().job do
        Citizen.Wait(100)
    end

    PlayerData = QBCore.Functions.GetPlayerData()
        debugPrint("Speler geladen na relog, Baan: "..tostring(PlayerData.job.name))

 
    setupGeneralPlayerTargets()
    setupGeneralVehicleTargets()
    setupJobTargets(PlayerData.job.name)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
        debugPrint("Baan veranderd naar: "..tostring(JobInfo.name))

    setupJobTargets(JobInfo.name)
end)
