-- ===============================================
-- Aim Assist and Triggerbot Delay
-- Disables ALL Aim Assist and Triggerbots when shot (Deagle, AWP, Scout)
-- Cooldown: 1 second
-- ===============================================

local weapon_names = {
    [1]="deagle",[3]="fiveseven",[4]="glock",[7]="ak47",[8]="aug",[9]="awp",[10]="famas",[11]="g3sg1",
    [13]="galilar",[16]="m4a1",[17]="mac10",[19]="p90",[23]="mp5sd",[24]="ump45",[32]="hkp2000",
    [33]="mp7",[34]="mp9",[36]="p250",[38]="scar20",[39]="sg556",[40]="ssg08",[60]="m4a1_silencer",
    [61]="usp_silencer",[63]="cz75a",[64]="revolver"
}
local weapon_menu_names = {
    ["deagle"] = "Desert Eagle", ["revolver"] = "R8 Revolver", ["usp_silencer"] = "USP-S",
    ["hkp2000"] = "P2000", ["glock"] = "Glock-18", ["p250"] = "P250",
    ["cz75a"] = "CZ75-Auto", ["fiveseven"] = "Five-SeveN", ["ak47"] = "AK-47",
    ["m4a1_silencer"] = "M4A1-S", ["m4a1"] = "M4A4", ["famas"] = "FAMAS",
    ["galilar"] = "Galil AR", ["ssg08"] = "SSG-08", ["awp"] = "AWP",
    ["scar20"] = "SCAR-20", ["g3sg1"] = "G3SG1", ["mp9"] = "MP9",
    ["mac10"] = "MAC-10", ["ump45"] = "UMP-45", ["mp7"] = "MP7",
    ["mp5sd"] = "MP5-SD", ["p90"] = "P90", ["aug"] = "AUG", ["sg556"] = "SG 553"
}

-- Only Weapons (IDs: Deagle, AWP, Scout)
local allowed_weapons = {
    [1] = true,    -- Desert Eagle
    [9] = true,    -- AWP
    [40] = true    -- SSG-08 (Scout)
}

--  Cooldown
local COOLDOWN_TIME = 1.0
local get_time = function() return game.global_vars.cur_time end

-- ===============================================
-- GUI & Controles
-- ===============================================
local gui_group = gui.ctx:find("lua>elements b")
if not gui_group then
    print("Error: No se encontró el grupo 'lua>elements a' para añadir los checkboxes.")
    return
end

local aim_delay_checkbox = gui.checkbox(gui.control_id("aim_assist_delay_enable"))
aim_delay_checkbox:set_value(true)
gui_group:add(gui.make_control("Disable Aimbot on Shot", aim_delay_checkbox))
local trigger_delay_checkbox = gui.checkbox(gui.control_id("triggerbot_delay_enable"))
trigger_delay_checkbox:set_value(true) 
gui_group:add(gui.make_control("Disable Triggerbot on Shot", trigger_delay_checkbox))

-- ===============================================
-- Aim Assist Logic
-- ===============================================

local aim_state = {
    is_disabled = false,
    disable_time = 0,
    controls_cache = {}
}

local function load_aim_controls()
    if #aim_state.controls_cache > 0 then return aim_state.controls_cache end
    
    local controls = {}
    local general = gui.ctx:find("legit>weapon>general>aim>aim assist")
    if general then table.insert(controls, general) end
    
    for weapon_id, weapon_key in pairs(weapon_names) do
        local menu_name = weapon_menu_names[weapon_key]
        if menu_name then
            local path = "legit>weapon>" .. menu_name .. ">aim>aim assist"
            local ctrl = gui.ctx:find(path)
            if ctrl then table.insert(controls, ctrl) end
        end
    end
    
    aim_state.controls_cache = controls
    return controls
end

local function disable_all_aim()
    local controls = aim_state.controls_cache
    for i = 1, #controls do
        local ctrl = controls[i]
        if ctrl then ctrl:get_value():set(false) end
    end
