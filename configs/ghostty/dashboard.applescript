-- Ghostty dashboard — reference layout
-- Left: full btop (cpu, mem, net, proc)  |  Right: fastfetch + zsh

tell application "Ghostty"
	activate

	set cfgBtop to new surface configuration
	set command of cfgBtop to "{{BTOP}}"

	set cfgShell to new surface configuration
	set command of cfgShell to "{{ZSH}} -l -i"
	set environment variables of cfgShell to {"MDB_DASHBOARD_PANE=1"}

	set dashWin to new window with configuration cfgShell
	set paneRight to terminal 1 of selected tab of dashWin
	set paneLeft to split paneRight direction left with configuration cfgBtop

	perform action "equalize_splits" on paneLeft

	-- Slight bias to left pane for btop proc column (~52%)
	focus paneLeft
	perform action "resize_split:right,60" on paneLeft

	focus paneRight

	try
		repeat with w in windows
			if w is not dashWin then
				close w
			end if
		end repeat
	end try
end tell
