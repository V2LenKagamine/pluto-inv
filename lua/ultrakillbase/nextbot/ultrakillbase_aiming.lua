if not ENT then return end


local istable = istable
local isvector = isvector
local Vector = Vector
local IsValid = IsValid
local UltrakillBase = UltrakillBase
local isentity = isentity
local isnumber = isnumber


function ENT:SetTurning( Bool )

  return self:SetNW2Bool( "UltrakillBase_Turning", Bool )

end

function ENT:GetTurning()

  return self:GetNW2Bool( "UltrakillBase_Turning" )

end

function ENT:IsTurning()

  return self:GetTurning()

end




function ENT:SetAimAngles( Angles )

  self:SetNW2Angle( "UltrakillBase_AimAngles", Angles )

end

function ENT:GetAimAngles()

  return self:GetNW2Angle( "UltrakillBase_AimAngles" )

end

function ENT:GetAimVector()

  return self:GetAimAngles():Forward()

end



--[[ 

  Helper Functions for Check is the Nextbot is looking somewhere.

--]] 



function ENT:IsLookingAt( Vec, Threshold, Base )

  if not isvector( Base ) then Base = self:GetAimVector() end

  return Base:Dot( Vec ) >= Threshold

end



function ENT:IsLookingAround( Vec, Threshold, Base )

  if not isvector( Base ) then Base = self:GetAimVector() end

  return Base:Dot( Vec ) >= Threshold

end



function ENT:IsLookingDown( Threshold, Base )

  return self:IsLookingAt( Vector( 0, 0, -1 ), Threshold, Base )

end



function ENT:IsLookingUp( Threshold, Base )

  return self:IsLookingAt( Vector( 0, 0, 1 ), Threshold, Base )

end



function ENT:GetAimEnemy()

  if not self:HasEnemy() then return end

  return ( self:GetEnemy():WorldSpaceCenter() - self:WorldSpaceCenter() ):GetNormalized()

end



if SERVER then


local function CalculateSpread( self, Proj, Vec, Offset )

  local DirectionProj = ( Vec - Proj:WorldSpaceCenter() ):GetNormalized()

  local NewOffset = Vector()

  NewOffset:Set( Offset or vector_origin )

  NewOffset:Rotate( DirectionProj:Angle() )

  return Proj:WorldSpaceCenter() + DirectionProj * 500 + NewOffset

end


  
local function IsInFov( self, Pos )

  return ( self:WorldSpaceCenter() + ( self:GetFullTracking() and self:GetAimVector() or self:GetForward() ) ):DrG_Degrees( Pos, self:WorldSpaceCenter()  ) <= ( self:GetSightFOV() / 2 )

end



function ENT:AimProjectile( Proj, Speed, Offset, UseFov )

  Speed = Speed * self:CalculateAnimRate()

  if self:IsPossessed() then

    local LockedOn = self:PossessionGetLockedOn()

    if not IsValid( LockedOn ) then

      local DesiredPos = CalculateSpread( self, Proj, self:PossessorTrace().HitPos, Offset )

      return Proj:DrG_AimAt( DesiredPos, Speed )

    else

      local DesiredPos = CalculateSpread( self, Proj, LockedOn:WorldSpaceCenter(), Offset )

      return Proj:DrG_AimAt( DesiredPos, Speed )

    end

  elseif self:HasEnemy() then

    local Enemy = self:GetEnemy()

    local Pos = Enemy:IsPlayer() and UltrakillBase.GetEntityEyePos( Enemy ) or Enemy:WorldSpaceCenter()

    if not IsInFov( self, Pos ) and UseFov then

      Pos = self:WorldSpaceCenter() + self:GetForward() * 500

    end

    local DesiredPos = CalculateSpread( self, Proj, Pos, Offset )

    return Proj:DrG_AimAt( DesiredPos, Speed ) 

  elseif self:HadEnemy() then

    self:UpdateEnemy()

    return self:AimProjectile( Proj, Speed, Offset )

  else

    local DesiredPos = CalculateSpread( self, Proj, self:WorldSpaceCenter() + self:GetAimVector() * 500, Offset )

    return Proj:DrG_AimAt( DesiredPos, Speed )

  end

end





--[[ 



  Overhauled Aiming Code. 2023-03-23.

  This functions identically to Nextbot Locomotion's FaceTowards.



--]] 




function ENT:InitializeAiming()

  self:SetAimAngles( self:GetAngles() )

end



function ENT:AimTowards( Target )

  if isentity( Target ) then

    Target = Target:WorldSpaceCenter()

  end

  local Angles = self:GetAimAngles()

  local Desired = ( Target - self:WorldSpaceCenter() ):Angle()

  UltrakillBase.AngleApproach( Angles, Desired, self:GetMaxYawRate() * self:GetUpdateInterval() )

  self:SetAimAngles( Angles )

end



function ENT:LookTowards( Pos )

  self:AimTowards( Pos )
  self:FaceTowards( Pos )

end




function ENT:AimInstant( Pos )

  if isentity( Pos ) then

    Pos = Pos:WorldSpaceCenter() 

  end

  local Desired = ( Pos - self:WorldSpaceCenter() ):Angle()

  self:SetAimAngles( Desired )

end




function ENT:LookInstant( Pos )

  self:AimInstant( Pos )
  self:FaceInstant( Pos )

end

function ENT:PossessionFaceForward()

  if not self:IsPossessed() then return end

  local LockedOn = self:PossessionGetLockedOn()

  if not IsValid( LockedOn ) then

    self:LookTowards( self:WorldSpaceCenter() + self:PossessorNormal() )

  else

    self:LookTowards( LockedOn )

  end

end


function ENT:PossessionFaceForwardInstant()

  if not self:IsPossessed() then return end

  local LockedOn = self:PossessionGetLockedOn()

  if not IsValid( LockedOn ) then

    self:LookInstant( self:WorldSpaceCenter() + self:PossessorNormal() )

  else

    self:LookInstant( LockedOn )

  end

end


--[[ 

  Rewrite Functions to use LookTowards.

--]] 


function ENT:FaceEnemy( Predict )

  if self:IsPossessed() and not self:HasEnemy() then

    return self:PossessionFaceForward()

  end

  if not isnumber( Predict ) or Predict <= 0 then

    if self:HasEnemy() then

      self:LookTowards( self:GetEnemy() )

    end

  else

    if self:HasEnemy() then

      self:LookTowards( UltrakillBase.Predict( self:GetEnemy(), Predict ) ) 

    end

  end

end



function ENT:FaceEnemyInstant( Predict )

  if self:IsPossessed() and not self:HasEnemy() then

    return self:PossessionFaceForwardInstant()

  end

  if not isnumber( Predict ) or Predict <= 0 then

    if self:HasEnemy() then

      self:LookInstant( self:GetEnemy() ) 

    end

  else

    if self:HasEnemy() then

      self:LookInstant( UltrakillBase.Predict( self:GetEnemy(), Predict ) ) 

    end

  end

end



end