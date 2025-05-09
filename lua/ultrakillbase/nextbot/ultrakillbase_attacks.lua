if not ENT or CLIENT then return end


local istable = istable
local isnumber = isnumber
local TInsert = table.insert
local MMax = math.max
local GetConVar = GetConVar
local Vector = Vector
local Angle = Angle
local MClamp = math.Clamp
local ipairs = ipairs
local UltrakillBase = UltrakillBase
local isfunction = isfunction
local isvector = isvector
local isstring = isstring
local DamageInfo = DamageInfo
local EFindAlongRay = ents.FindAlongRay
local MCos = math.cos
local MRad = math.rad

local vDefaultBounds = Vector( 4, 4, 4 )


function ENT:SetContinuousAttack( Bool )

  self.UltrakillBase_ContinuousAttack = Bool
  
end


function ENT:GetContinuousAttack()

  return self.UltrakillBase_ContinuousAttack

end



function ENT:ContinuousAttack( Attack, Function )

  Attack.Callback = function( self, HitTable )

    for K, V in ipairs( HitTable ) do

      if not IsValid( V ) then continue end
      if not istable( self.UltrakillBase_ContinuousAttacksTable.Ignore ) then break end

      if isfunction( Function ) then Function( self, V ) end

      self.UltrakillBase_ContinuousAttacksTable.Ignore[ V:EntIndex() ] = true

    end

  end

  self.UltrakillBase_ContinuousAttacksTable = Attack

  self:Attack( Attack )

end



function ENT:IsInCone( Ent, Ang, Dist )

  if isnumber( Dist ) and not self:IsInRange( Ent, Dist + Ent:BoundingRadius() ) then return false end

  local Dir = self:GetFullTracking() and self:GetAimVector() or self:GetForward()

  local Center = self:WorldSpaceCenter() - Dir * 10
  local Feet = self:GetPos() - Dir * 10

  return ( Center + Dir ):DrG_Degrees( Ent:GetPos() + Ent:OBBMins(), Center ) <= Ang * 0.5 or ( Center + Dir ):DrG_Degrees( Ent:GetPos() + Ent:OBBMaxs(), Center ) <= Ang * 0.5 or ( Center + Dir ):DrG_Degrees( Ent:WorldSpaceCenter(), Center ) <= Ang * 0.5 or ( Feet + Dir ):DrG_Degrees( Ent:GetPos(), Feet ) <= Ang * 0.5

end



local function EntitiesInCone( self, Angles, Dist, Disp, Spotted ) -- Cleaned up.

  local Entities = {}

  for Ent in self:EntityIterator( Disp, Spotted ) do

    if self:IsInCone( Ent, Angles, Dist ) then

      TInsert( Entities, Ent )

    end

  end

  return Entities

end



local function UltrakillScaleDamage( Ent )

  if Ent:IsPlayer() then

    return MMax( GetConVar( "drg_ultrakill_plytakedmgmult" ):GetFloat(), 0 )

  elseif Ent.IsUltrakillNextbot then

    return 1

  else

    return MMax( GetConVar( "drg_ultrakill_dmgmult" ):GetFloat(), 0 )

  end

end



