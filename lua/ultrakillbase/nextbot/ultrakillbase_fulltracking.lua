if not ENT then return end

local istable = istable
local isstring = isstring
local UltrakillBase = UltrakillBase
local isnumber = isnumber


function ENT:SetFullTracking( bFullTracking )

  self:SetNW2Bool( "UltrakillBase_FullTracking", bFullTracking )

end


function ENT:GetFullTracking()

  return self:GetNW2Bool( "UltrakillBase_FullTracking" )

end


local function DoFullTracking( self, mTrackingBone )

  if isstring( mTrackingBone ) then mTrackingBone = self:DrG_SearchBone( mTrackingBone ) end

  local aTargetRotation = self:GetAimAngles()
  local fPitch = aTargetRotation.p

  aTargetRotation:Zero()
  aTargetRotation.z = fPitch

  local aRotation = self:GetManipulateBoneAngles( mTrackingBone )

  UltrakillBase.AngleApproach( aRotation, aTargetRotation, 600 * self:GetUpdateInterval() )

  self:ManipulateBoneAngles( mTrackingBone, aRotation, false )

end


local function ResetFullTracking( self, mTrackingBone )

  if isstring( mTrackingBone ) then mTrackingBone = self:DrG_SearchBone( mTrackingBone ) end

  self:ManipulateBoneAngles( mTrackingBone, angle_zero, false )

end


function ENT:CalculateFullTracking( mTrackingBone )

  if not self:DrG_SearchBone( mTrackingBone ) then return end

  if self:GetFullTracking() then

    DoFullTracking( self, mTrackingBone )
    return

  end

  ResetFullTracking( self, mTrackingBone )

end
