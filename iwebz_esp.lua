local surface = require("gamesense/surface")
local csgo_weapons = require("gamesense/csgo_weapons")
local font = surface.create_font("Visitor TT2 (BRK)", 11, 400, 0x200)

local menu = {
    toggle = ui.new_checkbox("lua", "a", "esp_toggle"),
    healthbar = ui.new_checkbox("lua", "a", "esp_health_bar"),
    boxstyle = ui.new_combobox("lua", "a", "esp_box", {"None", "Bounding", "Bounding Corner"}),
    name = ui.new_checkbox("lua", "a", "esp_name"),
    weapon = ui.new_checkbox("lua", "a", "esp_weapon"),
    xhair = ui.new_checkbox("lua", "a", "esp_xhair"),
    override_chams = ui.new_checkbox("lua", "a", "override_chams")
}

local function get_local_player()
    local localPlayer = entity.get_local_player()
    if entity.is_alive(localPlayer) then
        return localPlayer
    else
        local observerTarget = entity.get_prop(localPlayer, "m_hObserverTarget")
        return observerTarget ~= nil and observerTarget <= 64 and observerTarget or nil
    end
end

local function get_players()
    local results = {}
    local localPlayerOrigin = {entity.get_origin(get_local_player())}
    for i=1, 64 do
        if entity.is_alive(i) and entity.is_enemy(i) then
            local origin = {entity.get_origin(i)}
            if origin[1] ~= nil and localPlayerOrigin[1] ~= nil then
                table.insert(results, {i})
            end
        end
    end
    return results
end

local function get_player_weapon(player)
    local weapon_ent = entity.get_player_weapon(player)
    if weapon_ent == nil then return end
    local weapon_idx = entity.get_prop(weapon_ent, "m_iItemDefinitionIndex")
    if weapon_idx == nil then return end
    local weapon = csgo_weapons[weapon_idx]
    if weapon == nil then return end
    local width, height = surface.get_text_size(font, string.format("%s - %s", weapon.name, weapon.primary_clip_size))
    return {weapon.name, width, height, weapon.primary_clip_size}
end

local visible_team_colors = {
    [0] = {255,255,255,255},
    [1] = {255,255,255,255},
    [2] = {255, 255, 0, 255},
    [3] = {34, 255, 0, 255}
}

local non_visible_team_colors = {
    [0] = {255,255,255,255},
    [1] = {255,255,255,255},
    [2] = {255, 25, 25, 255},
    [3] = {0, 136, 255, 255}
}

local function get_team_color(player)
    local m_iTeamNum = entity.get_prop(player, "m_iTeamNum")
    local hitbox_position = {entity.hitbox_position(player, 0)}
    local eye_pos = {client.camera_position()}
    local fraction, v_hit = client.trace_line(entity.get_local_player(), eye_pos[1], eye_pos[2], eye_pos[3], hitbox_position[1], hitbox_position[2], hitbox_position[3])
    return (v_hit == player or fraction == 1) and visible_team_colors[m_iTeamNum] or non_visible_team_colors[m_iTeamNum]
end

local function get_chams_team_color(player)
    local m_iTeamNum = entity.get_prop(player, "m_iTeamNum")
    return {non_visible_team_colors[m_iTeamNum], visible_team_colors[m_iTeamNum]}
end

local function draw_xhair()
    local screen_size = {client.screen_size()}
    renderer.rectangle(screen_size[1]/2-1, screen_size[2]/2+9, 3, 12, 0, 0, 0, 255)
    renderer.rectangle(screen_size[1]/2+9, screen_size[2]/2-1, 12, 3, 0, 0, 0, 255)
    renderer.rectangle(screen_size[1]/2-21, screen_size[2]/2-1, 12, 3, 0, 0, 0, 255)
    renderer.rectangle(screen_size[1]/2-2, screen_size[2]/2-21, 3, 12, 0, 0, 0, 255)
    renderer.rectangle(screen_size[1]/2-1, screen_size[2]/2-1, 3, 3, 0, 0, 0, 255)
    renderer.rectangle(screen_size[1]/2, screen_size[2]/2, 1, 1, 255, 0, 0, 255)
    renderer.rectangle(screen_size[1]/2, screen_size[2]/2+10, 1, 10, 255, 255, 255, 255)
    renderer.rectangle(screen_size[1]/2-1, screen_size[2]/2-20, 1, 10, 255, 255, 255, 255)
    renderer.rectangle(screen_size[1]/2+10, screen_size[2]/2, 10, 1, 255, 255, 255, 255)
    renderer.rectangle(screen_size[1]/2-20, screen_size[2]/2, 10, 1, 255, 255, 255, 255)
end

