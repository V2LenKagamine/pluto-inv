if not ENT or SERVER then return end


local RClearStencil = CLIENT and render.ClearStencil
local RSetStencilEnable = CLIENT and render.SetStencilEnable
local RSetStencilWriteMask = CLIENT and render.SetStencilWriteMask
local RSetStencilTestMask = CLIENT and render.SetStencilTestMask
local RSetStencilCompareFunction = CLIENT and render.SetStencilCompareFunction
local RSetStencilPassOperation = CLIENT and render.SetStencilPassOperation
local RSetStencilFailOperation = CLIENT and render.SetStencilFailOperation
local RSetStencilZFailOperation = CLIENT and render.SetStencilZFailOperation
local RSetStencilReferenceValue = CLIENT and render.SetStencilReferenceValue
local RMaterialOverride = CLIENT and render.MaterialOverride
local RCullMode = CLIENT and render.CullMode
local RSetBlend = CLIENT and render.SetBlend
local istable = istable
local Material = Material
local Vector = Vector
local CurTime = CurTime
local ipairs = ipairs
local ClientsideModel = ClientsideModel
local SafeRemoveEntity = SafeRemoveEntity


local mRadiantMaterial = Material( "models/ultrakill/vfx/Radiant" )
local mRadiantMaterial2 = Material( "models/ultrakill/vfx/Radiant2" )
local fOutlineThickness = 1.135


ENT.UltrakillBase_RadiantUpdate = 0


local function ScaleBones( self, fSize )

  local vScale = Vector( fSize, fSize, fSize )

  for I = 0, self:GetBoneCount() - 1 do

    self:ManipulateBoneScale( I, vScale )

  end

end


local function UpdateRadiant( self, mRadiantModel )

  if CurTime() < self.UltrakillBase_RadiantUpdate then return end

  self.UltrakillBase_RadiantUpdate = CurTime() + 0.1

  mRadiantModel:SetParent( self )

  for K, V in ipairs( self:GetBodyGroups() ) do

    mRadiantModel:SetBodygroup( V.id, self:GetBodygroup( V.id ) )

  end

end


local function StencilOutline( self )

  RClearStencil()
  
  RSetStencilEnable( true )

  RSetStencilWriteMask( 0xFF )
	RSetStencilTestMask( 0xFF )
	RSetStencilCompareFunction( STENCIL_ALWAYS )
	RSetStencilPassOperation( STENCIL_KEEP )
	RSetStencilFailOperation( STENCIL_KEEP )
	RSetStencilZFailOperation( STENCIL_KEEP )
  RSetStencilReferenceValue( 0xFF )

  RSetStencilCompareFunction( STENCIL_EQUAL )
  RSetStencilFailOperation( STENCIL_INCR )

  self:DrawModel()

  RSetStencilReferenceValue( 0 )

  RCullMode( MATERIAL_CULLMODE_CW )

  self.UltrakillBase_RadiantOutline:DrawModel( STUDIO_TWOPASS )

  RCullMode( MATERIAL_CULLMODE_CCW )

  RSetStencilFailOperation( STENCIL_KEEP )
  
  RSetStencilEnable( false )

  RClearStencil()

end


local function CreateRadiance( self )

  self.UltrakillBase_RadiantOutline = ClientsideModel( self:GetModel(), RENDERGROUP_TRANSLUCENT )

  self:CallOnRemove( "UltrakillBase_Radiant_Remover", function( self ) 

    SafeRemoveEntity( self.UltrakillBase_RadiantOutline )

  end )

  self.UltrakillBase_RadiantOutline:SetPos( self:GetPos() )
  self.UltrakillBase_RadiantOutline:AddEffects( EF_BONEMERGE + EF_BONEMERGE_FASTCULL + EF_NODRAW )

  ScaleBones( self.UltrakillBase_RadiantOutline, fOutlineThickness )

end


local function DrawOutline( self )

  if not self.UltrakillBase_RadiantOutline then CreateRadiance( self ) end

  UpdateRadiant( self, self.UltrakillBase_RadiantOutline )

  RMaterialOverride( mRadiantMaterial )

  StencilOutline( self )

end


function ENT:DrawRadiant()

  DrawOutline( self )

  if self.AlternateRadiantStyle ~= true then

    RSetBlend( 0.1 )

    RMaterialOverride( mRadiantMaterial2 )

    self:DrawModel()

    RSetBlend( 1 )

  end

  RMaterialOverride()

end