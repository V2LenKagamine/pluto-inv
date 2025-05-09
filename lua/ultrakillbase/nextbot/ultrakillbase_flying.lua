if not ENT or CLIENT then return end

local istable = istable
local isbool = isbool
local Vector = Vector
local IsEntity = IsEntity
local MMin = math.min
local isentity = isentity
local IsValid = IsValid
local GetConVar = GetConVar
local util = util
local isnumber = isnumber
local ETickInterval = engine.TickInterval
local TCreate = timer.Create
local NIsLoaded = SERVER and navmesh.IsLoaded
local NGetNearestNavArea = SERVER and navmesh.GetNearestNavArea


ENT.UltrakillBase_Flying_AccumVector = Vector()
ENT.UltrakillBase_Flying_AccumWeight = 0
ENT.UltrakillBase_Flying_IsAttemptingToMove = 0
ENT.UltrakillBase_Flying_IsResting = false


local function IsAttemptingToMove( self )

  return self.UltrakillBase_Flying_IsAttemptingToMove > CurTime()

end


function ENT:ApproachFlying( vPos, fWeight )

  fWeight = fWeight or 1

  local vWeightedDirection = ( vPos - self:GetPos() ) * fWeight

  if self.UltrakillBase_Flying_IsResting then 

    self:SetVelocity( vector_origin )
    self.UltrakillBase_Flying_IsResting = false

  end

  self.UltrakillBase_Flying_IsAttemptingToMove = CurTime() + 0.25
  self.UltrakillBase_Flying_AccumVector = self.UltrakillBase_Flying_AccumVector + vWeightedDirection
  self.UltrakillBase_Flying_AccumWeight = self.UltrakillBase_Flying_AccumWeight + fWeight

end


local function NormalizeInPlace( vPos )

  local fLength = vPos:Length()

  if fLength <= 0 then return 0 end

  vPos = vPos / fLength

  return fLength

end


local function FlyGround( self )
  
  local JumpHeight = self.loco:GetJumpHeight()
  
  self.loco:SetJumpHeight( 1 )
  
  local Seq = self:GetSequence()
  local Cycle = self:GetCycle()
  local Rate = self:GetPlaybackRate()

  self.loco:Jump()
  self:ResetSequence( Seq )
  self:SetPlaybackRate( Rate )
  self:SetCycle( Cycle )
  
  self.loco:SetJumpHeight( JumpHeight )
  
end


function ENT:UpdateFlying()

  if self.UltrakillBase_Flying_IsResting then return self:SetVelocity( vector_origin ) end
  if self:IsOnGround() then FlyGround( self ) end

  local fInterval = self:GetUpdateInterval()

  local vAccumulated = self.UltrakillBase_Flying_AccumVector
  local fAccumulated = self.UltrakillBase_Flying_AccumWeight
  local vVelocity = self:GetVelocity()
  local vNVelocity = vVelocity:GetNormalized()
  local fDesiredSpeed = self:GetDesiredSpeed()
  local fAcceleration = self:GetAcceleration()
  local fDeceleration = self:GetDeceleration()
  local vAcceleration = vector_origin

  if IsAttemptingToMove( self ) and fAccumulated > 0 then

    local fMove = fDesiredSpeed * fInterval
    local vApproach = vAccumulated / fAccumulated
    local fDesired = NormalizeInPlace( vApproach )

    if fDesired > fMove then fDesired = fMove end

    local vPos = self:GetPos() + fDesired * vApproach

    self.UltrakillBase_Flying_AccumVector:Zero()
    self.UltrakillBase_Flying_AccumWeight = 0

    local vDirection = vPos - self:GetPos()
    vDirection:Normalize()

    local fSpeed = vVelocity:LengthSqr()
    local fRatio = ( fSpeed <= 0 ) and 0 or MMin( ( fSpeed / ( fDesiredSpeed * fDesiredSpeed ) ), 1 )
    local fGovernor = 1 - ( fRatio * fRatio * fRatio * fRatio )

    vAcceleration = vDirection * fInterval * fGovernor * fAcceleration

  end

  vVelocity = vVelocity - ( vNVelocity * fDeceleration * ETickInterval() )

  if ( vVelocity + vAcceleration ):LengthSqr() <= 1.0201 then

    self.UltrakillBase_Flying_IsResting = true
    return

  end

  self:SetVelocity( vVelocity + vAcceleration )