local function draw_esp()
    client.exec(string.format("crosshair %i", ui.get(menu.xhair) and 0 or 1))
    if ui.get(menu.xhair) then
        draw_xhair()
    end

    local enemies = get_players()
    for i=1, #enemies do
        local player = unpack(enemies[i])
        if player ~= get_local_player() then
            local bbox = {entity.get_bounding_box(player)}
            if bbox[1] ~= nil or bbox[2] ~= nil or bbox[3] ~= nil or bbox[4] ~= nil or bbox[5] ~= 0 then
                local height, width = bbox[4]-bbox[2], bbox[3]-bbox[1]
                local color = entity.is_dormant(player) and {100, 100, 100, 255} or get_team_color(player)
                local name = entity.get_player_name(player)
                if ui.get(menu.healthbar) then
                    local health = entity.get_prop(player, "m_iHealth")
                    local health_width = (width*health/100)+2
                    for i = 1, 5 do
                        renderer.rectangle(bbox[1]-i, bbox[4]+i+5, width, 1, 0, 0, 0, 255)
                        renderer.rectangle(bbox[1]-i, bbox[4]+i+5, health_width, 1, color[1], color[2], color[3], color[4])
                        renderer.rectangle(bbox[1]-4, bbox[4]+8, health_width, 1, color[1]/1.5, color[2]/1.5, color[3]/1.5, color[4])
                        renderer.rectangle(bbox[1]-5, bbox[4]+9, health_width, 1, color[1]/1.5, color[2]/1.5, color[3]/1.5, color[4])

                        
                    end
                    local color = entity.is_dormant(player) and {100, 100, 100, 125} or {255, 255, 255, 255}
                    renderer.rectangle(bbox[1], bbox[4]+5, width+1, 1, color[1], color[2], color[3], 255)
                    renderer.rectangle((bbox[1]+1)-5, bbox[4]+10, width, 1, color[1], color[2], color[3], 255)
                    renderer.line((bbox[1]+1)-6, bbox[4]+11, bbox[1], bbox[4]+5, color[1], color[2], color[3], 255)
                    renderer.line(bbox[1]+width-4, bbox[4]+11, bbox[1]+width+2, bbox[4]+5, color[1], color[2], color[3], 255)
                end

                if ui.get(menu.boxstyle) == "Bounding" then
                    surface.draw_outlined_rect(bbox[1], bbox[2], width, height, color[1], color[2], color[3], 255)
                    surface.draw_outlined_rect(bbox[1]-1, bbox[2]-1, width+2, height+2, 0,0,0,255)
                elseif ui.get(menu.boxstyle) == "Bounding Corner" then
                    -- toplo
                    renderer.rectangle(bbox[1]-1, bbox[2]-1, 1, height/6+1, 0,0,0,255)
                    renderer.rectangle(bbox[1]-1, bbox[2]-1, width/6+2, 1, 0,0,0,255)

                    -- topro
                    
                    renderer.rectangle(bbox[3], bbox[2], 1, height/6, 0,0,0,255)
                    renderer.rectangle(bbox[3]+1, bbox[2]-1, -width/6-2, 1, 0,0,0,255)

                    --bottomro
                    
                    renderer.rectangle(bbox[3], bbox[4], 1, -height/6, 0,0,0,255)
                    renderer.rectangle(bbox[3]+1, bbox[4], -width/6-2, 1, 0,0,0,255)

                    --bottomlo
                    renderer.rectangle(bbox[1]-1, bbox[4], 1, -height/6, 0,0,0,255)
                    renderer.rectangle(bbox[1]-1, bbox[4], width/6+1, 1, 0,0,0,255)
                    
                    -- topl
                    renderer.rectangle(bbox[1], bbox[2], 1, height/6, color[1], color[2], color[3], 255)
                    renderer.rectangle(bbox[1], bbox[2], width/6+1, 1, color[1], color[2], color[3], 255)

                    -- topr

                    renderer.rectangle(bbox[3]-1, bbox[2], 1, height/6, color[1], color[2], color[3], 255)
                    renderer.rectangle(bbox[3], bbox[2], -width/6-1, 1, color[1], color[2], color[3], 255)

                    --bottomr
                    renderer.rectangle(bbox[3]-1, bbox[4], 1, -height/6, color[1], color[2], color[3], 255)
                    renderer.rectangle(bbox[3], bbox[4]-1, -width/6-1, 1, color[1], color[2], color[3], 255)

                    --bottoml
                    renderer.rectangle(bbox[1], bbox[4], 1, -height/6, color[1], color[2], color[3], 255)
                    renderer.rectangle(bbox[1], bbox[4]-1, width/6, 1, color[1], color[2], color[3], 255)
                end

                if ui.get(menu.name) then
                    local wide, tall = surface.get_text_size(font, name)
                    surface.draw_text(bbox[1] - wide / 2 - (bbox[1] - bbox[3]) / 2, bbox[2]-16, color[1], color[2], color[3], 255, font, entity.get_player_name(player))
                end

                if ui.get(menu.weapon) then
                    local weapon = get_player_weapon(player)
                    if weapon == nil then return end
                    surface.draw_text(bbox[1] - weapon[2] / 2 - (bbox[1] - bbox[3]) / 2, bbox[4]+13, color[1], color[2], color[3], 255, font, string.format("%s - %s", weapon[1], weapon[4]))
                end

                if ui.get(menu.override_chams) then
                    local color = get_chams_team_color(player)
                    local _, vis_cham_clr = ui.reference("visuals", "colored models", "player")
                    local _, invis_cham_clr = ui.reference("visuals", "colored models", "player behind wall")
                    ui.set(vis_cham_clr, color[2][1], color[2][2], color[2][3], 255)
                    ui.set(invis_cham_clr, color[1][1], color[1][2], color[1][3], 255)
                end
            end
        end
    end
    
end

client.set_event_callback("paint", function()
    if get_local_player() == nil or not ui.get(menu.toggle) then
        return
    end
    draw_esp()
end)
