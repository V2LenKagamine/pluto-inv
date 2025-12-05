AddCSLuaFile()

if SERVER then
    pluto.RAIDS = pluto.RAIDS or {}
    pluto.RAIDS.RAIDS_MAP_NODES = pluto.RAIDS.RAIDS_MAP_NODES or {}
    pluto.RAIDS.RAIDS_NODES_DISTANCE_MULT = pluto.RAIDS.RAIDS_NODES_DISTANCE_MULT or 2
    pluto_noraids = CreateConVar("pluto_disable_raids","0",FCVAR_ARCHIVE,nil,0,1)

    local AINET_VERSION_NUMBER = 37

    hook.Add("Initialize", "raids_load_map_nodes", function()
        pluto.RAIDS.RAIDS_MAP_NODES = table.Copy(pluto.currency.cached_positions) or {}
        pluto.RAIDS.RAIDS_NODES_DISTANCE_MULT = 2
    end)

    ---------------------------------------------------------
    ---------------------- GENERAL --------------------------
    ---------------------------------------------------------
    local raids ={
        zombies = {
            name = "Undead",
            nameColor = Color(0,114,0),
            enemy_mul = 3,
            Shares = 49,
            enemies = {
                ["drg_roach_dr1_em00"] = 85,
                ["drg_roach_dr1_em43"] = 5,
                ["drg_kfmod_husk"] = 10,
            },
        },
        soldiers = {
            name = "Hostile Military Forces",
            nameColor = Color(0,93,146),
            enemy_mul = 1,
            Shares = 49,
            enemies = {
                ["bwaaf_commander"] = 1,
                ["bwaaf_grenadier"] = 12,
                ["bwaaf_machinegunner"] = 12,
                ["bwaaf_medic"] = 12,
                ["bwaaf_shield"] = 2,
                ["bwaaf_sniper"] = 12,
                ["bwaaf_soldier"] = 12,
                ["bwaaf_stealth"] = 12,
                ["bwacc_patrol"] = 12,
                ["bwacc_riot"] = 12,
            },
        },
        hellisfull = {
            name = "MANKIND IS DEAD.\nBLOOD IS FUEL.\nHELL IS FULL.",
            nameColor = Color(119,0,0),
            enemy_mul = 2,
            Shares = 2,
            enemies = {
                ["ultrakill_filth"] = 30,
                ["ultrakill_stray"] = 20,
                ["ultrakill_schism"] = 20,
                ["ultrakill_soldier"] = 15,
                ["ultrakill_drone"] = 15,
                ["ultrakill_streetcleaner"] = 10,
                ["ultrakill_maliciousface_normal"] = 3,
                ["ultrakill_cerberus_normal"] = 3,
                ["ultrakill_swordsmachine_normal"] = 1,
            },
        },
    }

    local function checkIfMapJustBuiltNodes()
        if table.IsEmpty(pluto.RAIDS.RAIDS_MAP_NODES) and not table.IsEmpty(pluto.currency.cached_positions) then 
            pluto.RAIDS.RAIDS_MAP_NODES = table.Copy(pluto.currency.cached_positions)
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
        local victm = table.Random(#pluto.RAIDS.alivePlayers>0 and pluto.RAIDS.alivePlayers or ttt.GetEligiblePlayers()[math.random(#ttt.GetEligiblePlayers())])
        npc.targetedPlayer = victm
        npc.spawnedPos = pos
        npc.spawnedTime = CurTime()
        npc:JoinFaction("FACTION_RAID")
        if(class == "drg_roach_dr1_em00" or class == "drg_roach_dr1_em43" or class == "drg_kfmod_husk") then
            npc:SetOmniscient(true) --they s m e l l you.
        end

        -- Non arena code follows       
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
            local direction = (ply:GetPos() - npc:GetPos()):GetNormalized()
            local angle = direction:Angle() 
            angle.p = 0
            npc:SetAngles(angle)
        end)
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

        for _, nodePos in pairs(pluto.RAIDS.RAIDS_MAP_NODES) do
            if count > limit - 1 then break end
            if nodePos:DistToSqr(ply:GetPos()) <= 512^2 then continue end -- Don't spawn em too close.
            if nodeNearDoor(nodePos) then continue end -- Check if there are any doors nearby, if so fuck off
            if ply:IsLineOfSightClear( nodePos + Vector(0,0,12)) or ply:IsLineOfSightClear( nodePos + Vector(0,0,48)) or ply:IsLineOfSightClear( nodePos + Vector(0,0,72)) then continue end  -- Make sure player can't see enemies spawn
            if countNearbyEnemies(nodePos, math.random(160,256) * pluto.RAIDS.RAIDS_NODES_DISTANCE_MULT) > math.random(1,2) then continue end -- Don't spawn too many enemies in one area
        
            local offsetNodePos = findClearSpaceByNode(nodePos)
            setUpEnemy(pluto.inv.roll(class.enemies), nodePos, offsetNodePos, ply)

            count = count + 1
        end
    end

    concommand.Add("pluto_raids_begin", function(ply, cmd, args)
        if not pluto.cancheat(ply) then return end

        checkIfMapJustBuiltNodes()
        if(not raids[args[1]]) then
            ply:ChatPrint("No group selected/Invalid group.")
            return 
        end
        if(not args[2]) then
            ply:ChatPrint("Valid group, but no amount.")
            return 
        end
        raidSpawnNPCs(raids[args[1]], ply, tonumber(args[2]))
    end) 

    ---------------------------------------------------------
    -------------------- ARENA MODE -------------------------
    ---------------------------------------------------------
    local DefaultRaidLevel = 1
    local MaxRaidPlayers = 8
    pluto.RAIDS.disableArena = pluto.RAIDS.disableArena or true
    pluto.RAIDS.raidLevel =  pluto.RAIDS.raidLevel or DefaultRaidLevel
    pluto.RAIDS.arenaModeEnemyClass = pluto.RAIDS.arenaModeEnemyClass or raids["zombies"]
    pluto.RAIDS.alivePlayers = pluto.RAIDS.alivePlayers or {}
    pluto.RAIDS.allowDuringRound = false
    pluto.RAIDS.raidScores = pluto.RAIDS.raidScores or {}
    pluto.RAIDS.raidVotes = pluto.RAIDS.raidVotes or {}

    pluto.RAIDS.currentGM = CreateConVar("pluto_current_gamemode","raid",FCVAR_ARCHIVE,"What gamemode is being ran ATM?")

    local curEnemiesOnField = 0
    local killcount = 0
    local nextThink = CurTime()
    local raidColor = Color(255,174,0)
    local DiffColor = Color(255,0,0)
    local text_white = Color(255,255,255)

    function pluto.RAIDS.pcall_(fn, ...)
        local s, e = xpcall(fn, debug.traceback, ...)
    
        if (not s) then
            printf("Error: %s", e)
        end
    end

    function pluto.RAIDS.DoRaidEnd(dontanother,win)
        killcount = 0
        dontanother = dontanother or false
        win = win or false 
        pluto.RAIDS.disableArena = true
        local stay =  {}
        pluto.RAIDS.pcall_(hook.Run,"TTTAddPermanentEntities",stay)
        game.CleanUpMap(false,stay)
        for _, npc in ents.Iterator() do
            if not npc.raidsNPC then continue end
            npc:Remove()
        end
        if(table.Count(pluto.RAIDS.raidScores) > 0) then
            for _,plor in ipairs(player.GetAll()) do
                plor:ChatPrint(raidColor,"Top 3 Player Scores this raid: ")
            end
            local colors = {
                [1] = Color(233,217,0),
                [2] = Color(173,173,173),
                [3] = Color(214,121,0),
            }
            local idx = 1
            for ply,score in SortedPairsByValue(pluto.RAIDS.raidScores,true) do
                for _,plee in ipairs(player.GetAll()) do
                    if(not IsValid(ply)) then continue end
                    plee:ChatPrint(colors[idx],string.format("    %s : %.02f",ply:Nick(),score))
                end
                idx = idx + 1
                if(idx > 3) then break end
            end
        end
        if(win) then
            for _,plon in ipairs(ttt.GetEligiblePlayers()) do
                for ind = 1,5 do
                    pluto.inv.endrounddrops(plon)
                end
                for ind = 1,math.random(8,12) do
                    pluto.currency.spawnfor(plon)
                end
                plon:ChatPrint(Color(233,217,0),"You are showered in riches for defeating the raid!")
            end
        end
        if(not dontanother) then
            for _,ply in ipairs(ttt.GetEligiblePlayers()) do
                pluto.RAIDS.RaidRespawn(ply)
                ply:ChatPrint(raidColor,"A new raid will begin shortly...")
            end
        end
    end

    
    function pluto.RAIDS.RaidRespawn(ply)
        --TODO: check if player is spectating someone, then make them un-spectate
        if(not ply:Alive()) then
            ply:Spawn()
        end
        for i = 1, 6 do
            local wepid = tonumber(ply:GetInfo("pluto_loadout_slot" .. i, nil))
            local wep = pluto.itemids[wepid]
            if (wep and wep.Owner == ply:SteamID64()) then
                pluto.NextWeaponSpawn = wep
                ply:Give(wep.ClassName)
            end
        end
    end

    function pluto.RAIDS.CheckVotes()
        local activePlrs = #ttt.GetEligiblePlayers()
        local oldMode = pluto.RAIDS.currentGM:GetString()
        if(not table.IsEmpty(pluto.RAIDS.raidVotes)) then
            local raidVotes = 0
            local tttVotes = 0
            for ply,vote in pairs(pluto.RAIDS.raidVotes) do
                if(not IsValid(ply)) then continue end
                if(vote == "raid") then
                    raidVotes = raidVotes + 1
                elseif(vote == "ttt") then
                   tttVotes = tttVotes + 1 
                end
            end
            if(raidVotes>0 and raidVotes / activePlrs >= 0.6) then
                pluto.RAIDS.currentGM:SetString("raid")
            elseif(tttVotes>0 and tttVotes / activePlrs >= 0.6) then
                pluto.RAIDS.currentGM:SetString("ttt")
            end
            for _,plr in ipairs(player.GetAll()) do
                plr:ChatPrint("There are now ",raidColor,raidVotes .. " RAIDS ",text_white,"votes and ",DiffColor,tttVotes .. " TTT ",text_white,"votes.")
                if(not pluto.RAIDS.raidVotes[plr]) then
                    plr:ChatPrint("You can vote with '!votegm' and 'ttt' or 'raid'.")
                end
            end
        end
        if(activePlrs > MaxRaidPlayers) then
            pluto.RAIDS.currentGM:SetString("ttt")
        --elseif(activePlrs < GetConVar("ttt_minimum_players"):GetInt()) then
            --pluto.RAIDS.currentGM:SetString("raid")
        end
        if(pluto.RAIDS.currentGM:GetString() ~= oldMode) then
            for _,plr in ipairs(player.GetAll()) do
                plr:ChatPrint("The gamemode has been changed! New gamemode: ",pluto.RAIDS.currentGM:GetString() == "raid" and "Raids!" or "TTT!")
            end
            if(pluto.RAIDS.currentGM:GetString() == "ttt") then
                if(activePlrs < GetConVar("ttt_minimum_players"):GetInt()) then
                    for _,plr in ipairs(player.GetAll()) do
                        plr:ChatPrint("...But nobody came.")
                        pluto.RAIDS.DoRaidEnd(true,false)
                    end
                else
                    round.Prepare()
                end
            end
        end
    end

    hook.Add("PlayerSay","pluto_raids_vote",function(plr,text,tc)
        if(text:match("^[!%./]?votegm")) then
            if(text:match("[rR][aA][iI][dD][sS]?$")) then
                pluto.RAIDS.raidVotes[plr] = "raid"
                plr:ChatPrint("You have voted to play: ", raidColor, "RAIDS")
            elseif (text:match("([tT])%1%1$")) then
                pluto.RAIDS.raidVotes[plr] = "ttt"
                plr:ChatPrint("You have voted to play: ", DiffColor, "TTT")
            end
            pluto.RAIDS.CheckVotes()
            return ""
        end
    end)

    local function initiateAssault(class, raidLevel, escalate)
        if(not pluto.RAIDS.allowDuringRound and ((ttt.GetRoundState() ~= ttt.ROUNDSTATE_WAITING or ttt.GetRoundState() ~= ttt.ROUNDSTATE_PREPARING) and pluto.RAIDS.currentGM:GetString() == "ttt")) then 
            pluto.warn("You cant start a raid during rounds without setting pluto.RAIDS.allowDuringRound to true!")
            return 
        end
        if(pluto_noraids:GetBool()) then
            pluto.warn("Tried to start a raid with raids disabled!")
            return 
        end
        pluto.RAIDS.disableArena = false 
        pluto.RAIDS.arenaModeEnemyClass = class
        pluto.RAIDS.raidLevel = raidLevel or DefaultRaidLevel
        pluto.RAIDS.alivePlayers = {}
        pluto.RAIDS.raidScores = {}
        killcount = 0

        checkIfMapJustBuiltNodes()

        for idx,pla in ipairs(ttt.GetEligiblePlayers()) do
            pluto.RAIDS.RaidRespawn(pla)
            table.insert(pluto.RAIDS.alivePlayers,idx,pla)
        end
        if(not pluto.RAIDS.arenaModeEnemyClass) then
            pluto.error("Invalid enemy type in initateAssault !!!")
            pluto.RAIDS.disableArena = true 
            return 
        end
        nextThink = CurTime() + 10 --Give everyone a chance to respawn

        
        for _,plot in ipairs(player.GetAll()) do
            plot:ChatPrint(raidColor,"A raid is begining! Difficulty: ",DiffColor, pluto.RAIDS.raidLevel,raidColor, "; You will be fighting: ",pluto.RAIDS.arenaModeEnemyClass.nameColor or raidColor,pluto.RAIDS.arenaModeEnemyClass.name or "Something!")
        end
    end

    local function arenaFindNPCSpawn()
        if(#pluto.RAIDS.alivePlayers<=0 or not pluto.RAIDS.RAIDS_MAP_NODES) then return end
        local minDistance 
        local maxDistance 
        local spawn = nil
        local potentialSpawns = {}
        local plyDistancesFromNodes = {}
        local curDist -- For the iterator.
        local plyCurHighestDistFromNode -- For the iterator.

        local samplednodes = {}

        for _, ply in ipairs(pluto.RAIDS.alivePlayers) do
            if(ply:IsBot()) then continue end
            plyDistancesFromNodes[ply:SteamID()] = 0 -- Reset this every time we are looping for a new player, so we don't compare against a cached value for the previous player, this can be a disaster.
            
            for _,nodePos in pairs(pluto.RAIDS.RAIDS_MAP_NODES) do
                if(not nodePos) then break end
                table.insert(samplednodes,#samplednodes+1,nodePos)
                curDist = nodePos:DistToSqr(ply:GetPos())   
                plyCurHighestDistFromNode = plyDistancesFromNodes[ply:SteamID()] 
                plyDistancesFromNodes[ply:SteamID()] = (curDist  > plyCurHighestDistFromNode) and curDist or plyCurHighestDistFromNode
                if (#samplednodes >= 75) then break end
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
        for _, node in ipairs(samplednodes) do
            for _, ply in ipairs(pluto.RAIDS.alivePlayers) do 
                plyPos = ply:GetPos()
                local dist = node:DistToSqr(plyPos)
                if  dist < minDistance or dist > maxDistance then continue end -- min and max distance are already squared so
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

    function pluto.RAIDS.RaidThink()
        if(pluto_noraids:GetBool() or pluto.RAIDS.currentGM:GetString() ~= "raid") then return end
        if nextThink > CurTime() then return end
        if pluto.RAIDS.disableArena then 
            if (pluto.RAIDS.currentGM:GetString() == "raid" and #ttt.GetEligiblePlayers() > 0) then
                timer.Simple(16,function()
                    if(pluto.RAIDS.disableArena) then
                        initiateAssault(raids[pluto.inv.roll(raids)], DefaultRaidLevel, true)
                    end
                end)
                nextThink = CurTime() + 15 --Give a little for joiners on mapchange/join
            else
                nextThink = CurTime() + 30
            end
            return 
        end
        if(not pluto.RAIDS.arenaModeEnemyClass) then
            pluto.error("RAIDS: No enemy class! Ending raid...")
            pluto.RAIDS.DoRaidEnd()
            return 
        end
        nextThink = CurTime() + 1
        if(not pluto.RAIDS.allowDuringRound and (pluto.RAIDS.currentGM:GetString() == "ttt")) then
            for _,ply in ipairs(player.GetAll()) do
                ply:ChatPrint(raidColor,"The Gamemode is changing! Force ending raid...")
            end
            pluto.RAIDS.DoRaidEnd(true)
            return
        end
        if(pluto.RAIDS.raidLevel > 10) then
            for _,ply in ipairs(player.GetAll()) do
                ply:ChatPrint(raidColor,"The raid has been repelled!!!")
            end
            pluto.RAIDS.DoRaidEnd(false,true)
        end
        pluto.RAIDS.alivePlayers = {}
        for _,ply in ipairs(ttt.GetEligiblePlayers()) do
            if(ply:Alive()) then table.insert(pluto.RAIDS.alivePlayers,#pluto.RAIDS.alivePlayers+1,ply) end
        end
        if(#pluto.RAIDS.alivePlayers <= 0) then
            for _,ply in ipairs(player.GetAll()) do
                ply:ChatPrint(Color(255,115,0),"All players have perished! Ending raid...")
            end
            pluto.RAIDS.DoRaidEnd()
            return 
        end
        curEnemiesOnField = 0
        for _, npc in ents.Iterator() do
            if (not IsValid(npc) or not npc:IsNextBot() or not npc.raidsNPC or not npc:Alive()) then continue end
            if (not npc.checkedForStuck and CurTime() > npc.spawnedTime + 5) then
                npc.checkedForStuck = true
                local distNoZ = math.abs(npc:GetPos().x - npc.spawnedPos.x) + math.abs(npc:GetPos().y - npc.spawnedPos.y) -- ignoring z cause sometimes npcs drop down
                if distNoZ < 64 then
                    npc:Remove()
                end
            end
            curEnemiesOnField = curEnemiesOnField + 1
        end

        -- add enemies to field
        -- maxen = diff * enemymul * (1 + 0.15 per player over 1)
        local maxen = math.floor(pluto.RAIDS.raidLevel * (pluto.RAIDS.arenaModeEnemyClass.enemy_mul or 1)*(1+((#ttt.GetEligiblePlayers()-1) * 0.15)))
        if (curEnemiesOnField < maxen) then
            for idx = 1, (pluto.RAIDS.arenaModeEnemyClass.enemy_mul or 1) do
                local pos = arenaFindNPCSpawn()
                if (not pos) then continue end
                setUpEnemy(pluto.inv.roll(pluto.RAIDS.arenaModeEnemyClass.enemies), pos)
            end
        end
    end

    hook.Add("Think", "pluto_RAIDS_think", pluto.RAIDS.RaidThink)

    local function TryAddExp(ply,points)
        local wep = ply:GetActiveWeapon()
        if(wep.PlutoGun and wep.PlutoGun.Owner == wep:GetOwner():SteamID64()) then
            pluto.inv.addexperience(wep.PlutoGun.RowID,math.floor(points/4))
        end
    end

    hook.Add("OnNPCKilled","pluto_raids_kill_listen",function (npc,atk,inf)
        if(not npc.raidsNPC or not atk:IsPlayer()) then return end
        local multi = pluto.RAIDS.arenaModeEnemyClass.enemy_mul or 1
        local points = npc:GetMaxHealth()/(10*multi) * (1+((pluto.RAIDS.raidLevel-1) * (0.15/multi))) --Higher round -> more points.
        TryAddExp(atk,points)
        pluto.RAIDS.raidScores[atk] = (pluto.RAIDS.raidScores[atk] or 0) + points
        killcount = (killcount or 0) + 1
        if(killcount >= pluto.RAIDS.raidLevel*multi) then
            pluto.RAIDS.raidLevel = pluto.RAIDS.raidLevel + 1
            for _,plee in ipairs(player.GetAll()) do
                plee:ChatPrint(Color(255,230,0),"RAID ANTE-UP! Difficulty now: ",DiffColor, pluto.RAIDS.raidLevel)
                if(pluto.RAIDS.raidLevel == 4 or pluto.RAIDS.raidLevel == 7 or pluto.RAIDS.raidLevel == 9) then
                    plee:ChatPrint(Color(90,201,0),"You have been awarded endround drop chances for your efforts...")
                    pluto.inv.endrounddrops(plee)
                end
            end
            killcount = 0
        end
        if(math.random() < math.min(0.3,points/85)) then
            atk:ChatPrint(Color(145,255,0),"You feel something resonate...")
            pluto.currency.spawnfor(atk)
        end
        if(math.random() < math.min(0.15,points/150)) then
            atk:ChatPrint(Color(90,201,0),"You rummage around, hoping to find some supplies...")
            pluto.inv.endrounddrops(atk)
        end
        if(math.random() <= (0.4/multi)) then
            atk:ChatPrint(Color(0,255,0),"You feel your wounds begin to stitch shut...")
            pluto.statuses.byname["heal_flat"]:AddStatus(atk,_,20,10)
        end
        if(math.random() <= 0.7) then
            local wep = atk:GetActiveWeapon()
            if (IsValid(wep)) then
                local orig = baseclass.Get(wep:GetClass())
                atk:GiveAmmo(math.floor(orig.Primary.ClipSize),orig.Primary.Ammo,true)
            end
        end --TODO: Clean NPC body after a time
    end)

    hook.Add("DoPlayerDeath", "pluto_raids_death",function(ply,atk,dmg)
        if(pluto.RAIDS.disableArena) then return end
        for _,plr in ipairs(player.GetAll()) do
            plr:ChatPrint(Color(255,0,0),"RAIDS: " .. ply:Nick() .. " has fallen to the onslaught!")
        end
        pluto.RAIDS.raidScores[ply] = math.max((pluto.RAIDS.raidScores[ply] or 0)-25,0)
        if(pluto.RAIDS.raidScores[ply] >= 125 and #pluto.RAIDS.alivePlayers > 1) then -- They had 150 and wern't last.
            ply:ChatPrint(Color(0,255,0),"You will auto-revive in 5 seconds due to your score!")
            timer.Simple(5,function()
                pluto.RAIDS.RaidRespawn(ply)
                pluto.RAIDS.raidScores[ply] = math.max((pluto.RAIDS.raidScores[ply] or 0) - 125,0)
                for _,plr in ipairs(player.GetAll()) do
                    plr:ChatPrint(Color(125,255,0),"RAIDS: " .. ply:Nick() .. " has returned to the fray through sheer will!")
                end
            end)
        end
    end)

    hook.Add("PostCleanupMap", "RAIDS_Arena_Post_Cleanup", function() 
        pluto.RAIDS.disableArena = true
        curMaxEnemiesAllowed = DefaultRaidLevel
    end)


    concommand.Add("pluto_raids_begin_assault", function(ply, cmd, args)
        if not pluto.cancheat(ply) then return end

        checkIfMapJustBuiltNodes()

        if(not raids[args[1]]) then
            ply:ChatPrint("No/Invalid Group.")
            return 
        end

        if(not args[2]) then
            ply:ChatPrint("No starting difficulty.")
            return 
        end

        initiateAssault(raids[args[1]], tonumber(args[2]), args[3] or true)
    end)

    concommand.Add("pluto_raids_stop_assault", function(ply, cmd, args, argStr)
        if not pluto.cancheat(ply) then return end

        pluto.RAIDS.DoRaidEnd(true)

        pluto.RAIDS.disableArena = true
    end)
end