
--RANDOM
random = -1
aNum = "31415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
numLen = 100
function randInt(x)
    randomize()
    local letters = 1+random%numLen
    return tonumber( string.sub(aNum,letters,letters+1) ) %x
    --return ( flr((10^flr(random))*aNum) -(flr(10^(flr(random)-2) *aNum)*10^2) )%x
end


function randomize(x)
    if x==nil then x=1 end
    for i=1,x do
        random=random+1
        if random>99 then random=0 end
    end
end

--DEEP COPY

tab = {
    {
        {1,2},{3,4,5}
    },
    {
        6
    },
    {
        {},7,{8,{9,"10"}}
    },
    11
}

function deepCopy(tab)
    local tabCopy = {}
    for k,v in pairs(tab) do
        if type(v)=="table" then
            tabCopy[k] = deepCopy(v)
        else
            tabCopy[k] = v
        end
    end
    return tabCopy
end



function printTable(tab)
    local tabCopy = ""
    for k,v in pairs(tab) do
        if type(v)=="table" then
            tabCopy = tabCopy..printTable(v)
        else
            tabCopy = tabCopy..v
        end
    end
    return tabCopy
end


--CONTRÔLEURS
function input(id,bouton)
    if button == "menu" then return love.joystick.isDown(id, 8) end


    if button == "A" then return love.joystick.isDown(id, "a") end
    if button == "B" then return love.joystick.isDown(id, "b") end
    if button == "X" then return love.joystick.isDown(id, "x") end
    if button == "Y" then return love.joystick.isDown(id, "y") end

    if button == "h" then return love.joystick.isDown(id, "dpup") end
    if button == "b" then return love.joystick.isDown(id, "dpdown") end
    if button == "g" then return love.joystick.isDown(id, "dpleft") end
    if button == "d" then return love.joystick.isDown(id, "dpright") end

    if button == "h" then return 0.5<love.joystick.getGamepadAxis(id, "lefty") end
    if button == "b" then return -0.5>love.joystick.getGamepadAxis(id, "lefty") end
    if button == "g" then return -0.5>love.joystick.getGamepadAxis(id, "leftx") end
    if button == "d" then return 0.5<love.joystick.getGamepadAxis(id, "leftx") end
    return false
end
