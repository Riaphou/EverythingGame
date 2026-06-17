function love.conf(t)
    t.window.vsync = 0
    t.window.msaa = 0
    t.window.highdpi = false

    t.modules.joystick = false
    t.modules.physics = false
    t.modules.touch = false
    t.modules.video = false
end