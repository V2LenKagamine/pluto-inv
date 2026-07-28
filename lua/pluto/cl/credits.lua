--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local was_visible = false

local msg = [[
--------------------------------------------------------------------------------------------
|  Hi. If you are seeing this, and you just wanted to change console variables - go ahead! |
|  This message is here to thank the people that have severely helped me in my endeavor to |
|  create this server and hopefully maintain it as a healthy, fun place to hang out with   |
|  other people.                                                                           |
|------------------------------------------------------------------------------------------|
]]

local msg2 = [[
--------------------------------------------------------------------------------------------
| Though the time of Pluto has passed, let us not forget those who the original creator,   |
| Meepen, had thanked for their efforts in assisting them.                                 |
|------------------------------------------------------------------------------------------|
|                                   Pluto 2 Credits:                                       |
]]

local dumbo = "| Len Kagamine[DEV]| The dumbo themself; Stealer of Code, and Giver of Gifts.              |" 

local people2 = {
    "| Goth             | Provided immense support with Pluto, and provided great design docs   |\n" ..
    "|                  | for a similar project that shaped what you see before you now.        |",
}

hook.Add("Think", "pluto_credits", function()
	if (gui.IsConsoleVisible()) then
		MsgN "\n\n"
		MsgC(white_text, msg)
		local line_sep = "|" .. string.rep("-", 90) .. "|\n"
        MsgC(white_text, msg2)
        MsgC(white_text, "|")
        MsgC(Color(240,240,0),dumbo:sub(2,19))
        MsgC(white_text, dumbo:sub(20) .. "\n")
        MsgC(white_text, line_sep)
        for _, line in RandomPairs(people2) do
			MsgC(white_text, "|")
			MsgC(HSVToColor(math.random() * 360, 1, 1), line:sub(2, 19))
			MsgC(white_text, line:sub(20) .. "\n")
			MsgC(white_text, line_sep)
		end
        MsgC(white_text,"|    [Your Name]   | Time is long friend, you help alone by playing, but who knows, should |\n" ..
	                    "|      [Listed]    | you prove influental; by code, assets, or ideas, you may find your own|\n" ..
                        "|      [Here?]     | name amongst those carved in stone by time.                           |\n" ..
                        "|------------------------------------------------------------------------------------------|")
		hook.Remove("Think", "pluto_credits")
	end
end)