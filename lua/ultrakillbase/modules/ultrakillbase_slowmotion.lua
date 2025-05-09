if CLIENT then return end


local CreateConVar = CreateConVar
local UltrakillBase = UltrakillBase
local FrameTime = FrameTime
local TIsEmpty = table.IsEmpty
local HAdd = hook.Add
local istable = istable
local Lerp = Lerp
local SysTime = SysTime
local SetGlobal2Bool = SetGlobal2Bool
local GetTimeScale = game.GetTimeScale
local SetTimeScale = game.SetTimeScale
local InCubic = math.ease.InCubic

local mSlowMotionConVar = CreateConVar( "drg_ultrakill_slowmo", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enables Slow Motion Effect." )
local mHitStopConVar = CreateConVar( "drg_ultrakill_hitstop", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enables Parry HitStop Effect." )

local mSlowMotion = {}
local fSlowMotion = 1
local bIsSlowMotion = false
local fMinTimescale = 0.1


function UltrakillBase.SlowMotion( fTime, fHoldTime )

  if not mSlowMotionConVar:GetBool() then return end

  fHoldTime = fHoldTime or 0
  mSlowMotion.mInitTime = SysTime() + fHoldTime
  mSlowMotion.mTime = fTime * 0.7
  fSlowMotion = 0
  bIsSlowMotion = true

  SetGlobal2Bool( "UltrakillBase_IsSlowMotion", true )

end


function UltrakillBase.HitStop( fTime )

  if not mHitStopConVar:GetBool() then return end

  return UltrakillBase.SlowMotion( FrameTime(), fTime )

end


local function ProcessSlowMotion()

  if TIsEmpty( mSlowMotion ) then return 1 end

  local fTime = mSlowMotion.mTime
  local fInitTime = mSlowMotion.mInitTime
  local fDelta = ( SysTime() - fInitTime ) / fTime
  local fTimescale = Lerp( InCubic( fDelta ), fMinTimescale, 1 )

  return fTimescale

end


HAdd( "Think", "UltrakillBase_SlowMotion", function()

  if not bIsSlowMotion then return end

  local fTimescale = ProcessSlowMotion()

  SetTimeScale( fTimescale )

  if fTimescale >= 1 then

    bIsSlowMotion = false
    SetGlobal2Bool( "UltrakillBase_IsSlowMotion", false )

  end

end )

