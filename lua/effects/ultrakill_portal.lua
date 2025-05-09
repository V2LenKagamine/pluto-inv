-- Localize Libaries & Functions --


local Material = Material
local CurTime = CurTime
local ClientsideModel = ClientsideModel
local Lerp = Lerp
local Matrix = Matrix
local RMaterialOverride = CLIENT and render.MaterialOverride
local CLuaEffect = UltrakillBase.CLuaEffect
local InSine = math.ease.InSine

local DieTime = 0.53

local Materials = {

	Material( "models/ultrakill/vfx/Portals/Portal_Light" ),
	Material( "models/ultrakill/vfx/Portals/Portal_Heavy" ),
	Material( "models/ultrakill/vfx/Portals/Portal_Superheavy" ),
	Material( "models/ultrakill/vfx/Portals/Portal_Mindflayer" ),
	Material( "models/ultrakill/vfx/Portals/Portal_Red" )

}


function EFFECT:Init( CEffectData )

	local Pos = CEffectData:GetOrigin()
	local Ang = CEffectData:GetAngles()
	local Flag = CEffectData:GetColor()
	local Bounds = CEffectData:GetStart() * 0.04

	self.PortalMaterial = Materials[ Flag ]

	self.InitTime = CurTime()

	self.Scaling = 0

	self.Portal = ClientsideModel( "models/ultrakill/mesh/effects/sphere/Sphere_16.mdl", RENDERGROUP_OPAQUE )
	self.Portal:SetPos( Pos )
	self.Portal:SetAngles( Ang )
   	self.Portal:SetNoDraw( true )

	Bounds.x = Bounds.x * 1.3
	Bounds.y = Bounds.y * 1.3

	self:SetRenderBounds( -Bounds * 15, Bounds * 15 )

	self.Bounds = Bounds

	CLuaEffect.AddToGarbageCollector( self, self.Portal )

end


function EFFECT:Think()

   	if CurTime() - self.InitTime > DieTime then

		return false

	end

   	return true

end


local function CalculateLifeTimeDelta( self, DieTime )

	local LifeTime = CurTime() - self.InitTime

	return LifeTime / DieTime

end


local function LerpSine( X, From, To )

	X = X > 1 and 1 or X < 0 and 0 or X

	return Lerp( InSine( X ), From, To )

end


local ScaleMatrix = Matrix()


function EFFECT:Render()

	local Scaling = LerpSine( CalculateLifeTimeDelta( self, DieTime ), 1, 0 )
	local Bounds = self.Bounds

	RMaterialOverride( self.PortalMaterial )

	ScaleMatrix:SetScale( Bounds * Scaling )
	self.Portal:EnableMatrix( "RenderMultiply", ScaleMatrix )

   	self.Portal:DrawModel()

   	RMaterialOverride()
   
end