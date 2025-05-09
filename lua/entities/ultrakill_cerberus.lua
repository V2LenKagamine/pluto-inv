local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local DrGBase = DrGBase
local UltrakillBase = UltrakillBase
local Vector = Vector
local ECreate = SERVER and ents.Create
local MRand = math.Rand
local tostring = tostring
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local tonumber = tonumber
local istable = istable
local tobool = tobool
local Color = Color
local ipairs = ipairs
local EIterator = ents.Iterator
local MRandom = math.random
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "Cerberus"
ENT.Category = "ULTRAKILL - Bosses"
ENT.Models = { "models/ultrakill/characters/enemies/boss/cerberus.mdl" }
ENT.Skins = { 0 }
ENT.ModelScale = 1.25
ENT.CollisionBounds = Vector( 8, 8, 75 ) * 2.4
ENT.SurroundingBounds = Vector( 45, 45, 85 ) * 2.4

-- Ragdoll --

ENT.RagdollModel = "models/ultrakill/ragdolls/cerberus_boss.mdl"
ENT.RagdollScale = 1
ENT.RagdollOnDeath = true

-- Stats --

ENT.SpawnHealth = 8000
ENT.UltrakillBase_Phase = 1
ENT.UltrakillBase_PhaseMax = 2

-- Weight --

ENT.UltrakillBase_WeightClass = "Heavy"

-- AI --

ENT.MeleeAttackRange = 650
ENT.RangeAttackRange = 2000
ENT.ReachEnemyRange = 100
ENT.AvoidEnemyRange = 255

-- Detection --

ENT.EyeBone = "Head"

-- Locomotion --

ENT.Acceleration = 1000
ENT.Deceleration = 1000
ENT.JumpHeight = 150
ENT.StepHeight = 20
ENT.MaxYawRate = 400
ENT.DeathDropHeight = 30

-- Animations --

ENT.WalkAnimation = "Walk"
ENT.WalkAnimRate = 1
ENT.RunAnimation = "Walk"
ENT.RunAnimRate = 1
ENT.IdleAnimation = "Idle"
ENT.IdleAnimRate = 1
ENT.JumpAnimation = "Idle"
ENT.JumpAnimRate = 1

-- Movements --

ENT.UseWalkframes = false
ENT.WalkSpeed = 100
ENT.RunSpeed = 100

-- Variables --

ENT.CerberusCracked = false

local CerberusWakeUpRange = 600


-- Tables --


ENT.UltrakillBase_WeaknessTable = {

  [ DMG_BLAST ] = 1.5
  
}

ENT.UltrakillBase_EnragedRate = 1.35

ENT.UltrakillBase_DamageInfo = {

  [ "Tackle" ] = { 250, 100, DMG_CLUB, 25, Vector( 1300, 0, 500 ) }

}

