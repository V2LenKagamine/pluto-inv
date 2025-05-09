local Vector = Vector
local MSin = math.sin
local MRand = math.Rand
local CurTime = CurTime
local MApproach = math.Approach
local Angle = Angle
local isentity = isentity


function UltrakillBase.VectorNoise( Amp, Freq, Offset )

  local Vec = Vector()

  for X = 1, 3 do

    Vec[ X ] = MSin( ( MRand( -Offset, Offset ) + CurTime() ) * Freq ) * Amp

  end

  return Vec

end


function UltrakillBase.VectorApproach( self, TargetVec, Rate )

  for X = 1, 3 do

    self[ X ] = MApproach( self[ X ], TargetVec[ X ], Rate )

  end

end


function UltrakillBase.VectorNearGround( self, vPos )

  local mResult = self:TraceLine( nil, {

    start = vPos + vector_up * 50,
    endpos = vPos - vector_up * 120,
    collisiongroup = COLLISION_GROUP_WORLD

  } )

  return mResult.Hit, mResult

end


local FixedOffset = Angle( 90, 180, 180 )


function UltrakillBase.ReAngleHitNormal( HitNormal, YawOffset )

  if isentity( YawOffset ) then YawOffset = YawOffset:GetAngles().y end

  HitNormal:RotateAroundAxis( HitNormal:Right(), FixedOffset.x )
  HitNormal:RotateAroundAxis( HitNormal:Forward(), FixedOffset.y )
  HitNormal:RotateAroundAxis( HitNormal:Up(), FixedOffset.z + YawOffset )

end