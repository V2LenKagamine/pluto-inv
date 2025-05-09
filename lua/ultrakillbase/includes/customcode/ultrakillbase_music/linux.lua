-- Localize Libaries & Functions --


-- Linux BASS.dll workaround, using CSoundPatch. --
-- It should work fine enough --


local UltrakillBase = UltrakillBase
local DrGBase = DrGBase
local select = select
local Lerp = Lerp
local isstring = isstring
local CreateConVar = CreateConVar
local pairs = pairs
local istable = istable
local CurTime = CurTime
local ipairs = ipairs
local isnumber = isnumber
local GetConVar = GetConVar
local tostring = tostring
local SysTime = SysTime
local GGetWorld = game.GetWorld
local GIsGameUiVisible = CLIENT and gui.IsGameUIVisible
local GIsConsoleVisible = CLIENT and gui.IsConsoleVisible
local GGetTimeScale = game.GetTimeScale
local GSinglePlayer = game.SinglePlayer
local SHasFocus = system.HasFocus
local TIsEmpty = table.IsEmpty
local TRemove = table.remove
local TCopy = table.Copy
local MSqrt = math.sqrt
local MClamp = math.Clamp
local HAdd = hook.Add
local UBCallOnClient = UltrakillBase.CallOnClient

local mMusicQueue = {}
local fMusicQueueMax = 32

local fFadeTimeDefault = 1.5 

local mCurrentChannel = {}
local mPreviousChannel = {}
local mCurrentFadeInTrack = {}
local mCurrentFadeOutTrack = {}

local mMusic = UltrakillBase.mMusic


local function InSqrRoot( x )

  return MSqrt( MClamp( x, 0, 1 ) )

end


local function OutSqrRoot( x )

  return MSqrt( 1 - MClamp( x, 0, 1 ) )

end


local function LerpIn( Delta, From, To )

  return Lerp( InSqrRoot( Delta ), From, To )

end


local function LerpOut( Delta, From, To )

  return Lerp( OutSqrRoot( Delta ), From, To )

end


local function CheckConVar( sID )

  if not isstring( sID ) or mMusic[ sID ].mConVar == nil then return true end

  return mMusic[ sID ].mConVar:GetBool()

end


local function IsMusicValid( tMusic )

  return not TIsEmpty( tMusic ) and istable( tMusic ) and IsValid( tMusic.mAudio )

end


-- Fade System --


local function FadeInMusic( aAudio, fFadeTime )

  if not TIsEmpty( mCurrentFadeInTrack ) then return false end

  mCurrentFadeInTrack = {

    mAudio = aAudio,
    mFadeTime = fFadeTime or fFadeTimeDefault,
    mInitTime = CurTime()

  }

  return true

end


local function FadeOutMusic( aAudio, fFadeTime )

  if not TIsEmpty( mCurrentFadeOutTrack ) then return false end

  mCurrentFadeOutTrack = {

    mAudio = aAudio,
    mFadeTime = fFadeTime or fFadeTimeDefault,
    mInitTime = CurTime()

  }

  return true

end


-- Queue System --


local function PushToQueue( eEntity, sID, fTime )

  if #mMusicQueue >= fMusicQueueMax then return false end

  mMusicQueue[ #mMusicQueue + 1 ] = {

    mEntity = eEntity,
    mID = sID,
    mTime = fTime

  }

  return true

end


local function RemoveFromQueue( eEntity, sID )

  local Key

  for K, V in ipairs( mMusicQueue ) do

    if ( IsValid( V.mEntity ) and V.mEntity ~= eEntity ) or ( isstring( sID ) and V.mID ~= sID ) then continue end

    Key = K

    break

  end

  if not Key then return end

  TRemove( mMusicQueue, Key )

end


local function PlayNextInQueue()

  if #mMusicQueue <= 0 then return end

  local mNextInQueue = TRemove( mMusicQueue, 1 )

  if not IsValid( mNextInQueue.mEntity ) or not isstring( mNextInQueue.mID ) then return PlayNextInQueue() end

  UltrakillBase.PlayMusic( mNextInQueue.mEntity, mNextInQueue.mID, mNextInQueue.mTime, true )

end


local function IsNextInQueueValid()

  if #mMusicQueue <= 0 then return false end

  local mNextInQueue = mMusicQueue[ 1 ]

  return IsValid( mNextInQueue.mEntity )

end


-- UltrakillBase.Music Functions --


function UltrakillBase.PlayMusic( eEntity, sID, fTime, bFade )

  if not CheckConVar( sID ) or not IsValid( eEntity ) or ( IsValid( eEntity ) and eEntity.IsDrGNextbot and eEntity:IsDead() ) then return false end
  if not istable( mMusic[ sID ] ) then return false end
  if IsMusicValid( mCurrentChannel, true ) then return PushToQueue( eEntity, sID, fTime ) end

  local aAudio = CreateSound( GGetWorld(), mMusic[ sID ].mPath )

  aAudio:SetSoundLevel( 0 )
  aAudio:PlayEx( 0, 0 )

  mCurrentChannel = {
  
    mAudio = aAudio,
    mEntity = eEntity,
    mID = sID,
    mPitch = 1,
    mVolume = 1,
    mPauseTime = 0,
    mCallback = mMusic[ sID ].mCallback

  }

  if bFade and TIsEmpty( mCurrentFadeInTrack ) then FadeInMusic( mCurrentChannel.mAudio ) end

end


