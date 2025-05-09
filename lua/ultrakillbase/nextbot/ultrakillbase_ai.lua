if not ENT or CLIENT then return end

local util = util
local istable = istable
local Vector = Vector
local IsValid = IsValid
local GetConVar = GetConVar
local IsEntity = IsEntity
local isnumber = isnumber
local NIsLoaded = SERVER and navmesh.IsLoaded
local NGetNearestNavArea = SERVER and navmesh.GetNearestNavArea
local CRStatus = coroutine.status
local CRresume = coroutine.resume
local ErrorNoHalt = ErrorNoHalt
local UltrakillBase = UltrakillBase


local NearGroundVector = Vector( 0, 0, 0 )


function ENT:EnemyNearGround( ZDistance )

  if not self:HasEnemy() then return self:IsOnGround() end

  local Enemy = self:GetEnemy()
  local Pos = Enemy:GetPos()

  NearGroundVector.z = ZDistance or 150


  local TraceResult = Enemy:DrG_TraceHull( nil, {

    start = Pos,
    endpos = Pos - NearGroundVector,
    collisiongroup = COLLISION_GROUP_WORLD

  } )


  return TraceResult.Hit

end


function ENT:HandleAttacking()

  local Enemy = self:GetEnemy()

  local Relationship = self:GetRelationship( Enemy )

  if Relationship == D_HT or Relationship == D_FR then

    local EnemyVisible = self:Visible( Enemy )

    if not self.AISight then

      EnemyVisible = true

    end

    if IsValid( Enemy ) and EnemyVisible then 

      self:AttackEntity( Enemy ) 

    end

  end

end


local function ShouldCompute( self, PathF, Pos )

  if not IsValid( PathF ) then return true end

  local ComputeDelay = GetConVar( "drgbase_compute_delay" )

  local Segments = #PathF:GetAllSegments()

  if PathF:GetAge() >= ComputeDelay:GetFloat() * Segments then

    return PathF:GetEnd():DistToSqr( Pos ) > PathF:GetGoalTolerance() ^ 2

  end

  return false

end


function ENT:FollowPath( Pos, Tolerance, Generator )

  if IsEntity( Pos ) then

    if not IsValid( Pos ) then return "unreachable" end

    if Pos:GetClass() == "npc_barnacle" then

      Pos = util.DrG_TraceLine( {

        start = Pos:GetPos(),
        endpos = Pos:GetPos() - Vector( 0, 0, 999999 ),
        collisiongroup = COLLISION_GROUP_DEBRIS


      } ).HitPos

    else

      Pos = Pos:GetPos()

    end

  end

  Tolerance = isnumber( Tolerance ) and Tolerance or 20

  if NIsLoaded() and self:GetGroundEntity():IsWorld() then

    local PathF = self:GetPath()

    PathF:SetGoalTolerance( Tolerance )
    PathF:SetMinLookAheadDistance( 300 )

    local CNavArea = NGetNearestNavArea( Pos )

    if IsValid( CNavArea ) then

      Pos = CNavArea:GetClosestPointOnArea( Pos ) or Pos

    end

    if not IsValid( PathF ) and self:GetRangeSquaredTo( Pos ) <= PathF:GetGoalTolerance() ^ 2 then

      return "reached"

    end

    if ShouldCompute( self, PathF, Pos ) then

      PathF:Compute( self, Pos, Generator )

    end

    if not IsValid( PathF ) then return "unreachable" end

    local CurrentGoal = PathF:GetCurrentGoal()

    if not self:LastComputeSuccess() and PathF:GetCurrentGoal().distanceFromStart == PathF:LastSegment().distanceFromStart then

      return "unreachable"

    elseif not self:AvoidObstacles( true ) then

      PathF:Update( self )

      if not IsValid( PathF ) then

        return "reached"

      elseif self.loco:IsStuck() then

        self:HandleStuck()

        return "stuck"

      end

      return "moving"

    end

    return "obstacle"

  else

    if not self:AvoidObstacles( true ) then

      if self:GetRangeSquaredTo( Pos ) > Tolerance ^ 2 then

        self:MoveTowards( Pos )

        if self.loco:IsStuck() then

          self:HandleStuck()

          return "stuck"

        end

        return "moving"

      end

      return "reached"

    end

    return "obstacle"

  end

