if not ENT or CLIENT then return end


local istable = istable
local MMin = math.min
local MMax = math.max
local Vector = Vector
local isvector = isvector
local UltrakillBase = UltrakillBase
local isangle = isangle
local ECreate = SERVER and ents.Create
local isentity = isentity
local IsValid = IsValid
local EffectData = EffectData
local UEffect = util.Effect
local type = type
local Angle = Angle
local MRandom = math.random
local DamageInfo = DamageInfo
local UScreenShake = util.ScreenShake


function ENT:Height()

	local Min, Max = self:GetCollisionBounds()

	return MMax( Min.z, Max.z )

end


local GroundAngleVectorOffset = Vector()


function ENT:GetGroundAngles( Pos )

  local HitNormal, HitPos

  if not isvector( Pos ) and self:IsNextBot() then

    HitNormal = self.loco:GetGroundNormal()
    HitPos = self:GetPos()

  else

    GroundAngleVectorOffset.z =  self:Height() * 0.5

    local Trace = self:TraceLine( nil, {

      start = Pos + GroundAngleVectorOffset,
      endpos = Pos - self:GetUp() * 10000,
      collisiongroup = COLLISION_GROUP_WORLD,
      mask = MASK_NPCSOLID_BRUSHONLY,
      filter = self,

    } )

    HitNormal = Trace.HitNormal
    HitPos = Trace.HitPos

  end

  HitNormal = HitNormal:Angle()
  UltrakillBase.ReAngleHitNormal( HitNormal, self )

  return HitNormal, HitPos

end


function ENT:Shockwave( Active, Pos, Ang, Damage, Time, Radius, ScaleZ, IgnoreFilter )

  if not isvector( Pos ) then Pos = self:GetPos() end
  if not isangle( Ang ) then Ang = self:GetAngles() end

  local Shockwave = ECreate( "UltrakillBase_Shockwave" )
        
  Shockwave:SetOwner( self )
  Shockwave:SetPos( Pos )
  Shockwave:SetAngles( Ang )

  Shockwave.mDamage = Damage
  Shockwave:SetTime( Time )
  Shockwave:SetRadius( Radius )
  Shockwave:SetScaleZ( ScaleZ )

  Shockwave:SetSkin( Active and 0 or 1 )

  Shockwave.UltrakillBase_IgnoreFilter = IgnoreFilter or {}

  Shockwave:Spawn()

  Shockwave:ScreenShake( 2500, 10, Time, 6500 )

  local SoundID = Time > 1 and "Ultrakill_Shockwave" or "Ultrakill_Shockwave_Short"

  UltrakillBase.SoundScript( SoundID, Shockwave:GetPos(), Shockwave )

  return Shockwave

end


function ENT:VirtueBeam( vPos, aAng, fDamage, fTime, fRadius )



end



function ENT:Explosion( Pos, Damage, Force, Radius, Time, Owner, Parry, IgnoreFilter )

  if isentity( Pos ) then Pos = Pos:WorldSpaceCenter() end

  Owner = IsValid( Owner ) and Owner or self

  local mExplosion = ECreate( "UltrakillBase_Explosion" )

  mExplosion.mDamage = Damage
  mExplosion.mForce = Force
  mExplosion.mDieTime = Time
  mExplosion.mRadius = Radius
  mExplosion.mDamageType = Parry and DMG_BLAST + DMG_DIRECT or DMG_BLAST

  mExplosion:SetOwner( Owner )
  mExplosion:SetPos( Pos )

  mExplosion.UltrakillBase_IgnoreFilter = IgnoreFilter or {}

  mExplosion:Spawn()

  return mExplosion

end


local TypeToSoundID = {

  "Ultrakill_AlertParryable",
  "Ultrakill_AlertUnParryable",
  "Ultrakill_AlertParryable_Projectile",

}


function ENT:CreateAlert( Pos, AlertType, Radius )

  if isentity( Pos ) and Pos.EyePos then Pos:EyePos() end
  if Pos == nil then Pos = self:EyePos() end

  local CEffectData = EffectData()

    CEffectData:SetOrigin( Pos )
    CEffectData:SetRadius( Radius * 100 )
    CEffectData:SetFlags( AlertType )

  UEffect( "Ultrakill_Alert", CEffectData, true, true )

  UltrakillBase.SoundScript( TypeToSoundID[ AlertType or 1 ], self:GetPos(), self )

end


function ENT:CreateAlertFollow( Parent, AlertType, Radius, Attachment )

  if isentity( Pos ) and Pos.EyePos then Pos:EyePos() end
  if Pos == nil then Pos = self:EyePos() end

  local CEffectData = EffectData()

    CEffectData:SetEntity( Parent )
    CEffectData:SetAttachment( Attachment )
    CEffectData:SetRadius( Radius * 100 )
    CEffectData:SetFlags( AlertType )

  UEffect( "Ultrakill_AlertFollow", CEffectData, true, true )

  UltrakillBase.SoundScript( TypeToSoundID[ AlertType or 1 ], self:GetPos(), self )

end



function ENT:CreateRubble( Pos, Ang, Radius )

  if isentity( Pos ) then Pos:GetPos() end
  if Pos == nil then Pos = self:GetPos() end
  if Ang == nil then Ang = self:GetAngles() end
  if Radius == nil then Radius = 1 end

  local CEffectData = EffectData()

    CEffectData:SetOrigin( Pos )
    CEffectData:SetAngles( Ang )
    CEffectData:SetRadius( Radius * 100 )

  UEffect( "Ultrakill_Rubble", CEffectData, true, true )

end


