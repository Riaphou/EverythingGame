--[[
optimiser en supprimant les vides 
]]

function loadBullets()
    skinBullets = {
        love.graphics.newImage("Bullets/Projectile.png"),
        love.graphics.newImage("Bullets/mine.png"),
        love.graphics.newImage("Bullets/zone feu.png")
    }
    explosion = love.audio.newSource("Bullets/explosion.mp3","static")

    bulletsList = {"vide"}
end

function spawnBullet(immune,numSkin,x,y,dx,dy,bx,by,dmg,variante)
    local bulletToAdd = {}
    if variante == nil then bulletToAdd.type = "bullet" else bulletToAdd.type = variante end
    bulletToAdd.skin = skinBullets[numSkin]
    bulletToAdd.x,bulletToAdd.y = x,y
    bulletToAdd.dx,bulletToAdd.dy = dx,dy
    bulletToAdd.bx,bulletToAdd.by = bx,by
    bulletToAdd.damages = dmg
    bulletToAdd.immune = immune
    --Quand une nouvelle entitée spawn elle fait du nettoyage des "vides"
    local i = 1
    while i <= #bulletsList do
        if bulletsList[i] == "vide" then
            for i2 = i,#bulletsList-1 do
                bulletsList[i2]=bulletsList[i2+1]
            end
            bulletsList[#bulletsList] = nil
        else
            i=i+1
        end
    end
    bulletsList[#bulletsList+1] = bulletToAdd
end

--UPDATE
function updateBullets()
    for ipB=1,#bulletsList do
        if bulletsList[ipB] ~= "vide" then
            local b = bulletsList[ipB]
            bulletsList[ipB].x,bulletsList[ipB].y = b.x+b.dx*delta,b.y+b.dy*delta
            b = bulletsList[ipB]
            --TOUJOURS
            if b.type == "bullet" then
                if isOnWall(b.x,b.y, true) then bulletsList[ipB] = "vide" end
            elseif b.type == "mine" then
                if b.immune[1]>0 then bulletsList[ipB].immune[1] = b.immune[1]-1/60 end
            elseif b.type == "molotov" then
                bulletsList[ipB].immune = b.immune-1/60
                if bulletsList[ipB].immune <= 0 then bulletsList[ipB] = "vide" end
            end
            --QUAND TOUCHE 1 Joueur
            BulletCollPlayers(ipB)
            
            
            
        end
    end
    if #bulletsList>4 then
        for ip=#bulletsList,2,-1 do
            if bulletsList[ip] == "vide" then bulletsList[ip] = nil else break end
        end
    end
end


function BulletCollPlayers(ipB,ipP)
    if bulletsList[ipB] ~= "vide" then
        local b = bulletsList[ipB]
        local toDestroy = false
        for ip=1,numPlayers do
            local p = players[ip]
            if colliderect(p.x,p.y,b.x,b.y,p.bx+b.bx,p.by+b.by) then
            
                --Dégats / Effets
                if b.type == "mine" then
                    if b.immune[1]<=0 and players[ip].isAlive then
                        players[ip].default.timeSpeed=players[ip].default.timeSpeed +3
                        players[ip].default.Bspeed=players[ip].default.Bspeed -1
                        toDestroy = true
                    end
                elseif b.type == "molotov" then
                    if players[ip].isAlive then addPV(ip, b.damages) end
                elseif b.type == "bullet" then
                    if b.immune ~= ip and players[ip].isAlive then
                    addPV(ip, b.damages)
                    toDestroy = true
                    end
                end
            end
        end
        if toDestroy then
            if b.type == "mine" then
                bulletsList[ipB].type = "molotov"
                bulletsList[ipB].immune = b.immune[2]
                bulletsList[ipB].skin = skinBullets[3]
                bulletsList[ipB].bx,bulletsList[ipB].by = 24,24
                love.audio.play(explosion)
            else bulletsList[ipB] = "vide" end
        end
    end
end

--DRAW
function DrawBullets(camX,camY)
    for ipB=1,#bulletsList do
        if bulletsList[ipB] ~= "vide" then
            local b = bulletsList[ipB]
            if b.type=="mine" then love.graphics.setColor(1,1,1,b.immune[1]) end
            love.graphics.draw(b.skin,flr(b.x-camX) -b.skin:getWidth()/2, flr(b.y-camY) -b.skin:getHeight()/2)
            love.graphics.setColor(1,1,1)
        end
    end
end