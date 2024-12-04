----------------------------------------------------------NAME <--- Main Section
----------------------NAME---------------------- <--- Sub-Section


---------------------------------------------------------- VARIABLES

local QBCore = exports['qb-core']:GetCoreObject()
local outVehicles = {} --Table of vehicles that are currently out

---------------------------------------------------------- VARIABLES
---------------------------------------------------------- NECESSARY FOR SCRIPT FUNCTION

----------------------COMMANDS----------------------
RegisterCommand("addgangmember",function (source, args)
    if args[1] and args[2] then
        local name = args[1]
        local newMemberSource = exports.uid:GetIDfromUID(tonumber(args[2]))
        local newMemberLicense = QBCore.Functions.GetIdentifier(newMemberSource, "license")
        local result = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
            ['@GangName'] = name,
        })
        if result[1] then
            local result2 = exports.oxmysql:executeSync('SELECT * FROM players WHERE license=@license', {
                ['@license'] = newMemberLicense,
            })
            if result2[1] then
                if result2[1].playerGang ~= "none" then
                    local previousGang = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
                        ['@GangName'] = result2[1].playerGang,
                    })
                    if previousGang[1] then
                        local othermembers = json.decode(previousGang[1].members)
                        othermembers[newMemberLicense] = nil
                        exports.oxmysql:execute('UPDATE gangs SET members = @members WHERE name=@GangName', {
                            ['@GangName'] = result2[1].playerGang,
                            ['@members'] = json.encode(othermembers),
                        })
                        TriggerClientEvent('QBCore:Notify', newMemberSource, "Ai fost scos din factiunea "..result2[1].playerGang, 'success') 
                    end
                end 
                exports.oxmysql:execute('UPDATE players SET playerGang = @gang WHERE license=@license', {
                    ['@license'] = newMemberLicense,
                    ['@gang'] = name,
                })
            end
            local members = json.decode(result[1].members)
            members[newMemberLicense] = {
                rank = "member",
                rankLabel = "Member"
            }
            exports.oxmysql:execute('UPDATE gangs SET members = @members WHERE name=@GangName', {
                ['@GangName'] = name,
                ['@members'] = json.encode(members),
            })
            TriggerClientEvent('QBCore:Notify', newMemberSource, "Ai fost adaugat in factiunea "..name, 'success') 
            TriggerClientEvent("GangSystem:client:InitialiseGangMember", newMemberSource)
            updateMembers(name)
        else
            TriggerClientEvent('QBCore:Notify', source, "Aceasta factiune nu exista", 'error') 
        end
    else
        TriggerClientEvent('chatMessage', source, "/addgangmember (gangName) (memberID)") 
    end
end, false)

RegisterCommand("removegangmember",function (source, args)
    if args[1] and args[2] then
        local name = args[1]
        local MemberSource = exports.uid:GetIDfromUID(tonumber(args[2]))
        local MemberLicense = QBCore.Functions.GetIdentifier(MemberSource, "license")
        local result = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
            ['@GangName'] = name,
        })
        if result[1] then
            local members = json.decode(result[1].members)
            members[MemberLicense] = nil
            exports.oxmysql:execute('UPDATE gangs SET members = @members WHERE name=@GangName', {
                ['@GangName'] = name,
                ['@members'] = json.encode(members),
            })
            local result = exports.oxmysql:executeSync('SELECT * FROM players WHERE license=@license', {
                ['@license'] = MemberLicense,
            })
            if result[1] then
                exports.oxmysql:execute('UPDATE players SET playerGang = @gang WHERE license=@license', {
                    ['@license'] = MemberLicense,
                    ['@gang'] = "none",
                })
            end
            TriggerClientEvent('QBCore:Notify', source, "A fost scos din factiunea "..name, 'success') 
            TriggerClientEvent('QBCore:Notify', MemberSource, "Ai fost scos din factiunea "..name, 'success') 
            TriggerClientEvent("GangSystem:client:RemoveGangMember", MemberSource)
            updateMembers(name)
        else
            TriggerClientEvent('QBCore:Notify', source, "Aceasta factiune nu exista", 'error') 
        end
    else
        TriggerClientEvent('chatMessage', source, "/removegangmember (gangName) (memberID)") 
    end
end, false)

----------------------COMMANDS----------------------

----------------------METHODS----------------------

local function updateMembers(gangName)
    Wait(1000)
    for _, playerId in ipairs(GetPlayers()) do
        TriggerEvent("GangSystem:server:GetGangDetails", playerId, gangName)
    end
end

local function isGangMember(src, name)
    local license = QBCore.Functions.GetIdentifier(src, "license")
    local result = exports.oxmysql:executeSync('SELECT * FROM players WHERE license=@license', {
        ['@license'] = license,
    })
    if result[1] then
        local gang = result[1].playerGang
        if gang == name then
            return true
        end
    end
    return false 
end

----------------------METHODS----------------------

----------------------EVENTS----------------------

RegisterNetEvent("GangSystem:server:GetGangDetails")
AddEventHandler("GangSystem:server:GetGangDetails", function(source, name)
    local result = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
        ['@GangName'] = name,
    })
    if result[1] then
        local license = QBCore.Functions.GetIdentifier(source, "license")
        local members = json.decode(result[1].members)
        if members[license] then
            local gangData = result[1]
            TriggerClientEvent("GangSystem:client:GetGangDetails", source, gangData, license)
        end
    end
end)

RegisterNetEvent("GangSystem:server:GetGang")
AddEventHandler("GangSystem:server:GetGang", function(source)
    local license = QBCore.Functions.GetIdentifier(source, "license")
    local result = exports.oxmysql:executeSync('SELECT * FROM players WHERE license=@license', {
        ['@license'] = license,
    })
    if result[1] then
        local gang = result[1].playerGang
        if gang ~= "none" then
            TriggerClientEvent("GangSystem:client:GetGang", source, gang)
        end
    end
end)

----------------------EVENTS----------------------

----------------------CALLBACKS----------------------
----------------------CALLBACKS----------------------

---------------------------------------------------------- NECESSARY FOR SCRIPT FUNCTION

---------------------------------------------------------- GANG CREATION

----------------------METHODS----------------------
----------------------METHODS----------------------

----------------------EVENTS----------------------

RegisterNetEvent("GangSystem:server:CreateGang")
AddEventHandler("GangSystem:server:CreateGang", function(source, name, color,commandCenter, location, leaderID)
    local leaderSource = exports.uid:GetIDfromUID(tonumber(leaderID))
    local leaderLicense = QBCore.Functions.GetIdentifier(leaderSource, "license")
    local members = {}
    members[leaderLicense] = {
        rank = "leader",
        rankLabel = "Leader"
    }
    local query = 'INSERT INTO gangs (name, color, location, garages, storage, members, commandCenter) VALUES (@name, @color, @location,@garages, @storage, @members, @commandCenter)'
    local var = {
        ['@name'] = name,
        ['@color'] = json.encode(color),
        ['@location'] = json.encode(location),
        ['@garages'] = json.encode({}),
        ['@storage'] = json.encode({}),
        ['@members'] = json.encode(members),
        ['@commandCenter'] = json.encode(commandCenter)
    }
    exports.oxmysql:execute(query, var)
    exports.oxmysql:execute('UPDATE players SET playerGang = @gang WHERE license=@license', {
        ['@license'] = leaderLicense,
        ['@gang'] = name,
    })
    TriggerClientEvent("GangSystem:client:InitialiseGangMember", leaderSource)
end)

----------------------EVENTS----------------------

----------------------CALLBACKS----------------------
----------------------CALLBACKS----------------------

---------------------------------------------------------- GANG CREATION
---------------------------------------------------------- GARAGES

----------------------COMMANDS----------------------

RegisterCommand("deleteganggarage",function (source, args)
    if args[1] and args[2] then
        local name = args[1]
        local GarageName = args[2]
        TriggerEvent("GangSystem:server:DeleteGangGarage",source, name, GarageName)
        TriggerClientEvent('QBCore:Notify', source, "Ai sters garajul "..GarageName, 'success') 
    else
        TriggerClientEvent('chatMessage', source, "/deleteganggarage (GangName) (GarageName)") 
    end
end, false)

