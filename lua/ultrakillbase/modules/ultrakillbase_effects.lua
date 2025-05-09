if SERVER then


  function UltrakillBase.CreateBlood( ... )

    UltrakillBase.CallOnClient( "CreateBlood", ... )

  end


  function UltrakillBase.CreateSand( ... )

    UltrakillBase.CallOnClient( "CreateSand", ... )

  end


  function UltrakillBase.CreateGibs( ... )

    UltrakillBase.CallOnClient( "CreateGibs", ... )

  end


end


if SERVER then return end


local UltrakillBase = UltrakillBase
local CreateConVar = CreateConVar
local IsValid = IsValid
local ParticleEffect = ParticleEffect
local Vector = Vector
local Angle = Angle
local istable = istable
local Model = Model
local ParticleEffectAttach = ParticleEffectAttach
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local next = next
local ipairs = ipairs
local UEffect = util.Effect
local TIsEmpty = table.IsEmpty
local MClamp = math.Clamp
local MMin = math.min
local MRandom = math.random
local MRand = math.Rand
local RSetMaterial = render.SetMaterial
local RStartBeam = render.StartBeam
local RAddBeam = render.AddBeam
local REndBeam = render.EndBeam
local ECreateClientProp = CLIENT and ents.CreateClientProp
local Material = Material
local isvector = isvector


local GibsConVar = CreateConVar( "drg_ultrakill_gibs", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Gibs" )


local vRandomOffset = Vector()
local aRandomRotation = Angle()


local function SetVelocity( mEntity, vVelocity )

  local mPhysics = mEntity:GetPhysicsObject()

  if not IsValid( mPhysics ) then return end

  mPhysics:SetVelocity( vVelocity )

end


local function CreateClientPhysicsObject( mModel, vPos, vVelocity, fSize, sTrail, fDieTime )

  mModel = istable( mModel ) and mModel[ MRandom( #mModel ) ] or mModel

  local mEntity = ECreateClientProp( Model( mModel ) )

  aRandomRotation:Random()
  vRandomOffset:Random( -10, 10 )

  mEntity:SetPos( vPos + vRandomOffset )
  mEntity:SetAngles( aRandomRotation )
  mEntity:SetModelScale( fSize )
  mEntity:DestroyShadow()
  mEntity:DrawShadow( false )
  mEntity:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS )

  if sTrail then ParticleEffectAttach( sTrail, PATTACH_POINT_FOLLOW, mEntity, 0 ) end

  mEntity:Spawn()
  mEntity:Activate()

  vRandomOffset:Random( -vVelocity, vVelocity )
  vRandomOffset.z = MClamp( vRandomOffset.z, vVelocity * 0.4, vVelocity )

  local mPhysicsEntity = mEntity:GetPhysicsObject()

  mPhysicsEntity:SetVelocity( vRandomOffset )

  SafeRemoveEntityDelayed( mEntity, fDieTime or MRand( 2, 4 ) )

end


function UltrakillBase.CreateGibs( mGib )

  if not istable( mGib ) or TIsEmpty( mGib ) or not GibsConVar:GetBool() then return end

  local fKey, mNestedGib = next( mGib )

  if istable( mNestedGib ) then

    for K, V in ipairs( mGib ) do

      CreateClientPhysicsObject( V.Models, V.Position, V.Velocity, V.ModelScale, V.Trail, V.LifeTime )

    end

    return

  end

  CreateClientPhysicsObject( mGib.Models, mGib.Position, mGib.Velocity, mGib.ModelScale, mGib.Trail, mGib.LifeTime )

end