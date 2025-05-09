

-- Localize Libaries & Functions --


local Angle = Angle
local Vector = Vector
local CurTime = CurTime
local IsValid = IsValid
local ClientsideModel = ClientsideModel
local Material = Material
local Color = Color
local MMax = math.max
local RMaterialOverride = CLIENT and render.MaterialOverride
local Lerp = Lerp
local RSetMaterial = CLIENT and render.SetMaterial
local RDrawSprite = CLIENT and render.DrawSprite
local CLuaEffect = UltrakillBase.CLuaEffect
local OutCirc = math.ease.OutCirc


local OffsetAngle = Angle( 0, 90, 0 )

local Offsets = {

	Vector(),
	Vector( 0, 1, 0 ),
	Vector( 0, -1, 0 ),
	Vector( 0, 0, -1 ),
	Vector( 0, 0, 1 )

}

local DieTime = 4


function EFFECT:Init( CEffectData )

	self.Ent = CEffectData:GetEntity()
	self.DieTime = CEffectData:GetMagnitude() * 0.01

	self.InitTime = CurTime()

	if not IsValid( self.Ent ) then return end

	self.InitSeq = self.Ent:GetSequence()

	self:SetPos( self.Ent:GetPos() )
	self:SetAngles( self.Ent:GetAngles() + OffsetAngle )
	self:SetParent( self.Ent, 4 )
	self:SetRenderBounds( self.Ent:GetRenderBounds() )

	for I = 1, 5 do

		HellOrb = ClientsideModel( "models/ultrakill/mesh/effects/sphere/Sphere_16.mdl", RENDERGROUP_TRANSLUCENT )

		local Offset = Vector()

		Offset:Set( Offsets[ I ] )
		Offset:Rotate( self:GetAngles() )

		HellOrb:SetPos( self:GetPos() + Offset * 7 )
		HellOrb:SetAngles( self:GetAngles() )
		HellOrb:SetParent( self )
		HellOrb:SetNoDraw( true )

		CLuaEffect.AddToGarbageCollector( self, HellOrb )

		self[ "HellOrb_" .. I ] = HellOrb

	end

end


local function ShouldCancel( Ent )

	if not IsValid( Ent ) then return false end
	if Ent.IsUltrakillNextbot then return not Ent:IsDead() end
	if self.InitSeq ~= Ent:GetSequence() then return false end

	return true

end


function EFFECT:Think()

	if CurTime() - self.InitTime > self.DieTime or not ShouldCancel( self.Ent ) then

		return false

	end

	return IsValid( self.Ent )

end


local SpriteMaterial = Material( "particles/ultrakill/Charge" )
local SpriteColor = Color( 225, 0, 0, 255 )

local OrbMaterial = Material( "models/ultrakill/vfx/Skulls/Skull2" )


local function CalculateLifeTimeDelta( self, DieTime, HoldTime )

	if HoldTime == nil then HoldTime = 0 end

	if HoldTime > 0 then

		DieTime = DieTime - HoldTime

	end

	local LifeTime = CurTime() - self.InitTime

	LifeTime = MMax( LifeTime - HoldTime, 0 )

	return LifeTime / DieTime

end


function EFFECT:Render()

	if not IsValid( self.HellOrb_1 ) then return end

	local Delta = OutCirc( CalculateLifeTimeDelta( self, self.DieTime ) )

	RMaterialOverride( OrbMaterial )

	for I = 1, 5 do

		local MaxSize = I > 1 and 0.25 or 0.5
		local HellOrb = self[ "HellOrb_" .. I ]

		if not HellOrb then continue end

		HellOrb:SetModelScale( Lerp( Delta, 0, MaxSize ) )
		HellOrb:DrawModel()

	end

	-- Reset --

	RMaterialOverride()

	-- Sprite --

	RSetMaterial( SpriteMaterial )
	RDrawSprite( self:GetPos(), 31 * Delta, 31 * Delta, SpriteColor )

end
