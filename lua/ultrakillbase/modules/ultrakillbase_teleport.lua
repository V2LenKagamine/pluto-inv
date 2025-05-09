
if not SERVER then return end


local Angle = Angle
local Vector = Vector
local istable = istable
local unpack = unpack
local IsValid = IsValid
local isvector = isvector
local isnumber = isnumber
local isentity = isentity
local isfunction = isfunction
local MSqrt = math.sqrt
local MAbs = math.abs
local UTraceLine = util.TraceLine
local UTraceHull = util.TraceHull
local UIsInWorld = SERVER and util.IsInWorld
local NIsLoaded = SERVER and navmesh.IsLoaded
local NGetNearestNavArea = SERVER and navmesh.GetNearestNavArea
local BBor = bit.bor
local UltrakillBase = UltrakillBase
local mRayMask = MASK_NPCSOLID
local mRayMaskWorld = MASK_NPCSOLID_BRUSHONLY


function UltrakillBase.TraceSetPos( self, vPos )

    local vMin, vMax = self:GetCollisionBounds()

    local mTrace = {

        start = self:GetPos(),
        endpos = vPos,
        mins = vMin,
        maxs = vMax,
        filter = self

    }

    if self:IsNextBot() then mTrace.mask = self:GetSolidMask()
    else mTrace.collisiongroup = self:GetCollisionGroup() end

    local mResult = UTraceHull( mTrace )

    if not UIsInWorld( mResult.HitPos ) then return self:GetPos() end

    return self:SetPos( mResult.HitPos )

end


local function RayCast( vOrigin, vPos, mMask, bIgnoreWorld, mIgnore )

    if istable( Mask ) then Mask = BBor( unpack( Mask ) ) end

    local mTrace = {

        start = vOrigin,
        endpos = vPos,
        mask = mMask,
        ignoreworld = bIgnoreWorld,
        filter = mIgnore

    }

    return UTraceLine( mTrace )

end


local function HullRayCast( self, vOrigin, vPos, mMask, bIgnoreWorld, mIgnore, bStep )

    if istable( Mask ) then Mask = BBor( unpack( Mask ) ) end

    local vMin, vMax = self:GetCollisionBounds()

    if vMin.z == 0 and self.IsDrGNextbot and bStep then vMin.z = vMin.z + self:GetStepHeight() end

    local mTrace = {

        start = vOrigin,
        endpos = vPos,
        mask = mMask,
        ignoreworld = bIgnoreWorld,
        mins = vMin,
        maxs = vMax,
        filter = mIgnore

    }

    return UTraceHull( mTrace )

end


local function IsCollidingWorld( self, vOrigin, bStep )

    if bStep then vOrigin.z = vOrigin.z + self.loco:GetStepHeight() end

    return not UIsInWorld( vOrigin )

end


local function IsCollidingEntity( self, vOrigin )

    local mRayCastResult = HullRayCast( self, vOrigin, vOrigin, self:GetSolidMask(), true, self, false )

    return mRayCastResult.Hit and IsValid( mRayCastResult.Entity ), mRayCastResult.Entity

end


local vBoundingRadiusY = Vector( 0, 1, 0 )
local vBoundingRadiusX = Vector( 1, 0, 0 )


local function BoundingRadiusZDot( mEntity, vDirection )

    local vResult
    local vMin, vMax = mEntity:GetCollisionBounds()

    vMin.z = 0
    vMax.z = 0

    local fDotX = MAbs( vDirection:Dot( vBoundingRadiusX ) )
    local fDotY = MAbs( vDirection:Dot( vBoundingRadiusY ) )

    vResult = vMin:LengthSqr() > vMax:LengthSqr() and vMax or vMin

    vResult.x = vResult.x * fDotX
    vResult.y = vResult.y * fDotY

    return vResult:Length()

end


local function BoundingRadiusZ( mEntity )

    local vMin, vMax = mEntity:GetCollisionBounds()

    vMin.z = 0
    vMax.z = 0

    if vMin:LengthSqr() > vMax:LengthSqr() then return vMin:Length() end

    return vMax:Length()

