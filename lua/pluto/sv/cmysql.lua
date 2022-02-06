--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
--[[
	SEE https://github.com/pluto-oss/gluamysql/blob/master/lua/cmysql_example.lua IF YOU WANT TO HAVE AN EXAMPLE OF HOW TO USE THIS FILE

]]

include "promise.lua"
require "gluamysql"

local env = getfenv(0)

mysql.prepare_cache = setmetatable({}, {__mode = "k", __index = function(self, k)
	local r = {}
	self[k] = r
	return r
end})

mysql.finish_cache = setmetatable({}, {__mode = "k"})

local function handle_returns(success, ...)
	if (not success) then
		return nil, ...
	end

	return ...
end

local function handle_resume(co, success, err)
	if (not success) then
		pwarnf("error: %s\n%s", err, debug.traceback(co))
	end

	if (coroutine.status(co) == "dead") then
		local finished = mysql.finish_cache[co]
		if (finished) then
			return finished(success, err)
		end
	end
end

local function wait_promise(promise)
	local co = coroutine.running()

	promise
		:next(function(...)
			return handle_resume(co, coroutine.resume(co, true, ...))
		end)
		:catch(function(...)
			return handle_resume(co, coroutine.resume(co, false, ...))
		end)

	return handle_returns(coroutine.yield())
end

-- database library

function env.mysql_init(...)
	return wait_promise(mysql.connect(...))
end

function env.mysql_query(db, query)
	local r, err = wait_promise(db:query(query))

	if (not r) then
		pwarnf("mysql_query returned %s", err)
	end

	return r, err
end

function env.mysql_check_error(r, msg)
	if (not r) then
		error(msg, 2)
	end
end

function env.mysql_autocommit(db, b)
	return wait_promise(db:autocommit(b))
end

function env.mysql_commit(db)
	return wait_promise(db:commit())
end

function env.mysql_rollback(db)
	return wait_promise(db:rollback())
end

-- statement library

function env.mysql_stmt_prepare(db, query)

	local cache = mysql.prepare_cache[db][query]
	if (cache) then
		return cache
	end

	local stmt, err = wait_promise(db:prepare(query))

	if (stmt) then
		mysql.prepare_cache[db][query] = stmt
	end

	return stmt, err
end

function env.mysql_ping(db)
	return wait_promise(db:ping())
end

function env.mysql_stmt_execute(stmt, ...)
	return wait_promise(stmt:execute(...))
end

function env.mysql_stmt_run(db, query, ...)
	local stmt, err = mysql_stmt_prepare(db, query)
	if (not stmt) then
		return false, err
	end
	return wait_promise(stmt:execute(...))
end

-- entry point

function cmysql(func, finished)
	local co = coroutine.create(func)
	mysql.finish_cache[co] = finished
	handle_resume(co, coroutine.resume(co))
end

function env.mysql_cmysql()
	assert(coroutine.running() ~= nil, "not running in coroutine")
end