if not ENT or CLIENT then return end


local istable = istable
local CRRunning = coroutine.running
local isentity = isentity
local isvector = isvector
local isfunction = isfunction
local CurTime = CurTime
local IsValid = IsValid
local ETickInterval = engine.TickInterval
local isnumber = isnumber


local function CalcTrajectory( self, Pos, Speed )

  local Dir, Info = self:GetPos():DrG_CalcLineTrajectory( Pos, Speed, false )

  return Dir, Info

end


function ENT:AirLeap( Pos, Speed, Callback )

  if not CRRunning() then return end

  if isentity( Pos ) then

    local Dir, Info = CalcTrajectory( self, Pos:GetPos(), Speed )

    return self:AirLeap( Pos:GetPos() + Pos:GetVelocity() * Info.duration, Speed, Callback )

  elseif isvector( Pos ) then

    if not isfunction( Callback ) then 

      Callback = function()

        self:LookTowards( self:WorldSpaceCenter() + self:GetVelocity() )

      end 

    end

    local Dir, Info = CalcTrajectory( self, Pos, Speed )

    if self:TraceHull( Dir:GetNormalized() ).Hit then return false end

    local Collided = NULL

    local Now = CurTime()

    self:SetNW2Bool( "DrGBaseLeaping", true )

    while self:GetRangeSquaredTo( Pos ) > ( 25 ^ 2 ) and not self:IsOnGround() do

      local Time = CurTime() - Now

      local Left = Info.duration - Time

      local HasCollided = IsValid( Collided ) or Collided:IsWorld()

      if Callback( self, Left, HasCollided, Collided ) or HasCollided then break end

      if not HasCollided then

        local Pos, Vel = Info.Predict( Time )

        Collided = self:TraceHull( Info.Predict( Time + ETickInterval() ) - self:GetPos() ).Entity

        HasCollided = IsValid( Collided ) or Collided:IsWorld()

        if not HasCollided then

          self:SetPos( Pos )
          self:SetVelocity( Vel )

        end

      end

      self:YieldCoroutine( true )

    end

    self:SetNW2Bool( "DrGBaseLeaping", false )

    return not Collided

  end

end


local function LocoJump( self )

  local Seq = self:GetSequence()
  local Cycle = self:GetCycle()
  local Rate = self:GetPlaybackRate()

  self.loco:Jump()
  self:ResetSequence( Seq )
  self:SetPlaybackRate( Rate )
  self:SetCycle( Cycle )

end


local function LocoJumpGap( self, Pos )

  local Seq = self:GetSequence()
  local Cycle = self:GetCycle()
  local Rate = self:GetPlaybackRate()

  self.loco:JumpAcrossGap( Pos, self:GetForward() )
  self:ResetSequence( Seq )
  self:SetPlaybackRate( Rate )
  self:SetCycle( Cycle )

end


function ENT:LeaveGround()

  if not self:IsOnGround() then return end
  
  local JumpHeight = self.loco:GetJumpHeight()
  
  self.loco:SetJumpHeight( 1 )
  
  LocoJump( self )
  
  self.loco:SetJumpHeight( JumpHeight )
  
end


function ENT:Jump( Height, Callback )

  if not self:IsOnGround() then return end

  if isnumber( Height ) then

    local JumpHeight = self.loco:GetJumpHeight()

    self.loco:SetJumpHeight( Height * self:GetScale() )

    LocoJump( self )

    self.loco:SetJumpHeight( JumpHeight )

  elseif isvector( Height ) then

    LocoJumpGap( self, Height )

  else 

    return self:Jump( self.loco:GetJumpHeight(), Callback ) 

  end

  if not CRRunning() then return end

  self:SetNW2Bool( "DrGBaseJumping", true )

  local Now = CurTime()

  while not self:IsOnGround() do

    if isfunction( Callback ) and Callback( self, CurTime() - Now ) then

      break

    end

    self:YieldCoroutine( true )

  end

  self:SetNW2Bool( "DrGBaseJumping", false )

end