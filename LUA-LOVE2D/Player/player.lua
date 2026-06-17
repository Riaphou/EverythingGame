--[[
Il faut optimiser tout les quads des items
ajouter des messages systeme à la place de p.cant
]]

--Personalisable :
function PlayerUseItem(ip,selection,allTime)
    local p = players[ip]
    if p.stun < 0 then
        if p.selects[selection]+1 <= #p.i and p.i[p.selects[selection]+1] ~= "vide" then
            if allTime == nil then allTime = false end
            select = p.selects[selection]+1
            obj = p.i[select][1]

            if allTime then --ALL TIME
                if obj == 3 and p.isAlive then
                    players[ip].speed = p.speed-0.5
                    for i=1,numPlayers do
                        if i ~= ip and colliderect(p.x,p.y,players[i].x,players[i].y,p.bx+players[i].bx,p.by+players[i].by) then
                            addPV(i,-1)
                        end
                    end
                end
                if obj == 5 and p.isAlive then
                    players[ip].speed = 0
                    players[ip].cooldown = p.cooldown-1*delta
                    if players[ip].cooldown <= 0 then
                        local speed = 3
                        local down = 0
                        local right = 0
                        if love.keyboard.isDown(p.ctrl.d) then right = right+speed end
                        if love.keyboard.isDown(p.ctrl.g) then right = right-speed end
                        if love.keyboard.isDown(p.ctrl.b) then down = down+speed end
                        if love.keyboard.isDown(p.ctrl.h) then down = down-speed end
                        if not (down==0 and right==0) then spawnBullet(ip,1,p.x,p.y,right,down,4,4,-10) end
                        players[ip].cooldown = 10
                    end
                end

            else -- ONE TIME
                if obj == 0 then players[ip].default.timeSpeed=10  players[ip].default.Bspeed=players[ip].default.Bspeed+1 clearItem(ip,select)
                elseif obj == 1 then addPV(ip,30) clearItem(ip,select)
                elseif obj == 4 then addPV(ip,30) players[ip].isAlive=true clearItem(ip,select)
                elseif obj == 5 then p.cooldown=10
                elseif obj == 6 then spawnBullet({0,10},2,p.x,p.y,0,0,4,4,-45/60,"mine") clearItem(ip,select)
                elseif obj == 10 then
                    --players = backUps[1]["players"]
                    for i = 1,numPlayers do
                        if i~=ip then
                            players[i] = backUps[1]["players"][i]
                        end
                    end
                    itemsGround = backUps[1]["itemsGround"]
                    bulletsList = backUps[1]["bulletsList"]
                    frame = backUps[1]["frame"]
                    local x = findItem(ip,10)
                    if x > 0 then
                        players[ip].i[x] = {11,16*60}
                    else
                        x = findItem(ip,11)
                        if x > 0 then players[ip].i[x] = {11,16*60} end
                    end
                    love.audio.play(soundClock)
                elseif obj == 13 then players[ip] = deepCopy(p.i[select][2]) -- "p" ne remplace pas "players[ip]"
                elseif obj == 20 or obj == 21 then
                    local vx,vy = 0,0
                    if love.keyboard.isDown(players[ip].ctrl.h) then vy = vy-1 end
                    if love.keyboard.isDown(players[ip].ctrl.b) then vy = vy+1 end
                    if love.keyboard.isDown(players[ip].ctrl.g) then vx = vx-1 end
                    if love.keyboard.isDown(players[ip].ctrl.d) then vx = vx+1 end
                    if not (vx==0 and vy==0) then
                        dash(ip,vx,vy,45,15,true)
                        p.i[select][1] = p.i[select][1]+1
                    end
                end
            end
        end
    end
end




function updateDefaultValues(ip)
    p=players[ip]
    players[ip].default.Bspeed=0
    players[ip].default.speed=p.speed
    players[ip].default.scaleScreen=p.scaleScreen
    players[ip].default.timeSpeed = 0
    
