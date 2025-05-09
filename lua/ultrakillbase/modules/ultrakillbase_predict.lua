if CLIENT then return end


local GetConVar = GetConVar
local Vector = Vector
local PEGetGravity = physenv.GetGravity
local UTraceHull = util.TraceHull
local isentity = isentity
local IsValid = IsValid
local UltrakillBase = UltrakillBase


function UltrakillBase.Predict( mEntity, fTime, bUseFeet, bNoDown )

  if not isentity( mEntity ) or not IsValid( mEntity ) then return end

  local vPos = bUseFeet and mEntity:GetPos() or mEntity:WorldSpaceCenter()
  local iMask
  local vVelocity

  if mEntity:IsPlayer() then

    vVelocity = mEntity:GetVelocity()
    iMask = MASK_PLAYERSOLID

  elseif mEntity:IsNextBot() then

    vVelocity = mEntity.loco:GetVelocity()
    iMask = mEntity:GetSolidMask()

  elseif mEntity:IsNPC() then

    vVelocity = mEntity:GetGroundSpeedVelocity()
    iMask = MASK_NPCSOLID

  else

    vVelocity = Other:GetVelocity()
    iMask = MASK_SOLID

  end

  local vPredictedPos = vVelocity * fTime
  vPredictedPos = vPos + vPredictedPos

  if vPredictedPos.z < vPos.z and bNoDown then

    vPredictedPos.z = vPos.z

  end

  local vMin, vMax = mEntity:GetCollisionBounds()
  local mResult = UTraceHull( {

    start = vPos,
    endpos = vPredictedPos,
    collisiongroup = mEntity:GetCollisionGroup(),
    mask = iMask,
    mins = vMin,
    maxs = vMax,
    filter = { mEntity, self }

  } )

  if mResult.Hit then vPredictedPos = mResult.HitPos end

  return vPredictedPos, mResult

end


function UltrakillBase.PredictGravity( mEntity, fTime, bUseFeet, bNoDown )

  if not isentity( mEntity ) or not IsValid( mEntity ) then return end

  local vPos = bUseFeet and mEntity:GetPos() or mEntity:WorldSpaceCenter()
  local iMask
  local fGravity
  local vVelocity

  if mEntity:IsPlayer() then

    local fGravityMultiplier = mEntity:GetGravity()

    fGravity = ( fGravityMultiplier ~= 0 and fGravityMultiplier or 1 ) * GetConVar( "sv_gravity" ):GetFloat()
    vVelocity = mEntity:GetVelocity()
    iMask = MASK_PLAYERSOLID

    if mEntity:IsOnGround() or mEntity:IsFlagSet( FL_FLY ) or mEntity:IsEFlagSet( EFL_NOCLIP_ACTIVE ) or mEntity:WaterLevel() >= 2 then fGravity = 0 end

  elseif mEntity:IsNextBot() then

    fGravity = mEntity.loco:GetGravity()
    vVelocity = mEntity.loco:GetVelocity()
    iMask = mEntity:GetSolidMask()
  
    if mEntity.loco:IsOnGround() then fGravity = 0 end

  elseif mEntity:IsNPC() then

    fGravity = mEntity:GetGravity() * GetConVar( "sv_gravity" ):GetFloat()
    vVelocity = mEntity:GetGroundSpeedVelocity()
    iMask = MASK_NPCSOLID
  
    if mEntity:IsFlagSet( FL_FLY ) or mEntity:IsOnGround() then fGravity = 0 end

  else

    fGravity = -vector_up * PEGetGravity()
    vVelocity = Other:GetVelocity()
    iMask = MASK_SOLID

  end

  local vPredictedPos = vVelocity * fTime
  vPredictedPos.z = vPredictedPos.z - ( fGravity * fTime * fTime ) * 0.5
  vPredictedPos = vPos + vPredictedPos

  if vPredictedPos.z < vPos.z and bNoDown then

    vPredictedPos.z = vPos.z

  end

  local vMin, vMax = mEntity:GetCollisionBounds()
  local mResult = UTraceHull( {

    start = vPos,
    endpos = vPredictedPos,
    collisiongroup = mEntity:GetCollisionGroup(),
    mask = iMask,
    mins = vMin,
    maxs = vMax,
    filter = { mEntity, self }

  } )

  if mResult.Hit then vPredictedPos = mResult.HitPos end

  return vPredictedPos, mResult

end


function UltrakillBase.PredictEnemy( self, ... )

  if not self:HasEnemy() then return self:WorldSpaceCenter() end

  return UltrakillBase.Predict( self:GetEnemy(), ... )

end


function UltrakillBase.PredictEnemyGravity( self, ... )

  if not self:HasEnemy() then return self:WorldSpaceCenter() end

  return UltrakillBase.PredictGravity( self:GetEnemy(), ... )

end