end


function ENT:GetFlying()
  
  return self.Flying

end


function ENT:SetFlying( Bool )

  self.Flying = isbool( Bool ) and Bool or false 

end


function ENT:InitializeFlying()

  if not self:GetFlying() then return end

  self.loco:SetGravity( 0 )
  self:SetVelocity( vector_origin )
  self:SetStepHeight( 0 )

  self:SetFlying( true )

end


local NavMeshFlyingOffset = Vector( 0, 0, 45 )
local FlyingOffset = Vector( 0, 0, 45 )


local function FloatAboveGround( self, Pos )

  if not self.FlyingHeight then return end

  FlyingOffset.z = self.FlyingHeight or 45

  local GroundCheck = self:TraceLine( nil, {

    start = Pos,
    endpos = Pos - FlyingOffset,
    collisiongroup = COLLISION_GROUP_WORLD

  } )

  return GroundCheck.Hit

end


function ENT:FlyTowards( Pos )

  if isentity( Pos ) then Pos = Pos:GetPos() end

  self:FaceTowards( Pos )

  if FloatAboveGround( self, Pos ) then

    Pos = Pos + NavMeshFlyingOffset

  end

  self:ApproachFlying( Pos )

end


local function ShouldCompute( self, Path, Pos )

  if not IsValid( Path ) then return true end

  local Segments = #Path:GetAllSegments()

  if Path:GetAge() >= GetConVar( "drgbase_compute_delay" ):GetFloat()*Segments then

    return Path:GetEnd():DistToSqr( Pos ) > ( Path:GetGoalTolerance() ^ 2 )

  else 

    return false 

  end

end


function ENT:FollowPathFlying( Pos, Tolerance, Generator )

  if isentity( Pos ) then

    if not IsValid( Pos ) then return "unreachable" end

    if Pos:GetClass() == "npc_barnacle" then

      Pos = util.DrG_TraceLine({

        start = Pos:GetPos(), endpos = Pos:GetPos() - Vector( 0, 0, 999999 ),

        collisiongroup = COLLISION_GROUP_DEBRIS

      }).HitPos

    else 

      Pos = Pos:GetPos() 

    end

  end

  Tolerance = isnumber( Tolerance ) and Tolerance or 20

  if NIsLoaded() then

    local NavPath = self:GetPath()

    NavPath:SetGoalTolerance( Tolerance )

    local Area = NGetNearestNavArea( Pos )

    if IsValid( Area ) then Pos = Area:GetClosestPointOnArea( Pos ) or Pos end

    if not IsValid( NavPath ) and self:GetRangeSquaredTo( Pos ) <= ( NavPath:GetGoalTolerance() ^ 2 ) then return "reached" end

    if ShouldCompute( self, NavPath, Pos ) then NavPath:Compute( self, Pos, Generator ) end

    if not IsValid( NavPath ) then return "unreachable" end

    local Current = NavPath:GetCurrentGoal()

    if not self:AvoidObstacles( true ) then

      if self:GetRangeSquaredTo( Pos ) > ( Tolerance ^ 2 ) then

        self:FlyTowards( NavPath:NextSegment().pos + NavMeshFlyingOffset )

        if self.loco:IsStuck() then

          self:HandleStuck()

          return "stuck"

        else return "moving" end

      else return "reached" end

    else return "obstacle" end

  end

end


function ENT:HandleFlying( Pos )

  if isentity( Pos ) then Pos = Pos:GetPos() end

  local Obstructed = not self:VisibleVec( Pos )
  
  if Obstructed then

    return self:FollowPathFlying( Pos )

  else

    return self:FlyTowards( Pos )

  end

end