end
function applyItemsBuffs(ip) -- BUFFS
    local p = players[ip]
    local pd=p.default

    --réduit le temps de stun
    if p.stun > -1 then p.stun = p.stun -1 end
    
    --players[ip].speed = pd.speed
    if p.classe=="kamikaze" then addPV(ip,2/60) end
    players[ip].scaleScreen = pd.scaleScreen
    players[ip].speed = pd.speed+0.5*pd.Bspeed
    if pd.timeSpeed>0 then
        players[ip].default.timeSpeed = players[ip].default.timeSpeed-1/60
    else
        players[ip].default.Bspeed=0 
    end
    

    for i=1,#players[ip].i do
        --if players[ip].i[i][1] == 0 then players[ip].speed = p.speed+0.25 end
        if p.i[i][1] == 2 then players[ip].scaleScreen = {p.scaleScreen[1]+32*2,p.scaleScreen[2]+32*2} end
        if p.i[i][1] == 7 then addPV(ip,2/60) end -- aussi supr dans addPV()

        if p.i[i][1] == 11 then
            if p.i[i][2] == nil then p.i[i][2] = 0 end
            p.i[i][2] = p.i[i][2]-1
            if p.i[i][2]<0 then p.i[i] = {10} end
        end

        if p.i[i][1] == 13 and p.i[i][2] == nil then p.i[i][2] = deepCopy(p) playerPrint(ip,"You have returned",60) end

        if p.i[i][1] == 21 or p.i[i][1] == 22 then
            if p.i[i][2] == nil then p.i[i][2] = 1 end
            p.i[i][2] = p.i[i][2]-1
            if p.i[i][2]<1 then p.i[i][1] = p.i[i][1]-1 p.i[i][2] = 60*10 end
        end
    end

    a,b = p.canvas:getDimensions()
    if a ~= p.scaleScreen[1] or b ~= p.scaleScreen[2] then
        resizeCanvas(ip)
    end
end







--//////////////// Load
function loadPlayer(Nbre)
    if Nbre==nil then numPlayers=paramMenus.Nplayers[1] else numPlayers=Nbre end
    fractScreen = {numPlayers,1}
    --[[
    fractScreen = {1,1}
    if numPlayers > 9 then fractScreen = {4,3}
    elseif numPlayers > 6 then fractScreen = {3,3}
    elseif numPlayers > 4 then fractScreen = {3,2}
    elseif numPlayers > 3 then fractScreen = {2,2}
    elseif numPlayers > 2 then fractScreen = {3,1}
    elseif numPlayers > 1 then fractScreen = {2,1} end
    ]]

    --players
    local lClasses = {"classique","scout","explorateur","kamikaze","horloger"}
    players = {}
    for i=1,numPlayers do
        local player = {}
        if spawns==nil then
            player.x,player.y = 0,0
        else
            player.x,player.y = spawns[paramMenus.map[1]][1]+20*i,spawns[paramMenus.map[1]][2]
        end
        --classe
        if paramMenus.classe[i]==nil then paramMenus.classe[i]=1 end
        player.classe = lClasses[paramMenus.classe[i]]
        --Hit Box
        player.bx, player.by = 6,3
        --crafts
        if player.classe=="horloger" then
            player.crafts = {
                {{13},0,1,4},
                {{10},0,2},
                {{11,16*1.5*60},12}
            }
        elseif player.classe=="scout" then
            player.crafts = {
                {{0},2}
            }
        else
            player.crafts = {}
        end
        -- Inventaire
        player.colonnesInv = 2
        if player.classe=="scout" then
            player.i = {
            "vide","vide","vide",{22}
            }
            player.colonnesInv = 4
        elseif player.classe=="horloger" then
            player.i = {
            "vide","vide","vide","vide","vide","vide"
            }
        else
            player.i = {
            "vide","vide","vide","vide","vide","vide"
            }
        end
        player.inventaire = false
        player.selects = {0,0,1}
        player.select = 1
        player.canTakeItems = false
        
        --sprite
        player.anim = 0
        player.spr = love.graphics.newImage("Player/player.png")
        --stats player
        player.default = {}
        player.distAffichageEntity = 100
        if player.classe=="explorateur" then player.scaleScreen = {128+16*2,128+16*2} else player.scaleScreen = {128,128} end
        player.camX, player.camY = player.x-player.scaleScreen[1]/2, player.y-player.scaleScreen[2]/2
        if player.classe=="scout" then player.speed = 1.15 else player.speed = 1 end
        if player.classe=="explorateur" then player.pvMax = 75 else player.pvMax = 100 end
        if player.classe=="kamikaze" then player.pv = 100 else player.pv = 50 end
        player.isAlive = true
        player.attirance =  {0,0,0,false} --temps, directionX, Y, voidAllowed
        player.stun = -1
        -- canvas
        player.canvas = love.graphics.newCanvas(player.scaleScreen[1],player.scaleScreen[2])
        player.canvas:setFilter("nearest", "nearest", 1)
        -- contrôles player
        --local ctrl = 1
        --
        local ctrl = {}
        if i==3 then
        ctrl.menu = "escape"
        ctrl.h = ","
        ctrl.b = "n"
        ctrl.g = "b"
        ctrl.d = ";"
        ctrl.A = "v"
        ctrl.B = "x"
        ctrl.X = "c"
        ctrl.Y = "w"
        elseif i==2 then
        ctrl.menu = "escape"
        ctrl.h = "up"
        ctrl.b = "down"
        ctrl.g = "left"
        ctrl.d = "right"
        ctrl.A = "m"
        ctrl.B = "l"
        ctrl.X = "o"
        ctrl.Y = "k"
        elseif i==1 then
        ctrl.menu = "escape"
        ctrl.h = "t"
        ctrl.b = "g"
        ctrl.g = "f"
        ctrl.d = "h"
        ctrl.A = "d"
        ctrl.B = "s"
        ctrl.X = "z"
        ctrl.Y = "q"
        else
        ctrl.menu = "escape"
        ctrl.h = "7"
        ctrl.b = "6"
        ctrl.g = "5"
        ctrl.d = "8"
        ctrl.A = "4"
        ctrl.B = "2"
        ctrl.X = "3"
        ctrl.Y = "1"
        end
        player.ctrl = ctrl
        -- paramètres player
        player.cooldown = 60
        player.print = {}
        player.ecrire = ""

        players[i] = player
        updateDefaultValues(i)
        DegEffect = love.audio.newSource("deg.mp3", "static")
    end

    

    --écran partagé (Canvas)
    love.graphics.setDefaultFilter("nearest","nearest",1)
    canvas = {}
    for i = 1,numPlayers do
        canvas[i] = love.graphics.newCanvas(players[i].scaleScreen[1],players[i].scaleScreen[2])
        canvas[i]:setFilter("nearest", "nearest", 1)
    end
