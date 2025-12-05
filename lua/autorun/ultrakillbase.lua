local FExists = file.Exists
local include = include
local AddCSLuaFile = AddCSLuaFile
local CreateClientConVar = CreateClientConVar
local SIsLinux = system.IsLinux
local SIsOSX = system.IsOSX
local TSimple = timer.Simple
local ETickInterval = engine.TickInterval
local unpack = unpack
local IsValid = IsValid
local isentity = isentity
local isvector = isvector
local GetConVar = GetConVar
local MMin = math.min
local NStart = net.Start
local NWriteUInt = net.WriteUInt
local NWriteBool = net.WriteBool
local NSend = SERVER and net.Send
local Color = Color
local GSinglePlayer = game.SinglePlayer
local net = net
local isstring = isstring
local isfunction = isfunction
local ipairs = ipairs
local tostring = tostring
local ScrH = ScrH
local ScrW = ScrW
local LAdd = CLIENT and language.Add
local CreateConVar = CreateConVar
local SCreateFont = CLIENT and surface.CreateFont
local HAdd = hook.Add
local select = select
local FFind = file.Find
local TMerge = table.Merge
local pairs = pairs
local UPrecacheModel = util.PrecacheModel
local SMAddToolMenuOption = CLIENT and spawnmenu.AddToolMenuOption
local UScreenShake = util.ScreenShake
local LocalPlayer = LocalPlayer


if not FExists( "autorun/drgbase.lua", "LUA" ) then return end


if not DrGBase then

    include( "drgbase.lua" )
    AddCSLuaFile( "drgbase.lua" )

end


local CompatibilityConVar = CreateClientConVar( "drg_ultrakill_force_compatibility", 0, true, false, "Force Compability with OSX and Linux." )


UltrakillBase = UltrakillBase or {}
UltrakillBase.CompatibilityMode = SIsLinux() or SIsOSX() or CompatibilityConVar:GetBool()


HAdd( "RenderScene", "UltrakillBase_Render_Info", function( vOrigin, aAngles )

    UltrakillBase.EyePos = vOrigin
    UltrakillBase.EyeAngles = aAngles
    UltrakillBase.EyeNormal = aAngles:Forward()

end )


function UltrakillBase.DelayNextTick( Function, ... )

    local Args = { ... }

    TSimple( ETickInterval(), function()

      return Function( unpack( Args ) )

    end )

end


function UltrakillBase.GetEntityEyePos( Ent )

    if not IsValid( Ent ) or not isentity( Ent ) then return end

    local EntUp = Ent:GetUp()

    local Pos = Ent:EyePos() - ( EntUp * 10 * Ent:GetModelScale() )

    if not isvector( Pos ) then

      return Ent:WorldSpaceCenter()

    end

    return Pos

end


function UltrakillBase.CanAttack( EntToAttack )

    if not DrGBase.CanAttack( EntToAttack ) then return false end
    if UltrakillBase.CheckIFrames( EntToAttack ) then return false end
    if EntToAttack:IsPlayer() and ( EntToAttack:HasGodMode() or EntToAttack.Dashing ) or EntToAttack.IsDrGNextbot and EntToAttack:GetGodMode() then return false end

    return true

end


UltrakillBase.UltrakillMechanicsInstalled = FExists( "autorun/sh_ultrakill_ability.lua", "LUA" )


local function RefreshStamina( Ply )

    local MaxStamina = GetConVar( "ultrakill_max_stamina" ):GetInt()
    local Stamina = Ply:GetNW2Int( "AbilityStamina" )

    if Stamina >= MaxStamina then return end

    Ply:SetNW2Int( "AbilityStamina", MMin( Stamina + 3, MaxStamina ) ) -- Cap Stamina Parry Regen at 3!
    Ply.StaminaRegenTime = nil

    NStart( "ULTRAKILL_UpdateStaminaCount" )

        NWriteUInt( Ply:GetNW2Int( "AbilityStamina", MaxStamina ), 31 )
        NWriteBool( false )

    NSend( Ply )

