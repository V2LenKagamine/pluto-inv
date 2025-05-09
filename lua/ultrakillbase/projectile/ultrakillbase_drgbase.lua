if not ENT or CLIENT then return end


local istable = istable
local ipairs = ipairs
local IsValid = IsValid
local isentity = isentity
local Vector = Vector
local Angle = Angle
local UltrakillBase = UltrakillBase


local function LocoJump( self )

  local Seq = self:GetSequence()
  local Cycle = self:GetCycle()
  local Rate = self:GetPlaybackRate()

  self.loco:Jump()
  self:ResetSequence( Seq )
  self:SetPlaybackRate( Rate )
  self:SetCycle( Cycle )

end


local function LeaveGround( self )

  if not self:IsOnGround() then return end
  
  local JumpHeight = self.loco:GetJumpHeight()
  
  self.loco:SetJumpHeight( 1 )
  
  LocoJump( self )
  
  self.loco:SetJumpHeight( JumpHeight )
  
end


function ENT:PushEntity( Ent, Force )

  if istable( Ent ) then

    local Vecs = {}

    for K, V in ipairs( Ent ) do

      if not IsValid( V ) then continue end

      Vecs[ V:EntIndex() ] = self:PushEntity( V, Force )

    end

    return Vecs

  elseif isentity( Ent ) and IsValid( Ent ) then

    local Direction = self:GetPos():DrG_Direction( Ent:GetPos() )

    if Ent:IsPlayer() and Ent:InVehicle() then return Vector() end

    local VecForward = Direction

    VecForward.z = 0

    VecForward:Normalize()

    local VecRight = Vector()

    VecRight:Set( VecForward )

    VecRight:Rotate( Angle( 0, -90, 0 ) )

    local VecUp = Vector( 0, 0, 1 )

    local Vec = VecForward * Force.x + VecRight * Force.y + VecUp * Force.z

    local Phys = Ent:GetPhysicsObject()
    
    if not UltrakillBase.GetWeightData( Ent ).Push then return Vec end

    if Ent.IsDrGNextbot then

      LeaveGround( Ent )

      Ent:SetVelocity( Ent:GetVelocity() + Vec )

    elseif Ent.Type == "nextbot" then

      LeaveGround( Ent )

      Ent.loco:SetVelocity( Ent.loco:GetVelocity() + Vec )

    elseif IsValid( Phys ) and not Ent:IsPlayer() then

      Phys:AddVelocity( Vec )

    else

      Ent:SetVelocity( Ent:GetVelocity() + Vec )

    end

    return Vec

  end

end



function ENT:IsInRange( Pos, Range )

  if isentity( Pos ) and not IsValid( Pos ) then

    return false

  end

  return self:GetHullRangeSquaredTo( Pos ) <= ( Range * self:GetModelScale() ) ^ 2

end



function ENT:GetHullRangeSquaredTo( Pos )

  if isentity( Pos ) then Pos = Pos:NearestPoint( self:GetPos() ) end

  return self:GetPos():DistToSqr( Pos )

end

