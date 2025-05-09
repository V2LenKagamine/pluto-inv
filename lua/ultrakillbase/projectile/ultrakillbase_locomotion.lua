local istable = istable
local IsValid = IsValid

if not ENT then return end


local MaxDecel = 10000
local MaxAccel = 10000


function ENT:AddVelocity( AddVel )

  local Phys = self:GetPhysicsObject()

  if not IsValid( Phys ) then 
    
    return self:SetVelocity( self:GetVelocity() + AddVel ) 
  
  else

    return Phys:AddVelocity( AddVel )

  end

end


function ENT:Approach( Goal, MaxSpeed )

  local DeltaT = self:GetUpdateInterval()

  local m_MoveVector = ( Goal - self:GetPos() ):GetNormalized()
  local m_Velocity = self:GetVelocity()

  local ForwardSpeed = m_Velocity:Dot( m_MoveVector )

  local Decel = self.Deceleration or 10000
  local Accel = self.Acceleration or 10000

  local Ratio = ( ForwardSpeed <= 0 ) and 0 or ( ForwardSpeed / MaxSpeed )
  local DecelRatio = ( Decel <= 0 ) and 0 or ( Decel / MaxDecel )
  local AccelRatio = ( Accel <= 0 ) and 0 or ( Accel / MaxAccel )

  local Acceleration = m_MoveVector * MaxSpeed * ( 1 - Ratio ^ 4 ) * AccelRatio
  local Deceleration = self:GetVelocity() * ( 1 - ( DecelRatio ^ 4 ) * DeltaT )

  self:SetVelocity( Deceleration + Acceleration * DeltaT )

end