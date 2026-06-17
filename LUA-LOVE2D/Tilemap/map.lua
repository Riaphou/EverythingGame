function loadMap()
    pi = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679
    --/////Charger les tilesets
    abys = {}
    abys.t = love.graphics.newImage("Tilemap/abys.png")
    abys.i = {{0,0},{1,0},{1,0},{2,1},{2,1}}

    garden = {}
    garden.t = love.graphics.newImage("Tilemap/garden.png")
    garden.i = {{0,0},{1,0},{1,0},{2,1},{2,1}}

    piec1 = {}
    piec1.t = love.graphics.newImage("Tilemap/piec1.png")
    piec1.i = {{0,0},{0,0},{1,0},{1,0},{2,0},{2,0}}
    --[[
    0: traversable
    1: murs
    2: vides
    /////
    0:variantes
    1:animation
    2:fixe
    ]]

    --//////Paramètres Tilemap
    frame = 0
    scaleScreen = {1000,1000}
    renderDist = 3
    map = {}
    map.roomsW = 12 --taille des rooms en tiles
    map.tilesW = 16 --taille en pixel des tiles
    map.gen = {}

    maps = {}
    spawns = {}
    SI = {}
    spawns[1] = {40.4+2*16*12, 40.5+4*16*12}
    SI[1] = {{{1},{1},{1},{1},{1},
            {6},{6},{6},
            {0},{0},{0},{2},{2},{2},
            {3},{3},{5},{5},
            {4},{7}},
            0,0,4,6}
    maps[1] = {
            {2,1,3,2,4},
            {0,2,0,0,1},
            {4,4,4,0,4},
            {2,1,1,0,2},
            {2,3,1,2,3},
            {2,1,1,3},
            {2,1,3}
        }
    spawns[2] = {40.4+1*16*12, 40.5+1*16*12}
    SI[2] = {{{1},{1},
            {6},
            {0},{0},{2},{2},
            {3},{5},
            {4},},
            0,0,2,2}
    maps[2] = {
        {6,7,8},
        {0,9,10}
        }
    map.gen = maps[paramMenus.map[1]]

    rooms = {
        {   {garden},
            {2,1,0,0,0,0,0,0,0,0,2,2},
            {2,0,0,0,0,0,0,0,0,0,1,1},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {1,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,3,3,3,3,0,0,0,0,0,0},
            {0,0,4,4,4,4,3,0,0,0,0,0},
            {0,0,2,0,0,0,0,0,0,0,0,0},
            {0,0,2,0,0,0,0,0,0,0,0,0},
            {0,0,2,0,0,0,0,0,0,0,0,0},
            {0,0,1,1,1,1,1,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0}
        },
        {   {abys},
            {2,0,0,0,2,2,2,2,2,2,2,2},
            {2,0,0,0,1,1,1,1,1,1,1,1},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {2,0,0,0,0,0,0,1,1,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {1,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,2,2,2,2,0,0,0,0,0},
            {2,0,0,1,1,1,1,0,0,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0}
        },
        {   {abys},
            {2,2,2,2,2,2,0,2,2,2,2,2},
            {2,1,1,1,1,1,0,1,1,1,1,1},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {2,0,0,0,2,0,0,1,2,0,0,0},
            {1,0,0,0,1,0,0,0,1,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {2,0,0,0,2,0,0,0,2,0,0,0},
            {2,0,0,0,1,1,0,0,1,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0}
        },
        {   {piec1}, -- Milan
            {3,2,2,2,2,2,1,2,2,2,3,3},
            {3,0,0,0,1,0,0,1,0,0,2,2},
            {2,0,1,1,1,0,0,0,3,0,0,0},
            {0,0,1,0,0,1,0,1,3,1,0,0},
            {0,1,1,2,2,3,3,3,3,0,0,0},
            {0,0,0,0,1,3,2,2,2,0,0,1},
            {3,0,1,0,0,3,1,0,0,1,0,0},
            {3,0,0,0,0,2,2,3,1,0,0,0},
            {3,1,0,1,1,0,0,3,0,0,0,1},
            {3,1,0,0,1,1,2,2,0,0,0,0},
            {3,0,1,0,0,0,1,0,1,1,0,1},
            {3,1,0,1,0,1,0,1,0,0,1,1}
        },
        {   {abys}, -- vide
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0}
        },
        {   {garden}, --6 map2
            {1,1,1,1,1,2,1,1,1,1,2,2},
            {0,0,0,0,0,2,0,0,0,0,1,1},
            {0,0,0,0,0,2,0,0,0,0,0,0},
            {0,0,0,0,0,1,0,0,0,0,0,0},
            {0,0,0,0,3,3,0,0,0,0,0,0},
            {0,0,0,0,4,4,3,3,0,0,0,0},
            {0,0,0,0,4,4,4,4,3,0,0,0},
            {0,0,0,0,4,4,4,4,4,0,0,0},
            {0,0,0,0,0,4,4,4,4,0,0,0},
            {0,0,0,0,0,0,4,4,4,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0}
        },
        {   {piec1}, --7 map2
            {3,2,2,2,2,2,2,2,2,2,2,2},
            {2,0,0,0,1,0,0,1,0,0,0,0},
            {0,0,1,1,1,0,0,0,0,0,0,0},
            {0,0,1,0,0,1,0,1,0,1,0,0},
            {3,1,1,0,0,0,0,0,0,0,0,0},
            {3,0,0,0,1,0,0,0,0,0,0,1},
            {3,2,2,2,2,2,2,2,3,1,0,0},
            {3,0,0,0,0,0,0,0,3,0,0,0},
            {2,1,0,1,1,0,0,0,3,0,0,1},
            {0,1,0,0,1,1,0,0,3,0,0,0},
            {0,0,1,0,0,0,1,0,3,1,0,1},
            {0,1,0,1,0,1,0,1,3,0,1,1}
        },
        {   {abys}, --8 map2
            {1,1,1,1,2,1,1,1,1,1,1,2},
            {0,0,0,0,2,0,0,0,0,0,0,2},
            {0,0,0,0,2,0,0,0,0,0,0,2},
            {0,0,0,0,2,0,0,0,0,0,0,2},
            {0,0,0,0,1,1,1,1,1,0,0,2},
            {2,0,0,0,0,0,0,0,0,0,0,2},
            {2,0,0,0,0,0,0,0,0,0,0,2},
            {2,2,2,2,2,2,0,0,0,0,0,2},
            {2,1,1,1,1,1,0,0,0,0,0,2},
            {2,0,0,0,0,0,0,0,0,0,0,2},
            {2,0,0,0,0,0,0,0,0,0,0,2},
            {2,0,0,0,0,0,0,0,0,0,0,2}
        },
        {   {piec1}, --9 map2
            {3,2,2,2,2,2,1,2,2,0,3,3},
            {3,0,0,0,1,0,0,1,4,0,2,2},
            {2,0,1,1,1,0,0,0,4,0,0,0},
            {0,0,1,0,0,1,0,1,4,1,0,0},
            {0,1,1,2,2,3,3,3,3,0,0,0},
            {0,0,0,0,1,2,2,2,2,0,0,1},
            {3,0,1,0,0,4,1,0,0,1,0,0},
            {3,0,0,0,0,2,5,3,1,0,0,0},
            {3,1,0,1,1,0,0,3,0,0,0,1},
            {3,1,0,0,1,1,2,2,0,0,0,0},
            {3,0,1,0,0,0,1,0,1,1,0,1},
            {3,1,0,1,0,1,0,1,0,0,1,1}
        },
        {   {garden}, --10 map2
            {2,2,2,0,0,1,1,1,1,1,2,2},
            {2,2,1,0,0,0,0,0,0,0,1,1},
            {1,1,3,3,3,0,0,0,0,0,0,0},
            {0,0,0,4,4,3,0,0,0,0,0,0},
            {0,0,0,0,4,4,0,0,0,0,0,0},
            {2,0,0,0,4,4,3,3,0,0,0,0},
            {2,0,0,0,4,4,4,4,3,0,0,0},
            {2,0,0,0,4,4,4,4,4,0,0,0},
            {2,0,0,0,0,4,4,4,4,0,0,0},
            {2,0,0,0,0,0,4,4,4,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0},
            {2,0,0,0,0,0,0,0,0,0,0,0}
        }
    }

    --à rendre adaptable plus tard
    map.quads = {}
    for i = 0,9 do
        map.quads[i] = {}
        for i2 = 0,2 do
            map.quads[i][i2] = love.graphics.newQuad(map.tilesW*i,i2*map.tilesW,  map.tilesW,map.tilesW,  map.tilesW*10,map.tilesW*3)
        end
    end
end


--/////////Tile Map functions

local function flr(x)
    return math.floor(x)
end

function drawMap(x,y)
    x,y = flr(x),flr(y)
    local myRoomY = findPosRoom(y+scaleScreen[2]/2)
    local myRoomX = findPosRoom(x+scaleScreen[1]/2,"x")
    for ry=myRoomY-renderDist,myRoomY+renderDist do
        if map.gen[ry] ~= nil then --and ry>=1
            for rx=myRoomX-renderDist,myRoomX+renderDist do
                if map.gen[ry][rx] ~= nil and map.gen[ry][rx] ~= 0 then drawRoom(map.gen[ry][rx],(rx-1)*map.roomsW,(ry-1)*map.roomsW,x,y) end
            end
        end
    end
end

function findPosRoom(pos,x)
    x = x or "y"
    if x=="y" then return flr(flr(pos/map.tilesW)/map.roomsW) +1
    elseif x=="x" then return flr(flr(pos/map.tilesW)/map.roomsW) +1 end
end

function findRoom(x,y)
    if map.gen[findPosRoom(y,"y")]==nil then return false end
    if map.gen[findPosRoom(y,"y")][findPosRoom(x,"x")]==nil or map.gen[findPosRoom(y,"y")][findPosRoom(x,"x")]==0 then return false end
    return map.gen[findPosRoom(y,"y")][findPosRoom(x,"x")]
end

function infoTuile(num,x,y) --x et y local de la room
    return rooms[num][1][1].i [rooms[num][y+2][x+1]+1]
end

function isOnWall(x,y,voidAllowed) --x et y
    if voidAllowed == nil then voidAllowed = false end
    local i=findRoom(x,y)
    if i==false then return true end
    local rep = infoTuile(i, flr(x/map.tilesW)%map.roomsW,flr(y/map.tilesW)%map.roomsW)[1]
    if voidAllowed then
        return not (rep == 0 or rep == 2)
    else
        return rep ~= 0
    end
end

function drawRoom(num,xMap,yMap,xCam,yCam) -- num salle / Salle dans la table / où dessiner (Haut gauche de l'écran)
    for y=2,map.roomsW+1 do

        for x=1,map.roomsW do
            local test = 0
            local quad
            if infoTuile(num,x-1,y-2)[2] == 0 then
                test = ( ((yMap+y-1)%100)*10*pi * ((xMap+x)*0.3) ) %20 --RARETé DES VARIANTES DE TUILES
                if flr(test)==7 then test=2
                elseif flr(test)==2 then test=1
                else test=0 end
                quad = map.quads[rooms[num][y][x]][test]
            elseif infoTuile(num,x-1,y-2)[2] == 1 then
                test = flr(frame/30)%3                                --VITESSE D'ANIMATION
                quad = map.quads[rooms[num][y][x]][test]
            else
                quad = map.quads[rooms[num][y][x]][0]
            end
            love.graphics.draw(rooms[num][1][1].t,quad,xMap*map.tilesW +(x-1)*map.tilesW -xCam,yMap*map.tilesW +(y-2)*map.tilesW -yCam)
        end
    end
end
--//////////////End tile map
