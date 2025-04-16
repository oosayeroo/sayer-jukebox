local QBCore = exports['qb-core']:GetCoreObject()
local xSound = exports.xsound

local function DebugCode(msg)
    if Config.DebugCode then
        print("sayer-jukebox: "..msg)
    end
end

function SendNotify(src, Title, MSG, Type, Time)
    if not Title then Title = "Jukebox" end
    if not Time then Time = 5000 end
    if not Type then Type = 'success' end
    if not MSG then DebugCode("SendNotify Server Triggered With No Message") return end
    local data = {
        id = 'jukebox_notify',
        title = Title,
        description = MSG,
        type = Type 
    }
    TriggerClientEvent('ox_lib:notify', src, data)
end

if Config.TapePlayer then
    QBCore.Functions.CreateUseableItem(Config.TapePlayer, function(source, item)
    	local src = source
    	local Player = QBCore.Functions.GetPlayer(src)
    	if Player.Functions.RemoveItem(Config.TapePlayer, 1) then
    	    TriggerClientEvent('sayer-jukebox:PlaceProp', src)
        end
    end)
end

if Config.TapeItem then
    QBCore.Functions.CreateUseableItem(Config.TapeItem, function(source, item)
    	local src = source
    	local Player = QBCore.Functions.GetPlayer(src)
        if item.info then
            for k,v in pairs(item.info) do
                DebugCode("K = "..tostring(k))
                DebugCode("V = "..tostring(v))
            end
        end
    	if Player.Functions.RemoveItem(item.name, 1) then
    	    TriggerEvent('sayer-jukebox:UnlockSong', src, item.info.songID)
        end
    end)
end

RegisterNetEvent('sayer-jukebox:AddItem', function(item,amount)
    if not amount then amount = 1 end
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.AddItem(item,amount)
end)

RegisterNetEvent('sayer-jukebox:PlayTape', function(data)
    local add_to_queue = data.add_to_queue
    local isHRS = data.HRS
    local song = Config.Tapes[data.songID].Link
    local entity = data.prop
    if isHRS then entity = "hrs_prop_"..tostring(entity) end
    local Coords = data.coords
    local src = source

    xSound:PlayUrlPos(-1, tostring(entity), song, Config.DefaultVolume, Coords)
    xSound:Distance(-1, tostring(entity), Config.Radius)
end)

RegisterNetEvent('sayer-jukebox:DestroySound', function(entity, isHRS)
    local src = source
    if isHRS then entity = "hrs_prop_"..tostring(entity) end

    xSound:Destroy(-1, tostring(entity))
end)

RegisterNetEvent('sayer-jukebox:Stop', function(data)
    local pickup = data.isPickup
    local isHRS = data.isHRS or false
    local name = ""
    if pickup then name = tostring(data.entity) else name = data.id end
    if isHRS then name = "hrs_prop_"..tostring(data.id) end
    local src = source

    xSound:Destroy(-1, name)
end)

RegisterNetEvent('sayer-jukebox:Pause', function(data)
    local pickup = data.isPickup
    local isHRS = data.isHRS or false
    local name = ""
    if pickup then name = tostring(data.entity) else name = data.id end
    if isHRS then name = "hrs_prop_"..tostring(data.id) end
    local src = source

    xSound:Pause(-1, name)
end)

RegisterNetEvent('sayer-jukebox:Resume', function(data)
    local pickup = data.isPickup
    local isHRS = data.isHRS or false
    local name = ""
    if pickup then name = tostring(data.entity) else name = data.id end
    if isHRS then name = "hrs_prop_"..tostring(data.id) end
    local src = source

    xSound:Resume(-1, name)
end)

RegisterNetEvent('sayer-jukebox:ChangeVolume', function(volume, name)
    local src = source
    if not tonumber(volume) then return end
    local new_volume = volume / 100

    xSound:setVolume(-1, name, new_volume)
end)

-- EXPORTS

