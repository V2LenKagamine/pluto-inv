local AddCSLuaFile = AddCSLuaFile
local include = include
local CreateClientConVar = CreateClientConVar
local tostring = tostring
local IsValid = IsValid
local CurTime = CurTime
local isnumber = isnumber
local isfunction = isfunction
local pairs = pairs
local FindMetaTable = FindMetaTable
local Vector = Vector
local istable = istable
local GGetTimeScale = game.GetTimeScale
local MApproach = math.Approach
local SPlayFile = CLIENT and sound.PlayFile
local UltrakillBase = UltrakillBase

SOUND = ENT


ENT.Base = "base_entity"
ENT.Type = "point"
ENT.IsUltrakillSoundSystem = true


if SERVER then

	AddCSLuaFile( "shared.lua" )
	AddCSLuaFile( "sound.lua" )

end


include( "sound.lua" )


local cClientNoBlockConVar = CreateClientConVar( "drg_ultrakill_sound_noblock", 0, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables NoBlock Setting on SoundSystem." )


function SOUND:InitializeAudio( sAudioPath )

	if not CLIENT or #sAudioPath <= 0 then return end

	local sAudioPath = "sound/" .. tostring( sAudioPath )
	local sFlags = cClientNoBlockConVar:GetBool() and "noplay noblock" or "noplay"

	SPlayFile( sAudioPath, sFlags, function( aAudio, iErrorCode, sErrorName )

		if not IsValid( self ) then return false end
		if not IsValid( aAudio ) then

			ErrorNoHalt(  "UltrakillBase.Sound has failed to play Audio:", sAudioPath, "ErrorCode:", tostring( iErrorCode ),  "ErrorString: ", sErrorName )

			return false

		end

		aAudio:SetPos( self:GetPos(), self:GetForward() )
		aAudio:EnableLooping( self.mLooping or false )

		self.mAudio = aAudio
		self:AudioUpdate()

		aAudio:Play()

	end )

end


function SOUND:Initialize()

	self:DrawShadow( false )

	self.mInitData = UltrakillBase.PullSoundScript( self:GetScriptName(), true, self:GetRandomSeed() ) 

	for K, V in pairs( self.mInitData or {} ) do

		self[ K ] = V

	end

	self.mInitTime = CurTime()
	self.mCanDie = isnumber( self.mDieTime ) and self.mDieTime >= 0 or false
	self.mHasParent = IsValid( self:GetParent() )
	self.mLifeTime = 0

	if CLIENT then

		self.mLifeTime = nil
		self:VelocityUpdate()
		self:InitializeAudio( self.mPath )

	end

end



function SOUND:Think()

	if self.mStopUpdating or self:IsMarkedForDeletion() then return false end
	if SERVER and self.mCanDie and self.mLifeTime >= self.mDieTime then self:Remove() end

	self:UpdateLifeTime()

	if CLIENT then

		self:VelocityUpdate()
		self:AudioUpdate()

	end

	if isfunction( self.mCallback ) then

    	self.mCallback( self, self:GetParent() )

  	end

	self:NextThink( CurTime() )

	return true

end


function SOUND:OnRemove()

	self.mStopUpdating = true

	if not CLIENT or not IsValid( self.mAudio ) then return end
	
	self.mAudio:SetVolume( 0 )
	self.mAudio:Stop()

end


function SOUND:Draw() end
function SOUND:UpdateTransmitState() return TRANSMIT_ALWAYS end


function SOUND:SetupDataTables()

	self:NetworkVar( "String", 0, "ScriptName" )
	self:NetworkVar( "Int", 0, "RandomSeed" )

end


-- LifeTime --


function SOUND:UpdateLifeTime()

	if CLIENT then return end

	local fDeltaTime = FrameTime()
	local fPitch = 1

	if self.mAutoDieTime and self.mPitch ~= 0 then fPitch = self.mPitch end

	self.mLifeTime = MApproach( self.mLifeTime, self.mDieTime, fDeltaTime * fPitch )

end



-- Velocity --


local vVelocityEmpty = Vector()
local fVelocitySmoothFactor = 100000


local function AbsVelocity( self )

  	local fLastTime = self.mVelocity_LastPosTime or CurTime()
  	local vLastPos = self.mVelocity_LastPos or self:GetPos()
  	local fRelativeTime = CurTime() - fLastTime

  	if fRelativeTime == 0 then return vVelocityEmpty end

  	local vRelativePos = self:GetPos() - vLastPos
 	local vVelocity = vRelativePos / fRelativeTime

  	return vVelocity

end


local function ListenerAbsVelocity( self )

	local fLastTime = self.mListenerVelocity_LastPosTime or CurTime()
	local vLastPos = self.mListenerVelocity_LastPos or UltrakillBase.EyePos

	local fRelativeTime = CurTime() - fLastTime

	if fRelativeTime == 0 then return vVelocityEmpty end

	local vRelativePos = UltrakillBase.EyePos - vLastPos
   	local vVelocity = vRelativePos / fRelativeTime

	return vVelocity

end


local function ApproachVector( vCurrent, vTarget, fRate )

	local vApproachedVec = Vector()

	for X = 1, 3 do

		if vCurrent[ X ] > vTarget[ X ] then
			
			vApproachedVec[ X ] = MApproach( vCurrent[ X ], vTarget[ X ], fRate * 0.5 )

			continue

		end

		vApproachedVec[ X ] = MApproach( vCurrent[ X ], vTarget[ X ], fRate )

	end

	return vApproachedVec

end


function SOUND:VelocityUpdate()

	local fUpdateInterval = CurTime() - ( self.mVelocity_LastUpdate or CurTime() )
	local vCurrentSystemVelocity = self.mVelocity or vVelocityEmpty
	local vNewSystemVelocity = AbsVelocity( self )
	local vCurrentListenerVelocity = self.mListenerVelocity or vVelocityEmpty
	local vNewListenerVelocity = ListenerAbsVelocity( self )
	local vSmoothSystemVelocity = ApproachVector( vCurrentSystemVelocity, vNewSystemVelocity, fVelocitySmoothFactor * fUpdateInterval )
	local vSmoothListenerVelocity = ApproachVector( vCurrentListenerVelocity, vNewListenerVelocity, fVelocitySmoothFactor * fUpdateInterval )

	self.mVelocity = vSmoothSystemVelocity
	self.mListenerVelocity = vSmoothListenerVelocity

	self.mVelocity_LastUpdate = CurTime()
	self.mVelocity_LastPosTime = CurTime()
	self.mVelocity_LastPos = self:GetPos()
	self.mListenerVelocity_LastPosTime = CurTime()
	self.mListenerVelocity_LastPos = UltrakillBase.EyePos

end


-- Meta --


local mtEntityMeta = FindMetaTable( "Entity" )
local mBase_ToString = mtEntityMeta.__tostring


function mtEntityMeta:__tostring()

	if self.IsUltrakillSoundSystem then return "Sound [" .. self:EntIndex() .. "][" .. self:GetScriptName() .. "]" end

	return mBase_ToString( self )

end


local mBase_gmsaveShouldSaveEntity = gmsave.ShouldSaveEntity

function gmsave.ShouldSaveEntity( eEntity )

	if eEntity.IsUltrakillSoundSystem then return false end

	return mBase_gmsaveShouldSaveEntity

end