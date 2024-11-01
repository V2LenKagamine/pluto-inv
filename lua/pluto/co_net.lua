--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
_net = _net or net

co_net = co_net or {
	coroutines = {},
	max_packet = 0xfe00 * 8
}

for _, index in pairs {
	"Angle",
	"Bit",
	"Bool",
	"Color",
	"Data",
	"Double",
	"Entity",
	"Float",
	"Int",
	"Matrix",
	"Normal",
	"String",
	"Table",
	"Type",
	"UInt",
	"Vector",

	"Function",
} do
	co_net["Write" .. index] = function(...)
		local wt = co_net.BitsWritten()
		if (wt > co_net.max_packet) then
			net = _net
			co_net.finish_fn()
			co_net.Start(co_net.CurrentMessage, co_net.finish_fn, true)
		end

		_net["Write" .. index](...)
	end

	co_net["Read" .. index] = function(...)
		local rd = co_net.BitsRead()
		if (rd > co_net.max_packet) then
			coroutine.yield()
		end

		return _net["Read" .. index](...)
	end
end

function co_net.BitsWritten()
	return select(2, _net.BytesWritten()) - co_net.BitsAtStart
end

function co_net.BitsRead()
	return co_net.BitsAtStartRead - select(2, _net.BytesLeft())
end

function co_net.Start(name, finish, continued)
	co_net.CurrentMessage = name
	_net.Start(name)
	_net.WriteBool(not continued)
	net = co_net

	co_net.BitsAtStart = select(2, _net.BytesWritten())
	co_net.finish_fn = finish
end

function co_net.Finish()
	net = _net
	co_net.finish_fn()
	co_net.CurrentMessage = nil
end

function co_net.Receive(name, fn)
	_net.Receive(name, function(len, cl)
		local new = _net.ReadBool()

		local lookup = co_net.coroutines
		if (SERVER) then
			local real = lookup[cl]
			if (not real) then
				real = {}
				lookup[cl] = real
			end

			lookup = real
		end

		local co = lookup[name]

		if (new) then
			co = coroutine.create(fn)
			lookup[name] = co
		elseif (not co or coroutine.status(co) == "dead") then
			pluto.warn("INV", "Packet is dead, discarding.")
			return
		end

		co_net.BitsAtStartRead = select(2, _net.BytesLeft())
		net = co_net
		local succ, err = coroutine.resume(co, len, cl)

		net = _net
		if (not succ) then
			print(debug.traceback(co, err))
			error(debug.traceback(co, err))
		end
	end)
end

hook.Add("Tick", "pluto_ensure_co_net", function()
	net = _net
end)