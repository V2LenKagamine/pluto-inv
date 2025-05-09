if not SERVER then return end


-- Localize Libaries & Functions --


local CreateConVar = CreateConVar
local CurTime = CurTime
local IsValid = IsValid
local MMin = math.min
local MClamp = math.Clamp
local MFloor = math.floor
local ETickInterval = engine.TickInterval
local HAdd = hook.Add
local UltrakillBase = UltrakillBase



-- ConVars --


local cvHealingEnabled = CreateConVar( "drg_ultrakill_healing", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enables Healing" )
local cvHealingMax = CreateConVar( "drg_ultrakill_healing_maxheal", 25, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Set the Maximum amount of Health that can be healed in one shot." )
local cvHealingRange = CreateConVar( "drg_ultrakill_healing_range", 200, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Set Range required to gain health." )

local cvUltrakillOnly = CreateConVar( "drg_ultrakill_healing_ultrakillonly", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Should Healing only be considered for Ultrakill Nextbots." )

local cvHardDamageEnabled = CreateConVar( "drg_ultrakill_healing_harddamage", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enables Hard Damage." )
local cvHardDamageMult = CreateConVar( "drg_ultrakill_healing_harddamage_multiplier", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Multiplies the amount of Hard Damage you receive." )
local cvHardDamageRecoveryMult = CreateConVar( "drg_ultrakill_healing_harddamage_recovery_multiplier",1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Multiplies the amount of Hard Damage you receive." )
local cvHardDamageEnforce = CreateConVar( "drg_ultrakill_healing_harddamage_enforce", 0, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enforces Hard Damage. May cause issues with other addons." )


-- Hard Damage Helpers --


function UltrakillBase.SetHardDamage( mPlayer, fDamage, fTime )

    local iDifficulty = UltrakillBase.GetDifficulty()
    local fDelay = 1

    if iDifficulty <= 2 then

        fDelay = 1

    elseif iDifficulty == 3 then

        fDelay = 2

    else

        fDelay = 2.5

    end

    fTime = fTime or MMin( ( fDelay + fDamage * 0.1 ) / cvHardDamageRecoveryMult:GetFloat(), 5 )

    mPlayer:SetNW2Int( "UltrakillBase_HardDamage", MClamp( fDamage, 0, mPlayer:GetMaxHealth() - 1 ) )

    if fTime > 0 then mPlayer:SetNW2Float( "UltrakillBase_HardDamage_Time", CurTime() + fTime ) end

    return fTime

end


function UltrakillBase.GetHardDamage( mPlayer )

    return mPlayer:GetNW2Int( "UltrakillBase_HardDamage", 0 ), mPlayer:GetNW2Float( "UltrakillBase_HardDamage_Time", 0 ) - CurTime()

end


local SetHardDamage = UltrakillBase.SetHardDamage
local GetHardDamage = UltrakillBase.GetHardDamage


-- Healing Helpers --


local function ReverseScaleDamage( mEntity, mPlayer )

    if not IsValid( mEntity ) and mPlayer:IsPlayer() or not mEntity.IsUltrakillNextbot then return 1 end

    return UltrakillBase.ConVar_PlyDmgMult:GetFloat() * 10

end


local function IsHealingAllowed( mEntity )

    if not cvHealingEnabled:GetBool() or cvUltrakillOnly:GetBool() and not mEntity.IsUltrakillNextbot then return false end
    if mEntity.IsUltrakillBase and mEntity:IsSand() then return false end

    return true

end


local function IsInRange( mEntity1, mEntity2, fRange )

    return mEntity1:WorldSpaceCenter():DistToSqr( mEntity2:WorldSpaceCenter() ) <= fRange * fRange

end


-- Hook Helpers --


local function TakeDamageToHealing( mEntity, CDamageInfo, bTook )

    local mPlayer = CDamageInfo:GetAttacker()

    if not IsHealingAllowed( mEntity ) then return end
    if not bTook or not IsValid( mPlayer ) or not mPlayer:IsPlayer() or mPlayer == mEntity then return end
    if not mEntity:IsNPC() and not mEntity:IsPlayer() and not mEntity:IsNextBot() then return end
    if not IsInRange( mPlayer, mEntity, cvHealingRange:GetFloat() + mEntity:BoundingRadius() * 0.75 ) then return end

    local fHP = mPlayer:Health()
    local fHealingPerDamage = MMin( CDamageInfo:GetDamage() / ReverseScaleDamage( mEntity, mPlayer ), cvHealingMax:GetInt() )
    local fMaxHP = mPlayer:GetMaxHealth()
    local fHardDamage = GetHardDamage( mPlayer )

    mPlayer:SetHealth( fHP < fMaxHP and MClamp( fHP + fHealingPerDamage, 0, fMaxHP - fHardDamage ) or fHP )

    UltrakillBase.SoundScript( "Ultrakill_HP", mPlayer:GetPos(), mPlayer )

end


local function AddHardDamage( mPlayer, mAttacker, fRemaining, fTaken )

    if not cvHardDamageEnabled:GetBool() or MFloor( fRemaining + fTaken ) > mPlayer:GetMaxHealth() or fTaken <= 0 or mAttacker == mPlayer then return end
    if not IsValid( mAttacker ) or ( cvUltrakillOnly:GetBool() and not mAttacker.IsUltrakillNextbot and not mAttacker.IsUltrakillProjectile ) then return end

    local iDifficulty = UltrakillBase.GetDifficulty()
    local fDelay = 1
    local fPercentage = 1

    if iDifficulty <= 2 then

        fDelay = 1
        fPercentage = iDifficulty == 2 and 0.35 or 0

    elseif iDifficulty == 3 then

        fDelay = 2
        fPercentage = 0.35

    else

        fDelay = 2.5
        fPercentage = 0.5

    end
    
    local fHardDamage = fTaken * fPercentage * cvHardDamageMult:GetFloat()
    local fTime = MClamp( fTaken * 0.05 + fDelay, 0, 5 ) / cvHardDamageRecoveryMult:GetFloat()
    local fPrevHardDamage = GetHardDamage( mPlayer )

    SetHardDamage( mPlayer, fPrevHardDamage + fHardDamage, fTime )

end


local function UpdateHardDamage( mPlayer )

    local fHardDamage, fHardDamageTime = GetHardDamage( mPlayer )
    local fHP, fMaxHP = mPlayer:Health(), mPlayer:GetMaxHealth()
    local bEnforce = cvHardDamageEnforce:GetBool()
    local fTickRate = ETickInterval()

    if fHardDamage <= 0 then return end
    if fHardDamage > 0 and fHP > fMaxHP - fHardDamage and bEnforce then mPlayer:SetHealth( fMaxHP - fHardDamage ) end -- Enforce Hard Damage!
    if not mPlayer:Alive() then SetHardDamage( mPlayer, 0, 0 ) end
    if fHardDamageTime <= 0 then SetHardDamage( mPlayer, fHardDamage - 14 * fTickRate, 0 ) end

end


-- Hooks --


HAdd( "PostEntityTakeDamage", "UltrakillBase_Healing", TakeDamageToHealing )
HAdd( "PlayerHurt", "UltrakillBase_AddHardDamage", AddHardDamage )
HAdd( "PlayerPostThink", "UltrakillBase_UpdateHardDamage", UpdateHardDamage )