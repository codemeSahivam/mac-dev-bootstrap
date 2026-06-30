-- Ghostty dashboard: btop (left 50%) + zsh/fastfetch (right 50%)

tell application "Ghostty"
	activate

	set cfgBtop to new surface configuration
	set command of cfgBtop to "{{BTOP}} -c {{BTOP_SPLIT_CONF}}"

	set cfgShell to new surface configuration
	set command of cfgShell to "{{ZSH}} -l -i"
	set environment variables of cfgShell to {"FASTFETCH_CONFIG={{FASTFETCH_SPLIT_CONF}}", "MDB_DASHBOARD_PANE=1"}

	set dashWin to new window with configuration cfgShell
	set paneRight to terminal 1 of selected tab of dashWin
	set paneLeft to split paneRight direction left with configuration cfgBtop

	perform action "equalize_splits" on paneLeft
	focus paneRight

	try
		repeat with w in windows
			if w is not dashWin then
				close w
			end if
		end repeat
	end try
end tell
