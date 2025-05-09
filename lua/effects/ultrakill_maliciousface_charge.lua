-- Localize Libaries & Functions --


local Angle = Angle
local IsValid = IsValid
local Material = Material
local Color = Color
local Vector = Vector
local MMax = math.max
local RSetMaterial = CLIENT and render.SetMaterial
local RDrawBox = CLIENT and render.DrawBox
local CurTime = CurTime
local Lerp = Lerp
local CLuaEffect = UltrakillBase.CLuaEffect
local OutCirc = math.ease.OutCirc



local OffsetAngle = Angle( 0, 90, 0 )
local DieTime = 4


function EFFECT:Init( CEffectData )

	self.Ent = CEffectData:GetEntity()
	self.DieTime = CEffectData:GetMagnitude() * 0.01

	self.InitTime = CurTime()

	if not IsValid( self.Ent ) then return end

	self:SetRenderBounds( self.Ent:GetRenderBounds() )

	self:SetPos( self.Ent:GetPos() )
	self:SetAngles( self.Ent:GetAngles() + OffsetAngle )
	self:SetParent( self.Ent, 1 )

end


local function ShouldCancel( Ent )

	if not IsValid( Ent ) then return false end
	if Ent.IsUltrakillNextbot then return not Ent:IsDead() end

	return true

end


function EFFECT:Think()

	if CurTime() - self.InitTime > self.DieTime or not ShouldCancel( self.Ent ) then

		return false

	end

	return IsValid( self.Ent )

end


local SpriteMaterial = Material( "particles/ultrakill/Charge2" )
local SpriteColor = Color( 255, 255, 255, 255 )
local SpriteBounds = Vector()


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

	local Delta = CalculateLifeTimeDelta( self, self.DieTime )

	-- Sprite --

	SpriteBounds:SetUnpacked( 20 * Delta, 20 * Delta, 0 )

	RSetMaterial( SpriteMaterial )
	RDrawBox( self:GetPos(), self:GetAngles(), -SpriteBounds, SpriteBounds, SpriteColor )

end
