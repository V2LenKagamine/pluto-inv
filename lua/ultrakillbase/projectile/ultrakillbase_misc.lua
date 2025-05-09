local istable = istable
local IsValid = IsValid

if not ENT then return end


function ENT:AngleFollowVelocity()

  local PhysObject = self:GetPhysicsObject()
  local Velocity = self:GetVelocity()

  if not IsValid( PhysObject ) then return self:SetAngles( Velocity:Angle() ) end

  PhysObject:SetAngles( Velocity:Angle() )
  PhysObject:SetAngleVelocity( vector_origin )

end


function ENT:HaltVelocity()

  local PhysObject = self:GetPhysicsObject()

  if IsValid( PhysObject ) then

    PhysObject:SetAngleVelocity( vector_origin )
    PhysObject:SetVelocity( vector_origin )

  else

    self:SetVelocity( vector_origin )

  end

end

