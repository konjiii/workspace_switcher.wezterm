package.path = package.path .. ";" .. (select(2, ...):gsub("init.lua$", "?.lua"))
local wezterm = require("wezterm")
local helper = require("helper")
local act = wezterm.action

local workspace_switcher = {}

-- get names of all workspaces
local function get_workspaces(color)
	local workspaces = wezterm.mux.get_workspace_names()
	local choices = {}

	-- create choices table
	for _, name in ipairs(workspaces) do
		local colored_name = name
		if color then
			colored_name = wezterm.format({
				{ Foreground = { Color = color } },
				{ Text = name },
			})
		end
		table.insert(choices, { id = name, label = colored_name })
	end

	return choices
end

-- creates new workspace
local function creator()
	return wezterm.action_callback(function(window, pane, line)
		-- do nothing when invalid workspace name
		if line == "[+] Create new workspace" or line == "[-] Delete workspace" or line == nil then
			return
		end
		window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
	end)
end

-- delete a workspace
local function deleter()
	return wezterm.action_callback(function(_, _, id, _)
		helper.kill_workspace(id)
	end)
end

-- action when selected input
local function switcher(fzf)
	return wezterm.action_callback(function(window, pane, _, label)
		if label == "[+] Create new workspace" then
			window:perform_action(
				act.PromptInputLine({
					action = creator(),
					description = "Enter workspace name",
					initial_value = "",
				}),
				pane
			)
		elseif label == "[-] Delete workspace" then
			window:perform_action(
				act.InputSelector({
					action = deleter(),
					title = "Choose Workspace",
					description = "Select a workspace to delete",
					choices = get_workspaces("red"),
					fuzzy = fzf,
				}),
				pane
			)
		else
			-- only switch if label matches workspace that already exists
			for _, workspace in ipairs(get_workspaces()) do
				if label == workspace.label then
					window:perform_action(act.SwitchToWorkspace({ name = label }), pane)
					return
				end
			end
		end
	end)
end

function workspace_switcher.switch(fzf)
	fzf = fzf or false

	return wezterm.action_callback(function(window, pane)
		local choices = get_workspaces()

		-- create choice to create new workspace
		table.insert(choices, { label = "[+] Create new workspace" })
		table.insert(choices, { label = "[-] Delete workspace" })

		window:perform_action(
			act.InputSelector({
				action = switcher(fzf),
				title = "Choose Workspace",
				description = "Select a workspace",
				choices = choices,
				fuzzy = fzf,
			}),
			pane
		)
	end)
end

return workspace_switcher
