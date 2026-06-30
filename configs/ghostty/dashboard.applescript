-- Ghostty dashboard layout: btop (left) + zsh/fastfetch (right)
-- Deployed by mac-dev-bootstrap configure_ghostty.sh

tell application "Ghostty"
	activate

	set cfgBtop to new surface configuration
	set command of cfgBtop to "{{BTOP}}"

	set cfgShell to new surface configuration
	set command of cfgShell to "{{ZSH}} -l -i"

	set dashWin to new window with configuration cfgBtop
	set paneLeft to terminal 1 of selected tab of dashWin
	set paneRight to split paneLeft direction right with configuration cfgShell

	focus paneRight

	-- Close the temporary bootstrap window from initial-command
	try
		repeat with w in windows
			if w is not dashWin then
				close w
			end if
		end repeat
	end try
end tell
