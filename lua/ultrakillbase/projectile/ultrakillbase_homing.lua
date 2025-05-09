if not ENT then return end


local istable = istable
local IsValid = IsValid
local isentity = isentity
local UltrakillBase = UltrakillBase
local MMin = math.min
local MClamp = math.Clamp
local MApproach = math.Approach
local fDistancePredictive = 150


/*function ENT:Homing( vPos, fSpeed, fRate )

  if not IsValid( vPos ) then return end
  if isentity( vPos ) then vPos = UltrakillBase.GetEntityEyePos( vPos ) end

  local vDir = ( vPos - self:GetPos() ):Angle()
  local vCurDir = self.UltrakillBase_ProjectileAngle and self.UltrakillBase_ProjectileAngle or self:GetAngles()

  UltrakillBase.AngleApproach( vCurDir, vDir, fRate * self:GetUpdateInterval() )
  self.UltrakillBase_ProjectileAngle = vCurDir

  self:SetVelocity( vCurDir:Forward() * fSpeed )

end


function ENT:HomingGravity( vPos, fSpeed, fGravity, fRate, fDampingCoefficient, fAcceleration )

  if not IsValid( vPos ) then return end
  if isentity( vPos ) then vPos = UltrakillBase.GetEntityEyePos( vPos ) end

  local fDeltaT = self:GetUpdateInterval()
  local vDir = ( vPos - self:GetPos() ):Angle()
  local vCurDir = self.UltrakillBase_ProjectileAngle and self.UltrakillBase_ProjectileAngle or self:GetAngles()

  UltrakillBase.AngleApproach( vCurDir, vDir, fRate * self:GetUpdateInterval() )
  self.UltrakillBase_ProjectileAngle = vCurDir

  local vVelocity = self:GetVelocity()
  local vAcceleration = vCurDir:Forward() * fSpeed * fDeltaT * fAcceleration

  vAcceleration.z = vAcceleration.z - fGravity * fDeltaT

  vVelocity.x = vVelocity.x - vVelocity.x * fDampingCoefficient * fDeltaT
  vVelocity.y = vVelocity.y - vVelocity.y * fDampingCoefficient * fDeltaT
  vAcceleration.z = MMin( 0, vAcceleration.z - vAcceleration.z * fDampingCoefficient * fDeltaT ) -- Z Acceleration should be heavily damped.

  self:SetVelocity( vVelocity + vAcceleration )

end*/


local function ClampLength( vVector, fMax )

    local fSqrLength = vVector:LengthSqr()

    if fSqrLength > fMax * fMax then

        return vVector:GetNormalized() * fMax

    end

    return vVector

end


function ENT:GradualHoming()

    local fPredictiveMultiplier = self.UltrakillBase_HomingPredictiveMultiplier
    local fDeltaTime = self:GetUpdateInterval()
    local mTarget = self:GetEnemy()
    local vPos = UltrakillBase.GetEntityEyePos( mTarget )
    local vOrigin = self:GetPos()
    local fSpeedMultiplier = 100

    if vOrigin:DistToSqr( vPos ) >= fDistancePredictive * fDistancePredictive then fPredictiveMultiplier = 0 end

    if self.UltrakillBase_Difficulty == 0 then

        self.UltrakillBase_HomingMaxSpeed = self.UltrakillBase_HomingMaxSpeed + fDeltaTime * 350
        fSpeedMultiplier = 100

    elseif self.UltrakillBase_Difficulty == 1 then

        self.UltrakillBase_HomingMaxSpeed = self.UltrakillBase_HomingMaxSpeed + fDeltaTime * 612.5
        fSpeedMultiplier = 135

    else

        self.UltrakillBase_HomingMaxSpeed = self.UltrakillBase_HomingMaxSpeed + fDeltaTime * 875
        fSpeedMultiplier = self.UltrakillBase_Difficulty == 2 and 185 or 200

    end

    local aTo = ( vPos + mTarget:GetVelocity() * fPredictiveMultiplier - vOrigin ):Angle()

    UltrakillBase.AngleApproach( self.UltrakillBase_ProjectileAngle, aTo, fDeltaTime * fSpeedMultiplier * self.UltrakillBase_HomingTurningMultiplier )

    self:SetVelocity( self.UltrakillBase_ProjectileAngle:Forward() * self.UltrakillBase_HomingMaxSpeed )

end