function UltrakillBase.TransferOwnershipMusic( eOldEntity, eEntity )

  if TIsEmpty( mCurrentChannel ) or not IsValid( eOldEntity ) or eEntity ~= mCurrentChannel.mEntity then return end

  CurrentChannel.mEntity = eEntity

end


function UltrakillBase.StopCurrentMusic( eEntity, ... )

  return UltrakillBase.StopMusic( eEntity, mCurrentChannel.mID, ... )

end


function UltrakillBase.StopMusic( eEntity, sID, bBypassStack, bFade )

  if IsValid( mCurrentChannel.mAudio ) and mCurrentChannel.mEntity ~= eEntity and mCurrentChannel.mID ~= sID then return RemoveFromQueue( eEntity, sID ) end
  if not IsValid( mCurrentChannel.mAudio ) or IsValid( mCurrentChannel.mEntity ) and mCurrentChannel.mEntity ~= eEntity then return end

  bFade = bFade ~= nil and bFade or IsNextInQueueValid()

  if not bFade or not TIsEmpty( mCurrentFadeOutTrack ) then

    mCurrentChannel.mAudio:Stop()

  else

    mPreviousChannel = TCopy( mCurrentChannel )
    FadeOutMusic( mPreviousChannel.mAudio )

  end

  mCurrentChannel = {}

  if bBypassStack ~= true then PlayNextInQueue() end

end


function UltrakillBase.ChangeMusic( eEntity, sMusicFrom, sMusicTo, bFade, fTime )

  UltrakillBase.StopMusic( eEntity, sMusicFrom, true, bFade )
  UltrakillBase.PlayMusic( eEntity, sMusicTo, fTime or 0, bFade )

end


local function ProcessFadeIn()

  if not IsMusicValid( mCurrentChannel ) or TIsEmpty( mCurrentFadeInTrack ) then return 1 end

  local fDelta = ( CurTime() - mCurrentFadeInTrack.mInitTime ) / mCurrentFadeInTrack.mFadeTime

  local fVolume = LerpIn( fDelta, 0, 1 )

  if fDelta >= 1 then mCurrentFadeInTrack = {} end

  return fVolume

end


local function ProcessFadeOut()

  if not IsMusicValid( mPreviousChannel ) or TIsEmpty( mCurrentFadeOutTrack ) then return 1 end

  local fDelta = ( CurTime() - mCurrentFadeOutTrack.mInitTime ) / mCurrentFadeOutTrack.mFadeTime

  local fVolume = LerpOut( fDelta, 0, 1 )

  if fDelta >= 1 then

    mCurrentFadeOutTrack = {}

    mPreviousChannel.mAudio:Stop() -- Delete Audio when FadeOut is finished.
    mPreviousChannel = {}

  end

  return fVolume

end


local mMufflingInitTime = 0


local function ProcessMuffling()
  
  if GSinglePlayer and ( GIsGameUiVisible() or GIsConsoleVisible() ) then

    mMufflingInitTime = CurTime()

  end

  local fMufflingDelta = CurTime() - mMufflingInitTime

  local fMufflingVolume = Lerp( fMufflingDelta, 0.2, 1 )
  local fMufflingPitch = Lerp( fMufflingDelta, 0.6, 1 )

  return fMufflingVolume, fMufflingPitch

end


local function ProcessMusic()

  local mVolumeConVar = GetConVar( "drg_ultrakill_music_volume" )
  local aAudio = mCurrentChannel.mAudio
  local aPrevAudio = mPreviousChannel.mAudio
  local mCallback = mCurrentChannel.mCallback
  local mPrevCallback = mPreviousChannel.mCallback

  local fVolume = SHasFocus() and ( mCurrentChannel.mVolume and mCurrentChannel.mVolume * mVolumeConVar:GetFloat() or 0 ) or 0
  local fPrevVolume = SHasFocus() and ( mPreviousChannel.mVolume and mPreviousChannel.mVolume * mVolumeConVar:GetFloat() or 0 ) or 0
  local fPitch = mCurrentChannel.mPitch or 1
  local fPrevPitch = mPreviousChannel.mPitch or 1
  local fTimescale = GGetTimeScale() or 1

  local fFadeInVolume = ProcessFadeIn()
  local fFadeOutVolume = ProcessFadeOut()

  local fMuffleAudioVolume, fMuffleAudioPitch = ProcessMuffling()

  if aAudio ~= nil then

    aAudio:ChangeVolume( fVolume * fFadeInVolume * fMuffleAudioVolume * 100 )
    aAudio:ChangePitch( fPitch * fTimescale * fMuffleAudioPitch * 100 )

  end

  if aPrevAudio ~= nil then

    aPrevAudio:ChangeVolume( fPrevVolume * fFadeOutVolume * fMuffleAudioVolume * 100 )
    aPrevAudio:ChangePitch( fPrevPitch * fTimescale * fMuffleAudioPitch * 100 )

  end

  if isfunction( mCallback ) then mCallback( mCurrentChannel ) end
  if isfunction( mPrevCallback ) then mPrevCallback( mPreviousChannel ) end

end


HAdd( "Tick", "UltrakillBase_Music_Update", ProcessMusic )

-- Custom Music -- As of 2023-10-08, You can now add your own custom music via a single lua file.
-- Import All Lua files under lua/ultrakillbase/Includes/CustomMusic --
-- While you don't need to do it in this directory it is recommended to safeguard against your custom lua file being ran first. --

DrGBase.IncludeFolder( "ultrakillbase/Includes/CustomMusic" )