local imgui = require('imgui');
local json = require('json');
local settings = require('settings');

local ui = {};

function ui:draw(state, my_settings)
  if (imgui.Begin(string.format('%s v%s', addon.name, addon.version), state.show)) then
    if (imgui.SmallButton('Leave')) then
      AshitaCore:GetChatManager():QueueCommand(-2, '/p Take care!');
      AshitaCore:GetChatManager():QueueCommand(-2, '/pcmd leave');
      AshitaCore:GetChatManager():QueueCommand(-2, '/ma warp <me>');
    end

    if imgui.BeginTabBar('##TAXITabBar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton) then
      if imgui.BeginTabItem('Hailing') then
        if (imgui.BeginTable('##hailing_list', 3, bit.bor(ImGuiTableFlags_RowBg, ImGuiTableFlags_BordersH, ImGuiTableFlags_BordersV, ImGuiTableFlags_ContextMenuInBody, ImGuiTableFlags_ScrollX, ImGuiTableFlags_ScrollY))) then
          imgui.TableSetupColumn('Name', ImGuiTableColumnFlags_WidthFixed, 100.0, 0);
          imgui.TableSetupColumn('Message', bit.bor(ImGuiTableColumnFlags_DefaultSort, ImGuiTableColumnFlags_WidthStretch), 200.0, 0);
          imgui.TableSetupColumn('Invite', ImGuiTableColumnFlags_WidthFixed, 50.0, 0);
          imgui.TableSetupScrollFreeze(0, 1);
          imgui.TableHeadersRow();

          for i, hailer in ipairs(state.hailing) do
            imgui.TableNextColumn();
            imgui.Text(hailer[1] or '');

            imgui.TableNextColumn();
            imgui.Text(hailer[2] or '');

            imgui.TableNextColumn();
            -- all of these buttons are called '+' so they need a unique ID set this way..
            imgui.PushID(('invite#%d'):fmt(i));
            if (imgui.SmallButton('  +  ')) then
                AshitaCore:GetChatManager():QueueCommand(-2, '/pcmd add ' .. hailer[1] or '');
            end
            imgui.PopID();
          end
          imgui.EndTable();
        end
        imgui.EndTabItem();
      end
      imgui.EndTabBar();
    end
    imgui.End();
  end
end

return ui;
