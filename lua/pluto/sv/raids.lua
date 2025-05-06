AddCSLuaFile()

if SERVER then
    RAIDS = RAIDS or {}
    RAIDS.RAIDS_MAP_NODES = RAIDS.RAIDS_MAP_NODES or {}
    RAIDS.RAIDS_NODES_DISTANCE_MULT = RAIDS.RAIDS_NODES_DISTANCE_MULT or 2

    local AINET_VERSION_NUMBER = 37

    hook.Add("Initialize", "raids_load_map_nodes", function()
        RAIDS.RAIDS_MAP_NODES = table.Copy(pluto.currency.cached_positions) or {}
        RAIDS.RAIDS_NODES_DISTANCE_MULT = 2
    end)

    ---------------------------------------------------------
    ---------------------- GENERAL --------------------------
    ---------------------------------------------------------
    local raids ={
        zombies = {
            ["drg_roach_dr1_em00"] = 1,
        },
        soldiers = {
            ["bwaaf_commander"] = 1,
            ["bwaaf_grenadier"] = 12,
            ["bwaaf_machinegunner"] = 12,
            ["bwaaf_medic"] = 12,
            ["bwaaf_shield"] = 12,
            ["bwaaf_sniper"] = 12,
            ["bwaaf_soldier"] = 12,
            ["bwaaf_stealth"] = 12,
            ["bwacc_patrol"] = 12,
            ["bwacc_riot"] = 12,
        },
    }

    local function checkIfMapJustBuiltNodes()
        if table.IsEmpty(RAIDS.RAIDS_MAP_NODES) then 
            RAIDS.RAIDS_MAP_NODES = table.Copy(pluto.currency.cached_positions)
        end
    end

    local function countNearbyEnemies(pos, radius)
        local entsInRadius = ents.FindInSphere( pos, radius )
        local count = 0

        for _, ent in pairs(entsInRadius) do
            if ent:IsNextBot() then count = count + 1 end
        end

        return count
    end

    local function setUpEnemy(class, pos, offsetNodePos, ply)
        local npc = ents.Create(class)
        npc:SetPos(pos)
        npc:Spawn()
        npc.raidsNPC = true
        npc.targetedPlayer = table.Random(player.GetAll())
        npc.spawnedPos = pos
        npc.spawnedTime = CurTime()

        -- The rest of this function's code only applies to NPC's spawned by raids_spawn_* commands, not assault/arena mode.        
        timer.Simple(0.1, function()
            if !IsValid(offsetNodePos) then return end
            if !IsValid(npc) then return end
            npc:SetLastPosition( offsetNodePos )
            npc:SetSchedule( SCHED_FORCED_GO_RUN )
        end)

        timer.Simple(2, function()
            if !IsValid(offsetNodePos) then return end
            if !IsValid(npc) then return end
            if !IsValid(ply) then return end
            local direction = (ply:GetPos() - npc:GetPos()):GetNormalized() -- These 4 lines get the npc's to face towards the player
            local angle = direction:Angle() 
            angle.p = 0
            npc:SetAngles(angle)
        end)
    end

    util.AddNetworkString("raids_send_raid_update")
    local function report(ply, count, limit)
        net.Start("raids_send_raid_update")
        net.WriteUInt(count,8)
        net.Broadcast()
    end

    local function checkIfBoxIsColliding(mins, maxs)
        local sampleVec = Vector()

        for z = mins.z, maxs.z, 8 do 
            for x = mins.x, maxs.x, 8 do
                for y = mins.y, maxs.y, 8 do
                    sampleVec.x, sampleVec.y, sampleVec.z = x, y, z
                    if !util.IsInWorld(sampleVec) then return true end
                end
            end 
        end

        return false
    end 

    local function spawningAtCollidesWithNPC(nodePos)
        local localEnts = ents.FindInSphere( nodePos, 64 ) 
        
        for k, node in pairs(localEnts) do
            if node:IsNextBot() then return true end
        end
        
        return false
    end

    local offsetDirections = {
        north = Vector(0,128,4),
        northEast = Vector(96,96,4),
        east = Vector(128,0,4),
        southEast = Vector(96, -96, 4),
        south = Vector(0,-128,4),
        southWest = Vector(-96,-96, 4),
        west = Vector(-128,0,4),
        northWest = Vector(-96, 96, 4),
    }

    local function nodeNearDoor(nodePos)
        local potentialDoors = ents.FindInSphere( nodePos, 64 ) 
        
        for _, ent in pairs(potentialDoors) do
            if ent:GetClass() == "prop_door_rotating" or ent:GetClass() == "func_door" or ent:GetClass() == "func_door_rotating" or ent:GetClass() == "func_lookdoor" then
                return true
            end
        end

        return false
    end

    local function findClearSpaceByNode(nodePos)
        local offsetNodePos = nodePos
        local portentialDirections = table.Copy( offsetDirections )

        -- Try to find a random pos by node, give up after sampling around in a circle
        for i = 1, 8 do 
            local randomMult = math.random(0.25,1)
            
            local randomDirectionFromPotentialDirections = table.Random(portentialDirections) * Vector(randomMult, randomMult, 1)
            table.RemoveByValue( portentialDirections, randomDirectionFromPotentialDirections )

            local potentialSpawn = nodePos + randomDirectionFromPotentialDirections 

            if nodeNearDoor(potentialSpawn) then continue end
            if checkIfBoxIsColliding(potentialSpawn + Vector(-16, -16, 0), potentialSpawn + Vector(16, 16, 80)) then continue end

            offsetNodePos = potentialSpawn
            break
        end
        
        return offsetNodePos
    end
    ---------------------------------------------------------
    -------------------- RAID MODE --------------------------
    ---------------------------------------------------------
    local function raidSpawnNPCs(class, ply, limit)
        local count = 0

        for _, nodePos in pairs(RAIDS.RAIDS_MAP_NODES) do
            if count > limit - 1 then break end
            if nodePos:DistToSqr(ply:GetPos()) <= 512^2 then continue end -- Don't spawn em too close.
            if nodeNearDoor(nodePos) then continue end -- Check if there are any doors nearby, if so fuck off
            if ply:IsLineOfSightClear( nodePos + Vector(0,0,12)) or ply:IsLineOfSightClear( nodePos + Vector(0,0,48)) or ply:IsLineOfSightClear( nodePos + Vector(0,0,72)) then continue end  -- Make sure player can't see enemies spawn
            if countNearbyEnemies(nodePos, math.random(160,256) * RAIDS.RAIDS_NODES_DISTANCE_MULT) > math.random(1,2) then continue end -- Don't spawn too many enemies in one area
        
            local offsetNodePos = findClearSpaceByNode(nodePos)
            setUpEnemy(pluto.inv.roll(class), nodePos, offsetNodePos, ply)

            count = count + 1
        end

        report(ply, count, limit)
    end

    concommand.Add("pluto_raids_begin", function(ply, cmd, args)
        if not pluto.cancheat(ply) then return end

        checkIfMapJustBuiltNodes()
        if(not raids[args[1]]) then
            ply:PrintMessage(HUD_PRINTCONSOLE,"No group selected/Invalid group.")
            return 
        end
        if(not args[2]) then
            ply:PrintMessage(HUD_PRINTCONSOLE,"Valid group, but no amount.")
            return 
        end
        raidSpawnNPCs(raids[args[1]], ply, tonumber(args[2]))
    end) 

    ---------------------------------------------------------
    -------------------- ARENA MODE -------------------------
    ---------------------------------------------------------
    RAIDS.disableArena = RAIDS.disableArena or true
    RAIDS.curMaxEnemiesAllowed =  RAIDS.curMaxEnemiesAllowed or 8
    RAIDS.arenaModeEnemyClass = RAIDS.arenaModeEnemyClass or "npc_combine_s"
    local curEnemiesOnField = 0
    local nextThink = CurTime()
    local samplePly
    local initialArenaMessage = "Assault Started! Max enemies: "
    local arenaUpdateMessage = "Escalation Increased! Max enemies now: "

    util.AddNetworkString("raids_send_arena_escalation_update")
    local function initiateAssault(class, initialMaxNPCS, escalate)
        RAIDS.disableArena = false 
        RAIDS.arenaModeEnemyClass = class
        RAIDS.curMaxEnemiesAllowed = initialMaxNPCS
        print(RAIDS.curMaxEnemiesAllowed )
        
        net.Start("raids_send_arena_escalation_update")
        net.WriteString(initialArenaMessage .. tostring(RAIDS.curMaxEnemiesAllowed))
        net.Broadcast()

        if !escalate then return end
        timer.Create("raids_increase_arena_mode_escalation", 90, -1, function()
            RAIDS.curMaxEnemiesAllowed = RAIDS.curMaxEnemiesAllowed + 1
            net.Start("raids_send_arena_escalation_update")
            net.WriteString(arenaUpdateMessage .. tostring(RAIDS.curMaxEnemiesAllowed))
            net.Broadcast()
        end)
    end

    local function arenaFindNPCSpawn()
        local minDistance 
        local maxDistance 
        local spawn = nil
        local potentialSpawns = {}
        local plyDistancesFromNodes = {}
        local curDist -- For the iterator.
        local plyCurHighestDistFromNode -- For the iterator.

        -- Loop through all players, find their farthest node position, then pick the lowest of the bunch. This way we get a variable min-node distance we can use for spawning later.
        -- If we don't pick the minimum of this set then running distance checks later will fail since some player(s) will always be too close.
        for _, ply in pairs(player.GetAll()) do
            plyDistancesFromNodes[ply:SteamID()] = 0 -- Reset this every time we are looping for a new player, so we don't compare against a cached value for the previous player, this can be a disaster.
            
            for _, node in pairs(RAIDS.RAIDS_MAP_NODES) do
                curDist = node:DistToSqr(ply:GetPos()^2)   
                plyCurHighestDistFromNode = plyDistancesFromNodes[ply:SteamID()] 
                plyDistancesFromNodes[ply:SteamID()] = (curDist  > plyCurHighestDistFromNode) and curDist or plyCurHighestDistFromNode
            end
        end

        -- Find the lowest of samples points.
        maxDistance = table.Random(plyDistancesFromNodes)

        for _, curDist in pairs(plyDistancesFromNodes) do
            maxDistance = (curDist < maxDistance) and curDist or maxDistance
        end

        -- Reduce the dist slightly to ensure we clear on every player.
        maxDistance = maxDistance * 0.99
        minDistance = maxDistance * 0.5

        local plyPos
        -- Find spawn points that are also decently far relative to the furthest spawn
        for _, node in pairs(RAIDS.RAIDS_MAP_NODES) do
            for _, ply in pairs(player.GetAll()) do 
                plyPos = ply:GetPos()
                if node:DistToSqr( plyPos ) < minDistance^2 then continue end -- Will the NPC spawn at a good range?
                if node:DistToSqr( plyPos ) > maxDistance^2 then continue end 
                if ply:IsLineOfSightClear( node ) then continue end         -- Can the player see the NPC spawn here?
                if spawningAtCollidesWithNPC(node) then continue end     -- Will we spawn inside of another NPC if we spawn here?
                
                table.insert(potentialSpawns, node)
            end
        end

        --Pick a random spawn from the potential spawns
        spawn = table.Random(potentialSpawns)

        -- print("Pos: ", spawn)
        return spawn
    end

    hook.Add("Think", "RAIDS Arena Mode Think", function()
        if RAIDS.disableArena then return end
        if nextThink > CurTime() then return end
        nextThink = CurTime() + 1

        for _, npc in ents.Iterator() do
            if not IsValid(npc) or !npc:IsNextBot() or not npc.raidsNPC then continue end
            if npc.checkedForStuck or CurTime() < npc.spawnedTime + 5 then continue end
            npc.checkedForStuck = true
            local distNoZ = math.abs(npc:GetPos().x - npc.spawnedPos.x) + math.abs(npc:GetPos().y - npc.spawnedPos.y) -- ignoring z cause sometimes npcs drop down
            if distNoZ < 64 then
                npc:Remove()
            end
        end

        curEnemiesOnField = 0
        samplePly = table.Random(player.GetAll())
        --Make NPC's seek players at all times
        for _, npc in ents.Iterator() do
            if not IsValid(npc) or not npc:IsNextBot() or not npc.raidsNPC then continue end
            if npc:Disposition( samplePly ) != D_HT then continue end -- If it's not an enemy it's not counted
            curEnemiesOnField = curEnemiesOnField + 1

            if npc:IsLineOfSightClear(npc.targetedPlayer) then continue end
            if IsValid(npc.targetedPlayer) or !npc.targetedPlayer:Alive() then 
                npc.targetedPlayer = table.Random(player.GetAll()) 
            end
            
            npc:UpdateEnemyMemory( npc.targetedPlayer, npc.targetedPlayer:GetPos() )
            npc:SetTarget(npc.targetedPlayer)

            if npc:GetCurrentSchedule() != SCHED_TARGET_CHASE then
                npc:SetSchedule(SCHED_TARGET_CHASE)
            end
        end

        -- add enemies to field
        if curEnemiesOnField < RAIDS.curMaxEnemiesAllowed then
            local pos = arenaFindNPCSpawn()
            if !pos then return end

            setUpEnemy(RAIDS.arenaModeEnemyClass, pos)
        end 
    end)

    hook.Add("PostCleanupMap", "RAIDS Arena Post Cleanup", function() 
        RAIDS.disableArena = true
        curMaxEnemiesAllowed = 8
        if timer.Exists("raids_increase_arena_mode_escalation") then 
            timer.Remove("raids_increase_arena_mode_escalation") 
        end
    end)


    concommand.Add("pluto_zombie_assault", function(ply, cmd, args, argStr)
        if not pluto.cancheat(ply) then return end
        if RAIDS.disableArena == false then
            warnAssaultInProgress(ply)
            return 
        end

        checkIfMapJustBuiltNodes()

        initiateAssault("npc_zombie", tonumber(args[1] or 32), true)
    end)

    concommand.Add("pluto_zombie_assault_noesc", function(ply, cmd, args, argStr)
        if not pluto.cancheat(ply) then return end
        if RAIDS.disableArena == false then
            warnAssaultInProgress(ply)
            return 
        end

        checkIfMapJustBuiltNodes()

        initiateAssault("npc_zombie", tonumber(args[1] or 32), false)
    end)

    util.AddNetworkString("raids_stopped_assault")
    concommand.Add("raids_server_stop_assault", function(ply, cmd, args, argStr)
        if not pluto.cancheat(ply) then return end

        for _, npc in ents.Iterator() do
            if not npc.raidsNPC then continue end
            npc:Remove()
        end

        if timer.Exists("raids_increase_arena_mode_escalation") then 
            timer.Remove("raids_increase_arena_mode_escalation") 
        end

        net.Start("raids_stopped_assault")
        net.Broadcast()
        
        RAIDS.disableArena = true
    end)

    concommand.Add ( "raids_stop_assault", function(ply, cmd, args, argStr) 
        ply:ConCommand("raids_server_stop_assault")
    end)
end

if CLIENT then
    net.Receive("raids_send_arena_escalation_update", function()
        chat.AddText( Color(148,252,52), "RAIDS: " .. net.ReadString())
    end)

    net.Receive("raids_stopped_assault", function()
        chat.AddText( Color(148,252,52), "RAIDS: Assault stopped!")
    end)

    net.Receive("raids_send_raid_update", function()
        chat.AddText( Color(148,252,52), "RAIDS: " .. net.ReadUInt(8) .. " more combatants have appeared!")
    end)
end