end


local vGroundOffset = Vector( 0, 0, 10000 )


local function GroundTeleport( self, vPos )

    local mResult = HullRayCast( self, vPos + self:OBBCenter(), vPos - vGroundOffset, mRayMaskWorld, false, self, true )

    return mResult.HitPos

end


local fEntityResolverRecursions = 0
local fEntityResolverRecursionLimit = 4
local fEntityResolverGap = 20


function UltrakillBase.TeleportEntityResolver( self, vPos, mEntity, bGrounded )

    if not IsValid( self ) or not IsValid( mEntity ) then return vPos end

    local vEntityPos = mEntity:GetPos()
    local vDirection = ( vPos - vEntityPos ):GetNormalized()
    local fRadiusDot = BoundingRadiusZDot( mEntity, vDirection ) + BoundingRadiusZDot( self, vDirection ) + fEntityResolverGap

    if vDirection:IsZero() then

        vDirection:Random( 100 )
        vDirection:Normalize()

    end

    vDirection.z = 0
    vDirection:Normalize()

    local vTransform = vPos + vDirection * fRadiusDot

    if IsCollidingWorld( self, vTransform, bGrounded ) and fEntityResolverRecursions <= fEntityResolverRecursionLimit then

        fEntityResolverRecursions = fEntityResolverRecursions + 1

        return UltrakillBase.TeleportNavMeshResolver( self, vTransform, bGrounded )

    elseif fEntityResolverRecursions > fEntityResolverRecursionLimit then

        return vPos

    end

    return vTransform

end


local fMaxSearch = 35000


function UltrakillBase.TeleportNavMeshResolver( self, vPos, bGrounded )

    if not IsValid( self ) or not isvector( vPos ) or not NIsLoaded() then return vPos end
    
    local nArea = NGetNearestNavArea( vPos, false, fMaxSearch )

    if not IsValid( nArea ) then return vPos end

    local vNavPos = nArea:GetClosestPointOnArea( vPos )
    local bIsColliding, eCollidingEntity = IsCollidingEntity( self, vNavPos )

    if bIsColliding then return UltrakillBase.TeleportEntityResolver( self, vNavPos, eCollidingEntity, bGrounded ) end

    return vNavPos

end


function UltrakillBase.CalculateTeleportOffsets( self, vPos, vOffset, bShouldRayCast )

    if not isvector( vPos ) and not isentity( vPos ) then return end
    if isentity( vPos ) then vPos = vPos:GetPos() end

    local vPosOffset = vPos + vOffset
    local vOrigin = vPos

    if isentity( vPos ) then

        vPosOffset = vPos:GetForward() * vOffset.x + vPos:GetRight() * vOffset.y + vPos:GetUp() * vOffset.z
        vOrigin = vPos:WorldSpaceCenter()

    end

    if bShouldRayCast then

        local mResult = HullRayCast( self, vOrigin, vPosOffset, mRayMaskWorld, false, self )
        vPosOffset = mResult.HitPos

        if mResult.Hit then

            vPosOffset = vPosOffset + mResult.Normal * self:BoundingRadius()

        end

    end

    return vPosOffset

end


local vRandomRadiusEdge = Vector()
local vRadiusDirection = Vector()


function UltrakillBase.RandomInSphere( self, vOrigin, fRadius )

    vRadiusDirection:Random( 100 )
    vRadiusDirection:Normalize()
    vRandomRadiusEdge:Random( fRadius )

    local mRayCast = HullRayCast( self, vOrigin, vOrigin + vRadiusDirection * vRandomRadiusEdge, mRayMaskWorld, self )

    return mRayCast.HitPos - vOrigin

end


local function GetLocal( vFrom, vTo, bEnable2D )

    local vDirection = vTo - vFrom

    if bEnable2D then vDirection.z = 0 end

    return vDirection

end