end




function loadItems()
    allItems = love.graphics.newImage("Player/items.png")
    scaleItems = 8 --Taille en pixel des items
    itemsGround = {"vide"}
    itemsQuads = {}
    for i = 0,100 do
        itemsQuads[i] = love.graphics.newQuad(scaleItems*(i%10),scaleItems*flr(i/10),scaleItems,scaleItems,allItems:getWidth(),allItems:getHeight())
    end
    --les sons joués une fois à la fois sont à charger là, les autres direct dans les items
    soundClock = love.audio.newSource("Player/items_sounds/clock-sound.mp3","static")
    soundClock:setVolume(1)
end



--/////////// Update
function playerMove(ip)
    local p = players[ip]
    --mouvement imposé
    if p.attirance[1] > 0 then
        p.x = p.x+p.attirance[2]
        if playerIsOnWall(ip,p.attirance[4]) then p.x = p.x-p.attirance[2] end
        p.y = p.y+p.attirance[3]
        if playerIsOnWall(ip,p.attirance[4]) then p.y = p.y-p.attirance[3] end
        p.attirance[1] = p.attirance[1]-1
    end
    --mouvement choisis
    if p.stun < 0 then
        if not p.inventaire then
            if love.keyboard.isDown(players[ip].ctrl.h) then
                players[ip].y = players[ip].y-players[ip].speed*delta
                if isOnWall(p.x-p.bx,p.y-p.by) or isOnWall(p.x+p.bx,p.y-p.by) then players[ip].y = (flr((p.y-p.by)/map.tilesW)+1)*map.tilesW+0.5+p.by end
            end
            if love.keyboard.isDown(players[ip].ctrl.b) then
                players[ip].y = players[ip].y+players[ip].speed*delta
                if isOnWall(p.x-p.bx,p.y+p.by) or isOnWall(p.x+p.bx,p.y+p.by) then players[ip].y = flr((p.y+p.by)/map.tilesW)*map.tilesW-0.5-p.by end
            end
            if love.keyboard.isDown(players[ip].ctrl.g) then
                players[ip].x = players[ip].x-players[ip].speed*delta
                if isOnWall(p.x-p.bx, p.y-p.by) or isOnWall(p.x-p.bx, p.y+p.by) then players[ip].x = (flr((p.x-p.bx)/map.tilesW)+1)*map.tilesW+0.5+p.bx end
            end
            if love.keyboard.isDown(players[ip].ctrl.d) then
                p.x = p.x+p.speed*delta
                if isOnWall(p.x+p.bx, p.y-p.by) or isOnWall(p.x+p.bx,p.y+p.by) then players[ip].x = flr((p.x+p.bx)/map.tilesW)*map.tilesW-0.5-p.bx end
            end
            --animation marche
            if love.keyboard.isDown(players[ip].ctrl.h,players[ip].ctrl.b,players[ip].ctrl.g,players[ip].ctrl.d) then players[ip].anim = players[ip].anim+0.2*delta else players[ip].anim = 0 end
        end
    end
