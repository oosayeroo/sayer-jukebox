-- script rewrote for luko (outback zombies)
-- see read me for hrs:basebuilding integration
-- hrs prop event name = sayer-jukebox:hrs_access_jukebox

Config = {}
Config.DebugCode = true -- for testing

Config.Radius = 20 --reasonable distance for sound distance
Config.DefaultVolume = 0.1 --good starting volume.

Config.MyLibraryCommand = 'song_library'

-- Config.TapePlayer = false -- use this if you dont want inventory item boombox
Config.TapePlayer = 'casette_player' --itemcode for the placable boombox (inventory) (not basebuilding prop)
Config.PropModel = 'prop_boombox_01' --model that gets placed down

Config.Locations = { --locations where players can play tapes without the tape player item (safezones etc) (must still have unlocked that tape)
-- Lumberyard
    {Enable = true,ID = 'juke1', Coords = vector4(-572.39, 5318.32, 71.18, 249.96),Model = 'prop_boombox_01'}, -- hopefalls
}

Config.TapeItem = "casette_tape" -- TapeID is set in metadata when picked up (hopefully)
Config.Tapes = {
    -- did some for you already (feel free to remove if you dont like them)
    ['pinkfloyd1'] = { -- unlock code must be unique
        Label = "Pink Floyd - Comfortably Numb", -- will be item label when picked up. (unless you want otherwise)
        Link = 'https://www.youtube.com/watch?v=x-xTttimcNk', 
    },
    ['pinkfloyd2'] = { Label = "Pink Floyd – Time", Link = 'https://www.youtube.com/watch?v=Qr0-7Ds79zo', }, 
    ['pinkfloyd3'] = { Label = "Pink Floyd - Another Brick in the Wall", Link = 'https://www.youtube.com/watch?v=5IpYOF4Hi6Q', }, 
    ['pinkfloyd4'] = { Label = "Pink Floyd - Wish You Were Here", Link = 'https://www.youtube.com/watch?v=IXdNnw99-Ic', }, 
    
    ['philcollins1'] = { Label = "Phil Collins", Link = 'https://www.youtube.com/watch?v=fRHzg7SY6Ko', },

    ['kiss1'] = { Label = "KISS - I Was Made For Loving You", Link = 'https://www.youtube.com/watch?v=ZhIsAZO5gl0', }, 

    ['thepolice1'] = { Label = "The Police - Every Breath You Take", Link = 'https://www.youtube.com/watch?v=6cucosmPj-A', }, 

    ['spandau1'] = { Label = "Spandau Ballet - True", Link = 'https://www.youtube.com/watch?v=AR8D2yqgQ1U', },

    ['nazareth1'] = { Label = "Nazareth - Love Hurts", Link = 'https://www.youtube.com/watch?v=vOn0z0IRVN8', }, 

    ['katebush1'] = { Label = "Kate Bush - Running Up That Hill", Link = 'https://www.youtube.com/watch?v=wp43OdtAAkM', }, 
    ['katebush2'] = { Label = "Kate Bush - Babooshka", Link = 'https://www.youtube.com/watch?v=6xckBwPdo1c', }, 
    ['katebush3'] = { Label = "Kate Bush - Wuthering Heights", Link = 'https://www.youtube.com/watch?v=-1pMMIe4hb4', }, 

    ['shirelles1'] = { Label = "The Shirelles - Will You Still Love Me Tomorrow", Link = 'https://www.youtube.com/watch?v=PAxb1vnb520', }, 

    ['theanimals1'] = { Label = "The Animals - House Of The Rising Sun", Link = 'https://www.youtube.com/watch?v=N4bFqW_eu2I', }, 

    ['martyrobbins1'] = { Label = "Marty Robbins - Big Iron", Link = 'https://www.youtube.com/watch?v=-NuX79Ud8zI', }, 

    ['TRB1'] = { Label = "The Righteous Brothers - You've Lost That Lovin' Feelin'", Link = 'https://www.youtube.com/watch?v=xLiUp3-jCH0', }, 

    ['levang1'] = { Label = "Neil LeVang - Ghost Riders In The Sky", Link = 'https://www.youtube.com/watch?v=0SfU56IDsb4', }, 

    ['jerryleelewis1'] = { Label = "Jerry Lee Lewis - Great Balls of Fire", Link = 'https://www.youtube.com/watch?v=MW3GgSXtESk', }, 

    ['dion1'] = { Label = "Dion - The Wanderer", Link = 'https://www.youtube.com/watch?v=rXqWCeB8Vto', }, 

    ['mj1'] = { Label = "Michael Jackson - Don’t Stop 'Til You Get Enough", Link = 'https://www.youtube.com/watch?v=yURRmWtbTbo', }, 

    ['beegees1'] = {Label = "Bee Gees - Night Fever", Link = 'https://www.youtube.com/watch?v=SkypZuY6ZvA', }, 
    ['beegees2'] = {Label = "Bee Gees - Stayin' Alive", Link = 'https://www.youtube.com/watch?v=fNFzfwLM72c', },

    ['ewandf1'] = { Label = "Earth, Wind & Fire - Boogie Wonderland", Link = 'https://www.youtube.com/watch?v=ji-gH_yXjGo', }, 

    ['redbone1'] = { Label = "Redbone - Come and Get Your Love", Link = 'https://www.youtube.com/watch?v=bc0KhhjJP98', }, 

    ['abba1'] = { Label = "ABBA - Fernando", Link = 'https://www.youtube.com/watch?v=dQsjAbZDx-4', }, 
    ['abba2'] = { Label = "ABBA - Knowing Me, Knowing You", Link = 'https://www.youtube.com/watch?v=iUrzicaiRLU', }, 
    ['abba3'] = { Label = "ABBA - Waterloo", Link = 'https://www.youtube.com/watch?v=Sj_9CiNkkn4', }, 
    ['abba4'] = { Label = "ABBA - SOS", Link = 'https://www.youtube.com/watch?v=cvChjHcABPA', }, 

    ['fleetwoodmac1'] = { Label = "Fleetwood Mac - Go Your Own Way", Link = 'https://www.youtube.com/watch?v=oiosqtFLBBA', }, 

    ['elo1'] = { Label = "ELO - Mr. Blue Sky", Link = 'https://www.youtube.com/watch?v=aQUlA8Hcv4s', }, 

    ['beetles1'] = { Label = "The Beatles - Strawberry Fields Forever", Link = 'https://www.youtube.com/watch?v=HtUH9z_Oey8', },
    ['beetles2'] = { Label = "The Beatles - Come Together", Link = 'https://www.youtube.com/watch?v=45cYwDMibGo', }, 
    ['beetles3'] = { Label = "The Beatles - Hey Jude", Link = 'https://www.youtube.com/watch?v=A_MjCqQoLLA', }, 
    ['beetles4'] = { Label = "The Beatles - Eleanor Rigby", Link = 'https://www.youtube.com/watch?v=HuS5NuXRb5Y', },

    ['queen1'] = { Label = "Queen - The Show Must Go On", Link = 'https://www.youtube.com/watch?v=t99KH0TR-J4', },
    ['queen2'] = { Label = "Queen - Under Pressure", Link = 'https://www.youtube.com/watch?v=a01QQZyl-_I', },
    ['queen3'] = { Label = "Queen - I Want to Break Free", Link = 'https://www.youtube.com/watch?v=Kee9Et2j7DA', },
    ['queen4'] = { Label = "Queen - These Are The Days Of Our Lives", Link = 'https://www.youtube.com/watch?v=oB4K0scMysc', },
    ['queen5'] = { Label = "Queen – Bohemian Rhapsody", Link = 'https://www.youtube.com/watch?v=fJ9rUzIMcZQ', },

    ['gnr1'] = { Label = "Guns N' Roses - November Rain", Link = 'https://www.youtube.com/watch?v=8SbUC-UaAxE', },

    ['direstraits1'] = { Label = "Dire Straits - Sultans Of Swing", Link = 'https://www.youtube.com/watch?v=h0ffIJ7ZO4U', },

    ['prince1'] = { Label = "Prince - Purple Rain", Link = 'https://www.youtube.com/watch?v=edDiY323768', }, 


    ['oilrig_example'] = { no_random = true, Label = "Training Manual (Pump Seals)", Link = 'randommusiclink', }, 

}