end

local function enable_all_aim()
    local controls = aim_state.controls_cache
    for i = 1, #controls do
        local ctrl = controls[i]
        if ctrl then ctrl:get_value():set(true) end
    end
end

load_aim_controls()

-- ===============================================
-- Triggerbot Logic
-- ===============================================

local trigger_state = {
    is_disabled = false,
    disable_time = 0,
    controls_cache = {}
}

local function load_trigger_controls()
    if #trigger_state.controls_cache > 0 then return trigger_state.controls_cache end
    
    local controls = {}
    local general = gui.ctx:find("legit>weapon>general>trigger>triggerbot")
    if general then table.insert(controls, general) end

    for weapon_id, weapon_key in pairs(weapon_names) do
        local menu_name = weapon_menu_names[weapon_key]
        if menu_name then
            local path = "legit>weapon>" .. menu_name .. ">trigger>triggerbot"
            local ctrl = gui.ctx:find(path)
            if ctrl then table.insert(controls, ctrl) end
        end
    end
    
    trigger_state.controls_cache = controls
    return controls
end

local function disable_all_trigger()
    local controls = trigger_state.controls_cache
    for i = 1, #controls do
        local ctrl = controls[i]
        if ctrl then ctrl:get_value():set(false) end
    end
end

local function enable_all_trigger()
    local controls = trigger_state.controls_cache
    for i = 1, #controls do
        local ctrl = controls[i]
        if ctrl then ctrl:get_value():set(true) end
    end
end


load_trigger_controls()

local function on_game_event(event)
    if event:get_name() ~= 'weapon_fire' or not game.engine:in_game() then return end
    
    local shooter = event:get_pawn_from_id("userid")
    local local_player = entities.get_local_pawn()
    
    if not shooter or not local_player or shooter ~= local_player then return end
    
    local weapon = local_player:get_active_weapon()
    if not weapon or not weapon:is_gun() then return end
    
    local weapon_id = weapon:get_id()
    
    if not allowed_weapons[weapon_id] then return end
    
    local current_time = get_time()

    -- AIM ASSIST LOGIC
    if aim_delay_checkbox:get_value():get() then
        disable_all_aim()
        aim_state.is_disabled = true
        aim_state.disable_time = current_time
    end

    -- TRIGGERBOT LOGIC
    if trigger_delay_checkbox:get_value():get() then
        disable_all_trigger()
        trigger_state.is_disabled = true
        trigger_state.disable_time = current_time
    end
end

events.event:add(on_game_event)

local function on_present_queue()
    if not game.engine:in_game() then return end
    
    local lp = entities.get_local_pawn()
    if not lp then return end
    
    local weapon = lp:get_active_weapon()
    if not weapon or not weapon:is_gun() then return end
    
    local current_weapon_id = weapon:get_id()
    local current_time = get_time()

    if aim_state.last_weapon_id ~= nil and aim_state.last_weapon_id ~= current_weapon_id then
        if aim_state.is_disabled then
            enable_all_aim()
            aim_state.is_disabled = false
        end
    end
    
    if aim_state.is_disabled then
        local time_elapsed = current_time - aim_state.disable_time
        if time_elapsed >= COOLDOWN_TIME then
            enable_all_aim()
            aim_state.is_disabled = false
        end
    end

    if trigger_state.last_weapon_id ~= nil and trigger_state.last_weapon_id ~= current_weapon_id then
        if trigger_state.is_disabled then
            enable_all_trigger()
            trigger_state.is_disabled = false
        end
    end
    
    if trigger_state.is_disabled then
        local time_elapsed = current_time - trigger_state.disable_time
        if time_elapsed >= COOLDOWN_TIME then
            enable_all_trigger()
            trigger_state.is_disabled = false
        end
    end
    

    aim_state.last_weapon_id = current_weapon_id
    trigger_state.last_weapon_id = current_weapon_id
end

events.present_queue:add(on_present_queue)

