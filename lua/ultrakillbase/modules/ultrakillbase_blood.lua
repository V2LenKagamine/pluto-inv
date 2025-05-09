function UltrakillBase.CreateBlood( self, ... )

	if CLIENT then return end

	UltrakillBase.CallOnClient( "CreateBlood", self, ... )

end


if not CLIENT then return end

local GetViewEntity = GetViewEntity
local LocalPlayer = LocalPlayer
local CreateClientConVar = CreateClientConVar
local Vector = Vector
local Material = Material
local Color = Color
local VectorRand = VectorRand
local FrameTime = FrameTime
local CurTime = CurTime
local MMin = math.min
local MAcos = math.acos
local MDeg = math.deg
local MRandom = math.random
local MRand = math.Rand
local MRemap = math.Remap
local MCeil = math.ceil
local MFloor = math.floor
local TSimple = timer.Simple
local UTraceLine = util.TraceLine
local UDecalEx = util.DecalEx
local TRemove = table.remove
local RSetMaterial = render.SetMaterial
local RStartBeam = render.StartBeam
local RAddBeam = render.AddBeam
local REndBeam = render.EndBeam
local RDrawSprite = render.DrawSprite
local HAdd = hook.Add
local CVAddChangeCallback = cvars.AddChangeCallback


local mBloodLegacyConVar = CreateConVar( "drg_ultrakill_bloodlegacy", 0, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Legacy Blood FX" )
local mBloodConVar = CreateConVar( "drg_ultrakill_blood", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enable Blood FX" )
local mBloodLegacyAmountConVar = CreateConVar( "drg_ultrakill_bloodamount", 30, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Max Amount of Blood" )
local mQualityConVar = CreateClientConVar( "drg_ultrakill_bloodquality", 10, true, false, "Affects the Quality of Blood", 0, 10 )
local mSplatterConVar = CreateClientConVar( "drg_ultrakill_bloodsplatter", 1, true, false, "Enables / Disables Blood Splatter", 0, 1 )


-- Quality --

local mQuality = MCeil( MRemap( mQualityConVar:GetInt(), 0, 10, 10, 1 ) )

-- Splatter --

local mSplatter = mSplatterConVar:GetBool()

-- Render Table --

local mBloodRenderData = {}

-- Blood Related Variables --

local mSpacing = 3
local mEmissionRate = 0.01
local mTrailThreshold = 30
local mRandomVector = Vector()

local mBloodMaxParticles = 350
local mBloodTrailDieTime = 0.333
local mBloodTrail = Material( "particles/ultrakill/BloodDropTrail" )
local mBloodDrop = "particles/ultrakill/BloodDrop"
local mBloodRefract = "particles/ultrakill/Smoke_Refract"
local mBloodDropMat = Material( mBloodDrop )
local mBloodWidth = 10
local mBloodParticleGravity = Vector( 0, 0, -1000 )

local mBloodSplatter = {

	Material( "particles/ultrakill/BloodSplatter1" ),
	Material( "particles/ultrakill/BloodSplatter2" ),
	Material( "particles/ultrakill/BloodSplatter3" ),
	Material( "particles/ultrakill/BloodSplatter4" ),
	Material( "particles/ultrakill/BloodSplatter5" ),
	Material( "particles/ultrakill/BloodSplatter6" ),
	Material( "particles/ultrakill/BloodSplatter7" )

}

local mBloodSplatterColor = Color( 225, 0, 0 )

local mCollisionInterval = 0.1
local mCollisionTraceInfo = {

	collisiongroup = COLLISION_GROUP_WORLD,
	mask = MASK_NPCWORLDSTATIC

}

-- Sand --


local mSandParticleGravity = Vector( 0, 0, -100 )
local mSand = "particles/ultrakill/Smoke_Additive"


local function CalculateQuality( _, __, fQuality )

	mQuality = MCeil( MRemap( fQuality, 0, 10, 10, 1 ) )

end


local function SetSplatter( _, __, bSplatter )

	mSplatter = tobool( bSplatter )

end


local function CreateParticlesBlood( vPos, mEmitter2D )

	local BloodParticle = mEmitter2D:Add( mBloodDrop, vPos )

	BloodParticle:SetDieTime( 1 )
	BloodParticle:SetStartSize( 6 )
	BloodParticle:SetEndSize( 6 )
	BloodParticle:SetStartAlpha( 255 )
	BloodParticle:SetEndAlpha( 255 )
	BloodParticle:SetColor( 175, 0, 0 )

	mRandomVector.x = MRand( -1, 1 )
	mRandomVector.y = MRand( -1, 1 )
	mRandomVector.z = MRand( -1, 1 )

	BloodParticle:SetVelocity( mRandomVector * MRand( 228, 428 ) )
	BloodParticle:SetAirResistance( 0 )
	BloodParticle:SetCollide( false )
	BloodParticle:SetGravity( mBloodParticleGravity )

	mRandomVector.x = MRand( -1, 1 )
	mRandomVector.y = MRand( -1, 1 )
	mRandomVector.z = MRand( -1, 1 )

	local BloodMistParticle = mEmitter2D:Add( mBloodRefract, vPos + mRandomVector * 10 )

	BloodMistParticle:SetDieTime( 1 )
	BloodMistParticle:SetStartSize( 20 )
	BloodMistParticle:SetEndSize( 32 )
	BloodMistParticle:SetStartAlpha( 200 )
	BloodMistParticle:SetEndAlpha( 0 )
	BloodMistParticle:SetColor( 175, 0, 0 )
	
	BloodMistParticle:SetRoll( MRand( -1, 1 ) )

end


local function InitializeLegacyBlood( vPos, iAmount )

	for I = 1, MMin( iAmount, mBloodLegacyAmountConVar:GetInt() ) do

		ParticleEffect( "Ultrakill_Blood", vPos, angle_zero )

	end

end


local function InitializeBlood( vPos )

	local mBlood = {}

	mBlood.mOrigin = vPos
	mBlood.mPos = Vector()
	mBlood.mPos:Set( mBlood.mOrigin )
	mBlood.mCenter = vPos
	mBlood.mInitTime = CurTime()

	mBlood.mVelocity = VectorRand( -800, 800 )
	mBlood.mGravity = MRand( 800, 1400 )
	mBlood.mDieTime = MRand( 3, 6 )
	mBlood.mColor = Color( MRand( 175, 225 ), 0, 0, 255 )

	mBlood.mLastEmissionTime = 0
	mBlood.mLastPos = Vector()
	mBlood.mPoints = {}
	mBlood.mIsVisible = true

	mBlood.mHasCollided = false
	mBlood.mLastCollisionTime = 0
	mBlood.mLastPointRemovalTime = 0
	mBlood.mLastVelocityTime = 0
	mBlood.mLastVisibilityTime = 0

	mBloodRenderData[ #mBloodRenderData + 1 ] = mBlood

end


local function UpdateCollision( mBlood )

	if mBlood.mHasCollided or mBlood.mLastCollisionTime + mCollisionInterval > CurTime() then return end

	mCollisionTraceInfo.start = mBlood.mPos

	mCollisionTraceInfo.endpos = mBlood.mPos + mBlood.mVelocity * mCollisionInterval
	mCollisionTraceInfo.endpos.z = mBlood.mPos.z + ( mBlood.mVelocity.z * mCollisionInterval - ( mBloodParticleGravity.z * mCollisionInterval ^ 2 ) * 0.5 )

	local mCollision = UTraceLine( mCollisionTraceInfo )
	mBlood.mHasCollided = mCollision.Hit

	if mBlood.mHasCollided then

		TSimple( mCollision.Fraction * mCollisionInterval, function()

			mBlood.mStopVelocity = true

			if not mSplatter then return end

			UDecalEx( mBloodSplatter[ MRandom( 1, 7 ) ], mCollision.Entity, mCollision.HitPos, mCollision.HitNormal, mBloodSplatterColor, MRand( 0.65, 2.5 ), MRand( 0.65, 2.5 ) )

		end )

	end

	mBlood.mLastCollisionTime = CurTime()

end


local function UpdateVelocity( mBlood )

	if mBlood.mHasCollided and mBlood.mStopVelocity or ( not mBlood.mIsVisible and CurTime() - mBlood.mLastVelocityTime < mCollisionInterval ) then return end

	local fDeltaTime = mBlood.mIsVisible and FrameTime() or mCollisionInterval

	mBlood.mVelocity.z = mBlood.mVelocity.z - mBlood.mGravity * fDeltaTime
	mBlood.mPos = mBlood.mPos + mBlood.mVelocity * fDeltaTime
	mBlood.mLastVelocityTime = CurTime()

end


local function AddTrailPoint( mBlood )

	if bHasCollided or CurTime() - mBlood.mLastEmissionTime < mEmissionRate then return end
	if mBlood.mLastPos:DistToSqr( mBlood.mPos ) < mSpacing * mSpacing then return end

	local mPoints = mBlood.mPoints

	mPoints[ #mPoints + 1 ] = { mPos = mBlood.mPos, mInitTime = CurTime() }

	mBlood.mLastEmissionTime = CurTime()
	mBlood.mLastPos = mBlood.mPos
	mBlood.mOrigin = mPoints[ 1 ].mPos
	mBlood.mCenter = mPoints[ MCeil( 1 + ( #mPoints - 1 ) * 0.5 ) ].mPos

end


local function ProcessPointRemoval( mBlood )

	if CurTime() - mBlood.mLastPointRemovalTime < mCollisionInterval then return end

	local mPoints = mBlood.mPoints
	local fLength = #mPoints
	local cColor = mBlood.mColor

	if fLength > mTrailThreshold then

		TRemove( mPoints, 1 )
		fLength = #mPoints

	end

	for I = 1, fLength, mQuality do

		if not mPoints[ I ] then continue end

		if CurTime() > mPoints[ I ].mInitTime + mBloodTrailDieTime + mCollisionInterval then TRemove( mPoints, I ) end

	end

	mBlood.mLastPointRemovalTime = CurTime()

end


local function RenderTrail( mBlood )

	if not mBlood.mIsVisible then return ProcessPointRemoval( mBlood ) end

	local mPoints = mBlood.mPoints
	local fLength = #mPoints
	local cColor = mBlood.mColor

	if fLength > mTrailThreshold then

		TRemove( mPoints, 1 )
		fLength = #mPoints

	end

	RSetMaterial( mBloodTrail )
	RStartBeam( MCeil( fLength / mQuality ) + 1 )

		for I = 1, fLength, mQuality do

			if not mPoints[ I ] then continue end

			RAddBeam( mPoints[ I ].mPos, mBloodWidth, I / fLength, cColor )

			if CurTime() > mPoints[ I ].mInitTime + mBloodTrailDieTime then TRemove( mPoints, I ) end

		end

		RAddBeam( mBlood.mPos, mBloodWidth, 0, cColor )

	REndBeam()

end


local function CalculateVisibility( vPos, vEyePos, vNormal )

	return MDeg( MAcos( vNormal:Dot( ( vPos - vEyePos ):GetNormalized() ) ) ) <= LocalPlayer():GetFOV()

end



local function IsBloodVisible( mBlood )

	if mBlood.mIsVisible and CurTime() - mBlood.mLastVisibilityTime < mCollisionInterval * 0.5 then return end

	local vEyePos = UltrakillBase.EyePos
	local vEyeNormal = UltrakillBase.EyeNormal

	mBlood.mLastVisibilityTime = CurTime()
	mBlood.mIsVisible = ( CalculateVisibility( mBlood.mCenter, vEyePos, vEyeNormal ) or CalculateVisibility( mBlood.mPos, vEyePos, vEyeNormal ) or CalculateVisibility( mBlood.mOrigin, vEyePos, vEyeNormal ) )

end



local function RenderBlood( bDepth, bDrawSkybox, bIs3DSkybox )

	if #mBloodRenderData <= 0 or ( bDrawSkybox and bIs3DSkybox ) then return end

	for K, V in ipairs( mBloodRenderData ) do

		local fInitTime = V.mInitTime
		local fDieTime = V.mDieTime
		local mPoints = V.mPoints
		local vPos = V.mPos
		local cColor = V.mColor
		local bCollided = V.mHasCollided
		local bVisible = V.mIsVisible

		if not bCollided and K > mBloodMaxParticles and fInitTime + mBloodTrailDieTime < CurTime() then

			bCollided = true
			V.mHasCollided = true
			V.mStopVelocity = true

		end

		if ( #mPoints <= 0 and bCollided ) or fInitTime + fDieTime < CurTime() then

			TRemove( mBloodRenderData, K )
			continue

		end

		IsBloodVisible( V )
		UpdateVelocity( V )
		UpdateCollision( V )
		AddTrailPoint( V )
		RenderTrail( V )

		if bCollided or not bVisible then continue end
	
		RSetMaterial( mBloodDropMat )
		RDrawSprite( vPos, 10, 10, cColor )

	end

end


function UltrakillBase.CreateBlood( vPos, iAmount )

	if not mBloodConVar:GetBool() then return end
	if mBloodLegacyConVar:GetBool() then return InitializeLegacyBlood( vPos, iAmount ) end

	local mEmitter2D = ParticleEmitter( vPos )

	for I = 1, MMin( iAmount, 256 ) do

		InitializeBlood( vPos )
	
		if I ~= 1 and I % 7 ~= 0 then continue end

		CreateParticlesBlood( vPos, mEmitter2D )
	
	end

	mEmitter2D:Finish()

end


function UltrakillBase.CreateSand( vPos, iAmount )

	if not mBloodConVar:GetBool() then return end

 	local Emitter2D = ParticleEmitter( vPos )

  	for I = 1, iAmount do

    	mRandomVector.x = MRand( -1, 1 )
		mRandomVector.y = MRand( -1, 1 )
		mRandomVector.z = MRand( -1, 1 )

		local SandParticle = Emitter2D:Add( mSand, vPos + mRandomVector * MRand( 3, 12 ) )

		SandParticle:SetDieTime( 1.5 )
		SandParticle:SetStartSize( 7 )
		SandParticle:SetEndSize( 28 )
		SandParticle:SetStartAlpha( 125 )
		SandParticle:SetEndAlpha( 0 )
		SandParticle:SetColor( 255, 209, 99 )

    	mRandomVector.x = MRand( -1, 1 )
		mRandomVector.y = MRand( -1, 1 )
		mRandomVector.z = MRand( -1, 1 )

		SandParticle:SetVelocity( mRandomVector * MRand( 5, 45 ) )

		SandParticle:SetRoll( MRand( -1, 1 ) )
		SandParticle:SetAirResistance( 0.1 )
		SandParticle:SetCollide( false )
		SandParticle:SetGravity( mSandParticleGravity )

  	end

  	Emitter2D:Finish()

end


HAdd( "PostDrawOpaqueRenderables", "UltrakillBase_Blood_Renderer", RenderBlood )
CVAddChangeCallback( "drg_ultrakill_bloodquality", CalculateQuality, "UltrakillBase_Blood_Quality" )
CVAddChangeCallback( "drg_ultrakill_bloodsplatter", SetSplatter, "UltrakillBase_Blood_Splatter" )