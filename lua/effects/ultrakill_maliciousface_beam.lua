-- Localize Libaries & Functions --


local Vector = Vector
local CurTime = CurTime
local Material = Material
local Color = Color
local Lerp = Lerp
local RSetMaterial = CLIENT and render.SetMaterial
local RStartBeam = CLIENT and render.StartBeam
local LerpVector = LerpVector
local RAddBeam = CLIENT and render.AddBeam
local REndBeam = CLIENT and render.EndBeam
local CLuaEffect = UltrakillBase.CLuaEffect
local OutCirc = math.ease.OutCirc


-- Localized Vars --


local DieTime = 0.75
local RenderBounds = Vector( 100, 100, 100 )


function EFFECT:Init( CEffectData ) 

	self.StartPos = CEffectData:GetOrigin()
	self.EndPos = CEffectData:GetStart()

	self.Initialized = false

	if not self.StartPos or not self.EndPos then return end

	self:SetRenderBoundsWS( self.StartPos, self.EndPos, RenderBounds )

	self:SetPos( self.StartPos )

	self.InitTime = CurTime()
	self.Initialized = true

end


function EFFECT:Think()

	if CurTime() - self.InitTime > DieTime then

		return false

	end

   	return self.Initialized

end


local TrailMaterial = Material( "particles/ultrakill/ChargeO2_Trail" )
local TrailColor = Color( 255, 255, 205, 255 )


function EFFECT:Render()

	-- Trail --

	local Delta = ( CurTime() - self.InitTime ) / DieTime
	local TrailLerp = Lerp( Delta, 1, 0 )

	RSetMaterial( TrailMaterial )
	RStartBeam( 2 )

		for I = 0, 1 do

			local Vec = LerpVector( I, self.StartPos, self.EndPos )

			RAddBeam( Vec, 55 * TrailLerp, I, color_white )

		end

	REndBeam()

end