ENT.UltrakillBase_OnEventTable = {

  [ "Statue" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Stomp" then

      UltrakillBase.SoundScript( "Ultrakill_CerberusCharge2", self:GetPos(), self )

    elseif Event[ 2 ] == "Tackle" then

      UltrakillBase.SoundScript( "Ultrakill_CerberusCharge3", self:GetPos(), self )

    elseif Event[ 2 ] == "Throw" then

      UltrakillBase.SoundScript( "Ultrakill_CerberusCharge", self:GetPos(), self )

    elseif Event[ 2 ] == "Break" then

      UltrakillBase.SoundScript( "Ultrakill_GroundBreak", self:GetPos(), self )

    end

  end,


  [ "Dodge" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_Dodge2", self:GetPos(), self )

    local RandomVector = Vector()

    for X = 1, 10 do

      local Trail = ECreate( "env_spritetrail" )

      RandomVector:SetUnpacked( MRand( -100, 100 ), MRand( -100, 100 ), MRand( -100, 100 ) )

      local ExtraForward = Seq == "Tackle" and 2 or 1

      RandomVector:Rotate( self:GetAngles() )

      Trail:SetPos( self:WorldSpaceCenter() + RandomVector + self:GetForward() * 350 * ExtraForward )
      Trail:SetVelocity( -self:GetForward() * 9999 )
      Trail:SetName( "UltrakillBase_CerberusDashTrail_" .. tostring( self ) .. "_" .. X )
      Trail:SetKeyValue( "lifetime", "0.4" )
      Trail:SetKeyValue( "spritename", "particles/ultrakill/white_trail_additive.vmt" )
      Trail:SetKeyValue( "startwidth", "15" )
      Trail:SetKeyValue( "endwidth", "15" )
      Trail:SetKeyValue( "rendermode", "5" )
      Trail:SetKeyValue( "rendercolor", "255 255 255" )
      Trail:SetKeyValue( "renderamt", "25" )

      Trail:Spawn()

      SafeRemoveEntityDelayed( Trail, 0.4 )

    end

    self:ScreenShake( 250, 10, 0.6, 2500 )

  end,


  [ "Step" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_CerberusStep", self:GetPos(), self )

  end,


  [ "Turn" ] = function( self, Event, Seq )

    self:FaceEnemyInstant( tonumber( Event[ 2 ] or 0 ) / self:CalculateAnimRate( Seq ) )

  end,


  [ "Damage" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Start" then

      local DamageData = self.UltrakillBase_DamageInfo[ Seq ]

      if not istable( DamageData ) then return end

      self:ContinuousAttack( {

        Damage = DamageData[ 1 ],
        Range = DamageData[ 2 ],
        Type = DamageData[ 3 ],
        Angle = DamageData[ 4 ],
        Force = DamageData[ 5 ],
        Push = true

      } )

      self:SetContinuousAttack( true )

    else

      self.UltrakillBase_ContinuousAttacksTable = {}

      self:SetContinuousAttack( false )

    end

  end,


  [ "Shockwave" ] = function( self, Event, Seq )

    self:Shockwave( true, self:GetPos(), self:GetGroundAngles(), 250, 1.5, 100, 0.125 )

  end,


  [ "OrbProjectile" ] = function( self, Event, Seq )

    local Proj = self:CreateProjectile( "Ultrakill_Cerberus_Projectile", true )
    Proj:SetPos( self:WorldSpaceCenter() )
    Proj:SetAngles( self:GetAngles() )
    Proj.Damage = 200

    if self:HasEnemy() then

      Proj:AimAt( self:GetEnemy(), 4000, false )

    else

      self:AimProjectile( Proj, 4000 )

    end

  end,


  [ "Bodygroup" ] = function( self, Event, Seq )

    self:SetBodygroup( tonumber( Event[ 2 ] ), tonumber( Event[ 3 ] ) )

  end,


  [ "Flag" ] = function( self, Event, Seq )

    self:SetTurning( tobool( Event[ 3 ] ) )

  end


}

ENT.UltrakillBase_EventTable = {

  [ "Stomp" ] = {

    { 0, "Damage Stop"},
    { 0, "Statue Stomp" },
    { 0, "Flag Turning 0" },

    { 63, "Shockwave" },

    { 95, "Flag Turning 1" }

  },

  [ "Tackle" ] = {

    { 0, "Damage Stop" },
    { 0, "Statue Tackle" },
    { 0, "Flag Turning 1" },

    { 41, "Flag Turning 0" },
    { 41, "Turn 0.333" },

    { 61, "Dodge" },
    { 61, "Damage Start" },

    { 82, "Damage Stop" },

    { 95, "Flag Turning 1" }

  },
  
  [ "ThrowOrb" ] = {

    { 0, "Damage Stop" },
    { 0, "Statue Throw" },
    { 0, "Flag Turning 1" },
    
    { 40, "Flag Turning 0" },

    { 43, "Turn 0.25" },
    { 43, "Dodge" },

    { 57, "OrbProjectile" },
    { 57, "Bodygroup 1 1" },

    { 97, "Bodygroup 1 0" }

  },

  [ "Awaken" ] = {

    { 208, "Statue Break" },

    { 289, "Statue Break" },

    { 360, "Statue Break" }

  },

  [ "Walk" ] = {

    { 0, "Damage Stop" },
    { 0, "Step" },

    { 43, "Step" }

  },

  [ "Idle" ] = {

    { 0, "Damage Stop" }

  }

}

ENT.UltrakillBase_AttackTable = {

  "Tackle",
  "ThrowOrb",
  "Stomp"

}

ENT.UltrakillBase_IntroInfo = {

  "Awaken",
  "Awaken_Loop"

}


-- Possession --

ENT.PossessionCrosshair = true
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {

  {
    
    offset = Vector( 0, 24, 72 ),
    distance = 240,
    eyepos = false
    
  },

  {

    offset = Vector( 12, 0, 0 ),
    distance = 0,
    eyepos = true

  }

}

ENT.PossessionBinds = {

  [ IN_ATTACK ] = { { coroutine = true, onkeydown = function( self, Possessor )

    if Possessor:KeyDown( IN_FORWARD ) then

      self:CerberusTackle()

    elseif not Possessor:KeyDown( IN_FORWARD ) then

      self:CerberusStomp()

    end

  end } },

  [ IN_ATTACK2 ] = { { coroutine = true, onkeydown = function( self )

    self:CerberusThrowOrb()

  end } },

}


if SERVER then


function ENT:CustomInitialize()

  self:CreateLight( 1, Color( 255, 125, 0 ), 150, 6, 0, 2 )

  self.InitSkin = self:GetSkin()

end


function ENT:OnPhaseChange( Phase )

  if Phase ~= 2 or self:IsDead() then return end

  self.CerberusCracked = true

  self:SetSkin( self:GetEnraged() and 3 or 1 )

  UltrakillBase.ChangeMusic( self, "CerberusA", "CerberusB", 1.5 )
  UltrakillBase.SoundScript( "Ultrakill_RockBreak", self:GetPos(), self )
  UltrakillBase.CreateGibs( {

		{ 
			Position = self:WorldSpaceCenter(),
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
			Velocity = 350,
			ModelScale = 1.5,
			Trail = "Ultrakill_White_Trail"
		},

		{ 
			Position = self:WorldSpaceCenter(),
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
			Velocity = 350,
			ModelScale = 1.5,
			Trail = "Ultrakill_White_Trail"
		}

	} )

  -- Wake up Dormant Cerbs --

  for K, V in EIterator() do

    if V:GetClass() ~= "ultrakill_cerberus" or not V.CerberusDormant or V == self then continue end

    V.CerberusDormant = false

  end

end


function ENT:Enrage()

  if self:GetEnraged() then return end

  self:SetEnraged( true )

  UltrakillBase.SoundScript( "Ultrakill_CerberusEnrage", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_Enrage_Loop", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_Enrage", self:GetPos(), self )

  self:CreateLight( 0, Color( 255, 0, 0 ), 450, 6, 0, 1 )

  self:ScreenShake( 150, 10, 1, 2550 )

  self:SetSkin( self.CerberusCracked and 3 or 2 )

  self:CreateEnrage( 1, 1.65 )

  self.WalkSpeed = 270
  self.RunSpeed = 270

end


function ENT:CerberusStomp()

  if self:GetCooldown( "Stomp" ) > 0 then return end
          
  self:PlaySequenceAndMove( "Stomp", nil, function( self, Cycle )

    if Cycle > 0.958209 then

      return true
      
    end 

  end )

  self:SetCooldown( "Attack", 0.5 / self:CalculateAnimRate() )
  self:SetCooldown( "Stomp", 1.25 / self:CalculateAnimRate( "Stomp" ) )

end


function ENT:CerberusThrowOrb()

  if self:GetCooldown( "Throw" ) > 0 then return end
          
  self:PlaySequenceAndMove( "ThrowOrb", nil, function( self, Cycle ) 

    if Cycle > 0.952238908 then

      return true

    end

  end )

  self:SetCooldown( "Attack", 0.5 / self:CalculateAnimRate() )
  self:SetCooldown( "Throw", 2 / self:CalculateAnimRate( "ThrowOrb" ) )

end


function ENT:CerberusTackle()
          
  self:PlaySequenceAndMove( "Tackle", nil, function( self, Cycle )
   
    if Cycle > 0.952238836 then

      return true

    end

  end )

  self:SetCooldown( "Attack", 0.5 / self:CalculateAnimRate( "Tackle" ) )

end


function ENT:OnMeleeAttack( Enemy )

  if self:GetCooldown( "Attack" ) > 0 then return end

  local Random = MRandom( 3 )

  if Random == 1 then

    return self:CerberusThrowOrb()

  elseif Random == 2 then

    return self:CerberusTackle()

  elseif Random == 3 then

    return self:CerberusStomp()

  end

end


function ENT:OnRangeAttack( Enemy )

  if self:GetCooldown( "Attack" ) <= 0 then

    self:CerberusThrowOrb()

  end

end


local function CerberusExists( self )

  for K, V in EIterator() do

    if V:GetClass() ~= "ultrakill_cerberus" or V == self then continue end

    return true

  end

  return false

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:SetBodygroup( 2, 1 )

  self:SetGodMode( true )
  self:SetTurning( false )

  local Music = false

  self.CerberusDormant = CerberusExists( self ) and true or false
  self.CerberusStartedDormant = self.CerberusDormant
  self.CerberusAwake = false

  self:SetNoTarget( true )

  self:PlaySequenceAndLoop( nil, "Awaken_Loop", 1, function( self, Cycle )

    if not self.CerberusDormant and not self.CerberusStartedDormant then

      for Hostile in self:HostileIterator() do

        if not self:IsInRange( Hostile, CerberusWakeUpRange ) then continue end

        return true

      end

    elseif not self.CerberusDormant and self.CerberusStartedDormant then

      return true

    end

  end )

  self:SetNoTarget( true )

  self:PlaySequenceAndMove( "Awaken", 1, function( self, Cycle )

    if Cycle > 0.35 and not Music then

      UltrakillBase.PlayMusic( self, "CerberusA" )

      Music = true

    end

    if Cycle > 0.964179107 then

      return true

    end 

  end )

  self.CerberusAwake = true

  self:SetBodygroup( 2, 0 )
  self:SetNoTarget( false )

  self:SetPos( self:GetPos() + ( self:GetForward() * 70 ) )

  self:SetGodMode( false )

  UltrakillBase.AddBoss( self, "#ultrakill.cerberus.boss" )

  self:SetCooldown( "Attack", 0.5 )

end


function ENT:OnRemove()

  if self:GetEnraged() then UltrakillBase.SoundScript( "Ultrakill_Enrage_End", self:GetPos() ) end

  for K, V in EIterator() do

    if V:GetClass() ~= "ultrakill_cerberus" or not V.CerberusDormant or V == self then continue end

    V.CerberusDormant = false

  end

  UltrakillBase.StopCurrentMusic( self )

end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  self:DamageMultiplier( CDamageInfo, HitGroup )
  self:CreateBlood( CDamageInfo, HitGroup )

end


function ENT:OnDeath( CDamageInfo, HitGroup )

  UltrakillBase.SoundScript( "Ultrakill_Death", self:GetPos() )

  self:SetSkin( self.InitSkin )

  for K, V in EIterator() do

    if V == self then continue end

    local IsBoss = V:GetClass() == "ultrakill_cerberus"
    local IsNormal = V:GetClass() == "ultrakill_cerberus_normal"

    if IsBoss then

      UltrakillBase.TransferOwnershipMusic( self, V )

    end

    if ( IsBoss or IsNormal ) and V.IsUltrakillNextbot and V.CerberusAwake and not V:IsEnraged() then

      V:Timer( 1.03, V.Enrage )

    end

    if IsBoss and V.CerberusDormant then

      V.CerberusDormant = false

    end

  end

  UltrakillBase.SoundScript( "Ultrakill_CerberusDeath", self:GetPos() )

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )