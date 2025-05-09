local BaseClass = baseclass.Get( "ultrakillbase_nextbot" )
local UltrakillBase = UltrakillBase
local DrGBase = DrGBase
local Vector = Vector
local isstring = isstring
local tonumber = tonumber
local TInsert = table.insert
local MRand = math.Rand
local istable = istable
local tobool = tobool
local Color = Color
local MRandom = math.random
local AddCSLuaFile = AddCSLuaFile

if not DrGBase or not UltrakillBase then return end -- return if DrGBase or UltrakillBase isn't installed
ENT.Base = "ultrakillbase_nextbot"

-- Misc --

ENT.PrintName = "SwordsMachine"
ENT.Category = "ULTRAKILL - Bosses"
ENT.Models = {"models/ultrakill/characters/enemies/boss/swordmachine.mdl"}
ENT.Skins = { 0 }
ENT.ModelScale = 1
ENT.CollisionBounds = Vector( 6, 6, 78 ) * 1.35
ENT.SurroundingBounds = Vector( 45, 45, 145 ) * 1.35

-- Stats --

ENT.SpawnHealth = 12500
ENT.UltrakillBase_Phase = 1
ENT.UltrakillBase_PhaseMax = 2

-- Weight --

ENT.UltrakillBase_WeightClass = "Heavy"

-- Sounds --

ENT.UltrakillBase_HurtSoundDelay = 0.1
ENT.UltrakillBase_HurtSound = "Ultrakill_SwordsMachine_Hurt"

-- AI --

ENT.MeleeAttackRange = 425
ENT.RangeAttackRange = 2000
ENT.ReachEnemyRange = 105
ENT.AvoidEnemyRange = 0

-- Detection --

ENT.EyeBone = "Head"

-- Locomotion --

ENT.Acceleration = 2500
ENT.Deceleration = 1500
ENT.JumpHeight = 150
ENT.StepHeight = 20
ENT.MaxYawRate = 400
ENT.DeathDropHeight = 30

-- Animations --

ENT.WalkAnimation = "Run"
ENT.WalkAnimRate = 1.5
ENT.RunAnimation = "Run"
ENT.RunAnimRate = 1.5
ENT.IdleAnimation = "Idle"
ENT.IdleAnimRate = 1
ENT.JumpAnimation = "Idle"
ENT.JumpAnimRate = 1

-- Movements --

ENT.UseWalkframes = false
ENT.WalkSpeed = 350
ENT.RunSpeed = 350

-- Variables --

ENT.HasSword = true
ENT.WakeUpRange = 350

-- Tables --

ENT.UltrakillBase_WeaknessTable = {

  [ DMG_BUCKSHOT ] = 1.5
  
}

ENT.UltrakillBase_DamageInfo = {

  [ "ComboStill" ] = { 250, 100, DMG_SLASH, 35, Vector( 700, 0, 250 ) },
  [ "RunningSwing" ] = { 400, 100, DMG_SLASH, 45, Vector( 700, 0, 250 ) },
  [ "Shoot" ] = 250

}

ENT.UltrakillBase_AnimRateInfo = {

  [ "RunningSwing" ] = 1.25,
  [ "SwordSpiral" ] = 1.25

}

ENT.UltrakillBase_EnragedRate = 1.2

ENT.UltrakillBase_OnEventTable = {

  [ "Step" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_Machine_Footsteps", self:GetPos() )

  end,


  [ "SwordSwing" ] = function( self, Event, Seq )

    local Time = isstring( Event[ 2 ] ) and tonumber( Event[ 2 ] ) or 0.5

    self:ParticleEffectTimed( Time, "Ultrakill_SwordsMachine_Trail", { parent = self, attachment = "Sword_Attach" } )

  end,


  [ "Shoot" ] = function( self, Event, Seq )

    if self:GetPhase() >= 2 then return end

    UltrakillBase.SoundScript( "Ultrakill_Shotgun_Fire", self:GetPos(), self )
    UltrakillBase.SoundScript( "Ultrakill_Shotgun_Steam", self:GetPos(), self )

    self:ParticleEffectTimed( 0.5, "Ultrakill_Muzzleflash_Shotgun", { parent = self, attachment = "Shotgun_Attach" } )

    local Aim = self:GetAimVector():Angle()

    local Spread = {

      Vector( 0, 0, 0 )

    }

    for I = 1, 8 do

      TInsert( Spread, Vector( 0, MRand( -1, 1 ), MRand( -1, 1 ) ) )

    end

    local Intensity = 100

    for X = 1, #Spread do

      local Pos = Spread[ X ] * 100

      local Pellet = self:CreateProjectile( "Ultrakill_SwordsMachine_Projectile", true )

      Pellet:SetPos( self:WorldSpaceCenter() )
      Pellet:SetAngles( self:GetAngles() )

      Pellet.Damage = 250

      self:AimProjectile( Pellet, 3000, Pos, true )

    end

    self:Timer( 2 / self:CalculateAnimRate(self:GetSequence() ), function( self )

      UltrakillBase.SoundScript( "Ultrakill_Shotgun_Reload", self:GetPos(), self )

    end, self )

  end,


  [ "BigRubble" ] = function( self, Event, Seq )

    UltrakillBase.SoundScript( "Ultrakill_BigRockBreak", self:GetPos(), self )

    self:CreateBigRubble( self:GetPos(), self:GetAngles() )

    self:ScreenShake( 150, 10, 1, 2000 )

  end,


  [ "Rubble" ] = function( self, Event, Seq )

    self:CreateRubble( self:GetPos(), self:GetAngles() )
    UltrakillBase.SoundScript( "Ultrakill_RockBreak", self:GetPos(), self )

    self:ScreenShake( 5, 0.2, 0.35, 750 )

  end,


  [ "SwordThrow" ] = function( self, Event, Seq )

    self.HasSword = false

    local Sword = self:CreateProjectile( "Ultrakill_SwordsMachine_Sword_Projectile", true )
    Sword:SetPos( self:WorldSpaceCenter() )
    Sword:SetAngles( self:GetAimAngles() )

  end,


  [ "SwordSpiral" ] = function( self, Event, Seq )

    self.HasSword = false

    local Sword = self:CreateProjectile ( "Ultrakill_SwordsMachine_Sword_Spiral_Projectile", true )
    Sword:SetPos( self:WorldSpaceCenter() )
    Sword:SetAngles( self:GetAngles() )

  end,


  [ "Turn" ] = function( self, Event, Seq )

    self:FaceEnemyInstant()

  end,


  [ "SwordCatch" ] = function( self, Event, Seq )

    self:SetNW2Bool( "UltrakillBase_Heat", false )
    self.HasSword = true

  end,


  [ "Damage" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Start" then

      local DamageData = self.UltrakillBase_DamageInfo[ Seq ]

      if not istable( DamageData ) then return end

      UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_ChainsawSwing", self:GetPos(), self )

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


  [ "Alert" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Parry" then

      self:CreateAlertFollow( self, 1, 1.25, 1 )

    else

      self:CreateAlertFollow( self, 3, 1.25, 1 )

    end

  end,


  [ "Bodygroup" ] = function( self, Event, Seq )

    self:SetBodygroup( tonumber( Event[ 2 ] ), tonumber( Event[ 3 ] ) )

  end,


  [ "Sword" ] = function( self, Event, Seq )

    local Type = Event[ 2 ] == Heat and true or false

    self:SetNW2Bool( "UltrakillBase_Heat", Type )

  end,


  [ "Flag" ] = function( self, Event, Seq )

    if Event[ 2 ] == "Parry" then

      self:SetParryable( tobool( Event[ 3 ] ) )

    elseif Event[ 2 ] == "Turning" then

      self:SetTurning( tobool( Event[ 3 ] ) )

    end

  end


}

ENT.UltrakillBase_EventTable = {

  [ "ComboStill" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Turning 0"  },
    { 0, "Flag Parry 0"  },

    { 10, "Alert Parry"  },
    { 10, "Sword Heat"  },
    { 10, "Turn"  },
    { 10, "SwordSwing"  },
    { 10, "Flag Parry 1"  },

    { 15, "Damage Start"  },

    { 21, "Damage Stop" },
    { 21, "Flag Parry 0"  },

    { 23, "Sword Cool"  },

    { 27, "Turn"  },
    { 27, "SwordSwing"  },
    { 27, "Sword Heat"  },
    { 27, "Alert Parry"  },
    { 27, "Flag Parry 1"  },

    { 29, "Damage Start"  },

    { 34, "Damage Stop" },
    { 34, "Flag Parry 0"  },

    { 37, "Sword Cool"  },

    { 42, "Turn"  },
    { 42, "Sword Heat"  },
    { 42, "Alert Parry"  },
    { 42, "SwordSwing"  },
    { 42, "Flag Parry 1"  },

    { 46, "Damage Start"  },

    { 49, "Damage Stop" },
    { 49, "Flag Parry 0"  },

    { 54, "Sword Cool"  },

    { 56, "Flag Turning 1"  }

  },

  [ "RunningSwing" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Parry 0"  },
    { 0, "Flag Turning 1"  },

    { 10, "Flag Turning 0"  },

    { 12, "Sword Heat"  },
    { 12, "SwordSwing"  },
    { 12, "Alert Parry"  },
    { 12, "Flag Parry 1"  },

    { 19, "Damage Start"  },

    { 23, "Damage Stop" },
    { 23, "Flag Parry 0"  },

    { 29, "Sword Cool"  },

    { 45, "Flag Turning 1"  }
  
  },

  [ "SwordThrow" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Turning 0"  },
    { 0, "Flag Parry 0"  },

    { 9, "Sword Heat"  },
    { 9, "Alert ProjParry"  },
    { 9, "Flag Parry 1"  },

    { 17, "SwordThrow"  },
    { 17, "Bodygroup 2 1"  },
    { 17, "Flag Parry 0"  }

  },

  [ "SwordSpiral" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Parry 0"  },
    { 0, "Flag Turning 1"  },

    { 18, "Sword Heat"  },
    { 18, "Alert ProjParry"  },
    { 18, "Flag Parry 1"  },
    { 18, "Flag Turning 0"  },

    { 33, "SwordSpiral"  },
    { 33, "Bodygroup 2 1"  },
    { 33, "Flag Parry 0"  },

    { 60, "Flag Turning 1"  }

  },

  [ "Knockdown" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Parry 0"  },
    { 0, "Flag Turning 0"  },
    { 0, "Flag Parry 0" },
    { 0, "Sword Cool"  },

    { 110, "Flag Turning 1"  }

  },

  [ "Intro" ] = {

    { 0, "Damage Stop" },
    { 0, "Flag Turning 0"  },
    { 0, "Flag Parry 0" },
    { 0, "Sword Cool"  },

    { 12, "BigRubble"  },

    { 60, "Flag Turning 1"  },
    { 60, "Rubble"  }

  },

  [ "Run" ] = {

    { 0, "Damage Stop" },
    { 0, "Step" },
    { 0, "Sword Cool"  },

    { 10, "Step" }

  },

  [ "Idle" ] = {

    { 0, "Damage Stop" },
    { 0, "Sword Cool"  }

  }

}

ENT.UltrakillBase_AttackTable = {

  "ComboStill",
  "RunningSwing",
  "SwordThrow",
  "SwordSpiral"

}

ENT.UltrakillBase_IntroInfo = {

  "Intro"

}


-- Possession --

ENT.PossessionCrosshair = true
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {
  {

    offset = Vector( 0, 13.5, 40.5 ), 
    distance = 135, 
    eyepos = false

  },

  {
    offset = Vector( 6.75, 0, 0 ),
    distance = 0,
    eyepos = true
  }

}

ENT.PossessionBinds = {

  [ IN_ATTACK ] = { { coroutine = true, onkeydown = function( self, Possessor )

    local LockedOn = self:PossessionGetLockedOn()

    if not self.HasSword then return end

    if Possessor:KeyDown( IN_FORWARD ) then

      self:SwordMachineRunningSwing( LockedOn )

    elseif not Possessor:KeyDown( IN_FORWARD ) and not Possessor:KeyDown( IN_BACK ) then

      self:SwordMachineComboStill( LockedOn )

    elseif Possessor:KeyDown( IN_BACK ) then

      if self:GetPhase() < 2 then

        self:SwordMachineComboStill( LockedOn )

      elseif self:GetPhase() >= 2 then

        self:SwordMachineSwordSpiral( LockedOn )

      end

    end

  end } },

  [ IN_ATTACK2 ] = { { coroutine = true, onkeydown = function( self, Possessor )

    self:OnRangeAttack( self:PossessionGetLockedOn() )

  end } },

  [ IN_RELOAD ] = { { coroutine = true, onkeydown = function( self, Possessor )

    if self:IsEnraged() then return end

    self:Enrage()

  end } },

}


if SERVER then


function ENT:CustomInitialize()

  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_ChainsawLoop", self:GetPos(), self )

  self:CreateLight( 1, Color( 255, 125, 0 ), 250, 4, 0, 1 )

  self.InitSkin = self:GetSkin()

end


function ENT:OnPhaseChange( Phase )

  if Phase ~= 2 or self:IsDead() then return end

  if self:GetEnraged() then self:Derage() end

  self:SetBodygroup( 1, 1 )
  self:SetBodygroup( 3, 1 )

  self.UltrakillBase_RateMult = 1.2

  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_BigPain", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_BigPain_H", self:GetPos(), self )

  UltrakillBase.SlowMotion( 1.25 )

  self:CallOverCoroutine( self.PlaySequenceAndMove, false, "Knockdown", 1, function( self, Cycle )

    if Cycle > 0.886356176 then

      return true

    end

  end )

end


function ENT:Enrage()

  if self:GetEnraged() or self:IsDead() then return end

  self:SetEnraged( true )

  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_Enrage_Loop", self:GetPos(), self )
  UltrakillBase.SoundScript( "Ultrakill_Enrage", self:GetPos(), self )

  self:SetSkin( 1 )

  self:ScreenShake( 150, 10, 1, 1550 )

  self:CreateEnrage( 2, 0.85 )
  self:CreateLight( 1, Color( 255, 0, 0 ), 450, 6, 0, 2 )

  self:TimerIdentified( "SwordsMachine_EnragedTimer", 12, 1, self.Derage )

  self:PlaySequenceAndMove( "Knockdown", 2, function( self, Cycle )

    if Cycle > 0.886356176 then

      return true

    end

  end )

end


function ENT:Derage()

  if not self:GetEnraged() then return end

  self:SetEnraged( false )

  UltrakillBase.SoundScript( "Ultrakill_Enrage_End", self:GetPos() )

  self:CreateLight( 1, Color( 255, 125, 0 ), 250, 4, 0, 1 )

  self:SetSkin( self.InitSkin )

end


function ENT:SwordMachineComboStill()

  self:PlaySequenceAndMove( "ComboStill", nil, function( self, Cycle )

    if Cycle > 0.794185346 then

      return true

    end

  end )

end

function ENT:SwordMachineRunningSwing()

  if self:GetCooldown( "RunningSwing" ) > 0 then return end

  self:PlaySequenceAndMove( "RunningSwing", nil, function( self, Cycle )

    if Cycle > 0.902378989 then

      return true

    end

  end )

  self:SetCooldown( "RunningSwing", 2 / self:CalculateAnimRate( "RunningSwing" ) )

end


function ENT:SwordMachineSwordThrow()

  self:PlaySequenceAndMove( "SwordThrow", nil, function( self, Cycle )

    if self:HasEnemy() then

      self:FaceEnemy( self:GetEnemy():GetPos():Distance( self:GetPos() ) * 0.001 )

    end

    if Cycle > 0.271363352 then

      return true

    end

  end )

end


function ENT:SwordMachineSwordSpiral()

  self:PlaySequenceAndMove( "SwordSpiral", nil )

end


-- Layered Sequences --


function ENT:SwordMachineShoot()

  if self:GetCooldown( "Shoot" ) > 0 then return end

  self:SetTurning( true )

  self:SetCooldown( "Shoot", 3 / self:CalculateAnimRate() )

  local LastCycle = 0

  self:PlaySequence( "Shoot", self:CalculateAnimRate( "Shoot" ), function( self, Cycle, LayerID )

    if self:IsAttack( self:GetSequence() ) or Cycle > 0.928592221 then

      self:SetLayerWeight( LayerID, 0 )

      self:RemoveGesture( self:GetSequenceActivity( self:GetLayerSequence( LayerID ) ) )

      return true

    end

    if Cycle > ( 11 / 47 ) and LastCycle < ( 11 / 47 ) then

      self:OnAnimEvent( "Alert ProjParry", -1, self:GetPos(), self:GetAngles() )

    end

    if Cycle > ( 11 / 47 ) and LastCycle < ( 11 / 47 ) then

      self:OnAnimEvent( "Flag Parry 1", -1, self:GetPos(), self:GetAngles() )

    end

    if Cycle > ( 24 / 47 ) and LastCycle < ( 24 / 47 ) then

      self:OnAnimEvent( "Shoot", -1, self:GetPos(), self:GetAngles() )

    end

    if Cycle > ( 24 / 47 ) and LastCycle < ( 24 / 47 ) then

      self:OnAnimEvent( "Flag Parry 0", -1, self:GetPos(), self:GetAngles() )

    end

    LastCycle = Cycle

  end )

end


function ENT:SwordMachineCatch()

  self.HasSword = true
  self:SetNW2Bool( "UltrakillBase_Heat", false )
  self:SetBodygroup( 2, 0 )

  self:PlaySequence( "SwordCatch", self:CalculateAnimRate( "SwordCatch" ), function( self, Cycle, LayerID )

    if Cycle > 0.318514875 then

      self:SetLayerWeight( LayerID, 0 )

      self:RemoveGesture( self:GetSequenceActivity( self:GetLayerSequence( LayerID ) ) )

      return true

    end

  end )

end


function ENT:OnMeleeAttack( Enemy )

  if self:GetCooldown( "Attack" ) > 0 or not self.HasSword then return end
  if not self:IsInRange( Enemy, self.MeleeAttackRange * 0.7 ) then return self:SwordMachineRunningSwing() end

  if self:GetPhase() == 1 then
  
    local Random = MRandom( 2 )
  
    if Random == 1 then
  
      return self:SwordMachineComboStill()
  
    elseif Random == 2 then
  
      return self:SwordMachineRunningSwing()
  
    end
  
  else

    local Random = MRandom( 3 )

    if Random == 1 then

      return self:SwordMachineComboStill()

    elseif Random == 2 then

      return self:SwordMachineRunningSwing()

    elseif Random == 3 then
  
      return self:SwordMachineSwordSpiral()
  
    end
  
  end

end


function ENT:OnRangeAttack( Enemy )

  if self:GetCooldown( "Attack" ) > 0 or not self.HasSword then return end

  if self:GetPhase() == 1 and not self:GetEnraged() then

    self:SwordMachineShoot()

  elseif self:GetPhase() ~= 1 and not self:GetEnraged() then

    self:SwordMachineSwordThrow()

  end

end


function ENT:OnSpawn()

  BaseClass.OnSpawn( self )

  self:SetGodMode( true )
  self:SetNoTarget( true )
  self:SetTurning( false )

  self:Timer( 1, UltrakillBase.PlayMusic, "0-2" )

  self:PlaySequenceAndMove( "Intro", 1 )

  self:SetNoTarget( false )
  self:SetGodMode( false )

  UltrakillBase.AddBoss( self, "#ultrakill.swordsmachine.boss", 2  )

  self:SetCooldown( "Attack", 0.5 ) -- Attack Delay of 0.5s

end


function ENT:OnRemove()

  if self:GetEnraged() then UltrakillBase.SoundScript( "Ultrakill_Enrage_End", self:GetPos() ) end

  UltrakillBase.StopCurrentMusic( self )
end


function ENT:OnParry( Ply, Dmg )

  if not self:GetEnraged() then

    self:CallOverCoroutine( self.Enrage, false )

  end

  if not Dmg:IsDamageType( DMG_DIRECT ) then
    
    Dmg:SetDamage( Dmg:GetDamage() + 5000 )
    Dmg:SetDamageType( Dmg:GetDamageType() + DMG_DIRECT )

  end

  UltrakillBase.SoundScript( "Ultrakill_Parry", self:GetPos() )
  UltrakillBase.SoundScript( "Ultrakill_SwordsMachine_BigPain_H", self:GetPos(), self )
  UltrakillBase.HitStop( 0.25 )

  self:SetParryable( false )

  UltrakillBase.OnParryPlayer( Ply )

end


function ENT:OnTakeDamage( CDamageInfo, HitGroup )

  BaseClass.OnTakeDamage( self, CDamageInfo, HitGroup )

end


function ENT:OnDeath( Dmg, HitGroup )

  self:SetSkin( self.InitSkin )

  UltrakillBase.SoundScript( "Ultrakill_Machine_Death", self:GetPos() )

  UltrakillBase.SlowMotion( 1.25 )

end


end


AddCSLuaFile()
DrGBase.AddNextbot( ENT )