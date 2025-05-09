local Angle = Angle
local MAngleDifference = math.AngleDifference
local isvector = isvector
local MApproachAngle = math.ApproachAngle

function UltrakillBase.AngleDifference( self, TargetAngle )

  local AngleDifference = Angle()

  for X = 1, 3 do

    AngleDifference[ X ] = MAngleDifference( TargetAngle[ X ], self[ X ] )

  end

  return AngleDifference

end



function UltrakillBase.AngleApproach( self, TargetAngle, Rate )

  if isvector( self ) then self = self:Angle() end
  if isvector( TargetAngle ) then TargetAngle = TargetAngle:Angle() end

  for X = 1, 3 do

    self[ X ] = MApproachAngle( self[ X ], TargetAngle[ X ], Rate )

  end

end