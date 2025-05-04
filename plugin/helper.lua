local wezterm = require("wezterm")
local helper = {}

-- get all panes of a workspace
function helper.get_panes(workspace)
	local success, stdout = wezterm.run_child_process({ "wezterm", "cli", "list", "--format=json" })

	local workspace_panes = {}
	if success then
		local json = wezterm.json_parse(stdout)
		if not json then
			return false, workspace_panes
		end

		-- get all workspace_panes of workspace
		for _, pane in ipairs(json) do
			if pane.workspace == workspace then
				table.insert(workspace_panes, pane)
			end
		end
	end

	return success, workspace_panes
end

-- kill workspace given workspace name
function helper.kill_workspace(workspace)
	local success, workspace_panes = helper.get_panes(workspace)

	if success then
		-- kill all workspace_panes
		for _, pane in ipairs(workspace_panes) do
			wezterm.run_child_process({ "wezterm", "cli", "kill-pane", "--pane-id=" .. pane.pane_id })
		end
	end
end

return helper