end


function UltrakillBase.OnParryPlayer( Ply )

    if UltrakillBase.UltrakillMechanicsInstalled then

        RefreshStamina( Ply )

    end

    local HP, MaxHP = Ply:Health(), Ply:GetMaxHealth()
    local HardDamage = UltrakillBase.GetHardDamage( Ply )
    local Healing = HP < MaxHP and MaxHP - HardDamage or HP

    Ply:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 40 ), 0.1, 0.25 )
    Ply:SetHealth( Healing )
    UScreenShake( Ply:GetPos(), 50, 1, 0.3, 10, true )

    UltrakillBase.SoundScript( "Ultrakill_HP", Ply:GetPos(), Ply )

end


if SERVER then

    function UltrakillBase.CallOnClient( Function, ... )

        if not GSinglePlayer() then

            UltrakillBase.DelayNextTick( net.DrG_Send, "UltrakillBase_CallOnClient", Function, ... )

        else

            net.DrG_Send( "UltrakillBase_CallOnClient", Function, ... )

        end

    end

else

    function UltrakillBase.CallOnClient( Function, ... )

        if not isstring( Function ) or not isfunction( UltrakillBase[ Function ] ) then return end

        UltrakillBase[ Function ]( ... )

    end


    net.DrG_Receive( "UltrakillBase_CallOnClient", function( Function, ... )

        if not GSinglePlayer() then

            UltrakillBase.DelayNextTick( UltrakillBase.CallOnClient, Function, ... )

        else

            UltrakillBase.CallOnClient( Function, ... )

        end

    end )

end


function UltrakillBase.ScreenAverage()

    return ( ScrH() + ScrW() ) * 0.5

end


function UltrakillBase.ScreenAverageClamped()

    return UltrakillBase.ScreenAverage()

end


    -- PlaceHolder --


if CLIENT then

    LAdd( "ultrakill.minosprime.boss", "MINOS PRIME" )
    LAdd( "ultrakill.sisyphusprime.boss", "SISYPHUS PRIME" )
    LAdd( "ultrakill.gabriel.boss", "GABRIEL, JUDGE OF HELL" )
    LAdd( "ultrakill.swordsmachine.boss", "SWORDSMACHINE" )
    LAdd( "ultrakill.swordsmachine.tundra.boss", "SWORDSMACHINE \"TUNDRA\"" )
    LAdd( "ultrakill.swordsmachine.agony.boss", "SWORDSMACHINE \"AGONY\"" )
    LAdd( "ultrakill.maliciousface.boss", "MALICIOUS FACE" )
    LAdd( "ultrakill.cerberus.boss", "CERBERUS, GUARDIAN OF HELL" )
    LAdd( "ultrakill.mass.boss", "HIDEOUS MASS" )

end


    -- AutoRun --


DrGBase.IncludeFolder( "ultrakillbase/modules" )
DrGBase.IncludeFolder( "ultrakillbase/includes/customcode/ultrakillbase" )


    -- ConVars --

UltrakillBase.ConVar_DmgMult = CreateConVar( "drg_ultrakill_dmgmult", 25, { FCVAR_ARCHIVE, FCVAR_REPLICATED } )
UltrakillBase.ConVar_TakeDmgMult = CreateConVar( "drg_ultrakill_takedmgmult", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED } )

UltrakillBase.ConVar_PlyDmgMult = CreateConVar( "drg_ultrakill_plydmgmult", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Ultrakill Player Damage Multiplier ( 4x for Balanced Damage( HL2 Weps ) )" )
UltrakillBase.ConVar_PlyTakeDmgMult = CreateConVar( "drg_ultrakill_plytakedmgmult", 0.1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Ultrakill Player Damage Multiplier ( Scalar of How much damage a Player should take. )" )


    -- Gibs --


UltrakillBase.Gibs_Flesh = {

    "models/ultrakill/mesh/effects/gibs/Flesh_Gib1.mdl",
    "models/ultrakill/mesh/effects/gibs/Flesh_Gib2.mdl",
    "models/ultrakill/mesh/effects/gibs/Flesh_Gib3.mdl",
    "models/ultrakill/mesh/effects/gibs/Flesh_Gib4.mdl",
    "models/ultrakill/mesh/effects/gibs/Flesh_Gib5.mdl",
    "models/ultrakill/mesh/effects/gibs/Flesh_Gib6.mdl",
    "models/ultrakill/mesh/effects/gibs/Flesh_Gib7.mdl",
    "models/ultrakill/mesh/effects/gibs/Flesh_Gib8.mdl",
    "models/ultrakill/mesh/effects/gibs/Flesh_Gib9.mdl",
    "models/ultrakill/mesh/effects/gibs/Flesh_Gib10.mdl",
    "models/ultrakill/mesh/effects/gibs/Flesh_Gib11.mdl"

}

UltrakillBase.Gibs_Rubble = {

    "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
    "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl"

}

UltrakillBase.Gibs_Virtue = "models/ultrakill/mesh/effects/virtue/Virtue_Gib.mdl"


    -- Shared Tables --

UltrakillBase.PrimeOutroDelays = {

    0,
    1.5,
    3,
    4,
    5,
    5.5,
    6,
    6.25,
    6.5,
    6.75,
    6.775,
    6.8,
    6.825,
    6.85,
    6.875,
    6.9,
    6.925,
    6.95,
    6.975

}

    -- Fonts --


if CLIENT then

    local function CreateFonts()

        -- Screen Res --

        local ResolutionDelta = UltrakillBase.ScreenAverage() / 1500

        ResolutionDelta = ResolutionDelta < 1 and ResolutionDelta * 1.1 or ResolutionDelta

        -- Normal --

        SCreateFont( "Ultrakill_Font", { font = "VCR OSD Mono",  size = 42 * ResolutionDelta, weight = 600, antialias = true } )
        SCreateFont( "Ultrakill_Font_Small", { font = "VCR OSD Mono",  size = 29 * ResolutionDelta, weight = 600, antialias = true } )

        -- Subtitles --

        SCreateFont( "Ultrakill_SubFont", { font = "VCR OSD Mono", size = 29 * ResolutionDelta, weight = 0, antialias = true } )

    end

    CreateFonts()


        -- Hook. --


    HAdd( "OnScreenSizeChanged" , "UltrakillBase_DynamicTextSize", function()

        CreateFonts()

    end )

end


-- Precaching --


function UltrakillBase.RecursiveSearch( Dir, DirPath, Ext ) -- Neat Function to Find what I want to precache.

    local Folders = select( 2, FFind( Dir .. "/*", DirPath ) ) -- Find all Folders.
    local Files = FFind( Dir .. "/*" .. Ext, DirPath )

    local Table = {}

    for I, File in ipairs( Files ) do

        Table [ Dir .. "/" .. File ] = File

    end

    for I, Folder in ipairs( Folders ) do

        TMerge( Table, UltrakillBase.RecursiveSearch( Dir .. "/" .. Folder, DirPath, Ext ) )

    end

    return Table

end


local Models = UltrakillBase.RecursiveSearch( "models/ultrakill", "GAME", ".mdl" )


for File, FileName in pairs( Models ) do

    UPrecacheModel( File )

end


UltrakillBase.GabrielInstalled = FExists( "entities/ultrakill_gabriel.lua", "LUA" )
UltrakillBase.SisyphusPrimeInstalled = FExists( "entities/ultrakill_sisyphusprime.lua", "LUA" )
UltrakillBase.MinosPrimeInstalled = FExists( "entities/ultrakill_minosprime.lua", "LUA" )
UltrakillBase.PreludeInstalled = FExists( "entities/ultrakill_filth.lua", "LUA" )
UltrakillBase.Act1Installed = FExists( "entities/ultrakill_mindflayer.lua", "LUA" )


DrGBase.AddParticles( "Ultrakill_Gabriel.pcf", {

    "Ultrakill_Gabriel_ZweiTrail",
    "Ultrakill_Gabriel_KatanaTrail",
    "Ultrakill_Gabriel_SpearTrail",
    "Ultrakill_Gabriel_BladeTrail",
    "Ultrakill_Gabriel_WeaponSpawn",
    "Ultrakill_Gabriel_WeaponBreak",
    "Ultrakill_Gabriel_Break",
    "Ultrakill_Gabriel_BigBreak"

} )


DrGBase.AddParticles( "Ultrakill_Videogames.pcf", {

    "Ultrakill_VideogamesPhase",
    "Ultrakill_VideogamesPhase_Rings",
    "Ultrakill_VideogamesPhaseChange",
    "Ultrakill_VideogamesSwing_Ring"

} )


DrGBase.AddParticles( "Ultrakill_SisyphusPrime.pcf", {

    "Ultrakill_SisyphusPhase",
    "Ultrakill_SisyphusPhase_Rings",
    "Ultrakill_SisyphusPhaseChange",
    "Ultrakill_SisyphusExplosionCharge",
    "Ultrakill_SisyphusBloodSwing_Ring"

} )


DrGBase.AddParticles( "Ultrakill_MinosPrime.pcf", {

    "Ultrakill_MinosPhase",
    "Ultrakill_MinosPhase_Rings",
    "Ultrakill_MinosPhaseChange",
    "Ultrakill_PrimeOrb",
    "Ultrakill_MinosProjectileCharge",
    "Ultrakill_MinosSnakeBlue_Ring",
    "Ultrakill_MinosSnakeYel",
    "Ultrakill_MinosSnakeYel_Ring"

} )


-- Act 1 --

DrGBase.AddParticles( "Ultrakill_Act1.pcf", {

    "Ultrakill_Portal_Mindflayer",
    "Ultrakill_Portal_HideousMass",
    "Ultrakill_Drone_Charge",
    "Ultrakill_Mindflayer_Beam",
    "Ultrakill_Mindflayer_Beam_End",
    "Ultrakill_Mindflayer",
    "Ultrakill_Mindflayer_Charging",
    "Ultrakill_Mindflayer_Trail",
    "Ultrakill_HomingOrb",
    "Ultrakill_HomingOrb_Impact",
    "Ultrakill_MortarTrail",
    "Ultrakill_StreetCleaner_Flames"

} )


DrGBase.AddParticles( "Ultrakill_Prelude.pcf", {

    "Ultrakill_Portal_Filth",
    "Ultrakill_Portal_Stray",
    "Ultrakill_Portal_SwordsMachine",
    "Ultrakill_Portal_Cerberus",
    "Ultrakill_SwordsMachine_Trail",
    "Ultrakill_Muzzleflash_Shotgun",
    "Ultrakill_Shotgun_Sparks",
    "Ultrakill_Shotgun_Trail"

} )


DrGBase.AddParticles( "Ultrakill_Shared.pcf", {

    "Ultrakill_DashRings",
    "Ultrakill_Blood",
    "Ultrakill_ExplosionSmoke",
    "Ultrakill_ExplosionSmokeLinger",
    "Ultrakill_Portal_Heavy",
    "Ultrakill_Portal_Red",
    "Ultrakill_HellOrb",
    "Ultrakill_HellOrb_Impact",
    "Ultrakill_Radiance",
    "Ultrakill_Sand_Drip",
    "Ultrakill_SandExplosion",
    "Ultrakill_SandExplosionStalker",
    "Ultrakill_VirtueShatter_Trail",
    "Ultrakill_White_Trail"

} )