RegisterCommand("refreshgarages", function (source)
    TriggerEvent("GangSystem:server:RefreshGarages", source)
end, false)

----------------------COMMANDS----------------------

----------------------EVENTS----------------------

RegisterNetEvent("GangSystem:server:CreateGangGarage")
AddEventHandler("GangSystem:server:CreateGangGarage", function(source, name, garageName, location)
    print(source)
    local result = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
        ['@GangName'] = name,
    })
    if result[1] then
        local foundGarages = json.decode(result[1].garages)
        local vehicles = {}
        if foundGarages[garageName] then
            vehicles = foundGarages[garageName].vehicles
        end
        foundGarages[garageName] = {
            name = garageName,
            location = location,
            vehicles =  vehicles,
        }
        exports.oxmysql:execute('UPDATE gangs SET garages = @garages WHERE name=@GangName', {
            ['@GangName'] = name,
            ['@garages'] = json.encode(foundGarages),
        })
        updateMembers(name)
    else
        TriggerClientEvent('QBCore:Notify', source, "Aceasta factiune nu exista", 'error') 
    end
end)

RegisterNetEvent("GangSystem:server:DeleteGangGarage")
AddEventHandler("GangSystem:server:DeleteGangGarage", function(source, name, garageName)
    local result = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
        ['@GangName'] = name,
    })
    if result[1] then
        local foundGarages = json.decode(result[1].garages)
        foundGarages[garageName] = nil
        exports.oxmysql:execute('UPDATE gangs SET garages = @garages WHERE name=@GangName', {
            ['@GangName'] = name,
            ['@garages'] = json.encode(foundGarages),
        })
        updateMembers(name)
    else
        TriggerClientEvent('QBCore:Notify', source, "Aceasta factiune nu exista", 'error') 
    end
end)

RegisterNetEvent("GangSystem:server:AddVehicleToGarage")
AddEventHandler("GangSystem:server:AddVehicleToGarage", function(source, model, garage)
    local license = QBCore.Functions.GetIdentifier(source, "license")
    local result = exports.oxmysql:executeSync('SELECT * FROM players WHERE license=@license', {
        ['@license'] = license,
    })
    if result[1] then
        local gang = result[1].playerGang
        if gang ~= "none" then
            local result = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
                ['@GangName'] = gang,
            })
            if result[1] then
                local garages = json.decode(result[1].garages)
                local vehicles = garages[garage].vehicles
                local vehicleID = math.random(100000, 999999)
                if vehicles[vehicleID] then
                    TriggerEvent("GangSystem:server:AddVehicleToGarage", source, model, garage)
                else
                    vehicles[vehicleID] = {
                        props = {
                            vehProps ={
                                color1 = 5,
                                color2 = 39,
                                fuelLevel = 100,
                            },
                            rgb = {r = 255, g = 255, b = 255}
                        },
                        name = QBCore.Shared.Vehicles[model]["name"],
                        model = model,
                        id = vehicleID,
                        fuelLevel = 100,
                        out = false,
                    }
                    exports.oxmysql:execute('UPDATE gangs SET garages = @garages WHERE name=@GangName', {
                        ['@GangName'] = gang,
                        ['@garages'] = json.encode(garages),
                    })
                    TriggerClientEvent('QBCore:Notify', source, "Vehiculul a fost adaugat in garaj", 'success') 
                    updateMembers(gang)
                end
            end
        end
    end
end)

RegisterNetEvent("GangSystem:server:RefreshGarages")
AddEventHandler("GangSystem:server:RefreshGarages", function(source)
    local result = exports.oxmysql:executeSync('SELECT * FROM gangs')
    outVehicles = {}
    if result[1] then
        local gangs = result
        for k,v in pairs(gangs) do
            local garages = json.decode(v.garages)
            if garages ~= nil then
                for i,j in pairs(garages) do
                    if j.vehicles ~= nil then
                        for z,x in pairs(j.vehicles) do
                            if x.out then
                                x.out = false
                            end
                        end
                    end
                end
            end
            exports.oxmysql:execute('UPDATE gangs SET garages = @garages WHERE name=@GangName', {
                ['@GangName'] = v.name,
                ['@garages'] = json.encode(garages),
            })
            updateMembers(v.name)
        end
        TriggerClientEvent('QBCore:Notify', source, "Garajele au fost resetate cu success", 'success') 
    end
end)

