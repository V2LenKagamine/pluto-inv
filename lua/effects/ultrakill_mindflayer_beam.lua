
-- Localize Libaries & Functions --


local Vector = Vector
local IsValid = IsValid
local UTraceLine = util.TraceLine
local ClientsideModel = ClientsideModel
local CreateParticleSystem = CreateParticleSystem
local Material = Material
local Lerp = Lerp
local LerpVector = LerpVector
local table = table
local CurTime = CurTime
local Color = Color
local CLuaEffect = UltrakillBase.CLuaEffect
local RSetMaterial = CLIENT and render.SetMaterial
local RStartBeam = CLIENT and render.StartBeam
local RAddBeam = CLIENT and render.AddBeam
local REndBeam = CLIENT and render.EndBeam


local RenderBounds = Vector( 100, 100, 100 )
local GoodSequences = {

	[ "BeamHold" ] = true

}


function EFFECT:Init( CEffectData )

	self.Ent = CEffectData:GetEntity()
	self.DieTime = 2

	self.InitTime = CurTime()
	self.Initialized = false

	if not IsValid( self.Ent ) then return end

	self:SetPos( self.Ent:GetPos() )
	self:SetAngles( self.Ent:GetAngles() )
	self:SetParent( self.Ent, 8 )

	local WSCenter = self.Ent:WorldSpaceCenter()
	local EntAimVec = self.Ent:GetAimVector()

	local TraceResult = UTraceLine( {

		start = WSCenter,
		endpos = WSCenter + EntAimVec * 2000,
		collisiongroup = COLLISION_GROUP_WORLD

	} )

	self.CPoint1 = ClientsideModel( "models/ultrakill/characters/enemies/lesser/drone.mdl" )
	self.CPoint1:SetPos( TraceResult.HitPos )
	self.CPoint1:SetNoDraw( true )

	self:SetRenderBoundsWS( WSCenter, TraceResult.HitPos, RenderBounds )

	CNewParticleEffect = CreateParticleSystem( self, "Ultrakill_Mindflayer_Beam", PATTACH_POINT_FOLLOW )
	CNewParticleEffect:AddControlPoint( 1, self.CPoint1, PATTACH_POINT_FOLLOW )

	CLuaEffect.AddToGarbageCollector( self, CNewParticleEffect, self.CPoint1 )

	self.Initialized = true

end


local function ShouldCancel( Ent )

	if not IsValid( Ent ) or not GoodSequences[ Ent:GetCurrentSequenceName() ] then return false end

	return true

end


function EFFECT:Think()

	if CurTime() - self.InitTime > self.DieTime or not ShouldCancel( self.Ent ) then

		return false

	end

   	return self.Initialized

end


local TrailMaterial = Material( "particles/ultrakill/MindflayerBeam" )


function EFFECT:Render()


	if not IsValid( self.Ent ) then return end


	local CurrentPos = self:GetPos()
	local WSCenter = self.Ent:WorldSpaceCenter()
	local EntAimVec = self.Ent:GetAimVector()

	local TraceResult = UTraceLine( {

		start = WSCenter,
		endpos = WSCenter + EntAimVec * 2000,
		collisiongroup = COLLISION_GROUP_WORLD

	} )


	self.CPoint1:SetPos( TraceResult.HitPos )


	-- Trail --


	local Delta = ( CurTime() - self.InitTime ) / self.DieTime
	local TextureLerp = Lerp( Delta, 0, 10 )


	RSetMaterial( TrailMaterial )
	RStartBeam( 2 )

		for I = 0, 1 do

			local Vec = LerpVector( I, CurrentPos, TraceResult.HitPos )

			RAddBeam( Vec, 18, I + TextureLerp, color_white )

		end

	REndBeam()

end
