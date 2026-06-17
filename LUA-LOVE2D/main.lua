--[[
boites de dialogue
objets stackable
énemis
]]

function love.load()

    require("systeme")
    require("Menu/menu")
    require("Tilemap/map")
    require("Player/player")
    require("Bullets/bullets")

    loadMenu()
    loadPlayer(NbreJoueursMax)



    --paramètres menues
    musique = love.audio.newSource("musique.mp3", "stream")
    love.audio.setVolume(0.1)

    love.window.setMode(128*8,128*8,{resizable = true})
    love.window.setTitle("Menu Milan")

    --Menus
    addBouton("principal",Bmenu("jouer","principal","chargement"))
    addBouton("principal",Bvalue("joueur.s","Nplayers",12))
    addBouton("principal",Bvalue("map","map",2))
    addBouton("principal",Bmenu("Personnages","classe"))
    addBouton("principal",Bmenu("options","dev"))
    addBouton("principal",Baffichage("v2.5"))
    addBouton("principal",Bmenu("futurs updates?","futur"))

    addBouton("dev",Bactiver("musique","musique"))
    addBouton("dev",Bactiver("voir les FPS","fps"))
    addBouton("dev",Baffichage("pour jouer manette\nutilisez Joy2Key !",1))

    addBouton("joueurs",Baffichage("bonjour\nle\nmonde :)",2))
    addBouton("joueurs",Bvalue("joueur.s","Nplayers",12))
    addBouton("joueurs",Bfunc("reload players",loadPlayer))
    addBouton("joueurs",Blist({"Choix 1","c2","NON, pas ça !!!"},"map"))

    addBouton("futur",Baffichage("à venir :"))
    addBouton("futur",Baffichage("- contrôles manettes"))
    addBouton("futur",Baffichage("- classe musicien"))
    addBouton("futur",Baffichage("- Modes de jeu"))
    --addBouton("futur",Bmenu("joueurs","joueurs"))

    addBouton("classe",Baffichage("Classes :"))
    addBouton("classe",Blist({"classique","scout","explorateur","kamikaze","horloger"},"classe"))
end




function love.update(dt)
    if sequance == "menu" then --////////////////////
        randomize()

    elseif sequance == "chargement" then --////////////////////
        love.window.setTitle("Le jeu supergénial de fou furieux tellement bien qu'il ...   (random : "..random..")  "..paramMenus.Nplayers[1].." joueur.s")

        loadMap()
        loadPlayer()
        loadItems()
        loadBullets()



        msec = 0 --FPS count
        frameSec = 0
        delta = 1
        frame = 0
        local i = paramMenus.map[1]
        randomSpawnItems(SI[i][1],SI[i][2],SI[i][3],SI[i][4],SI[i][5])
        timeSpawn = 0

        local backUp = {
            itemsGround = itemsGround,
            frame = 0,
            players = players,
            bulletsList = {"vide"}
        }
        backUps = {backUp,backUp,backUp} 


        sequance = "en jeu"

    elseif sequance == "en jeu" then --////////////////////

        delta = 1--dt*60
        if frameSec >= 180 then
            frameSec=0
            msec = 0
        end
        msec = msec+dt --FPS count
        frameSec = frameSec+1
        frame = frame+1 --INDICATEUR GLOBAL DE TEMPS / Charger une backUp avant (ou à la fin du code) / save une back up après

        if frame%120==0 then -- toutes les secondes, charge des back up
            backUps[1] = backUps[2]
            backUps[2] = backUps[3]
            backUps[3] = {
                itemsGround = deepCopy(itemsGround),
                frame = frame,
                players = deepCopy(players),
                bulletsList = deepCopy(bulletsList)
            }
        end
        --respawn des items
        timeSpawn = timeSpawn+1/60
        if timeSpawn>60 then
            timeSpawn = 0

            local it = {}
            local rand = randInt(3)
            if rand == 0 then
                it = {{12},{1},{6}}
            elseif rand == 1 then
                it = {{0},{2},{22}}
            else
                it = {{6},{7},{1}}
            end

            local i = paramMenus.map[1]
            randomSpawnItems(
                it,
            SI[i][2],SI[i][3],SI[i][4],SI[i][5])
        end

        randomize()

        --oulala code code (Musique)
        if paramMenus.musique[1] then love.audio.play(musique) end


        --////////////// A CHAQUE JOUEUR
        for ip=1,numPlayers do
            local p=players[ip]

            applyItemsBuffs(ip)

            --touche action pressé ?
            if p.inventaire then
                if love.keyboard.isDown(p.ctrl.A) and (p.select==1 or p.select==2) then PlayerUseItem(ip,p.select,true) end
            else
                if love.keyboard.isDown(p.ctrl.A) then PlayerUseItem(ip,1,true)
                elseif love.keyboard.isDown(p.ctrl.B) then PlayerUseItem(ip,2,true) end
            end


            if p.isAlive then playerMove(ip) end --toujours après avoir utiliser un item pour les boost de vitesse

            --Caméra
            cameraToPlayer(ip)
            --pick up items
            autoTakeItem(ip)
        end
        updateBullets()
    end
