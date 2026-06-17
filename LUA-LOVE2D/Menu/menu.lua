--[[
Changer l'initialisation des paramètres des joueurs qui actuellement se trouve dans draw !!!
]]

NbreJoueursMax = 12
--///////////////////functions menu
function loadMenu()
    Tcanv = {128,128}
    menuCanvas = {}
    for i=1,NbreJoueursMax do
        menuCanvas[i] = love.graphics.newCanvas(Tcanv[1],Tcanv[2])
        menuCanvas[i]:setFilter("nearest", "nearest", 1)
    end
    menuSolo = true
    --PARAPèTRES MENU
    paramMenus = {Nplayers={2},map={1},musique={true},classe = {},fps={false}}
    menus = {principal = {},joueurs={},futur = {},classe={},dev={}}
    selection = {}
    sequance = "menu"
    menu = "principal"
end



function keypressedMenu(key, ip)
    if ip==nil then ip=1 end
    if selection[ip]==nil then selection[ip]=0 end
    if key == players[ip].ctrl.B or key == players[ip].ctrl.menu then
        menuSolo=true
        menu = "principal"
        sequance = "menu"
        menu = "principal"
        selection[1]=1
    end

    if key == players[ip].ctrl.b then selection[ip]=selection[ip]+1 if selection[ip]>8 then selection[ip]=8 end end
    if key == players[ip].ctrl.h then selection[ip]=selection[ip]-1 if selection[ip]<1 then selection[ip]=1 end end

    if menus[menu][selection[ip]]~=nil then -- si il y a un paramètre
        local o = menus[menu][selection[ip]]
        if key == players[ip].ctrl.A then
            if o[1] == "menu" then
                sequance = o[4]
                menu = o[3]
                selection[ip]=1
                if menu == "classe" or menu == "..." then
                    menuSolo=false
                    fractScreen = {1,1}
                    local Num = paramMenus.Nplayers[1]
                    if Num > 9 then fractScreen = {4,3} elseif Num > 4 then fractScreen = {3,3} elseif Num > 1 then fractScreen = {2,2} end
                else menuSolo=true selection[1]=1 end
            end
            if o[1] == "func" then o[3]() end
            if o[1] == "activer" then paramMenus[o[3]][ip] = not paramMenus[o[3]][ip] end
        end
        if o[1] == "value" then
            if key == players[ip].ctrl.d then paramMenus[o[3]][ip] = paramMenus[o[3]][ip]+1 if paramMenus[o[3]][ip]>o[5] then paramMenus[o[3]][ip]=o[5] end end
            if key == players[ip].ctrl.g then paramMenus[o[3]][ip] = paramMenus[o[3]][ip]-1 if paramMenus[o[3]][ip]<o[4] then paramMenus[o[3]][ip]=o[4] end end
        end
        if o[1] == "list" then
            if key == players[ip].ctrl.d then paramMenus[o[3]][ip] = paramMenus[o[3]][ip]+1 if paramMenus[o[3]][ip]>#o[2] then paramMenus[o[3]][ip]=#o[2] end end
            if key == players[ip].ctrl.g then paramMenus[o[3]][ip] = paramMenus[o[3]][ip]-1 if paramMenus[o[3]][ip]<1 then paramMenus[o[3]][ip]=1 end end
        end
    end
end


function DrawMenu(ip)
    if ip==nil then ip=1 end
    love.graphics.setCanvas(menuCanvas[ip])
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    --//////////////////dessiner ici
    local x = 10
    local y = 3
    local taille = 1
    local fs = adaptRatio(paramMenus.Nplayers[1])
    for i in ipairs(menus[menu]) do
        if selection[ip] == i then taille = 1.2 love.graphics.setColor(1,1,0) else taille=1 love.graphics.setColor(1,1,1) end
        local o = menus[menu][i]
        local s = o[1]
        if s == "affichage" then love.graphics.print(o[2],x,y,0,1) y=y+15*o[3]
        elseif s == "value" then
            if paramMenus[o[3]][ip]==nil then paramMenus[o[3]][ip]=1 end --INITIALISE PARAMètre
            love.graphics.print(paramMenus[o[3]][ip],x,y,0,taille)
            love.graphics.print(o[2],x+20,y,0,taille)
        elseif s == "list" then
            if paramMenus[o[3]][ip]==nil then paramMenus[o[3]][ip]=1 end --INITIALISE PARAMètre
            love.graphics.print(">",x,y,0,taille)
            love.graphics.print(o[2][paramMenus[o[3]][ip]],x+20,y,0,taille)
        elseif s == "activer" then
            if paramMenus[o[3]][ip]==nil then paramMenus[o[3]][ip]=false end --INITIALISE PARAMètre
            local active = "X"
            if paramMenus[o[3]][ip] then active = "O" end
            love.graphics.print(active,x,y,0,taille)
            love.graphics.print(o[2],x+20,y,0,taille)
        else love.graphics.print(o[2],x,y,0,taille) end
        y = y+15
    end
    --////////////affichage canvas
    love.graphics.setColor(1,1,1)
    love.graphics.setCanvas()

    

    if menuSolo then
        local wx, wy = love.graphics.getDimensions()
        local size = (wx/p.scaleScreen[1] )
        if adaptBest({1,1}) == 2 then
            size = (wy/p.scaleScreen[2] )
        end

        love.graphics.push()
        love.graphics.scale(size, size)
        love.graphics.draw(menuCanvas[ip], 0, 0)
        love.graphics.pop()
    else
        local wx, wy = love.graphics.getDimensions()
        local size = (wx/p.scaleScreen[1] ) /fs[1]
        if adaptBest(fs) == 2 then
            size = (wy/p.scaleScreen[2] ) /fs[2]
        end

        love.graphics.push()
        love.graphics.scale(size, size)
        love.graphics.draw(menuCanvas[ip], Tcanv[1]*((ip-1)%fs[1]), Tcanv[2]*flr((ip-1)/fs[1]))
        love.graphics.pop()
    end

    
end



function addBouton(onMenu,ajouter)
    menus[onMenu][#menus[onMenu] +1]=ajouter
end
function Baffichage(text,sautLignes) if sautLignes==nil then sautLignes=0 end return {"affichage",text,sautLignes} end
function Bmenu(text,Nmenu,Nsequance) if Nsequance == nil then Nsequance = sequance end return {"menu",text,Nmenu,Nsequance} end
function Bactiver(text,param) return {"activer",text,param} end
function Bfunc(text,func) return {"func",text,func} end
function Bvalue(text,param,max,min)
    if min==nil then min=1 end
    if max==nil then max=2 end
    return {"value",text,param,min,max}
end
function Blist(text,param,choix) return {"list",text,param} end