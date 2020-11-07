local surface = require('gamesense/surface')
local font = surface.create_font("Visitor TT2 (BRK)", 11, 400, 0x200)

local function localplayer()
    local real_lp = entity.get_local_player()
    if entity.is_alive(real_lp) then
        return real_lp
    else
        local obvserver = entity.get_prop(real_lp, "m_hObserverTarget")
        return obvserver ~= nil and obvserver <= 64 and obvserver or nil
    end
end

local function collect_players()
    local results = {}
    local lp_origin = {entity.get_origin(localplayer())}

    for i=1, 64 do
        if entity.is_alive(i) then
            local player_origin = {entity.get_origin(i)}
            if player_origin[1] ~= nil and lp_origin[1] ~= nil then
                table.insert(results, {i})
            end
        end
    end
    return results
end

local function vis_check(enemy, team)
    local hitbox_position = {entity.hitbox_position(enemy, 0)}
    local eye_pos = {client.eye_position()}
    local fraction, v_hit = client.trace_line(entity.get_local_player(), eye_pos[1], eye_pos[2], eye_pos[3], hitbox_position[1], hitbox_position[2], hitbox_position[3])
    if (v_hit == enemy or fraction == 1) then
        if team == 3 then
            --print("3")
            return {34, 255, 0, 255} -- CT VIS
            
        elseif team == 2 then
            --print("2")
            return {255, 255, 0, 255} -- T VIS

        end
    else
        if team == 3 then
            --print("3.1")
            return {0, 136, 255, 255} -- CT NON VIS
        elseif team == 2 then
            --print("2.1")
            return {255, 25, 25, 255} -- T NON VIS
        end
    end
end

local function team_check(enemy)
    local return_clr
    if entity.get_prop(enemy, "m_iTeamNum") == 2 then
        return_clr = vis_check(enemy, 2)
    elseif entity.get_prop(enemy, "m_iTeamNum") == 3 then
        return_clr = vis_check(enemy, 3)
    end

    return return_clr
end

local iwebz = {
    toggle = ui.new_checkbox("lua", "a", "esp_toggle"),
    healthstyle = ui.new_checkbox("lua", "a", "esp_health_bar"),
    boxstyle = ui.new_combobox("lua", "a", "esp_box", {"None", "Bounding", "Bounding Corner"}),
    name = ui.new_checkbox("lua", "a", "esp_name"),
    weapon = ui.new_checkbox("lua", "a", "esp_weapon"),
    xhair = ui.new_checkbox("lua", "a", "esp_xhair"),
    chams_team_check = ui.new_checkbox("lua", "a", "chams_team_check"),
    indicator = ui.new_checkbox("lua", "a", "remove_indicators")
}

local indicators = {}
ui.set_callback(iwebz.indicator, function()
    if ui.get(iwebz.indicator) then
        client.set_event_callback("indicator", function(i)
            table.insert(indicators, i)
        end)
    else
        client.unset_event_callback("indicator", function(i)end)
    end
end)

local weapons = {
    [1] = "DEagle",
    [2] = "Elite",
    [3] = "FiveseveN",
    [4] = "Glock",
    [7] = "AK47",
    [8] = "AUG",
    [9] = "AWP",
    [10] = "FAMAS",
    [11] = "G3SG1",
    [13] = "GalilAR",
    [14] = "M249",
    [16] = "M4A4",
    [17] = "MAC10",
    [19] = "P90",
    [23] = "MP5SD",
    [24] = "UMP45",
    [25] = "XM1014",
    [26] = "PPBizon",
    [27] = "MAG7",
    [28] = "Negev",
    [29] = "SawedOff",
    [30] = "Tec9",
    [31] = "Taser",
    [32] = "Hkp2000",
    [33] = "MP7",
    [34] = "MP9",
    [35] = "Nova",
    [36] = "P250",
    [38] = "SCAR20",
    [39] = "SG553",
    [40] = "SSG08",
    [41] = "Knife",
    [42] = "Knife ct",
    [43] = "Flashbang",
    [44] = "HEGrenade",
    [45] = "Smokegrenade",
    [46] = "Molotov",
    [47] = "Decoy",
    [48] = "Incgrenade",
    [49] = "C4",
    [59] = "Knife t",
    [60] = "M4a1 silencer",
    [61] = "Usp silenced",
    [63] = "CZ75auto",
    [64] = "Revolver",
    [500] = "knife Bayonet",
    [505] = "knife Flip Knife",
    [506] = "knife Gut Knife",
    [507] = "knife Karambit",
    [508] = "knife M9 Bayonet",
    [509] = "knife Huntsman Knife",
    [512] = "knife Falchion Knife",
    [514] = "knife Bowie Knife",
    [515] = "knife Butterfly Knife",
    [516] = "knife Shadow Daggers",
    [519] = "knife Ursus Knife",
    [520] = "knife Navaja Knife",
    [522] = "knife Siletto Knife",
    [523] = "knife Talon Knife",
}