end


function love.keypressed(key)
    if sequance == "menu" then
        if menuSolo then keypressedMenu(key)
        else for ip=1,paramMenus.Nplayers[1] do keypressedMenu(key,ip) end end

    elseif sequance == "en jeu" then
        for ip=1,numPlayers do
            local p=players[ip].ctrl

            playerInventory(ip,key) --le Code des inputs est dans la fonction


            if players[ip].inventaire then
                if love.keyboard.isDown(p.A) and (players[ip].select==1 or players[ip].select==2) then PlayerUseItem(ip,players[ip].select,false) end
            else
                if love.keyboard.isDown(p.A) then PlayerUseItem(ip,1,false)
                elseif love.keyboard.isDown(p.B) then PlayerUseItem(ip,2,false) end
            end


            if key == p.menu then
                sequance = "menu" menu = "principal"
                love.audio.stop()
                local text = "le menu de fin n'est jamais le menu de fin n'est jamais le menu de fin n'est jamais " 
                love.window.setTitle(text..text..text..text..text.." ...")
            end
        end
    end
end







function love.draw()
    love.graphics.clear()
    if sequance == "menu" then
        if menuSolo then DrawMenu()
        else for ip=1,paramMenus.Nplayers[1] do DrawMenu(ip) end end

    elseif sequance == "en jeu" then
        local fs = adaptRatio(numPlayers)

        for ip=1,numPlayers do
            local p = players[ip]
            love.graphics.setCanvas(p.canvas)
            love.graphics.clear()
            love.graphics.setColor(1, 1, 1)
            --//////////////////dessiner ici

            drawMap(p.camX, p.camY, p.scaleScreen)
            love.graphics.circle("fill", 10-p.camX,10-p.camY,5)

            DrawItems(p.camX,p.camY,p.scaleScreen)

            DrawBullets(p.camX,p.camY)
            DrawPlayers(p.camX,p.camY)

            DrawInventory(ip)
            output(ip)

            --////////////affichage canvas
            love.graphics.setColor(1, 1, 1)
            love.graphics.setCanvas()
            --problèmes de performances (moyens)
            local wx, wy = love.graphics.getDimensions()
            local size = (wx/p.scaleScreen[1] ) /fs[1]
            if adaptBest(fs) == 2 then
                size = (wy/p.scaleScreen[2] ) /fs[2]
            end
            --local size = adaptScreen(fs)
            love.graphics.push()
            love.graphics.scale(size, size)
            love.graphics.draw(p.canvas, p.scaleScreen[1]*((ip-1)%fs[1]), p.scaleScreen[2]*flr((ip-1)/fs[1]))
            love.graphics.pop()
        end
        if paramMenus.fps[1] then
            love.graphics.print(frameSec/msec,10,10,0,3,3) --affiche les fps
        end
    end
end





--fonctions en plus
function flr(x)
    return math.floor(x)
end
function abs(x)
    return math.abs(x)
end

function adaptRatio(numP)
    local fractScreenL = {numP,1}
    while fractScreenL[1]>1 and compareScreens(fractScreenL) do
        fractScreenL[1] = fractScreenL[1] -1
        while fractScreenL[1]*fractScreenL[2] < numP do
            fractScreenL[2] = fractScreenL[2] +1
        end
    end
    return fractScreenL
    --return fractScreenL
end
function compareScreens(fractScreenL)
    if fractScreenL[1] <= 1 then
        return false
    end

    local wx,wy = love.graphics.getDimensions()

    local s1 = wx/fractScreenL[1]
    if adaptBest(fractScreenL) == 2 then
        s1 = wy/fractScreenL[2]
    end

    local fs = {fractScreenL[1],fractScreenL[2]}
    fs[1] = fs[1] -1
    if fs[1]*fs[2] < numPlayers then
        fs[2] = fs[2] +1
    end

    local s2 = wx/fs[1]
    if adaptBest(fs) == 2 then
        s2 = wy/fs[2]
    end

    local rep = false
    if s2>s1 then
        rep = true
    end
    return rep
end

function adaptBest(fractScreenL)
    local wx, wy = love.graphics.getDimensions()
    local rep = 1
    if wx/fractScreenL[1]>wy/fractScreenL[2] then
        rep = 2
    end
    return rep
end