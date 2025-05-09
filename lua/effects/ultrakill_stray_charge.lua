-- Localize Libaries & Functions --


local Angle = Angle
local CurTime = CurTime
local IsValid = IsValid
local ClientsideModel = ClientsideModel
local Material = Material
local Color = Color
local MMax = math.max
local Lerp = Lerp
local RMaterialOverride = CLIENT and render.MaterialOverride
local RSetMaterial = CLIENT and render.SetMaterial
local RDrawSprite = CLIENT and render.DrawSprite
local CLuaEffect = UltrakillBase.CLuaEffect
local OutCirc = math.ease.OutCirc



local OffsetAngle = Angle( 0, 90, 0 )
local DieTime = 4


function EFFECT:Init( CEffectData )

	self.Ent = CEffectData:GetEntity()
	self.DieTime = CEffectData:GetMagnitude() * 0.01

	self.InitTime = CurTime()

	if not IsValid( self.Ent ) then return end

	self.InitSeq = self.Ent:GetSequence()

	self:SetPos( self.Ent:GetPos() )
	self:SetAngles( self.Ent:GetAngles() + OffsetAngle )
	self:SetParent( self.Ent, 2 )
	self:SetRenderBounds( self.Ent:GetRenderBounds() )

	self.HellOrb = ClientsideModel( "models/ultrakill/mesh/effects/sphere/Sphere_16.mdl", RENDERGROUP_TRANSLUCENT )

	self.HellOrb:SetPos( self:GetPos() )
	self.HellOrb:SetAngles( self:GetAngles() )
	self.HellOrb:SetParent( self )
	self.HellOrb:SetNoDraw( true )

	CLuaEffect.AddToGarbageCollector( self, self.HellOrb )

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

	if not IsValid( self.HellOrb ) then return end

	local Delta = OutCirc( CalculateLifeTimeDelta( self, self.DieTime ) )

	local OrbScale = Lerp( Delta, 0, 0.5 )

	RMaterialOverride( OrbMaterial )

	self.HellOrb:SetModelScale( OrbScale )
	self.HellOrb:DrawModel()

	-- Reset --

	RMaterialOverride()

	-- Sprite --

	RSetMaterial( SpriteMaterial )
	RDrawSprite( self:GetPos(), 28 * Delta, 28 * Delta, SpriteColor )

end