function ENT:Attack( Attack )

  Attack = Attack or {}
  Attack.Damage = Attack.Damage or 0
  Attack.Delay = Attack.Delay or 0
  Attack.Type = Attack.Type or DMG_GENERIC
  Attack.Force = Attack.Force or Vector( 100, 0, 0 )
  Attack.Viewpunch = Attack.Viewpunch or Angle( 10, 0, 0 )
  Attack.Range = Attack.Range or self.MeleeAttackRange
  Attack.Angle = Attack.Angle or 90
  Attack.Ignore = Attack.Ignore or {}

  local RadiantDamage = self:IsRadiant() and self:GetRadiantData().Damage or 1

  if Attack.Relationships == nil then Attack.Relationships = { D_HT, D_FR } end

  if not istable( Attack.Relationships ) then Attack.Relationships = { Attack.Relationships } end

  self:Timer( MClamp( Attack.Delay, 0, math.huge ), function( self )

    local Hit = {}

    for X, Ent in ipairs( EntitiesInCone( self, Attack.Angle, Attack.Range, Attack.Relationships ) ) do

      if Ent == self or not UltrakillBase.CanAttack( Ent ) or not self:Visible( Ent ) or Attack.Ignore[ Ent:EntIndex() ] then continue end

      local Trace = false

      local Origin = self:WorldSpaceCenter()

      local AimAt = Ent:WorldSpaceCenter()

      if isfunction( Attack.AimAt ) then

        local Res = Attack.AimAt( Ent )

        if isvector( Res ) then AimAt = Res end

      elseif isstring( Attack.AimAt ) then

        local BoneId = Ent:DrG_SearchBone( Attack.AimAt )

        if BoneId then AimAt = Ent:GetBonePosition( BoneId ) end

      end

      local Dmg = DamageInfo()

      Dmg:SetAttacker( self )

      Dmg:SetInflictor( self )

      Dmg:SetDamageType( Attack.Type )

      if Attack.Push and ( not Attack.Groundforce or Ent:IsOnGround() ) then

        Dmg:SetDamageForce( self:PushEntity( Ent, Attack.Force ) )

      else

        Dmg:SetDamageForce( self:CalcOffset( Attack.Force ) ) 

      end

      if isstring( Attack.Attachment ) or isnumber( Attack.Attachment ) then

        if isstring( Attack.Attachment ) then

          Attack.Attachment = self:LookupAttachment( Attack.Attachment )

        end

        local Attachment = self:GetAttachment( Attack.Attachment )

        if Attachment then

          if Attack.Trace then

            Trace = self:TraceLine( nil, {

              endpos = Attachment.Pos + Attachment.Pos:DrG_Direction( AimAt ),
              start = Attachment.Pos
              
            } )

          end

          Origin = Attachment.Pos

        end

      elseif isstring( Attack.Bone ) or isnumber( Attack.Bone ) then

        if isstring( Attack.Bone ) then Attack.Bone = self:LookupBone( Attack.Bone ) end

        if isnumber( Attack.Bone ) then

          local BonePos, BoneAngles = self:GetBonePosition( Attack.Bone )

          if Attack.Trace then

            Trace = self:TraceLine( nil, {

              endpos = BonePos + BonePos:DrG_Direction( AimAt ),
              start = BonePos

            } )

          end

          Origin = BonePos

        end

      elseif Attack.Trace then

        Trace = self:TraceLine( Origin:DrG_Direction( AimAt ) )

      end

      Dmg:SetDamage( ( isfunction( Attack.Damage ) and Attack.Damage( Ent, Origin ) or Attack.Damage ) * UltrakillScaleDamage( Ent ) * RadiantDamage )

      if Attack.Trace and Trace and Trace.Entity == Ent then

        Dmg:SetReportedPosition( Trace.HitPos )
        Dmg:SetDamagePosition( Trace.HitPos )
        Ent:DispatchTraceAttack( Dmg, Trace )

      else

        Dmg:SetReportedPosition( Origin )
        Dmg:SetDamagePosition( Ent:WorldSpaceCenter() )
        Ent:TakeDamageInfo( Dmg )

      end

      if Attack.Viewpunch and Ent:IsPlayer() then

        Ent:ViewPunch( Attack.Viewpunch )
          
      end

      if Ent:IsPlayer() then

        UltrakillBase.SetIFrames( Ent, UltrakillBase.CalculateIFrameTime( Ent, Attack.Damage * RadiantDamage ) )

      end

      if Attack.Damage * RadiantDamage >= 500 then

        UltrakillBase.SoundScript( "Ultrakill_Hit_Low", Ent:GetPos() )

      else

        UltrakillBase.SoundScript( "Ultrakill_Hit", Ent:GetPos() )

      end

      TInsert( Hit, Ent )

    end

    if isfunction( Attack.Callback ) then Attack.Callback( self, Hit ) end

  end )

end


function ENT:RayAttack( mAttack )

  mAttack = mAttack or {}
  mAttack.Damage = mAttack.Damage or 0
  mAttack.Type = mAttack.Type or DMG_GENERIC
  mAttack.Force = mAttack.Force or Vector( 100, 0, 0 )
  mAttack.Viewpunch = mAttack.Viewpunch or Angle( 10, 0, 0 )
  mAttack.Min = mAttack.Max and -mAttack.Max or -vDefaultBounds
  mAttack.Max = mAttack.Min and -mAttack.Min or vDefaultBounds
  mAttack.Ignore = mAttack.Ignore or {}

  local fRadiantDamage = self:IsRadiant() and self:GetRadiantData().Damage or 1
  local vOrigin = mAttack.Origin
  local vPos = mAttack.Pos

  if not isvector( vOrigin ) or not isvector( vPos ) then return end

  local mHit = {}
  local tEntities = EFindAlongRay( vOrigin, vPos, mAttack.Min, mAttack.Max )
  local aRayAngles = ( vPos - vOrigin )

  aRayAngles.z = 0
  aRayAngles = aRayAngles:Angle()

  mAttack.Force = mAttack.Force.x * aRayAngles:Forward() + mAttack.Force.y * aRayAngles:Right() + mAttack.Force.z * aRayAngles:Up()

  for K, mEntity in ipairs( tEntities ) do

    if mEntity == self or not UltrakillBase.CanAttack( mEntity ) or mAttack.Ignore[ mEntity:EntIndex() ] or not self:IsHostile( mEntity ) then continue end

    local CDamageInfo = DamageInfo()

    CDamageInfo:SetDamage( ( isfunction( mAttack.Damage ) and mAttack.Damage( mEntity ) or mAttack.Damage ) * UltrakillScaleDamage( mEntity ) * fRadiantDamage )
    CDamageInfo:SetDamageType( mAttack.Type )
    CDamageInfo:SetInflictor( self )
    CDamageInfo:SetAttacker( self )
    CDamageInfo:SetDamageForce( mAttack.Force )

    mEntity:TakeDamageInfo( CDamageInfo )

    if mAttack.Viewpunch and mEntity:IsPlayer() then mEntity:ViewPunch( mAttack.Viewpunch ) end
    if mEntity:IsPlayer() then UltrakillBase.SetIFrames( mEntity, UltrakillBase.CalculateIFrameTime( mEntity, mAttack.Damage * fRadiantDamage ) ) end

    if mAttack.Damage * fRadiantDamage >= 500 then UltrakillBase.SoundScript( "Ultrakill_Hit_Low", mEntity:GetPos() )
    else UltrakillBase.SoundScript( "Ultrakill_Hit", mEntity:GetPos() ) end

    self:PushEntity( mEntity, mAttack.Force )

    TInsert( mHit, mEntity )

  end

  if isfunction( mAttack.Callback ) then mAttack.Callback( self, mHit ) end

end