RegisterNetEvent("GangSystem:server:SaveVehicle")
AddEventHandler("GangSystem:server:SaveVehicle", function(source, props,color, garage, gang, plate)
    local result = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
        ['@GangName'] = gang,
    })
    if result[1] then
        local foundGarage = outVehicles[gang]
        local vehicle = foundGarage[plate]
        if foundGarage and vehicle then
            local vehicleID = vehicle.vehicleID
            local garages = json.decode(result[1].garages)
            local vehicles = garages[vehicle.garage].vehicles
            vehicles[vehicleID].out = false
            vehicles[vehicleID].props = {vehProps = props, rgb = color}
            if vehicle.garage == garage then
                exports.oxmysql:execute('UPDATE gangs SET garages = @garages WHERE name=@GangName', {
                    ['@GangName'] = gang,
                    ['@garages'] = json.encode(garages),
                })
            else
                local newGarage = garages[garage]
                newGarage.vehicles[vehicleID] = vehicles[vehicleID]
                vehicles[vehicleID] = nil
                exports.oxmysql:execute('UPDATE gangs SET garages = @garages WHERE name=@GangName', {
                    ['@GangName'] = gang,
                    ['@garages'] = json.encode(garages),
                })
            end
            TriggerClientEvent('QBCore:Notify', source, "Vehiculul a fost bagat in garaj", 'success') 
            TriggerClientEvent("GangSystem:client:DeleteVehicle", source)
            updateMembers(gang)
        else
            TriggerClientEvent('QBCore:Notify', source, "Acest vehicul nu este vehicul de mafie", 'error') 
        end
    end
end)

RegisterNetEvent("GangSystem:server:TakeVehicleOut")
AddEventHandler("GangSystem:server:TakeVehicleOut", function(source, gang, plate, vehicleID, garage)

    outVehicles[gang] = outVehicles[gang] or {}

    outVehicles[gang][plate] = {
            vehicleID = vehicleID, 
            garage = garage,
        }

    local result = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
        ['@GangName'] = gang,
    })

    if result[1] then
        local garages = json.decode(result[1].garages)
        local vehicles = garages[garage].vehicles
        vehicles[vehicleID].out = true
        exports.oxmysql:execute('UPDATE gangs SET garages = @garages WHERE name=@GangName', {
            ['@GangName'] = gang,
            ['@garages'] = json.encode(garages),
        })
        TriggerClientEvent('QBCore:Notify', source, "Vehiculul a fost scos din garaj", 'success') 
        updateMembers(gang)
    end
end)

----------------------EVENTS----------------------

----------------------CALLBACKS----------------------

QBCore.Functions.CreateCallback("GangSystem:server:CheckExistingGang", function(source, cb, gang)
    local result = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
        ['@GangName'] = gang,
    })
    if result[1] then
        cb(true)
    else
        cb(nil)
    end

end)

----------------------CALLBACKS----------------------
---------------------------------------------------------- GARAGES
---------------------------------------------------------- COMMAND CENTER

----------------------COMMANDS----------------------
----------------------COMMANDS----------------------

----------------------EVENTS----------------------

RegisterNetEvent("GangSystem:server:CreateGangCommandCenter")
AddEventHandler("GangSystem:server:CreateGangCommandCenter", function(source, name,location)
    print(source)
    local result = exports.oxmysql:executeSync('SELECT * FROM gangs WHERE name=@GangName', {
        ['@GangName'] = name,
    })
    if result[1] then
        exports.oxmysql:execute('UPDATE gangs SET commandCenter = @location WHERE name=@GangName', {
            ['@GangName'] = name,
            ['@location'] = json.encode(location),
        })
        updateMembers(name)
    else
        TriggerClientEvent('QBCore:Notify', source, "Aceasta factiune nu exista", 'error') 
    end
end)

----------------------EVENTS----------------------

----------------------CALLBACKS----------------------
----------------------CALLBACKS----------------------

---------------------------------------------------------- COMMAND CENTER
