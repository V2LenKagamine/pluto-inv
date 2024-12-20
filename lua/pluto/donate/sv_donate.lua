--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
SetGlobalInt("pluto_donate_goal", 15000)

local function init()
	pluto.db.transact(function(db)
		local monthly = mysql_stmt_run(db, [[
			SELECT SUM(tokens) as total
			
			FROM forums.pluto_donations

			WHERE time >= (LAST_DAY(CURDATE()) + INTERVAL 1 DAY - INTERVAL 1 MONTH) AND time < (LAST_DAY(CURDATE()) + INTERVAL 1 DAY) AND status='COMPLETED'
		]])[1].total or 0

		SetGlobalInt("pluto_donate_pct", math.Round(monthly / GetGlobalInt "pluto_donate_goal" * 100))
	end)
end

--init()