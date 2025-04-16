local QBCore = exports['qb-core']:GetCoreObject()
local currentData = nil
local PropTarget = {}
local PermProps = {}
local PermTargets = {}

local function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        local endTime = GetGameTimer() + 5000
        while not HasAnimDictLoaded(dict) and GetGameTimer() < endTime do
            Wait(5)
        end
        if not HasAnimDictLoaded(dict) then
            print("Failed to load anim dict: " .. dict)
        end
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('sayer-jukebox:InitialiseDatabase')
end)

CreateThread(function()
    for k,v in pairs(Config.Locations) do
        if v.Enable then
            if v.Model then
                if v.Coords then
                    local model = ''
                    model = v.Model
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                      Wait(0)
                    end
                
                    PermProps["Prop"..k..v.Coords.x] = CreateObject(model, v.Coords.x, v.Coords.y, v.Coords.z-1, false, true, false)
		            SetEntityHeading(PermProps["Prop"..k..v.Coords.x],v.Coords.w)
                    FreezeEntityPosition(PermProps["Prop"..k..v.Coords.x],true)
                    -- PlaceObjectOnGroundProperly(PermProps["Prop"..k..v.Coords.x])
                    SetEntityAsMissionEntity(PermProps["Prop"..k..v.Coords.x])  
                    PermTargets["Prop"..k..v.Coords.x] = 
                    exports['ox_target']:addLocalEntity(PermProps["Prop"..k..v.Coords.x], {
                        {
                            onSelect = function()
                                OpenMusicMenu(false, v.ID)
                            end,
                            icon = "fas fa-radio",
                            label = "Use Jukebox",
                            distance = 3.0,
                        },
                    })
                    -- exports['qb-target']:AddTargetEntity(PermProps["Prop"..k..v.Coords.x],{
                    --     options = {{action = function() OpenMusicMenu(false, v.ID) end,icon = "fas fa-radio",label = "Use Jukebox",},},
                    --     distance = 2.5,
                    -- })
                else
                    print("CASSETTEPLAYER: Prop Enabled But No Coords Set")
                end
            else
                print("CASSETTEPLAYER: Prop Enabled But No Model Set")
            end
        end
    end
end)

RegisterNetEvent('sayer-jukebox:PlaceProp', function()
    if currentData then
        QBCore.Functions.Notify('You already have a cassette player placed.', 'error')
        return 
    end

    loadAnimDict("anim@heists@money_grab@briefcase")
    TaskPlayAnim(PlayerPedId(), "anim@heists@money_grab@briefcase", "put_down_case", 8.0, -8.0, -1, 1, 0, false, false, false)
    Wait(1000)
    ClearPedTasks(PlayerPedId())
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local forward = GetEntityForwardVector(PlayerPedId())
    local x, y, z = table.unpack(coords + forward * 0.5)
    local object = CreateObject(GetHashKey(Config.PropModel), x, y, z, true, false, false)
    PlaceObjectOnGroundProperly(object)
    SetEntityHeading(object, heading)
    FreezeEntityPosition(object, true)
    currentData = NetworkGetNetworkIdFromEntity(object)
    PropTarget["Player"] = 
    exports['ox_target']:addLocalEntity(object, {
        {
            onSelect = function()
                OpenMusicMenu(true)
            end,
            icon = "fas fa-radio",
            label = "Use Casette Player",
            distance = 3.0,
        },
    })
end)

RegisterNetEvent('sayer-jukebox:client:PickupProp', function()
    if currentData then
        local obj = NetworkGetEntityFromNetworkId(currentData)
        local objCoords = GetEntityCoords(obj)
        NetworkRequestControlOfEntity(obj)
        loadAnimDict("anim@heists@narcotics@trash")
        TaskPlayAnim(PlayerPedId(), "anim@heists@narcotics@trash", "pickup", 8.0, -8.0, -1, 1, 0, false, false, false)
        Wait(700)
        SetEntityAsMissionEntity(obj, false, true)
        DeleteEntity(obj)
        DeleteObject(obj)
        if not DoesEntityExist(obj) then
            TriggerServerEvent('sayer-jukebox:DestroySound', currentData)
            TriggerServerEvent('sayer-jukebox:AddItem', Config.TapePlayer)
            currentData = nil 
        end
        if PropTarget["Player"] ~= nil then
            exports.ox_target:removeLocalEntity(PropTarget["Player"])
            -- exports['qb-target']:RemoveTargetModel(PropTarget["Player"])
        end
        Wait(500)
        ClearPedTasks(PlayerPedId())
    else
        QBCore.Functions.Notify("This isnt yours", 'error')
    end
end)