local function draw_main_esp()
    if not ui.get(iwebz.toggle) then return end
    if ui.get(iwebz.xhair) then
        local x,y = client.screen_size()
        client.exec("crosshair 0")
        renderer.rectangle(x/2-1, y/2+9, 3, 12, 0, 0, 0, 255)
        renderer.rectangle(x/2+9, y/2-1, 12, 3, 0, 0, 0, 255)
        renderer.rectangle(x/2-21, y/2-1, 12, 3, 0, 0, 0, 255)
        renderer.rectangle(x/2-2, y/2-21, 3, 12, 0, 0, 0, 255)

       
        renderer.rectangle(x/2-1, y/2-1, 3, 3, 0, 0, 0, 255)
        renderer.rectangle(x/2, y/2, 1, 1, 255, 0, 0, 255)

        renderer.rectangle(x/2, y/2+10, 1, 10, 255, 255, 255, 255)
        renderer.rectangle(x/2-1, y/2-20, 1, 10, 255, 255, 255, 255)
        renderer.rectangle(x/2+10, y/2, 10, 1, 255, 255, 255, 255)
        renderer.rectangle(x/2-20, y/2, 10, 1, 255, 255, 255, 255)

    else
        client.exec("crosshair 1")
    end

    local enemies = collect_players()
    for i=1, #enemies do
        local enemy = unpack(enemies[i])
        if entity.is_enemy(enemy) then
            local bbox = {entity.get_bounding_box(enemy)}
            if bbox[1] ~= nil or bbox[2] ~= nil or bbox[3] ~= nil or bbox[4] ~= nil or bbox[5] ~= 0 then
                local height, width = bbox[4]-bbox[2], bbox[3]-bbox[1]
                if ui.get(iwebz.healthstyle) then
                    local health = entity.get_prop(enemy, "m_iHealth")
                    local health_color = entity.is_dormant(enemy) and {100, 100, 100, 0} or team_check(enemy)
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 0} or {255, 255, 255, 255}
                    local health_width = (width*health/100)+2
                    for i = 1, 5 do
                        renderer.rectangle(bbox[1]-i, bbox[4]+i+5, width, 1, 0, 0, 0, 255)
                        renderer.rectangle(bbox[1]-i, bbox[4]+i+5, health_width, 1, health_color[1], health_color[2], health_color[3], health_color[4])

                        renderer.rectangle(bbox[1]-3, bbox[4]+8, health_width, 1, health_color[1]/1.5, health_color[2]/1.5, health_color[3]/1.5, health_color[4])
                        renderer.rectangle(bbox[1]-4, bbox[4]+9, health_width, 1, health_color[1]/1.5, health_color[2]/1.5, health_color[3]/1.5, health_color[4])
                    end
                    renderer.rectangle(bbox[1], bbox[4]+5, width, 1, color[1], color[2], color[3], 255)
                    renderer.rectangle((bbox[1]+1)-5, bbox[4]+10, width, 1, color[1], color[2], color[3], 255)
                    renderer.line((bbox[1]+1)-6, bbox[4]+11, bbox[1], bbox[4]+5, color[1], color[2], color[3], 255)
                    renderer.line(bbox[1]+width-4, bbox[4]+11, bbox[1]+width+2, bbox[4]+5, color[1], color[2], color[3], 255)
                    for i = 1, 5 do
                        renderer.rectangle(bbox[1], bbox[4]+5, 1, 1, color[1], color[2], color[3], 255)
                        if i ~= 0 then
                            renderer.rectangle(bbox[1]+width, bbox[4]+5, 1, 1, color[1], color[2], color[3], 255)
                        end
                    end
                end
                if ui.get(iwebz.chams_team_check) then -- I was lazy to write another method lol
                    local _, vis_cham_clr = ui.reference("visuals", "colored models", "player")
                    local _, invis_cham_clr = ui.reference("visuals", "colored models", "player behind wall")
                    local return_vis_clr
                    local return_invis_clr
                    if entity.get_prop(enemy, "m_iTeamNum") == 2 then
                        return_vis_clr = {255, 255, 0, 255}
                        return_invis_clr = {255, 25, 25, 255}
                    elseif entity.get_prop(enemy, "m_iTeamNum") == 3 then
                        return_vis_clr = {34, 255, 0, 255}
                        return_invis_clr = {0, 136, 255, 255}
                    end
                    ui.set(vis_cham_clr, return_vis_clr[1], return_vis_clr[2], return_vis_clr[3], return_vis_clr[4])
                    ui.set(invis_cham_clr, return_invis_clr[1], return_invis_clr[2], return_invis_clr[3], return_invis_clr[4])
                end
                if ui.get(iwebz.boxstyle) == "Bounding" then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or team_check(enemy)
                    surface.draw_outlined_rect(bbox[1], bbox[2], width, height, color[1], color[2], color[3], 255)
                    surface.draw_outlined_rect(bbox[1]-1, bbox[2]-1, width+2, height+2, 0,0,0,255)
                elseif ui.get(iwebz.boxstyle) == "Bounding Corner" then
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or team_check(enemy)
                    -- toplo
                    renderer.rectangle(bbox[1]-1, bbox[2]-1, 1, height/6+1, 0,0,0,255)
                    renderer.rectangle(bbox[1]-1, bbox[2]-1, width/6+2, 1, 0,0,0,255)

                    -- topro
                    
                    renderer.rectangle(bbox[3], bbox[2], 1, height/6, 0,0,0,255)
                    renderer.rectangle(bbox[3]+1, bbox[2]-1, -width/6-2, 1, 0,0,0,255)

                    --bottomro
                    
                    renderer.rectangle(bbox[3], bbox[4]-1, 1, -height/6+1, 0,0,0,255)
                    renderer.rectangle(bbox[3]+1, bbox[4], -width/6-2, 1, 0,0,0,255)

                    --bottomlo
                    renderer.rectangle(bbox[1]-1, bbox[4]-1, 1, -height/6+1, 0,0,0,255)
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

                if ui.get(iwebz.name) then
                    local name = entity.get_player_name(enemy)
                    if name == nil then return end
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or team_check(enemy)

                    if name:len() > 15 then 
                        name = name:sub(0, 15)
                    end

                    local wide, tall = surface.get_text_size(font, name:lower())
        
                    local middle_x = (bbox[1] - bbox[3]) / 2
        
                    surface.draw_text(bbox[1] - wide / 2 - middle_x, bbox[2]-16, color[1], color[2], color[3], 255, font, name:lower())
                end
                if ui.get(iwebz.weapon) then
                    local weapon_id = entity.get_prop(enemy, "m_hActiveWeapon")
                    if entity.get_prop(weapon_id, "m_iItemDefinitionIndex") ~= nil then
                        weapon_item_index = bit.band(entity.get_prop(weapon_id, "m_iItemDefinitionIndex"), 0xFFFF)
                    end
                    local weapon_name = weapons[weapon_item_index]
                    if weapon_name == nil then return end
                    local color = entity.is_dormant(enemy) and {100, 100, 100, 255} or team_check(enemy)
                    if weapon_name:len() > 15 then 
                        weapon_name = weapon_name:sub(0, 15)
                    end

                    local enemy_weapon = entity.get_player_weapon(enemy)
                    local current_ammo = entity.get_prop(enemy_weapon, "m_iClip1") or 0
                    local current_weapon
                    if not (weapon_item_index == 31 or weapon_item_index == 41 or weapon_item_index == 42 or weapon_item_index == 43 or weapon_item_index == 44 or weapon_item_index == 45 or weapon_item_index == 46 or weapon_item_index == 47 or weapon_item_index == 48 or weapon_item_index == 49 or weapon_item_index == 59 or weapon_item_index >= 500) then
                        current_weapon = weapon_name:lower().."-"..current_ammo
                    else
                        current_weapon = weapon_name:lower()
                    end
                    local wide, tall = surface.get_text_size(font, current_weapon)
        
                    local middle_x = (bbox[1] - bbox[3]) / 2
        
                    surface.draw_text(bbox[1] - wide / 2 - middle_x, bbox[4]+12, color[1], color[2], color[3], 255, font, current_weapon)
                end
            end
        end
    end
end

client.set_event_callback("paint", function()
    if localplayer() == nil then
        return
    end
    draw_main_esp()
end)
