----------------------------------------------------------Variables
local QBCore = exports['qb-core']:GetCoreObject()
local ui = false
local gang = nil
local gangData = {}
local gangColor = nil
local gangGarages = {}
local gangStorage = {}
local gangLocation = nil
local gangCommandCenter = {}
local gangMembers = {}
local license = nil
local uiUnavailable = false

local blips = {}
local activeBlips
----------------------------------------------------------Variables
----------------------------------------------------------Garages

function OpenGarageUI(name,garage, image)
    if not ui then
        SendNUIMessage({
            type = "ShowGarage",
            name = name,
            garage = garage,
            bgImage = image,
        })
        SetNuiFocus(true,true)
        ui = true   
    end
end

function SpawnVehicle(model, vehid, location, heading, garage)
    local coords = vector4(location.x, location.y, location.z, heading)
    local plate = "AER "..tostring(math.random(1000, 9999))
    print(garage)
    print(vehid)
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(0)
    end
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        QBCore.Functions.SetVehicleProperties(veh, gangGarages[garage].vehicles[vehid].props.vehProps)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetEntityHeading(veh, coords.w)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleEngineOn(veh, true, true,false)
        exports['LegacyFuel']:SetFuel(veh, gangGarages[garage].vehicles[vehid].props.vehProps.fuelLevel)
        plate = QBCore.Functions.GetPlate(veh)
        TriggerEvent("vehiclekeys:client:SetOwner",plate)
        DoScreenFadeIn(500)
        uiUnavailable = false    
    end, model, coords, true)
    return plate
end

function SaveVehicle(currentGarage)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local props = QBCore.Functions.GetVehicleProperties(veh)
    local r,g,b = GetVehicleCustomPrimaryColour(veh)
    local source = GetPlayerServerId(PlayerId())
    local plate = props.plate
    local color = {r = r,g = g,b = b}
    TriggerServerEvent("GangSystem:server:SaveVehicle", source, props, color, currentGarage.name, gang, plate)
end

RegisterNetEvent("GangSystem:client:DeleteVehicle")
AddEventHandler("GangSystem:client:DeleteVehicle", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    SetEntityAsMissionEntity(veh, true, true)
    DeleteVehicle(veh)
end)

RegisterCommand("addvehicle",function (source, args)
    local model = args[1]
    local garage = args[2]
    local source = GetPlayerServerId(PlayerId())
    TriggerServerEvent("GangSystem:server:AddVehicleToGarage", source, model, garage)
end, false)

RegisterCommand("CreateGangGarage",function(source, args)
    local name = args[1]
    local garageName = args[2]
    local source = GetPlayerServerId(PlayerId())
    TriggerServerEvent("GangSystem:server:CreateGangGarage", source, name, garageName, GetEntityCoords(PlayerPedId()))
end, false)

----------------------------------------------------------Garages
----------------------------------------------------------Gang Creation

function OpenCreatorUI()
    if not ui then
        SendNUIMessage({
            type = "ShowCreator",
        })
        SetNuiFocus(true,true)
        ui = true   
    end
end

RegisterCommand("CreateGang",function (source, args)
    OpenCreatorUI()
end, false)

RegisterCommand("CreateGangCommandCenter",function(source, args)
    local name = args[1]
    local source = GetPlayerServerId(PlayerId())
    TriggerServerEvent("GangSystem:server:CreateGangCommandCenter", source, name, GetEntityCoords(PlayerPedId()))
end, false)

