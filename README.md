simple wezterm workspace switcher.

Install:
```bash
local wezterm = require("wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/konjiii/wez_workspace_switcher")
```

Configuration:
```bash
config.keys = {
  {
    key = "s",
    mods = "LEADER",
    action = workspace_switcher.switch(),
  },
}
```
