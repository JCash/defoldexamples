local M = {}

function M.create(info)
    local dialog = {}
    dialog.nodes = {}
    
    local H_size = gui.get_text_metrics(info.font, "H", info.width, 1, 1, 0)
    dialog.text_offset = vmath.vector3(H_size.width, 0, 0) * 0.5
    
    -- extra padding around the text: left, top, right, bottom
    local padding = info.padding or vmath.vector4(0,0,0,0)
    dialog.padding_offset = vmath.vector3(padding.x, padding.y, 0)
    dialog.padding_size = vmath.vector3(padding.x+padding.z, padding.y+padding.w, 0)
    
    dialog.slice9_radius = info.outline_radius or 16
    dialog.slice9_pos = vmath.vector3(dialog.slice9_radius, -dialog.slice9_radius, 0)
    dialog.slice9_size = vmath.vector3(dialog.slice9_radius, dialog.slice9_radius, 0)
    
    local icon_node = nil    
    dialog.icon_size = vmath.vector3(0,0,0)
    if info.icon_name ~= nil then
        icon_node = gui.new_box_node(dialog.slice9_pos*0.5, vmath.vector3(dialog.slice9_radius, dialog.slice9_radius, 0))
        gui.set_pivot(icon_node, gui.PIVOT_NW)
        if gui.SIZE_MODE_AUTOMATIC == nil then
            gui.SIZE_MODE_AUTOMATIC = 1
        end
        gui.set_size_mode(icon_node, gui.SIZE_MODE_AUTOMATIC)
        gui.set_texture(icon_node, info.icon_texture)
        gui.play_flipbook(icon_node, info.icon_name)
        dialog.icon_size = gui.get_size(icon_node)
        table.insert(dialog.nodes, icon_node)
    end
    
    dialog.icon_offset = vmath.vector3(dialog.icon_size.x, 0, 0)

    local background_node = gui.new_box_node(info.position, vmath.vector3(1,1,1))
    gui.set_pivot(background_node, gui.PIVOT_NW)
    gui.set_texture(background_node, info.texture)
    gui.play_flipbook(background_node, info.background)
    table.insert(dialog.nodes, background_node)
    
    local dialog_size = gui.get_size(background_node)
    
    local text_node = gui.new_text_node(dialog.slice9_pos*0.5 + dialog.text_offset + dialog.padding_offset + dialog.icon_offset, "")
    gui.set_parent(text_node, background_node)
    gui.set_pivot(text_node, gui.PIVOT_NW)
    gui.set_font(text_node, info.font)
    gui.set_line_break(text_node, true)
    gui.set_leading(text_node, info.leading or 1)
    gui.set_tracking(text_node, info.tracking or 0)
    table.insert(dialog.nodes, text_node)
    
    local outline_node = gui.new_box_node(dialog.slice9_pos * -0.5, vmath.vector3(1,1,1))
    gui.set_parent(outline_node, background_node)
    gui.set_pivot(outline_node, gui.PIVOT_NW)
    gui.set_texture(outline_node, info.texture)
    gui.play_flipbook(outline_node, info.outline)
    gui.set_slice9(outline_node, vmath.vector4(dialog.slice9_radius, dialog.slice9_radius, dialog.slice9_radius, dialog.slice9_radius))
    table.insert(dialog.nodes, outline_node)
    
    -- for the speech buuble look
    local arrow_node = nil
    if info.arrow ~= nil then
	    arrow_node = gui.new_box_node(vmath.vector3(dialog.slice9_radius, -dialog_size.y, 0), vmath.vector3(1,1,1))
	    gui.set_parent(arrow_node, background_node)
	    gui.set_pivot(arrow_node, gui.PIVOT_NW)
        gui.set_size_mode(arrow_node, gui.SIZE_MODE_AUTOMATIC)
	    gui.set_texture(arrow_node, info.texture)
	    gui.play_flipbook(arrow_node, info.arrow)
        table.insert(dialog.nodes, arrow_node)
    end
        
    -- to show an icon to let the user know there's more text coming
    local more_node = nil
    if info.more ~= nil then
        more_node = gui.new_box_node(vmath.vector3(dialog_size.x - dialog.slice9_radius, -dialog_size.y, 0), vmath.vector3(8, 8, 0))
        gui.set_parent(more_node, background_node)
        gui.set_pivot(more_node, gui.PIVOT_NW)
        gui.set_size_mode(more_node, gui.SIZE_MODE_AUTOMATIC)
        gui.set_texture(more_node, info.texture)
        gui.play_flipbook(more_node, info.more)
        gui.set_enabled(more_node, false)
        table.insert(dialog.nodes, more_node)
    end
    
    if icon_node ~= nil then
        gui.set_parent(icon_node, background_node)
    end
    if more_node ~= nil then
        gui.set_parent(more_node, background_node)
    end
    
    dialog.info = info
    dialog.text_node = text_node
    dialog.background_node = background_node
    dialog.outline_node = outline_node
    dialog.icon_node = icon_node
    dialog.arrow_node = arrow_node
    dialog.more_node = more_node
    dialog.text_index = 0
    
    M.next(dialog)
    
    return dialog
end

function M.next(dialog)
    local text_size = vmath.vector3(0,0,0)
    local text = ""
    if dialog.text_index < #dialog.info.text then
        dialog.text_index = dialog.text_index + 1
        text = dialog.info.text[dialog.text_index]
	    text_size = gui.get_text_metrics(dialog.info.font, dialog.info.text[dialog.text_index], dialog.info.width, 1, dialog.info.leading or 1, dialog.info.tracking or 0)
	    text_size = vmath.vector3(text_size.width, text_size.height, 0)
	end
	
    text_size.y = math.max(text_size.y, dialog.icon_size.y)
    
    if dialog.more_node then
        local enabled = dialog.text_index < #dialog.info.text
        gui.set_enabled(dialog.more_node, enabled)
        if enabled then
            local size = gui.get_size(dialog.more_node)
            text_size.y = math.max(text_size.y + size.y*0.5, dialog.icon_size.y)
            local offset = text_size + dialog.slice9_size + dialog.text_offset + dialog.padding_size + dialog.icon_offset
            gui.set_position(dialog.more_node, vmath.vector3(offset.x - size.x * 2, -text_size.y, 0))
        end
    end
    
    local dialog_size = text_size + dialog.slice9_size + dialog.text_offset + dialog.padding_size + dialog.icon_offset
	gui.set_size(dialog.background_node, dialog_size)
    gui.set_size(dialog.text_node, text_size)
    gui.set_text(dialog.text_node, text)
    
    local outline_size = text_size + dialog.slice9_size*2 + dialog.text_offset + dialog.padding_size + dialog.icon_offset
    gui.set_size(dialog.outline_node, outline_size)

    gui.set_position(dialog.arrow_node, vmath.vector3(dialog.slice9_radius, -dialog_size.y, 0))
    
    return #text > 0    
end

function M.set_enabled(dialog, enabled)
    for i, node in ipairs(dialog.nodes) do
        if node ~= nil then
            gui.set_enabled(node, enabled)
        end
    end
end

function M.destroy(dialog, enabled)
    for i, node in ipairs(dialog.nodes) do
        if node ~= nil then
            gui.delete_node(node)
        end
    end
end

return M