function ENT:CreateRubbleLine( vOrigin, vPos, aRotation, fRadius )

  if isentity( vPos ) then vPos:GetPos() end
  if vOrigin == nil then vOrigin = self:GetPos() end
  if aRotation == nil then aRotation = self:GetAngles() end
  if fRadius == nil then fRadius = 1 end

  local CEffectData = EffectData()

    CEffectData:SetOrigin( vOrigin )
    CEffectData:SetStart( vPos )
    CEffectData:SetAngles( aRotation )
    CEffectData:SetRadius( fRadius * 100 )

  UEffect( "Ultrakill_Rubble_Line", CEffectData, true, true )

end


function ENT:CreateBigRubble( Pos, Ang, Radius )

  if isentity( Pos ) then Pos:GetPos() end
  if Pos == nil then Pos = self:GetPos() end
  if Ang == nil then Ang = self:GetAngles() end
  if Radius == nil then Radius = 1 end

  local CEffectData = EffectData()

    CEffectData:SetOrigin( Pos )
    CEffectData:SetAngles( Ang )
    CEffectData:SetRadius( Radius * 100 )

  UEffect( "Ultrakill_BigRubble", CEffectData, true, true )

end


function ENT:CreateSoftExplosion( Pos, Ang, Radius )

  if isentity( Pos ) then Pos:GetPos() end
  if Pos == nil then Pos = self:GetPos() end
  if Ang == nil then Ang = self:GetAngles() end
  if Radius == nil then Radius = 1 end

  local CEffectData = EffectData()

    CEffectData:SetOrigin( Pos )
    CEffectData:SetAngles( Ang )
    CEffectData:SetRadius( Radius * 100 )

  UEffect( "Ultrakill_Soft_Explosion", CEffectData, true, true )

end


function ENT:CreateExplosion( Pos, Ang, Radius )

  if isentity( Pos ) then Pos:GetPos() end
  if Pos == nil then Pos = self:GetPos() end
  if Ang == nil then Ang = self:GetAngles() end
  if Radius == nil then Radius = 1 end

  local CEffectData = EffectData()

    CEffectData:SetOrigin( Pos )
    CEffectData:SetAngles( Ang )
    CEffectData:SetRadius( Radius * 100 )

  UEffect( "Ultrakill_Explosion", CEffectData, true, true )

end


function ENT:CreateHardExplosion( Pos, Ang, Radius )

  if isentity( Pos ) then Pos:GetPos() end
  if Pos == nil then Pos = self:GetPos() end
  if Ang == nil then Ang = self:GetAngles() end
  if Radius == nil then Radius = 1 end

  local CEffectData = EffectData()

    CEffectData:SetOrigin( Pos )
    CEffectData:SetAngles( Ang )
    CEffectData:SetRadius( Radius * 100 )

  UEffect( "Ultrakill_Hard_Explosion", CEffectData, true, true )

end


function ENT:CreatePortal( Pos, Ang, ColorIndex, PortalBounds )

  local CEffectData = EffectData()

    CEffectData:SetEntity( self )
    CEffectData:SetOrigin( Pos )
    CEffectData:SetAngles( Ang )
    CEffectData:SetColor( ColorIndex )
    CEffectData:SetStart( PortalBounds )

  UEffect( "Ultrakill_Portal", CEffectData, true, true )

end


function ENT:CreateBlood( CDamageInfo, HitGroup )

  if type( CDamageInfo ) ~= "CTakeDamageInfo" or CDamageInfo:GetDamage() <= 0 then return end

  local Amount = MMax( 1, 0.75 * ( CDamageInfo:GetDamage() / self:GetDamageMultiplierConVar( CDamageInfo:GetAttacker() ) - 5 ) )

  local Pos = CDamageInfo:GetDamagePosition()
  local SCenter = self:WorldSpaceCenter()
  local DistSqr = Pos:DistToSqr( SCenter )

  if DistSqr > self:GetModelRadius() * self:GetModelRadius() * 0.81 then Pos = SCenter end

  if self:IsSand() then

    UltrakillBase.CreateSand( Pos, MMin( Amount, 32 ) )

  else

    UltrakillBase.CreateBlood( Pos, MMin( Amount, 48 ) )

  end


  local GibsInfo = {}
  local FScale = 1.1 + ( self:GetModelRadius() * 0.0025 )


  for I = 1, 0.1 * MMin( Amount + 1, 20 ) do

    GibsInfo[ I ] = {}

    GibsInfo[ I ].Position = Pos
    GibsInfo[ I ].Models = UltrakillBase.Gibs_Flesh
    GibsInfo[ I ].Velocity = 200
    GibsInfo[ I ].ModelScale = FScale

  end


  UltrakillBase.CreateGibs( GibsInfo )


end


function ENT:RepelRockets( Rpg )

  local Dir = ( self:WorldSpaceCenter() - Rpg:WorldSpaceCenter() ):GetNormalized()

  local Random = { -1, 1 }

  Dir:Rotate( Angle( 0, 90 * Random[ MRandom( #Random ) ], 0 ) )

  UltrakillBase.SoundScript( "Ultrakill_Deflect", self:GetPos(), self )

  local Dmg = DamageInfo()

  Dmg:SetDamage( 1000 )
  Dmg:SetDamageForce( Dir * 5000 )
  Dmg:SetDamageType( DMG_MISSILEDEFENSE )
  Dmg:SetAttacker( self )
  Dmg:SetInflictor( self )
  Rpg:TakeDamageInfo( Dmg )

  Rpg:SetPos( Rpg:GetPos() + Dir * 200 )
  Rpg:SetAngles( Dir:Angle() )

end


function ENT:ScreenShake( Amp, Freq, Duration, Radius )

  return UScreenShake( self:GetPos(), Amp, Freq, Duration, Radius, true )

end