end
function playerIsOnWall(ip,voidAllowed)
    if voidAllowed == nil then voidAllowed = false end
    p = players[ip]
    return ( isOnWall(p.x-p.bx,p.y-p.by,voidAllowed) or isOnWall(p.x+p.bx,p.y-p.by,voidAllowed) or isOnWall(p.x-p.bx,p.y+p.by,voidAllowed) or isOnWall(p.x+p.bx,p.y+p.by,voidAllowed) )
end
function cameraToPlayer(ip)
    players[ip].camX, players[ip].camY = players[ip].x-players[ip].scaleScreen[1]/2, players[ip].y-players[ip].scaleScreen[2]/2
end
function TakeItem(ip)
    for i = 1,#itemsGround do
        if itemsGround[i] ~= "vide" then
            if colliderect(players[ip].x,players[ip].y,itemsGround[i][2],itemsGround[i][3],players[ip].bx+4,players[ip].by+4) then
                if toInventory(ip,i) == false then players[ip].cant = 30 end
                break
            end
        end
    end
end

function autoTakeItem(ip)
    if players[ip].stun < 0 then
        if players[ip].canTakeItems then
            TakeItem(ip)
        else
            local test = true
            for i = #itemsGround,1,-1 do
                if itemsGround[i] ~= "vide" then
                    if colliderect(players[ip].x,players[ip].y,itemsGround[i][2],itemsGround[i][3],players[ip].bx+4,players[ip].by+4) then
                        test = false
                    end
                end
            end
            if test then players[ip].canTakeItems = true end
        end
    end
end

--//////////// Keypressed
function playerInventory(ip,key)
    local p = players[ip]
    if not p.inventaire then --quand l'inventaire est fermé
        if key == players[ip].ctrl.X then players[ip].inventaire=true p.select=1 end

    elseif p.inventaire then  -- inventaire ouvert
        if key == p.ctrl.Y then if p.select==3 then p.select=1 else p.select=p.select+1 end end
        if key == players[ip].ctrl.X then players[ip].inventaire=false end
        if p.select==1 or p.select==2 then
            if key == players[ip].ctrl.g then p.selects[p.select] = p.selects[p.select]-1 if p.selects[p.select]<0 then p.selects[p.select]=0 end end
            if key == players[ip].ctrl.d then p.selects[p.select] = p.selects[p.select]+1 if p.selects[p.select]>players[ip].colonnesInv*3-1 then p.selects[p.select]=players[ip].colonnesInv*3-1 end end
            if key == players[ip].ctrl.h then p.selects[p.select] = p.selects[p.select]-players[ip].colonnesInv if p.selects[p.select]<0 then p.selects[p.select]=p.selects[p.select]+players[ip].colonnesInv end end
            if key == players[ip].ctrl.b then p.selects[p.select] = p.selects[p.select]+players[ip].colonnesInv if p.selects[p.select]>players[ip].colonnesInv*3-1 then p.selects[p.select]=p.selects[p.select]-players[ip].colonnesInv end end
            if key == players[ip].ctrl.B then dropitem(ip,p.selects[p.select]+1) players[ip].canTakeItems=false end
        elseif p.select==3 then
            if key == players[ip].ctrl.h then p.selects[p.select] = p.selects[p.select]-1 if p.selects[p.select]<1 then p.selects[p.select]=1 end end
            if key == players[ip].ctrl.b then p.selects[p.select] = p.selects[p.select]+1 if p.selects[p.select]>#p.crafts then p.selects[p.select]=#p.crafts end end
            if key == players[ip].ctrl.A then craft(ip) end
        end
    end
end

--/////////////////////////// Draw
function DrawPlayers(camX,camY)
    for ip2=1,numPlayers do
        DrawPlayer(ip2,camX,camY)
    end