AddEventHandler('sayer-jukebox:hrs_access_jukebox',function(base_prop_id, base_prop_entity)
    local entity_coords = GetEntityCoords(base_prop_entity)
    print(tostring(entity_coords))
    print("entity interacting with: "..tostring(base_prop_entity))
    OpenHRSMusicMenu(tostring(base_prop_id))
end)

function OpenMusicMenu(includePickup, ID)
    TriggerEvent('sayer-jukebox:MusicMenu',includePickup, ID)
end

function OpenHRSMusicMenu(ID)
    local musicMenu = {
        {
            title = '🖭 | Play a tape', 
            description = 'Play a discovered song', 
            
            event = 'sayer-jukebox:CheckPockets', 
            args = {
                isPickup = false, 
                id = ID,
                isHRS = true,
            }
        },
        {
            title = '⏸️ | Pause Tape', 
            description = 'Pause currently playing tape', 
            serverEvent = 'sayer-jukebox:Pause', 
            args = {
                isPickup = false, 
                id = ID,
                isHRS = true,
            }
        },
        {
            title = '▶️ | Resume Tape', 
            description = 'Resume playing paused tape', 
            serverEvent = 'sayer-jukebox:Resume', 
            args = {
                isPickup = false, 
                id = ID,
                isHRS = true,
            }
        },
        {
            title = '🔈 | Change Volume', 
            description = 'Change volume of tape', 
            event = 'sayer-jukebox:Volume', 
            args = {
                isPickup = false, 
                id = ID,
                isHRS = true,
            }
        },
        {
            title = '❌ | Turn off tape', 
            description = 'Stop the tape & choose a new one', 
            serverEvent = 'sayer-jukebox:Stop', 
            args = {
                isPickup = false, 
                id = ID,
                isHRS = true,
            }
        }
    }

    lib.registerContext({
        id = 'jukebox_hrs_main_menu',
        title = '🖭 | My Jukebox',
        options = musicMenu
      })
    lib.showContext('jukebox_hrs_main_menu')
end

RegisterNetEvent('sayer-jukebox:MusicMenu', function(includePickup, ID)
    local musicMenu = {
        {
            title = '🖭 | Play a tape', 
            description = 'Play a discovered song', 
            
            event = 'sayer-jukebox:CheckPockets', 
            args = {
                isPickup = includePickup, 
                id = ID
            }
        },
        {
            title = '⏸️ | Pause Tape', 
            description = 'Pause currently playing tape', 
            serverEvent = 'sayer-jukebox:Pause', 
            args = {
                entity = currentData, 
                isPickup = includePickup, 
                id = ID
            }
        },
        {
            title = '▶️ | Resume Tape', 
            description = 'Resume playing paused tape', 
            serverEvent = 'sayer-jukebox:Resume', 
            args = {
                entity = currentData, 
                isPickup = includePickup, 
                id = ID
            }
        },
        {
            title = '🔈 | Change Volume', 
            description = 'Change volume of tape', 
            event = 'sayer-jukebox:Volume', 
            args = {
                isPickup = includePickup, 
                id = ID,
            }
        },
        {
            title = '❌ | Turn off tape', 
            description = 'Stop the tape & choose a new one', 
            serverEvent = 'sayer-jukebox:Stop', 
            args = {
                entity = currentData, 
                isPickup = includePickup, 
                id = ID
            }
        }
    }

    if includePickup then
        table.insert(musicMenu, {
            title = '❌ | Pickup',
            description = 'Stop the tape & Pick Up Player',
            event = 'sayer-jukebox:client:PickupProp',
            args = {}
        })
    end

    lib.registerContext({
        id = 'jukebox_main_menu',
        title = '🖭 | Casette Player',
        options = musicMenu
      })
    lib.showContext('jukebox_main_menu')
end)


RegisterNetEvent('sayer-jukebox:CheckPockets', function(data)
    local Coords = GetEntityCoords(PlayerPedId())
    local Prop = nil
    local isHRS = data.isHRS or false

    if data.isPickup then
        Coords = GetEntityCoords(NetworkGetEntityFromNetworkId(currentData))
        Prop = currentData
    else
        Prop = data.id
    end

    QBCore.Functions.TriggerCallback('sayer-jukebox:GetAllSongs', function(ReturningSongs)
        local columns = {}

        if ReturningSongs then
            for _, v in pairs(ReturningSongs) do
                local CFG = Config.Tapes[v]
                if CFG then
                    local item = {
                        title = CFG.Label,
                        description = "Play Song",
                        event = 'sayer-jukebox:PlayTape',
                        args = {
                            songID = v,
                            prop = Prop,
                            coords = Coords,
                            HRS = isHRS,
                        }
                    }
                    table.insert(columns, item)
                end
            end
        else
            table.insert(columns, {
                title = "No songs unlocked",
                description = "Discover tapes to play them.",
                disabled = true
            })
        end

        lib.registerContext({
            id = 'jukebox_songs_menu',
            title = '🖭 | My Discovered Songs',
            options = columns
        })

        lib.showContext('jukebox_songs_menu')
    end)
end)

