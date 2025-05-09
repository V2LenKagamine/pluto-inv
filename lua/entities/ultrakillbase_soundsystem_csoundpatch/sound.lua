
SOUND = ENT

if not istable( SOUND ) or SERVER then return end


-- Localize Libaries & Functions --


local istable = istable
local LocalPlayer = LocalPlayer
local IsValid = IsValid
local MClamp = math.Clamp
local MAbs = math.abs
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
  local fDying = ProcessDying()

  fVolume = SHasFocus() and fVolume or 0

  aAudio:ChangeVolume( fVolume * 100 )
  aAudio:ChangePitch( fPitch * fTimescale * fDying * 100 )

end