end


function ENT:HandleEnemyPathing()

  local ShouldMove = self.CantMove ~= true

  local Enemy = self:GetEnemy()

  local Relationship = self:GetRelationship( Enemy )

  if Relationship == D_HT or Relationship == D_FR then

    local EnemyVisible = self:Visible( Enemy )

    if ( not self:IsInRange( Enemy, self.ReachEnemyRange ) or not EnemyVisible ) and ShouldMove then

      if self:OnChaseEnemy( Enemy ) ~= true then

        if self:FollowPath( Enemy ) == "unreachable" then

          self:OnEnemyUnreachable( Enemy )

        end

      end

    elseif self:IsInRange( Enemy, self.AvoidEnemyRange ) and EnemyVisible and not self:IsInRange( Enemy, self.MeleeAttackRange ) and ShouldMove then

      if self:OnAvoidEnemy( Enemy ) ~= true then

        self:FollowPath( self:GetPos():DrG_Away( Enemy:GetPos() ) )

      end

    elseif self:OnIdleEnemy( Enemy ) ~= true then

      if self.BehaviourStrafe then

        self:Approach( self:GetPos() + ( self.BehaviourStrafeDirection * self:GetRight() ) )
        self:LookTowards( Enemy )

      else 

        self:LookTowards( Enemy ) 

      end

    end

  elseif relationship == D_LI then 

    self:OnAllyEnemy( Enemy )

  elseif relationship == D_NU then 

    self:OnNeutralEnemy( Enemy ) 

  end

end


function ENT:HandleEnemyFlyingPathing()

  local Enemy = self:GetEnemy()

  local Relationship = self:GetRelationship( Enemy )

  if Relationship == D_HT then

    local EnemyVisible = self:Visible( Enemy )

    if not self:IsInRange( Enemy, self.ReachEnemyRange ) or not EnemyVisible then

      if self:OnChaseEnemy( Enemy ) ~= true then

        if self:HandleFlying( Enemy ) == "unreachable" then

          self:OnEnemyUnreachable( Enemy )

        end

      end

    elseif self:IsInRange( Enemy, self.AvoidEnemyRange ) and EnemyVisible and not self:IsInRange( Enemy, self.MeleeAttackRange ) then

      if self:OnAvoidEnemy( Enemy ) ~= true then

        self:HandleFlying( self:GetPos():DrG_Away( Enemy:GetPos() ) )

      end

    elseif self:OnIdleEnemy( Enemy ) ~= true then

      if self.BehaviourStrafe then

        self:ApproachFlying( self:GetPos() + ( self.BehaviourStrafeDirection * self:GetRight() ) )
        self:LookTowards( Enemy )

      else 

        self:SetVelocity( vector_origin )
        self:LookTowards( Enemy ) 

      end

    end

  elseif relationship == D_FR then

    local EnemyVisible = self:Visible( Enemy )

    if self:IsInRange( Enemy, self.AvoidAfraidOfRange ) and EnemyVisible then

      if self:OnAvoidAfraidOf( Enemy ) ~= true then

        self:HandleFlying( self:GetPos():DrG_Away( Enemy:GetPos() ) )

      end

    elseif self:OnIdleAfraidOf( Enemy ) ~= true then 

      self:SetVelocity( vector_origin )
      self:LookTowards( Enemy ) 

    end

  elseif relationship == D_LI then 

    self:OnAllyEnemy( Enemy )

  elseif relationship == D_NU then 

    self:OnNeutralEnemy( Enemy ) 

  end

end


function ENT:UpdateEnemy()

  if self:IsPossessed() then

    local LockedOn = self:PossessionGetLockedOn()

    return IsValid( LockedOn ) and LockedOn or NULL

  end

  local Enemy

  if self:HasNemesis() then return self:GetNemesis() end

  Enemy = self:OnUpdateEnemy()

  if Enemy == nil then return self:GetEnemy() end

  if not IsValid( Enemy ) or self:GetRangeSquaredTo( Enemy ) > ( GetConVar( "drgbase_ai_radius" ):GetFloat() ^ 2 ) then

    Enemy = NULL

  end

  if self:IsAfraidOf( Enemy ) and not self:IsInRange( Enemy, self.WatchAfraidOfRange ) then

    Enemy = NULL

  end

  self:SetEnemy( Enemy )

  return Enemy

