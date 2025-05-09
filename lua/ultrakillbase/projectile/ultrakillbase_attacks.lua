if not ENT or CLIENT then return end


local istable = istable
local IsValid = IsValid
local TInsert = table.insert
local MClamp = math.Clamp
local MMax = math.max
local GetConVar = GetConVar
local UltrakillBase = UltrakillBase
local DamageInfo = DamageInfo
local BBor = bit.bor
local isvector = isvector
local Vector = Vector
local Angle = Angle
local ipairs = ipairs
local EFindAlongRay = ents.FindAlongRay
local MCos = math.cos
local MRad = math.rad


function ENT:DamageFilter( Ent )
  
  local Owner = self:GetOwner()

  if Owner:IsPlayer() and Owner == Ent or Owner.IsUltrakillNextbot and not self.UltrakillBase_DamageRelationships[ self:GetRelationship( Ent ) ] then return false end

  return true

end



local function UltrakillScaleDamage( self, Ent )

  local Owner = self:GetOwner()

  if IsValid( Owner ) and Owner:IsPlayer() and Ent.IsUltrakillNextbot then

    return 40 * ( 1 / MClamp( UltrakillBase.ConVar_PlyDmgMult:GetFloat() * 10, 0, math.huge ) )

  elseif IsValid( Owner ) and Owner:IsPlayer() then
    
    return 1
    
  end

  if Ent:IsPlayer() then

    return MMax( GetConVar( "drg_ultrakill_plytakedmgmult" ):GetFloat(), 0 )

  elseif Ent.IsUltrakillNextbot then

    return 1

  else

    return MMax( GetConVar( "drg_ultrakill_dmgmult" ):GetFloat(), 0 )

  end

end



function ENT:DealDamage( Ent, Damage, Force, Type )

  if not self:DamageFilter( Ent ) or not UltrakillBase.CanAttack( Ent ) then return end

  local Dmg = DamageInfo()
  local Owner = self:GetOwner()
  local RadiantDamage = ( IsValid( Owner ) and Owner.IsUltrakillNextbot and Owner:IsRadiant() ) and Owner:GetRadiantData().Damage or 1

  Dmg:SetDamage( Damage * UltrakillScaleDamage( self, Ent ) * RadiantDamage )

  Dmg:SetDamageType( self:GetParried() and ( Type + DMG_DIRECT ) or Type )
  Dmg:SetDamagePosition( self:GetPos() )
  Dmg:SetAttacker( IsValid( Owner ) and Owner or self )
  Dmg:SetInflictor( self )

  if Ent:IsPlayer() then

    UltrakillBase.SetIFrames( Ent, UltrakillBase.CalculateIFrameTime( Ent, Damage * RadiantDamage ) )

  end

  if Damage * RadiantDamage >= 500 then

    UltrakillBase.SoundScript( "Ultrakill_Hit_Low", Ent:GetPos() )

  else

    UltrakillBase.SoundScript( "Ultrakill_Hit", Ent:GetPos() )

  end

  if not Ent.IsUltrakillProjectile and isvector( Force ) and not Force:IsZero() then

    Dmg:SetDamageForce( self:PushEntity( Ent, Force ) )

  end

  Ent:TakeDamageInfo( Dmg )
    
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

  local mOwner = self:GetOwner()
  local vOrigin = mAttack.Origin
  local vPos = mAttack.Pos

  if not isvector( vOrigin ) or not isvector( vPos ) or not IsValid( mOwner ) then return end

  local mHit = {}
  local fRadiantDamage = mOwner:IsRadiant() and mOwner:GetRadiantData().Damage or 1
  local tEntities = EFindAlongRay( vOrigin, vPos, mAttack.Min, mAttack.Max )
  local aRayAngles = ( vPos - vOrigin )

  aRayAngles.z = 0
  aRayAngles = aRayAngles:Angle()

  mAttack.Force = mAttack.Force.x * aRayAngles:Forward() + mAttack.Force.y * aRayAngles:Right() + mAttack.Force.z * aRayAngles:Up()

  for K, mEntity in ipairs( tEntities ) do

    if mEntity == mOwner or not self:DamageFilter( mEntity ) or not UltrakillBase.CanAttack( mEntity ) or mAttack.Ignore[ mEntity:EntIndex() ] then continue end

    local CDamageInfo = DamageInfo()

    CDamageInfo:SetDamage( ( isfunction( mAttack.Damage ) and mAttack.Damage( mEntity ) or mAttack.Damage ) * UltrakillScaleDamage( self, mEntity ) * fRadiantDamage )
    CDamageInfo:SetDamageType( mAttack.Type )
    CDamageInfo:SetInflictor( self )
    CDamageInfo:SetAttacker( mOwner )
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