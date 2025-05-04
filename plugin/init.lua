local wezterm = require("wezterm")
local act = wezterm.action

local workspace_switcher = {}

-- creates new workspace
local function creator()
	return wezterm.action_callback(function(window, pane, line)
		print(pane)
		window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
	end)
end

-- action when selected input
local function switcher()
	return wezterm.action_callback(function(window, pane, _, label)
		if label == "[+] Create new workspace" then
			window:perform_action(
				act.PromptInputLine({
					description = "Enter workspace name",
					initial_value = "",
					action = creator(),
				}),
				pane
			)
		else
			window:perform_action(act.SwitchToWorkspace({ name = label }), pane)
		end
	end)
end

function workspace_switcher.switch()
	return wezterm.action_callback(function(window, pane)
		local workspaces = wezterm.mux.get_workspace_names()
		local choices = {}

		-- create choices table
		for _, name in ipairs(workspaces) do
			table.insert(choices, { label = name })
		end

		-- create choice to create new workspace
		table.insert(choices, { label = "[+] Create new workspace" })
		table.insert(choices, { label = "[-] Delete workspace" })

		window:perform_action(
			act.InputSelector({
				action = switcher(),
				title = "Choose Workspace",
				description = "Select a workspace and press Enter = accept, Esc = cancel, / = filter",
				choices = choices,
				fuzzy = true,
			}),
			pane
		)
	end)
end

return workspace_switcher
