-- Localize Libaries & Functions --


local Vector = Vector
local Angle = Angle
local LerpVector = LerpVector
local MRand = math.Rand
local MClamp = math.Clamp
local UTraceLine = util.TraceLine
local ClientsideModel = ClientsideModel
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local ParticleEmitter = ParticleEmitter
local CLuaEffect = UltrakillBase.CLuaEffect


local aOffsetRotation = Angle( 0, 0, 90 )
local vOffset = Vector( 0, 0, 1 )
local aRandomRotation = Angle()
local mTraceInfo = {

	collisiongroup = COLLISION_GROUP_WORLD

}




function EFFECT:Init( CEffectData )

	local vPos = CEffectData:GetStart()
	local vOrigin = CEffectData:GetOrigin()
	local aRotation = CEffectData:GetAngles()
	local fModelScale = CEffectData:GetRadius() * 0.01
	local fDistance = MClamp( vOrigin:Distance( vPos ) * 0.02, 0, 25 )
	local aLerpRotation
	local vLerpPos

	fModelScale = fModelScale or 1

	self.mDieTime = MRand( 3, 5 )

	self:SetPos( vPos )
	self:SetAngles( aRotation )
	self:AddEFlags( EFL_IN_SKYBOX ) -- Force Render.

	for I = 1, fDistance do

		local vLerpPos = LerpVector( I / fDistance, vOrigin, vPos )

		mTraceInfo.start = vLerpPos + vOffset * 50
		mTraceInfo.endpos = vLerpPos - vOffset * 120

		local mResult = UTraceLine( mTraceInfo )

		if not mResult.Hit then continue end

		vLerpPos = mResult.HitPos
		aLerpRotation = mResult.HitNormal

		aLerpRotation:Rotate( aRotation + aOffsetRotation )
		aLerpRotation = aLerpRotation:Angle()

		self:CreateRubble( vLerpPos, aLerpRotation, fModelScale )

	end

end


function EFFECT:CreateRubble( vPos, aRotation, fModelScale )

	aRandomRotation.y = MRand( -360, 360 )

	local mRubble = ClientsideModel( "models/ultrakill/mesh/effects/rubble/Rubble.mdl", RENDERGROUP_TRANSLUCENT )

	mRubble:SetPos( vPos )
	mRubble:SetAngles( aRotation + aRandomRotation )
	mRubble:SetModelScale( 1.1 * fModelScale )

	SafeRemoveEntityDelayed( mRubble, self.mDieTime )

	local mEmitter2D = ParticleEmitter( vPos, false )
	local mRubbleSmoke = mEmitter2D:Add( "particles/ultrakill/Smoke_Additive", vPos - vOffset * 160 )

	if mRubbleSmoke then

		mRubbleSmoke:SetDieTime( 0.4 )
		mRubbleSmoke:SetStartSize( 0 )
		mRubbleSmoke:SetEndSize( 70 * fModelScale )
		mRubbleSmoke:SetStartAlpha( 255 )
		mRubbleSmoke:SetEndAlpha( 0 )

		mRubbleSmoke:SetStartLength( 0 )
		mRubbleSmoke:SetEndLength( 800 * fModelScale )

		mRubbleSmoke:SetVelocity( vOffset * 0.01 )
		mRubbleSmoke:SetAirResistance( 0 )

		mRubbleSmoke:SetCollide( false )

	end

	local mRubbleSmoke = mEmitter2D:Add( "particles/ultrakill/Smoke_Additive", vPos - vOffset * 160 )

	if mRubbleSmoke then

		mRubbleSmoke:SetDieTime( 0.4 )
		mRubbleSmoke:SetStartSize( 0 )
		mRubbleSmoke:SetEndSize( 100 * fModelScale )
		mRubbleSmoke:SetStartAlpha( 255 )
		mRubbleSmoke:SetEndAlpha( 0 )

		mRubbleSmoke:SetStartLength( 0 )
		mRubbleSmoke:SetEndLength( 800 * fModelScale )

		mRubbleSmoke:SetVelocity( vOffset * 0.01 )
		mRubbleSmoke:SetAirResistance( 0 )

		mRubbleSmoke:SetCollide( false )

	end

	mEmitter2D:Finish()

	UltrakillBase.CreateGibs( {

		{
			Position = vPos,
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk1.mdl",
			Velocity = 600,
			ModelScale = 1.1 * fModelScale,
			Trail = "Ultrakill_White_Trail"
		},

		{
			Position = vPos,
			Models = "models/ultrakill/mesh/effects/rubble/Rubble_Chunk2.mdl",
			Velocity = 600,
			ModelScale = 1.1 * fModelScale,
			Trail = "Ultrakill_White_Trail"
		}

	} )


end


function EFFECT:Think()

	return false

end


function EFFECT:Render() end