end

function DrawPlayer(ip,camX,camY)
    local p = players[ip]
    camX = camX or p.camX
    camY = camY or p.camY
    if math.floor(p.anim)%4==0 then quad = love.graphics.newQuad(0,0,17,15,34,30)
    elseif math.floor(p.anim)%4==1 then quad = love.graphics.newQuad(17,0,17,15,34,30)
    elseif math.floor(p.anim)%4==2 then quad = love.graphics.newQuad(0,15,17,15,34,30)
    else quad = love.graphics.newQuad(17,15,17,15,34,30) end
    love.graphics.draw(p.spr,quad,flr(p.x-7.5 -camX), flr(p.y-10.5 -camY))
    if not p.isAlive then love.graphics.setColor(1,0.5,0.5) end
    love.graphics.rectangle("fill",flr(p.x-3.5 -camX),flr(p.y-13.5 -camY),8,2)
    love.graphics.setColor(0,1,0)
    love.graphics.rectangle("fill",flr(p.x-3.5 -camX),flr(p.y-13.5 -camY),math.ceil(8*(p.pv/p.pvMax)),2)
    love.graphics.setColor(1,1,1)
end
function DrawItems(camX,camY,scaleScreen)
    camX,camY = flr(camX),flr(camY)
    for i = 1,#itemsGround do
        if itemsGround[i] ~= "vide" and camX-(scaleItems/2)<itemsGround[i][2] and itemsGround[i][2]<camX+scaleScreen[1]+(scaleItems/2) and camY-(scaleItems/2)<itemsGround[i][3] and itemsGround[i][3]<camY+scaleScreen[2]+(scaleItems/2) then
            love.graphics.draw(allItems,itemsQuads[itemsGround[i][1][1]],itemsGround[i][2]-(scaleItems/2) -camX,itemsGround[i][3]-(scaleItems/2) -camY)
        end
    end
end

function DrawInventory(ip)
    local p = players[ip]
    if players[ip].inventaire == true then
        love.graphics.setColor(100/255, 100/255, 100/255)
        love.graphics.rectangle("fill", 0,p.scaleScreen[2] -3*(scaleItems+2)-2,p.scaleScreen[1],3*(scaleItems+2)+2) --supr le -1
        love.graphics.setColor(30/255, 100/255, 100/255)
        love.graphics.rectangle("fill", p.scaleScreen[1] -1*(scaleItems+2) -2 ,p.scaleScreen[2] -3*(scaleItems+2)-2,p.scaleScreen[1],3*(scaleItems+2)+2) --supr le -1
        love.graphics.setColor(1,1,1)
        --Crafts
        if #p.crafts>0 then
            local fois = 2
            if #players[ip].crafts==1 then fois = 0 elseif #players[ip].crafts==2 then fois = 1 end
            local startList = 1
            if p.selects[3]==1 then startList = 1
            elseif p.selects[3]==#players[ip].crafts then startList = #players[ip].crafts-fois
            else startList = p.selects[3]-1 end
            local i = 0
            for x = startList,startList+fois do -- dans players[ip].crafts
                
                --affichage item à récupérer
                quad = love.graphics.newQuad(scaleItems*(p.crafts[x][1][1]%10),scaleItems*flr(p.crafts[x][1][1]/10),scaleItems,scaleItems,allItems:getWidth(),allItems:getHeight())
                love.graphics.draw(allItems,quad,p.scaleScreen[1]-1*(scaleItems+2),p.scaleScreen[2] -3*(scaleItems+2) +(scaleItems+2)*i)
                --affichage prix
                local i2 = 0
                for x2 = 2,#p.crafts[x] do
                    quad = love.graphics.newQuad(scaleItems*(p.crafts[x][x2]%10),scaleItems*flr(p.crafts[x][x2]/10),scaleItems,scaleItems,allItems:getWidth(),allItems:getHeight())
                    love.graphics.draw(allItems,quad,p.scaleScreen[1]-2*(scaleItems+2)-6-(scaleItems+2)*i2,p.scaleScreen[2] -3*(scaleItems+2) +(scaleItems+2)*i)
                    i2=i2+1
                end
                i=i+1
            end
            if p.select == 3 then
                iconOffset = 1
                if p.selects[3]==1 then iconOffset = 3 elseif #p.crafts==2 or p.selects[3]~= #p.crafts then iconOffset = 2 end
                love.graphics.setColor(0,0.5,0)
                rect(p.scaleScreen[1] -2 -1*(scaleItems+2),p.scaleScreen[2] -2 -iconOffset*(scaleItems+2),(scaleItems+2),(scaleItems+2))
                love.graphics.setColor(1,1,1)
            end
        end
        --Mes Objets
        for i = 1,#players[ip].i do
            if players[ip].i[i] ~= "vide" then
                quad = love.graphics.newQuad(scaleItems*(players[ip].i[i][1]%10),scaleItems*flr(players[ip].i[i][1]/10),scaleItems,scaleItems,allItems:getWidth(),allItems:getHeight())
                love.graphics.draw(allItems,quad,2+(scaleItems+2)*((i-1)%players[ip].colonnesInv),p.scaleScreen[2] -3*(scaleItems+2) +(scaleItems+2)*flr((i-1)/players[ip].colonnesInv))
            end
        end
        if p.select==1 or p.select==2 then
            if p.select == 1 then love.graphics.setColor(0.5,0,0) elseif p.select == 2 then love.graphics.setColor(0,0,0.5) end
            rect((scaleItems+2)*(p.selects[p.select]%p.colonnesInv),p.scaleScreen[2]-3*(scaleItems+2)-2+(scaleItems+2)*flr(p.selects[p.select]/p.colonnesInv),(scaleItems+2),(scaleItems+2))
            love.graphics.setColor(1,1,1)
        end
    end