RegisterNetEvent('sayer-jukebox:PlayFromWhere',function(data)
    print(tostring(data.prop))
    local columns = {}
    table.insert(columns, {
        title = 'Play From Speakers', 
        description = 'Play From Connected Speakers (if any)', 
        event = 'sayer-jukebox:hrs_get_speakers', 
        args = data
    })
    table.insert(columns, {
        title = 'Play From Jukebox', 
        description = 'Play From The Jukebox', 
        event = 'sayer-jukebox:PlayTape', 
        args = data
    })
    lib.registerContext({
        id = 'jukebox_from_where_menu',
        title = '🖭 | Play From Where?',
        options = columns
    })

    lib.showContext('jukebox_from_where_menu')
end)

RegisterNetEvent('sayer-jukebox:PlayFromSpeakers',function(data)
    ExecuteCommand("e atm")
    if lib.progressCircle({duration = 1500,position = 'bottom',useWhileDead = false,canCancel = true,disable = {    car = true,},}) then 
        TriggerServerEvent('sayer-jukebox:PlayTape',data)
        ExecuteCommand("emotecancel")
        ClearPedTasks(PlayerPedId()) 
    else 
        ClearPedTasks(PlayerPedId())
        ExecuteCommand("emotecancel")
        lib.notify({
            title = 'Cancelled...',
            description = 'You cancelled playing the tape',
            type = 'error'
        })
    end
end)

RegisterNetEvent('sayer-jukebox:PlayTape',function(data)
    ExecuteCommand("e atm")
    if lib.progressCircle({duration = 1500,position = 'bottom',useWhileDead = false,canCancel = true,disable = {    car = true,},}) then 
        TriggerServerEvent('sayer-jukebox:PlayTape',data)
        ExecuteCommand("emotecancel")
        ClearPedTasks(PlayerPedId()) 
    else 
        ClearPedTasks(PlayerPedId())
        ExecuteCommand("emotecancel")
        lib.notify({
            title = 'Cancelled...',
            description = 'You cancelled playing the tape',
            type = 'error'
        })
    end
end)

RegisterNetEvent('sayer-jukebox:Volume', function(data)
    local pickup = data.isPickup
    local isHRS = data.isHRS or false
    local name = ""

    if pickup then name = tostring(currentData) else name = data.id end
    if isHRS then name = "hrs_prop_"..tostring(data.id) end

    local input = lib.inputDialog('Tape Volume', {
        {type = 'input', label = 'Volume', description = 'Min: 1 - Max: 100', required = true, min = 1, max = 100},
      })

    if input then
        if not input[1] then return end
        ExecuteCommand("e atm")
        if lib.progressCircle({duration = 1500,position = 'bottom',useWhileDead = false,canCancel = true,disable = {    car = true,},}) then 
            TriggerServerEvent('sayer-jukebox:ChangeVolume', input[1], name)
            ExecuteCommand("emotecancel")
            ClearPedTasks(PlayerPedId()) 
        end
    end
end)

RegisterCommand(Config.MyLibraryCommand, function()
    QBCore.Functions.TriggerCallback('sayer-jukebox:GetAllSongs', function(ReturningSongs)
        local columns = {}

        if ReturningSongs then
            for _, v in pairs(ReturningSongs) do
                local CFG = Config.Tapes[v]
                if CFG then
                    local item = {
                        title = CFG.Label,
                        description = "Unload Song Into Pockets",
                        serverEvent = 'sayer-jukebox:UnloadSong',
                        args = {
                            songID = v,
                        }
                    }
                    table.insert(columns, item)
                end
            end
        else
            table.insert(columns, {
                title = "No songs unlocked",
                description = "Discover tapes to view them.",
                disabled = true
            })
        end

        lib.registerContext({
            id = 'jukebox_library_menu',
            title = '🖭 | My Library',
            options = columns
        })

        lib.showContext('jukebox_library_menu')
    end)
end)

AddEventHandler('onResourceStop', function(t) if t ~= GetCurrentResourceName() then return end
    for k in pairs(PermTargets) do exports['ox_target']:removeLocalEntity(k) end
    if PropTarget["Player"] ~= nil then
        exports['ox_target']:removeLocalEntity(PropTarget["Player"])
    end
    if currentData then
        local obj = NetworkGetEntityFromNetworkId(currentData)
        DeleteEntity(obj)
        DeleteObject(obj)
    end
    for _,v in pairs(PermProps) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
    end
end)