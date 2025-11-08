-- Simple FakePitch by Shaw <3

local luaB = gui.ctx:find('lua>elements b')
local fakepitch_cb = gui.checkbox(gui.control_id('FakePitch'))
local row_fp = gui.make_control('FakePitch', fakepitch_cb)
luaB:add(row_fp)
luaB:reset()

local function fakepitch_main()
    local pitch = gui.ctx:find('rage>anti-aim>angles>pitch>settings>value')
    if pitch then
       pitch:get_value():set(-3402823346297399750336966557696) 
    end
end

events.present_queue:add(fakepitch_main)
