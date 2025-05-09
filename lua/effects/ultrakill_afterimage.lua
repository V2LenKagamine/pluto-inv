-- Localize Libaries & Functions --

local Color = Color
local CurTime = CurTime
local IsValid = IsValid
local ClientsideModel = ClientsideModel
local ipairs = ipairs
local Material = Material
local Lerp = Lerp
local RSetBlend = CLIENT and render.SetBlend
local RMaterialOverride = CLIENT and render.MaterialOverride
local RSetColorModulation = CLIENT and render.SetColorModulation
local CLuaEffect = UltrakillBase.CLuaEffect
local DefaultColor = Color( 0, 0.6, 1 )


function EFFECT:Init( CEffectData )

	self.Ent = CEffectData:GetEntity()
	self.AfterImageLifeTime = CEffectData:GetMagnitude() or 1
	self.AfterImageColor = CEffectData:GetStart() * 0.1 or DefaultColor

	local Ent = self.Ent

	self.Initialized = false
	self.InitTime = CurTime()

	if not IsValid( Ent ) then return end

	local Pos = CEffectData:GetOrigin() or Ent:WorldSpaceCenter()
	local Ang = CEffectData:GetAngles() or Ent:GetAngles()

	self:SetPos( Pos )
	self:SetAngles( Ang )
	self:SetRenderBounds( Ent:GetRenderBounds() )

	local Seq = Ent:GetSequence()
	local Cycle = Ent:GetCycle()

	local AfterImage = ClientsideModel( Ent:GetModel(), RENDERGROUP_TRANSLUCENT )

	AfterImage:SetPos( Pos )
	AfterImage:SetAngles( Ang )
	AfterImage:SetModelScale( Ent:GetModelScale() )
	AfterImage:ResetSequence( Seq )
	AfterImage:SetSequence( Seq )
	AfterImage:SetCycle( Cycle )

	-- BodyGroups --

	local BodyGroups = Ent:GetBodyGroups()

	for K, BodyGroup in ipairs( BodyGroups ) do

		local ID = BodyGroup.id

		AfterImage:SetBodygroup( ID, Ent:GetBodygroup( ID ) )

	end
	

	-- Copy Bone Manipulations --

	if Ent:HasBoneManipulations() then

		for X = 0, Ent:GetBoneCount() - 1 do

			AfterImage:ManipulateBoneAngles( X, Ent:GetManipulateBoneAngles( X ), false )
			AfterImage:ManipulateBonePosition( X, Ent:GetManipulateBonePosition( X ), false )
			AfterImage:ManipulateBoneScale( X, Ent:GetManipulateBoneScale( X ) )
			AfterImage:ManipulateBoneJiggle( X, Ent:GetManipulateBoneJiggle( X ) )

		end

	end

	AfterImage:SetNoDraw( true )

	self.AfterImage = AfterImage
	self.Initialized = true

	CLuaEffect.AddToGarbageCollector( self, AfterImage )

end


function EFFECT:Think()

	if CurTime() - self.InitTime > self.AfterImageLifeTime then

		return false

	end

	return self.Initialized

end


local AfterImageMaterial = Material( "models/ULTRAKILL/vfx/White" )
local FresnelMaterial = Material( "models/ULTRAKILL/vfx/Afterimage" )


function EFFECT:Render()

	if not IsValid( self.AfterImage ) then return end

	local Delta = ( CurTime() - self.InitTime ) / self.AfterImageLifeTime
	local Alpha = Lerp( Delta, 1, 0 )

   	-- AfterImage Render --

   		RSetBlend( 0.33333 * Alpha )
   		RMaterialOverride( AfterImageMaterial )
   		RSetColorModulation( self.AfterImageColor.r, self.AfterImageColor.g, self.AfterImageColor.b )

   		self.AfterImage:DrawModel()

		RMaterialOverride( FresnelMaterial )

		self.AfterImage:DrawModel()

	-- Reset --

   		RSetBlend( 1 )
   		RMaterialOverride()
   		RSetColorModulation( 1, 1, 1 )

end