end


function ENT:GetEnemy()

  if self:IsPossessed() then return self:PossessionGetLockedOn() end

  return self:GetNW2Entity( "DrGBaseEnemy" )

end


function ENT:AIBehaviour()

  if self:HasEnemy() then

    self:HandleAttacking() 

    if self:GetFlying() then

      self:HandleEnemyFlyingPathing()

    else

      self:HandleEnemyPathing()

    end

  elseif self:HadEnemy() then 

    self:UpdateEnemy()
    
  else

    if self:GetFlying() then

      self:SetVelocity( vector_origin )

    end

    self:OnIdle() 

  end

end


function ENT:BehaveUpdate( fInterval )

  self.UpdateInterval = fInterval

  if not self.BehaveThread then return end

  if CRStatus( self.BehaveThread ) ~= "dead" then

    local Ok, Args = CRresume( self.BehaveThread )

    if not Ok then 

      self.BehaveThread = nil

      if not self:OnError( Args ) then

        ErrorNoHalt( self, " Error: ", Args, "\n" )

      else

        self:BehaveStart()

      end

    end

  else

    self.BehaveThread = nil

  end


end


-- Generator --
-- Returns Cost of Nav --
-- This Generator Ignores Ladder & Climbing due to Ultrakill not having those. --

function UltrakillBase.NavGenerator( self, NavArea, NavFromArea, Ladder, Elevator, NavLength )

  if not IsValid( NavFromArea ) then return 0 end

  if self:IsNavAreaBlacklisted( NavArea ) or not self.loco:IsAreaTraversable( NavArea ) then return -1 end
  
  local NavDistance = NavLength > 0 and NavLength or ( NavArea:GetCenter() - NavFromArea:GetCenter() ):GetLength()

  local NavCost = NavFromArea:GetCostSoFar() + NavDistance

  local NavHeight = NavFromArea:ComputeAdjacentConnectionHeightChange( NavArea )

  if NavHeight > 0 then

    if NavHeight < self.loco:GetStepHeight() then

      local CustomCost = self:OnComputePathStep( NavFromArea, NavArea, NavHeight )

      if CustomCost >= 0 then

        NavCost = NavCost + NavDistance * CustomCost

      else

        return -1

      end

    elseif UltrakillBase.EnableNextbotJumping and NavHeight < self.loco:GetStepHeight() then

      local CustomCost = self:OnComputePathJump( NavFromArea, NavArea, NavHeight )

      if CustomCost >= 0 then

        NavCost = NavCost + NavDistance * CustomCost

      else

        return -1

      end

    else

      return -1

    end

  elseif NavHeight < 0 then -- Drop

    local NavDrop = -NavHeight

    if NavDrop < self.loco:GetDeathDropHeight() then

      local CustomCost = self:OnComputePathDrop( NavFromArea, NavArea, NavDrop )

      if CustomCost >= 0 then

        NavCost = NavCost + NavDistance * CustomCost

      else

        return -1

      end

    else

      return -1

    end

  else

    local CustomCost = self:OnComputePathFlat( NavFromArea, NavArea )

    if CustomCost >= 0 then

      NavCost = NavCost + NavDistance * CustomCost

    else

      return -1

    end

  end

  if NavArea:IsUnderwater() then

    local CustomCost = self:OnComputePathUnderwater( NavFromArea, NavArea )

    if CustomCost >= 0 then

      NavCost = NavCost + NavDistance * CustomCost

    else

      return -1

    end

  end

  local TotalCost = self:OnComputePath( NavFromArea, NavArea )

  if TotalCost >= 0 then

    return NavCost + NavDistance * TotalCost

  else

    return -1

  end

end


function ENT:GetPathGenerator()

  return function( NavArea, NavFromArea, Ladder, Elevator, NavLength )

    return UltrakillBase.NavGenerator( self, NavArea, NavFromArea, Ladder, Elevator, NavLength )

  end

end