end

function playerPrint(ip,text,dure)
    local p = players[ip]
    p.print[#p.print+1] = {text,dure}
end

function output(ip)
    local p = players[ip]
    local i = 1
    while i <= #p.print do
        if p.print[i] == "vide" then
            for i2 = i,#p.print-1 do
                p.print[i2]=p.print[i2+1]
            end
            p.print[#p.print] = nil
        else
            i=i+1
        end
    end
    for i = 1,#p.print do
        love.graphics.print(p.print[i][1],1,10+10*(i-1))
        p.print[i][2] = p.print[i][2] -1
        if p.print[i][2] <1 then
            p.print[i] = "vide"
        end
    end
end





--/////////////////////////Fonctions Player
local function flr(x)
    return math.floor(x)
end
local function abs(x)
    return math.abs(x)
end
function rect(x,y,w,h)
    love.graphics.rectangle("fill",x,y,2,h)
    love.graphics.rectangle("fill",x,y,w,2)
    love.graphics.rectangle("fill",x+w,y,2,h+2)
    love.graphics.rectangle("fill",x,y+h,w,2)
end
function colliderect(x1,y1,x2,y2,dx,dy)
    if abs(x2-x1)<=dx and abs(y2-y1)<=dy then return true else return false end
end
function dupliquerTable(item)           --ATTENTION COPIE PARTIELLE -> bug si table complexe
    local itemCopy = {}
    for k,v in ipairs(item) do
        itemCopy[k] = v
    end
    return itemCopy
end
function toInventory(ip,x)
    local p = players[ip]
    for i = 1,#p.i do
        if p.i[i] == "vide" then
            p.i[i] = deepCopy(itemsGround[x][1])
            itemsGround[x] = "vide"
            return true
        end
    end
    return false
end
function give(ip,x)
    local p = players[ip]
    for i = 1,#p.i do
        if p.i[i] == "vide" then
            p.i[i] = deepCopy(x)
            return true
        end
    end
    return false
end
function dropitem(ip,x)
    local p = players[ip]
    if x<=#p.i and p.i[x] ~= "vide" then
        --à executer avant de drop
        if p.i[x][1] == 6 then spawnBullet({3,10},2,p.x,p.y,0,0,4,4,-45/60,"mine") clearItem(ip,x) return true end
        if p.i[x][1] == 10 then clearItem(ip,x) p.i[x]={12} end
        if p.i[x][1] == 11 then clearItem(ip,x) p.i[x]={12} end
        --Drop l'item
        for i = 1,#itemsGround do
            if itemsGround[i] == "vide" then
                itemsGround[i] = {p.i[x],flr(p.x),flr(p.y)}
                p.i[x] = "vide"
                return true
            end
        end
        itemsGround[#itemsGround+1] = {p.i[x],flr(p.x),flr(p.y)}
        p.i[x] = "vide"
    end
end
function spawnItem(item,x,y)
    for i = 1,#itemsGround do
        if itemsGround[i] == "vide" then
            itemsGround[i] = {item,x,y}
            return true
        end
    end
    itemsGround[#itemsGround+1] = {item,x,y}
end
function clearItem(ip,select)
    players[ip].i[select] = "vide"
end

function hasItem(ip,numItem)
    local count=0
    for i=1,#players[ip].i do
        if players[ip].i[i][1] == numItem then count=count+1 end
    end
    return count
end

function findItem(ip,numItem)
    for i=1,#players[ip].i do
        if players[ip].i[i][1] == numItem then return i end
    end
    return 0
end

function addPV(ip,Value)
    local Item7 = (hasItem(ip,7)>0 or players[ip].classe=="kamikaze")-- ITEM 7
    if Item7 then Value = -Value end -- ITEM 7 inversement
    players[ip].pv = players[ip].pv +Value
    if players[ip].pv > players[ip].pvMax then players[ip].pv = players[ip].pvMax end
    if players[ip].pv <= 0 then players[ip].pv=0 players[ip].isAlive = false end
    if Value<0 and not Item7 then love.audio.play(DegEffect) end -- ITEM 7 sans bruit
end
function resizeCanvas(ip)
    players[ip].canvas = love.graphics.newCanvas(players[ip].scaleScreen[1],players[ip].scaleScreen[2])
    players[ip].canvas:setFilter("nearest", "nearest", 1)
end
function randomSpawnItems(list,ox,oy,sx,sy)
    --ox,oy,sx,sy = ox+1,oy+1,sx+1,sy+1
    for i=1,#list do
        repeat
            --dans quelle salle ça spawn
            local roomY = (randInt(1+sy-oy)+oy)*map.tilesW*map.roomsW
            randomize()
            local roomX = (randInt(1+sx-ox)+ox)*map.tilesW*map.roomsW
            --à quel endroit de la salle
            local tileY = randInt(map.roomsW)*map.tilesW
            randomize()
            local tileX = randInt(map.roomsW)*map.tilesW
            randomize()
            --centrer sur une tuile
            y = map.tilesW/2  + roomY + tileY
            x = map.tilesW/2  + roomX + tileX
        until not isOnWall(x,y)
        spawnItem(list[i],x,y)
    end
end

function craft(ip)
    local p = players[ip]
    if p.crafts[p.selects[3]] ~= nil then
        local craftV = deepCopy(p.crafts[p.selects[3]])

        local countIngredient = #craftV-1
        for i = 1,#p.i do
            if p.i[i] ~= "vide" then
                for i2 = 2,#craftV do
                    if craftV[i2] == p.i[i][1] then craftV[1][1]=-1 countIngredient=countIngredient-1 break end
                end
                if countIngredient<1 then break end
            end
        end
        craftV = deepCopy(p.crafts[p.selects[3]])
        if countIngredient<1 then
            for i2 = 2,#craftV do
            clearItem(ip,findItem(ip,craftV[i2]))
            end
            if craftV[1][1] == 13 then give(ip,{13,deepCopy(p)})
            else give(ip,deepCopy(craftV[1])) end
        end
    end
end

function dash(ip,dx,dy,dist,temps,voidAllowed)
    if voidAllowed == nil then voidAllowed = false end
    p = players[ip]
    local i = 0
    local px = p.x
    local py = p.y  
    local distL = dist
    local doubleCount = 0
    --avancer jusqu'a toucher un obstacle
    while distL>0 and doubleCount < 2 do
        doubleCount = 0
        p.x = p.x +dx
        if playerIsOnWall(ip,voidAllowed) or dx==0 then if dx~=0 then p.x = p.x -dx end doubleCount = doubleCount+1 end
        p.y = p.y +dy
        if playerIsOnWall(ip,voidAllowed) or dy==0 then if dy~=0 then p.y = p.y -dy end doubleCount = doubleCount+1 end
        distL = distL -1
        i = i+1
    end
    --reculer pour sortir du mur puis du vide
    while playerIsOnWall(ip) and i>0 do
        p.x = p.x -dx
        p.y = p.y -dy
        i = i-1
    end
    p.x = px
    p.y = py
    if not (dist == 0 or temps == 0) and i > 0 then
        temps = math.max(1, math.floor(temps * (i / dist) + 0.5))--temps*(i/dist)
        p.attirance =  {temps,i*dx/temps,i*dy/temps,true}
        p.stun = temps
    end
end