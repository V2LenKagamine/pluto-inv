if SERVER then return end


UltrakillBase.CLuaEffect = UltrakillBase.CLuaEffect or {}


-- Localize libraries & Functions --

local isfunction = isfunction
local ipairs = ipairs
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
local RealFrameTime = RealFrameTime
local IsValid = IsValid
local isvector = isvector
local EyePos = EyePos
local isangle = isangle
local EyeAngles = EyeAngles
local WorldToLocal = WorldToLocal
local CStart3D = cam.Start3D
local CEnd3D = cam.End3D
local Type = type
local CLuaEffect = UltrakillBase.CLuaEffect

local function AddToGarbageCollector( self, Object )

    self.ObjectsToGarbageCollect = self.ObjectsToGarbageCollect or {}

    self.ObjectsToGarbageCollect[ #self.ObjectsToGarbageCollect + 1 ] = Object

end


local TypeToFunctionIndex = {

    [ "CSEnt" ] = function( Object )

        SafeRemoveEntityDelayed( Object, RealFrameTime() )

    end,

    [ "CLuaEmitter" ] = function( Object )

        Object:Finish()

    end,

    [ "ProjectedTexture" ] = function( Object )

        Object:Remove()

    end,

    [ "CNewParticleEffect" ] = function( Object )

        Object:StopEmissionAndDestroyImmediately()

    end

}


local function RunGarbageCollector( self )

    local Collection = self.ObjectsToGarbageCollect

    for Index, Garbage in ipairs( Collection ) do

        if not isfunction( TypeToFunctionIndex[ Type( Garbage ) ] ) or not IsValid( Garbage ) then continue end

        TypeToFunctionIndex[ Type( Garbage ) ]( Garbage )

    end

end


local function CreateGarbageCollector( self )

    if self.ObjectsToGarbageCollect then return end

    self.ObjectsToGarbageCollect = {}

    self:CallOnRemove( "CLuaEffect_GarbageCollector", function( self )

        RunGarbageCollector( self )

    end )

end


function CLuaEffect.AddToGarbageCollector( self, ... )

    CreateGarbageCollector( self )

    for _, ObjectToPass in ipairs( { ... } ) do

        if ObjectToPass == nil then continue end

        AddToGarbageCollector( self, ObjectToPass )

    end

end


function CLuaEffect.LockEmitterToTransform( Emitter, Pos, Ang )

	if not IsValid( Emitter ) then return end

	if not isvector( Pos ) then Pos = UltrakillBase.EyePos end
	if not isangle( Ang ) then Ang = UltrakillBase.EyeAngles end

	local LocalPos, LocalAngle = WorldToLocal( UltrakillBase.EyePos, UltrakillBase.EyeAngles, Pos, Ang )
 
	CStart3D( LocalPos, LocalAngle )

		Emitter:Draw()

	CEnd3D()

end