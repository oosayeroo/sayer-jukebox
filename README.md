Requires:
  - qb-core
  - ox_lib
  - core_inventory
  - oxmysql
  [xsound](https://github.com/Xogy/xsound) its just a drag n drop script

  - run `sayer_jukebox.sql` for your database
  - add images from `img` folder to your servers images folder (or get new ones)
  - ensure `sayer-jukebox` in your `server.cfg` or place in folder already ensured
  - configure script to your liking (some songs already in list)

  ### items.lua 
  - no category set so you can do that bit yourself
  - not made images for the basebuilding items yet either
  ```lua
  casette_tape 				 = {name = 'casette_tape', 			  	  	label = 'Casette Tape', 			weight = 500, 		type = 'item', 		image = 'casette_tape.png', 		unique = true, 	    useable = true, 	shouldClose = true,	   combinable = nil,   description = 'old tunes'},
	casette_player 				 = {name = 'casette_player', 			  	label = 'Casette Player', 			weight = 500, 		type = 'item', 		image = 'casette_player.png', 		unique = true, 		useable = true, 	shouldClose = true,	   combinable = nil,   description = 'old tunes'},
-- FOR BASE BUILDING
  ['bkr_prop_clubhouse_jukebox_01a'] = {["name"] = "bkr_prop_clubhouse_jukebox_01a", ["label"] = "Jukebox (Wall)", ["weight"] = 200, ["type"] = "item", ["image"] = "bkr_prop_clubhouse_jukebox_01a.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Used for base building"},
  ['bkr_prop_clubhouse_jukebox_01b'] = {["name"] = "bkr_prop_clubhouse_jukebox_01b", ["label"] = "Jukebox (Floor)", ["weight"] = 200, ["type"] = "item", ["image"] = "bkr_prop_clubhouse_jukebox_01b.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Used for base building"},
  ['bkr_prop_clubhouse_jukebox_02a'] = {["name"] = "bkr_prop_clubhouse_jukebox_02a", ["label"] = "Jukebox (Floor)", ["weight"] = 200, ["type"] = "item", ["image"] = "bkr_prop_clubhouse_jukebox_02a.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Used for base building"},
  ['prop_boombox_01'] = {["name"] = "prop_boombox_01", ["label"] = "Boombox", ["weight"] = 200, ["type"] = "item", ["image"] = "casette_player.png", ["unique"] = false, ["useable"] = true, ["shouldClose"] = true, ["combinable"] = nil, ["description"] = "Used for base building"},
  ```




## base building
- add this to your hrs_base_building/config.lua
```lua
------- Music Props

    ["bkr_prop_clubhouse_jukebox_01a"] = {
        item = "bkr_prop_clubhouse_jukebox_01a",
        life = 20000.0,
        type = "jukebox",
        subtype = "findWall",
        TriggerEvent = {
            type = "client",
            event = "sayer-jukebox:pre_hrs_access_jukebox",
            args = {"hrs_base_entity"},
            entityAsArg = "hrs_base_entity"
        },
        power = 10, -- may need changing
        crafting = {
            {name = "metalscrap",count = 20}
        }
    },

    ["bkr_prop_clubhouse_jukebox_01b"] = {
        item = "bkr_prop_clubhouse_jukebox_01b",
        life = 20000.0,
        type = "jukebox",
        subtype = "findGroud",
        TriggerEvent = {
            type = "client",
            event = "sayer-jukebox:pre_hrs_access_jukebox",
            args = {"hrs_base_entity"},
            entityAsArg = "hrs_base_entity"
        },
        power = 10, -- may need changing
        crafting = {
            {name = "metalscrap",count = 20}
        }
    },

    ["bkr_prop_clubhouse_jukebox_02a"] = {
        item = "bkr_prop_clubhouse_jukebox_02a",
        life = 20000.0,
        type = "jukebox",
        subtype = "findGroud",
        TriggerEvent = {
            type = "client",
            event = "sayer-jukebox:pre_hrs_access_jukebox",
            args = {"hrs_base_entity"},
            entityAsArg = "hrs_base_entity"
        },
        power = 10, -- may need changing
        crafting = {
            {name = "metalscrap",count = 20}
        }
    },

    ["prop_boombox_01"] = {
        item = "prop_boombox_01",
        life = 20000.0,
        type = "jukebox",
        TriggerEvent = {
            type = "client",
            event = "sayer-jukebox:pre_hrs_access_jukebox",
            args = {"hrs_base_entity"},
            entityAsArg = "hrs_base_entity"
        },
        power = 10, -- may need changing
        crafting = {
            {name = "metalscrap",count = 20}
        }
    },
```

 - add this to your `hrs_base_building/client_unlocked.lua`

 - in `registerTarget` function where label = `label = Config.Locales["turn_off"] .. getLabel(v.item),`
 - add this event `TriggerServerEvent('sayer-jukebox:DestroySound', entity)` so it looks like this 
 ```lua
 {
    num= #options + 1,
    type = 'client',
    icon = "fa-solid fa-toggle-on",
    label = Config.Locales["turn_off"] .. getLabel(v.item),
    action = function(entity)
        TriggerEvent('building:interact',entity,false)
        TriggerServerEvent('sayer-jukebox:DestroySound', propsalreadyspowned[entity].id, true)
    end,
    canInteract = function(entity)
        if propsalreadyspowned[entity] then
            if propsalreadyspowned[entity].on then
                return true
            end
        end
        return false
    end
}
```

 - in `RegisterNUICallback("action", function(data)` add this function to the `if data.action == "deleteprop" then`
 - should look like this 
 ```lua
 if data.action == "deleteprop" then
    CloseHtml()
    if progressBar('prop_remove') then
        SayerCheckEntity(data.id)
        TriggerServerEvent('hrs_base_building:remove',data.id)
    end
    return
end 
```

- lastly, at the bottom of the file add this `new` chunk of code
```lua
local EnergyCheckTimeInMS = 30000 -- 30 seconds for better performance
CreateThread(function()
    while true do
        Wait(EnergyCheckTimeInMS)
        for entity,values in pairs(propsalreadyspowned) do
            if Config.Models[values.hash].type == "jukebox" then
                if Config.Models[values.hash].power ~= nil and Config.Models[values.hash].power > 0 then

                    if not hasEnergy(values.id) then
                        TriggerServerEvent('sayer-jukebox:DestroySound', propsalreadyspowned[entity].id, true)
                    end
                end
            elseif Config.Models[values.hash].type == "someothershit" then
                -- do some other shit with some other thing
            end
        end
    end
end)

function SayerCheckEntity(id)
    for entity, values in pairs(propsalreadyspowned) do
        if values.id == id then
            if Config.Models[values.hash].type == "jukebox" then
                TriggerServerEvent('sayer-jukebox:DestroySound', values.id, true)
            elseif Config.Models[values.hash].type == "someothershit" then
                -- do some other shit ( can be cycled for other props to add options on delete)
            end
        end
    end
end

RegisterNetEvent('sayer-jukebox:pre_hrs_access_jukebox', function(entity)
    local propsID = propsalreadyspowned[entity].id
    print(tostring(propsID))
    TriggerEvent('sayer-jukebox:hrs_access_jukebox', propsID)
end)
```





## core_inventory

  - add this to your `core_inventory/server/metadata.lua` inside the metadata chunk
  ```lua
  elseif itemData["name"] == "casette_tape" then
        local randomSong, songDetails = exports['sayer-jukebox']:GetRandomSong()
        info.songID = randomSong
        info.songname = songDetails.Label
  ```




## hrs_loot

 - you can also assign metadata to ignore the core inventory one above if you set it in looting
 - using variables:
    - `songID` = must be a unlock code from the `sayer-jukebox` config.lua/Config.Tapes table
    - `songname` = the label shown in info section of invenotry item
 - here is a hrs loot example
 ```lua
 {names = {'casette_tape'},minValue = 1,maxValue = 1,probability = 80,metadata = {songID = "kiss1",songname = "this is a test with song kiss"}} 
 ```
 - for some reason hrs only allows metadata on probability loots and not fixed loots

 - full working example
 ```lua
 ["zombie_default"] = {
        fixedLoots = {
            {name = "money",count = 1} 
        }, 
        probabilityLoots = {
            loop = 1, 
            items = {
                {names = {'casette_tape'},minValue = 1,maxValue = 1,probability = 80,metadata = {songID = "kiss1",songname = "this is a test with song kiss"}} 
            }
        }, 
        lootRefreshTime = 10
    },
 ```
