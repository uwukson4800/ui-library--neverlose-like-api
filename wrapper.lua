local wrapper = {}

local _ui = ui

local mt = {
    __index = function(t, k)
        if wrapper[k] then
            return wrapper[k]
        end
        return _ui[k]
    end
}

local refs = {}

local function create_base_object()
    local obj = {}
    
    function obj:get()
        return _ui.get(self.reference)
    end
    
    function obj:set(value)
        _ui.set(self.reference, value)
    end
    
    function obj:set_callback(callback)
        _ui.set_callback(self.reference, callback)
    end
    
    function obj:type()
        return _ui.type(self.reference)
    end

    function obj:visibility(visible)
        _ui.set_visible(self.reference, visible)
    end

    function obj:update(value, ...)
        _ui.update(self.reference, value, ...)
    end

    function obj:disabled(state)
        if state ~= nil then
            _ui.set_enabled(self.reference, not state)
        end
        return not _ui.get(self.reference)
    end

    function obj:id()
        return self.reference
    end
    
    return obj
end

function wrapper.create(tab, container, name)
    local group = {
        name = name,
        tab = tab,
        container = container,
        
        switch = function(self, name, default)
            local obj = create_base_object()
            obj.reference = _ui.new_checkbox(self.tab, self.container, name)
            if default ~= nil then
                _ui.set(obj.reference, default)
            end
            return obj
        end,
        
        combo = function(self, name, ...)
            local obj = create_base_object()
            local options = {...}
            if type(options[1]) == 'table' then
                options = options[1]
            end
            obj.reference = _ui.new_combobox(self.tab, self.container, name, unpack(options))
            return obj
        end,

        selectable = function(self, name, ...)
            local obj = create_base_object()
            local options = {...}
            if type(options[1]) == 'table' then
                options = options[1]
            end
            obj.reference = _ui.new_multiselect(self.tab, self.container, name, unpack(options))
            return obj
        end,

        list = function(self, name, options)
            local obj = create_base_object()
            obj.reference = _ui.new_listbox(self.tab, self.container, name, options)
            return obj
        end,
        
        slider = function(self, name, min, max, default)
            local obj = create_base_object()
            obj.reference = _ui.new_slider(self.tab, self.container, name, min, max, default or min)
            return obj
        end,
        
        color_picker = function(self, name, default_color)
            local obj = create_base_object()
            obj.reference = _ui.new_color_picker(self.tab, self.container, name, 
                default_color.r or 255,
                default_color.g or 255, 
                default_color.b or 255,
                default_color.a or 255)
            return obj
        end,

        label = function(self, text)
            local obj = create_base_object()
            obj.reference = _ui.new_label(self.tab, self.container, text)
            return obj
        end,

        input = function(self, text)
            local obj = create_base_object()
            obj.reference = _ui.new_textbox(self.tab, self.container, text)
            return obj
        end,

        button = function(self, name, callback)
            local obj = create_base_object()
            obj.reference = _ui.new_button(self.tab, self.container, name, callback)
            return obj
        end,

        hotkey = function(self, name, ecx, edx)
            local obj = create_base_object()
            obj.reference = _ui.new_hotkey(self.tab, self.container, name, ecx, edx)
            return obj
        end
    }
    
    return group
end

function wrapper.find(tab, container, name)
    local obj = create_base_object()
    obj.reference = _ui.reference(tab, container, name)
    return obj
end

function wrapper.color(r, g, b, a)
    return {r = r, g = g, b = b, a = a}
end

function wrapper.get_alpha()
    return _ui.is_menu_open() and 1 or 0
end

function wrapper.get_size()
    return {_ui.menu_size()}
end

function wrapper.get_position() 
    return {_ui.menu_position()}
end

function wrapper.get_mouse_position()
    return {_ui.mouse_position()}
end

local wrapped = setmetatable({}, mt)

return wrapped