function ENT:InstantHoming()

    local fPredictiveMultiplier = self.UltrakillBase_HomingPredictiveMultiplier
    local fDeltaTime = self:GetUpdateInterval()
    local mTarget = self:GetEnemy()
    local vPos = UltrakillBase.GetEntityEyePos( mTarget )
    local vOrigin = self:GetPos()
    local fSpeedMultiplier = 100

    if vOrigin:DistToSqr( vPos ) >= fDistancePredictive * fDistancePredictive then fPredictiveMultiplier = 0 end

    if self.UltrakillBase_Difficulty == 0 then

        fSpeedMultiplier = 100

    elseif self.UltrakillBase_Difficulty == 1 then

        fSpeedMultiplier = 135

    elseif self.UltrakillBase_Difficulty == 2 then

        fSpeedMultiplier = 185

    else

        fSpeedMultiplier = 200

    end

    local aTo = ( vPos + mTarget:GetVelocity() * fPredictiveMultiplier - vOrigin ):Angle()

    UltrakillBase.AngleApproach( self.UltrakillBase_ProjectileAngle, aTo, fDeltaTime * fSpeedMultiplier * self.UltrakillBase_HomingTurningMultiplier )

    self:SetVelocity( self.UltrakillBase_ProjectileAngle:Forward() * self.UltrakillBase_HomingSpeed )

end


function ENT:LooseHoming()

    local fPredictiveMultiplier = self.UltrakillBase_HomingPredictiveMultiplier
    local fDeltaTime = self:GetUpdateInterval()
    local mTarget = self:GetEnemy()
    local vPos = UltrakillBase.GetEntityEyePos( mTarget )
    local vOrigin = self:GetPos()

    if vOrigin:DistToSqr( vPos ) >= fDistancePredictive * fDistancePredictive then fPredictiveMultiplier = 0 end

    self.UltrakillBase_HomingMaxSpeed = self.UltrakillBase_HomingMaxSpeed + fDeltaTime * 80

    local aRotation = ( vOrigin + self:GetVelocity() )
    local vDirection = ( vPos + mTarget:GetVelocity() * fPredictiveMultiplier - vOrigin ):GetNormalized()

    self:AddVelocity( ClampLength( vDirection * self.UltrakillBase_HomingSpeed * fDeltaTime * fDeltaTime * 200, self.UltrakillBase_HomingMaxSpeed ) )

end


function ENT:HorizontalOnlyHoming()

    local fPredictiveMultiplier = self.UltrakillBase_HomingPredictiveMultiplier
    local fTurnSpeed = self.UltrakillBase_HomingTurningSpeed
    local fDeltaTime = self:GetUpdateInterval()
    local mTarget = self:GetEnemy()
    local vPos = UltrakillBase.GetEntityEyePos( mTarget )
    local vOrigin = self:GetPos()
    local vVelocity = self:GetVelocity()

    if vOrigin:DistToSqr( vPos ) >= fDistancePredictive * fDistancePredictive then fPredictiveMultiplier = 0 end

    local vTransform2D = vPos + mTarget:GetVelocity() * fPredictiveMultiplier
    vTransform2D.z = vOrigin.z

    local fAxisX = MClamp( vTransform2D.x - vOrigin.x, -self.UltrakillBase_HomingTurningSpeed, self.UltrakillBase_HomingTurningSpeed )
    local fAxisY = MClamp( vTransform2D.y - vOrigin.y, -self.UltrakillBase_HomingTurningSpeed, self.UltrakillBase_HomingTurningSpeed )

    if vOrigin:DistToSqr( vTransform2D ) < self.UltrakillBase_HomingTurningSpeed * self.UltrakillBase_HomingTurningSpeed * 0.05 * 0.05 then

        fAxisX = ( vTransform2D - vOrigin ).x
        fAxisY = ( vTransform2D - vOrigin ).y

    end

    local fSpeedMultiplier = 200

    if self.UltrakillBase_Difficulty == 0 then

        fSpeedMultiplier = 70

    elseif self.UltrakillBase_Difficulty == 1 then

        fSpeedMultiplier = 135

    elseif self.UltrakillBase_Difficulty >= 3 then

        fSpeedMultiplier = 350

    end

    vVelocity.x = MApproach( vVelocity.x, fAxisX, fDeltaTime * fSpeedMultiplier * self.UltrakillBase_HomingTurningMultiplier )
    vVelocity.y = MApproach( vVelocity.y, fAxisY, fDeltaTime * fSpeedMultiplier * self.UltrakillBase_HomingTurningMultiplier )

    self:SetVelocity( vVelocity )

end


function ENT:DefaultHoming()

    local fPredictiveMultiplier = self.UltrakillBase_HomingPredictiveMultiplier
    local fDeltaTime = self:GetUpdateInterval()
    local mTarget = self:GetEnemy()
    local vPos = UltrakillBase.GetEntityEyePos( mTarget )

    if self:GetPos():DistToSqr( vPos ) >= 100 * 100 then fPredictiveMultiplier = 0 end

    self.UltrakillBase_HomingMaxSpeed = self.UltrakillBase_HomingMaxSpeed + fDeltaTime * 120

    local aTo = ( vPos + mTarget:GetVelocity() * fPredictiveMultiplier - self:GetPos() ):Angle()

    UltrakillBase.AngleApproach( self.UltrakillBase_ProjectileAngle, aTo, fDeltaTime * self.UltrakillBase_HomingTurningSpeed )

    self:SetVelocity( self.UltrakillBase_ProjectileAngle:Forward() * self.UltrakillBase_HomingMaxSpeed )

end