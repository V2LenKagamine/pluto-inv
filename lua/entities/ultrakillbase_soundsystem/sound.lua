
SOUND = ENT

if not istable( SOUND ) or SERVER then return end


-- Localize Libaries & Functions --


local GetGlobal2Bool = GetGlobal2Bool
local istable = istable
local LocalPlayer = LocalPlayer
local IsValid = IsValid
local MMax = math.max
local MClamp = math.Clamp
local MAbs = math.abs
local MRemap = math.Remap
local CurTime = CurTime
local istable = istable
local CreateConVar = CreateConVar
local SysTime = SysTime
local Lerp = Lerp
local SHasFocus = system.HasFocus
local GSinglePlayer = game.SinglePlayer
local GIsGameUIVisible = gui.IsGameUIVisible
local GGetTimeScale = game.GetTimeScale
local HAdd = hook.Add


local mVolumeConVar = CreateConVar( "drg_ultrakill_sound_volume", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "SFX Volume." )
local mDyingConVar = CreateConVar( "drg_ultrakill_sound_dying_pitch", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Lowers Pitch when Dead." )
local fSpeedOfSound = 18005.2493438
local fSmallestPlayback = 0.001


local function ProcessDoppler( self, fDopplerFactor )

  if fDopplerFactor <= 0 then return 1 end

  local fSpeed = fSpeedOfSound * fDopplerFactor
  local vPos, vListenerPos = self:GetPos(), UltrakillBase.EyePos
  local vVelocity = self.mVelocity
  local vListenerVelocity = self.mListenerVelocity

  local vRelativePos = vPos - vListenerPos

  if vVelocity:IsZero() and vListenerVelocity:IsZero() or vRelativePos:IsZero() then return 1 end

  local fRelativeLength = vRelativePos:Length()
  local vRelativeVelocity = vRelativePos:Dot( vVelocity ) / fRelativeLength
  local vRelativeListenerVelocity = vRelativePos:Dot( vListenerVelocity ) / fRelativeLength

  local fDoppler = MAbs( ( fSpeed + vRelativeListenerVelocity ) / ( fSpeed + vRelativeVelocity ) )

  return fDoppler

end


local function ProcessPanning( self )

  local vPos, vListenerPos = self:GetPos(), UltrakillBase.EyePos
  local aListenerAngle = UltrakillBase.EyeAngles:Right()
  local vNormalizedRelativePos = ( vPos - vListenerPos ):GetNormalized()
  
  return vNormalizedRelativePos:Dot( aListenerAngle )

end


local function ProcessPausing( mAudio )

  if mAudio:GetState() == GMOD_CHANNEL_STOPPED then return end
  if mAudio:GetState() == GMOD_CHANNEL_PLAYING and GSinglePlayer() and GIsGameUIVisible() then return mAudio:Pause()
  elseif mAudio:GetState() == GMOD_CHANNEL_PAUSED and GSinglePlayer() and not GIsGameUIVisible() then return mAudio:Play() end

end


local function Process3D( self, aAudio, fRadius, fVolume )

  if fRadius <= 0 then return aAudio:SetVolume( fVolume ) end

  local fSqrDistance = self:GetPos():DistToSqr( UltrakillBase.EyePos )
  local fPan = ProcessPanning( self )
  fRadius = fRadius * fRadius

  aAudio:SetPan( fPan )

  if fSqrDistance > fRadius then return aAudio:SetVolume( 0 ) end

  local fVolume3D = MClamp( 1 - fSqrDistance / fRadius, 0, 1 ) ^ 1.2

  aAudio:SetVolume( fVolume * fVolume3D )

end


local fDyingInitTime = 0
local fDyingLerpTime = 10


local function ProcessDying()

  if not mDyingConVar:GetBool() then return 1 end

  local eListener = LocalPlayer()

  if eListener:Alive() then

    fDyingInitTime = SysTime()

    return 1

  end

  local fDyingDelta = ( SysTime() - fDyingInitTime ) / fDyingLerpTime
  local fPitch = Lerp( fDyingDelta, 1, 0.0000000001 )

  return fPitch

end


function SOUND:AudioUpdate()

  if not IsValid( self.mAudio ) or self.mStopUpdating then return end

  local aAudio = self.mAudio
  local fRadius = self.mRadius
  local fPitch = self.mPitch
  local fVolume = self.mVolume * mVolumeConVar:GetFloat()
  local fTimescale = self.mTimeScale and GGetTimeScale() or 1
  local bIsSlowMotion = GetGlobal2Bool( "UltrakillBase_IsSlowMotion", false )
  local fDoppler = ProcessDoppler( self, self.mDopplerFactor or 1 )
  local fDying = ProcessDying()

  fTimescale = bIsSlowMotion and MRemap( fTimescale, 0.1, 1, 0.01, 1 ) or fTimescale
  fVolume = SHasFocus() and fVolume or 0

  Process3D( self, aAudio, fRadius, fVolume )
  ProcessPausing( aAudio )

  aAudio:SetPlaybackRate( MMax( fPitch * fTimescale * fDoppler * fDying, fSmallestPlayback ) )

end