RegisterNUICallback('gangCreation', function(data, cb)
    if data.action == 'checkExisting' then  
        QBCore.Functions.TriggerCallback('GangSystem:server:CheckExistingGang', function(result)
            if result == nil then
                cb({
                    status = false,
                }) --A gang with this name doesn't exist
            else
                cb({
                    status = true
                }) --There already is a gang with this name
            end
        end,data.gangName)
    end

    if data.action == 'beginLocationSelection' then
        uiUnavailable = true
        local chosenName = data.gangName
        local leaderID = data.leaderId
        local color = {
            r = data.r,
            g = data.g,
            b = data.b
        }
        local location = nil
        local commandCenter = nil
        SendNUIMessage({
            type = "LocationPlace",
            open = true,
            text = "PRESS E TO PLACE GANG HQ"
        })
        while location == nil do
            Wait(0)
            if IsControlJustPressed(0, 38) then
                location = GetEntityCoords(PlayerPedId())
            end
        end
        SendNUIMessage({
            type = "LocationPlace",
            open = true,
            text = "PRESS E TO PLACE COMMAND CENTER"
        })
        while commandCenter == nil and location ~= nil do
            Wait(0)
            if IsControlJustPressed(0, 38) then
                commandCenter = GetEntityCoords(PlayerPedId())
            end
        end
        SendNUIMessage({
            type = "LocationPlace",
            open = false,
            text = "N/A"
        })
        while commandCenter ~= nil and location ~= nil do
            TriggerServerEvent("GangSystem:server:CreateGang", source, chosenName, color,commandCenter, location, leaderID) 
            uiUnavailable = false
            break   
        end
    end
end)



----------------------------------------------------------Gang Creation
----------------------------------------------------------Gang Necessities


RegisterNetEvent("GangSystem:client:InitialiseGangMember")
AddEventHandler("GangSystem:client:InitialiseGangMember", function()
    local source = GetPlayerServerId(PlayerId())
    TriggerServerEvent("GangSystem:server:GetGang",source)
    Wait(1000)
    if gang ~= nil then
        TriggerServerEvent("GangSystem:server:GetGangStuff", source, gang)
    end
end)

RegisterNetEvent("GangSystem:client:GetGangStuff")
AddEventHandler("GangSystem:client:GetGangStuff", function(data, playerLicense)
    gangData = data
    gangCommandCenter = json.decode(gangData.commandCenter)
    gangGarages = json.decode(gangData.garages)
    gangLocation = json.decode(gangData.location)
    gangStorage = json.decode(gangData.storage)
    gangMembers = json.decode(gangData.members)
    gangColor = json.decode(gangData.color)
    license = playerLicense
   --blips[gang]= {title=gang.." HQ", colour=5, id=378,x= gangLocation.x, y= gangLocation.y, z = gangLocation.z}

   -- for k,v in pairs(activeBlips) do
   --     RemoveBlip(v)
   -- end
   -- for _, info in pairs(blips) do
   --   info.blip = AddBlipForCoord(info.x, info.y, info.z)
    --  SetBlipSprite(info.blip, info.id)
    --  SetBlipDisplay(info.blip, 4)
    --  SetBlipScale(info.blip, 1.0)
    --  SetBlipColour(info.blip, info.colour)
    --  SetBlipAsShortRange(info.blip, true)
	--  BeginTextCommandSetBlipName("STRING")
    --  AddTextComponentString(info.title)
    --  EndTextCommandSetBlipName(info.blip)
    --end
end)

RegisterNetEvent('GangSystem:client:RemoveGangMember')
AddEventHandler('GangSystem:client:RemoveGangMember', function ()
    gang = nil
    gangData = {}
    gangCommandCenter = nil
    gangGarages = {}
    gangLocation = nil
    gangStorage = {}
end)

RegisterNetEvent("GangSystem:client:GetGang")
AddEventHandler("GangSystem:client:GetGang", function(foundGang)
    gang = foundGang
end)

----------------------------------------------------------Gang
----------------------------------------------------------Main


RegisterNUICallback('action', function(data, cb)
    if data.action == 'CloseUI' then  
        SetNuiFocus(false,false)
        ui = false
    end

    if data.action == 'TakeOutVehicle' then
        uiUnavailable = true
        local source = GetPlayerServerId(PlayerId())
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        local veh = gangGarages[data.garageName].vehicles[data.vehicleID]
        local plate = SpawnVehicle(data.model, data.vehicleID,coords, heading, data.garageName)
        TriggerServerEvent("GangSystem:server:TakeVehicleOut", source, gang, plate,data.vehicleID,data.garageName)
    end
end)


function drawText3D(x, y, z, text)
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(false)
    SetTextColour(gangColor.r or 255, gangColor.g or 255, gangColor.b or 255, 255)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    ClearDrawOrigin()
end

AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    Citizen.Wait(100)
    TriggerEvent("GangSystem:client:InitialiseGangMember")
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        local source = GetPlayerServerId(PlayerId())
        TriggerServerEvent("GangSystem:server:GetGang",source)
        Wait(1000)
        if gang ~= nil then
            TriggerServerEvent("GangSystem:server:GetGangStuff", source, gang)
        end
    end
end)


Citizen.CreateThread(function ()
    local waitTime = 0
    while true do
        Wait(waitTime)
            if gangData == {} or uiUnavailable then
                waitTime = 2000
            else
                local ped = PlayerPedId()
                local plocation = GetEntityCoords(ped)
                if gangLocation ~= nil and not ui then
                    if #(plocation - vector3(gangLocation.x, gangLocation.y, gangLocation.z)) <= 50 then
                        waitTime = 100
                        for k,v in pairs(gangGarages) do
                            local distanceGarages  = #(plocation - vector3(v.location.x, v.location.y, v.location.z))
                            if distanceGarages <= 5 then
                                waitTime = 1
                                DrawMarker(36, v.location.x, v.location.y, v.location.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, gangColor.r, gangColor.g, gangColor.b, 200, 0, 0, 0, true)
                                DrawMarker(27, v.location.x, v.location.y, v.location.z-0.9, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, gangColor.r, gangColor.g, gangColor.b, 200, 0, 0, 0, true)
                                if distanceGarages <= 2 then
                                    --drawText3D(v.location.x, v.location.y, v.location.z, "Apasa pe E pentru a deschide garajul: "..v.name)
                                    if IsControlJustPressed(0, 38) then 
                                        if GetVehiclePedIsIn(ped, false) == 0 then
                                            local source = GetPlayerServerId(PlayerId())
                                            TriggerServerEvent("GangSystem:server:GetGangStuff", source, gang)
                                            Wait(200)
                                            OpenGarageUI(gang, gangGarages[v.name], gangData.photo_bg)
                                        else
                                            SaveVehicle(v)
                                        end                         
                                    end
                                end
                            end
                        end
                        for k,v in pairs(gangStorage) do
                            local distanceStorage  = #(plocation - vector3(v.location.x, v.location.y, v.location.z))
                            if distanceStorage <= 5 then
                                waitTime = 1
                                DrawMarker(36, v.location.x, v.location.y, v.location.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, gangColor.r, gangColor.g, gangColor.b, 200, 0, 0, 0, true)
                                DrawMarker(27, v.location.x, v.location.y, v.location.z-0.9, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, gangColor.r, gangColor.g, gangColor.b, 200, 0, 0, 0, true)
                                if distance <= 2 then
                                    --drawText3D(v.location.x, v.location.y, v.location.z, "Apasa pe E pentru a deschide Storage")
                                    if IsControlJustPressed(0, 38) then
                                        QBCore.Functions.Notify("Ai intrat in storage factiunii")
                                    end
                                end
                            end
                        end
                        if gangCommandCenter ~= nil then --and gangMembers[license].rank == "leader" then
                            local distanceCenter = #(plocation - vector3(gangCommandCenter.x, gangCommandCenter.y, gangCommandCenter.z))
                            if distanceCenter <= 5 then
                                waitTime = 1
                                DrawMarker(31, gangCommandCenter.x, gangCommandCenter.y, gangCommandCenter.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, gangColor.r, gangColor.g, gangColor.b, 200, 0, 0, 0, true)
                                DrawMarker(27, gangCommandCenter.x, gangCommandCenter.y, gangCommandCenter.z-0.9, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, gangColor.r, gangColor.g, gangColor.b, 200, 0, 0, 0, true)
                                if distanceCenter <= 2 then
                                    --drawText3D(gangCommandCenter.x, gangCommandCenter.y, gangCommandCenter.z, "Apasa pe E pentru a deschide Command Center")
                                    if IsControlJustPressed(0, 38) then
                                        QBCore.Functions.Notify("Ai intrat in commmand factiunii")
                                    end
                                end
                            end
                        end
                    else 
                        waitTime = 2000
                    end
                end
            end
        end
end)
----------------------------------------------------------Main