local function GetAimPos( self )

    local vAim = self:GetAimVector()

    local mTrace = {

        start = self:EyePos() + self:GetAimVector(),
        endpos = self:EyePos() + self:GetAimVector() * 1000,
        filter = self

    }

    return UTraceLine( mTrace ).HitPos

end


local EntityResolver = UltrakillBase.TeleportEntityResolver
local NavMeshResolver = UltrakillBase.TeleportNavMeshResolver


function UltrakillBase.Teleport( self, mTeleport, mCallback )

    if not IsValid( self ) then return false end

    if isvector( mTeleport ) or isentity( mTeleport ) then

        mTeleport = { Pos = mTeleport }

    end

    fEntityResolverRecursions = 0

    mTeleport.Rotation = mTeleport.Rotation or angle_zero
    mTeleport.Ground = mTeleport.Ground or false

    local vPos = mTeleport.Pos
    local aRotation = mTeleport.Rotation
    local bGround = mTeleport.Ground
    local bEnable2D = mTeleport.Enable2D
    local bUseFeet = mTeleport.UseFeet

    local vFeetOrigin = self:GetPos()

    if not isvector( vPos ) and not IsValid( vPos ) then vPos = GetAimPos( self )
    elseif IsValid( vPos ) then vPos = bUseFeet and vPos:GetPos() or vPos:WorldSpaceCenter() end

    if IsCollidingWorld( self, vPos, bGround ) then vPos = NavMeshResolver( self, vPos, bGround ) end

    local fRadius = self:BoundingRadius()
    local vOrigin = bUseFeet and self:GetPos() or self:WorldSpaceCenter()
    local vDirection = GetLocal( vOrigin, vPos, bEnable2D ):GetNormalized()

    vOrigin = vPos - vDirection * fRadius * 1.65

    local mResult = HullRayCast( self, vOrigin, vPos, mRayMask, false, self, bGround )
    local vTranslatedPos = mResult.HitPos - mResult.Normal * fRadius * 0.65

    local vLocalOffset = GetLocal( vPos, vTranslatedPos, bEnable2D )
    if bEnable2D then vLocalOffset.z = 0 end

    vLocalOffset:Rotate( aRotation )

    if self:WorldSpaceCenter():DistToSqr( vPos ) <= fRadius * 0.65 then return false end

    vTranslatedPos = vLocalOffset + vPos

    if bGround then vTranslatedPos = GroundTeleport( self, vTranslatedPos ) end

    local bIsCollidingEntity, eCollidingEntity = IsCollidingEntity( self, vTranslatedPos )

    if bIsCollidingEntity then vTranslatedPos = EntityResolver( self, vTranslatedPos, eCollidingEntity, bGround )
    elseif IsCollidingWorld( self, vTranslatedPos, bGround ) then vTranslatedPos = NavMeshResolver( self, vTranslatedPos, bGround ) end

    self:SetPos( vTranslatedPos )
    self:SetVelocity( vector_origin )

    if isfunction( mCallback ) then mCallback( self, vFeetOrigin, vTranslatedPos, mResult ) end

    return true, mResult, vTranslatedPos

end


function UltrakillBase.BypassRayCastTeleport( self, vPos, mCallback )

    if not IsValid( self ) then return false end
    if not isvector( vPos ) and not IsValid( vPos ) then vPos = self
    elseif IsValid( vPos ) then vPos = vPos:WorldSpaceCenter() end

    fEntityResolverRecursions = 0

    local vOrigin = self:GetPos()

    if self:WorldSpaceCenter():DistToSqr( vPos ) <= self:BoundingRadius() * 0.65 then return false end

    local bIsCollidingEntity, eCollidingEntity = IsCollidingEntity( self, vPos )

    if bIsCollidingEntity then vPos = EntityResolver( self, vPos, eCollidingEntity )
    elseif IsCollidingWorld( self, vPos ) then vPos = NavMeshResolver( self, vPos ) end

    self:SetPos( vPos )
    self:SetVelocity( vector_origin )

    if isfunction( mCallback ) then mCallback( self, vOrigin, vPos ) end

    return true, vPos

end