function GetRandomSong()
    local keys = {}
    for k, v in pairs(Config.Tapes) do
        if v.no_random == nil or not v.no_random then
            table.insert(keys, k)
        end
    end

    if #keys == 0 then return nil end

    local randomKey = keys[math.random(1, #keys)]
    return randomKey, Config.Tapes[randomKey]
end

exports('GetRandomSong', GetRandomSong)







-- DATABASE STUFF

RegisterNetEvent('sayer-jukebox:InitialiseDatabase', function()
    local Player = QBCore.Functions.GetPlayer(source)
    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT * FROM sayer_jukebox WHERE citizenid = ?', {citizenid}, function(exisitingdata)
        if not exisitingdata[1] then
            DebugCode("existing data was nil, creating new")
            local songs = {}

            MySQL.insert('INSERT INTO sayer_jukebox (citizenid, songs) VALUES (?, ?)', {
                citizenid,
                json.encode(songs),
            })
            DebugCode("Added New Data")
        else
            DebugCode("existing data already there")
        end
    end)
end)

--trigger from client
QBCore.Functions.CreateCallback('sayer-jukebox:GetAllSongs', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then 
        cb(nil) 
        return 
    end

    local citizenid = Player.PlayerData.citizenid

    MySQL.query('SELECT * FROM sayer_jukebox WHERE citizenid = ?', {citizenid}, function(songsData)
        if songsData and songsData[1] then
            local FormattedData = json.decode(songsData[1].songs)
            cb(FormattedData)
        else
            cb(nil)
        end
    end)
end)

--trigger from server
RegisterNetEvent('sayer-jukebox:UnlockSong', function(src, song_code)
    local SongCFG = Config.Tapes[song_code]
    if not SongCFG then DebugCode("Song doesnt exist in Config.Tapes") return end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then DebugCode("player not found") return end

    local citizenid = Player.PlayerData.citizenid
    local songsData = MySQL.query.await('SELECT `songs` FROM `sayer_jukebox` WHERE `citizenid` = ?', {citizenid})

    if songsData and songsData[1] then
        local FormattedData = json.decode(songsData[1].songs)

        if type(FormattedData) ~= "table" then
            FormattedData = {}
        end

        for _, v in ipairs(FormattedData) do
            if v == song_code then
                DebugCode("song already discovered")
                return -- song already unlocked
            end
        end

        -- Add and update
        table.insert(FormattedData, song_code)
        MySQL.update('UPDATE sayer_jukebox SET songs = ? WHERE citizenid = ?', {
            json.encode(FormattedData),
            citizenid
        }, function(affectedRows)
            if affectedRows > 0 then
                SendNotify(src, "Song Discovered", "Discovered Song: " .. SongCFG.Label)
            else
                DebugCode("Failed to update songs table, SQL issue")
            end
        end)
    end
end)

--trigger from client
RegisterNetEvent('sayer-jukebox:UnloadSong', function(data)
    local src = source
    local song_code = data.songID
    local SongCFG = Config.Tapes[song_code]
    if not SongCFG then DebugCode("Song doesn't exist in Config.Tapes") return end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then DebugCode("Player not found") return end

    local citizenid = Player.PlayerData.citizenid
    local songsData = MySQL.query.await('SELECT `songs` FROM `sayer_jukebox` WHERE `citizenid` = ?', {citizenid})

    if songsData and songsData[1] then
        local FormattedData = json.decode(songsData[1].songs)

        if type(FormattedData) ~= "table" then
            FormattedData = {}
        end

        local removed = false
        for i, v in ipairs(FormattedData) do
            if v == song_code then
                table.remove(FormattedData, i)
                removed = true
                break
            end
        end

        if removed then
            MySQL.update('UPDATE sayer_jukebox SET songs = ? WHERE citizenid = ?', {json.encode(FormattedData),citizenid}, function(affectedRows)
                if affectedRows > 0 then
                    SendNotify(src, "Song Removed", "Removed Song: "..SongCFG.Label)
                    exports.core_inventory:addItem('content-'..citizenid, Config.TapeItem, 1, { songID = song_code, songname = SongCFG.Label }, 'content')
                else
                    DebugCode("Failed to update songs table, SQL issue")
                end
            end)
        else
            DebugCode("Song not found in user's library")
            SendNotify(src, "Error", "You haven't unlocked this song, HOW ARE YOU DOING THIS???")
        end
    end
end)
