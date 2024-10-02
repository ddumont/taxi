addon.name = 'Taxi';
addon.author = 'Notagain';
addon.version = '1.1';
addon.desc = 'Teleport taxi helper';
addon.link = 'https://google.com';

require('common');
require('string');
local chat = require('chat');
local json = require('json');
local settings = require('settings');

local ui = require('ui');

local TAXI = { settings = {}, state = {
  show = {},
  hailing = { },
} };

local initialized = nil;

settings.register('settings', 'settings_update', function(newSettings)
  TAXI.settings = newSettings;
end);


ashita.events.register('load', 'load_cb', function()
  TAXI.settings = settings.load({});

  initialized = false;
end);

ashita.events.register('unload', 'unload_cb', function()
  initialized = nil;
end);

ashita.events.register('d3d_present', 'rendertick', function()
  if initialized == false then
    initialized = true;
  end
  if TAXI.state.show[1] then
    ui:draw(TAXI.state, TAXI.settings);
  end
end);

ashita.events.register('command', 'command_callback1', function(e)
    --[[ Valid Arguments
        e.mode       - (ReadOnly) The mode of the command.
        e.command    - (ReadOnly) The raw command string.
        e.injected   - (ReadOnly) Flag that states if the command was injected by Ashita or an addon/plugin.
        e.blocked    - Flag that states if the command has been, or should be, blocked.
    --]]
    if (e.command == '/taxi') then
        TAXI.state.show[1] = not TAXI.state.show[1];
        e.blocked = true;
    end
end);

--[[
* event: text_in
* desc : Event called when the addon is processing incoming text.
--]]
ashita.events.register('text_in', 'text_in_cb', function(e)
  if TAXI.state.show[1] then
    -- Obtain the chat mode..
    local mode = bit.band(e.mode_modified, 0x000000FF);
    if mode == 10 or mode == 11 then -- shout or yell
      local msg = AshitaCore:GetChatManager()
        :ParseAutoTranslate(e.message, true)
        -- Strip FFXI-specific color and translate tags..
        :strip_colors()
        :strip_translate(true);

      local who, message = msg:match("^([^%[%s]+)([%[%s].+)");

      if message:lower():match("teleport") then
        TAXI.state.hailing[#TAXI.state.hailing + 1] = { who, message };
        ashita.misc.play_sound(addon.path:append('\\hail.wav'));


        (function(a) table.remove(TAXI.state.hailing, 1) end):once(10);
      end
    end
  end
end);



return TAXI;
