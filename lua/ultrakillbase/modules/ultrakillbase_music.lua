-- Localize Libaries & Functions --

local UltrakillBase = UltrakillBase
local DrGBase = DrGBase
local select = select
local Lerp = Lerp
local isstring = isstring
local CreateConVar = CreateConVar
local pairs = pairs
local istable = istable
local IsValid = IsValid
local CurTime = CurTime
local ipairs = ipairs
local unpack = unpack
local isnumber = isnumber
local GetConVar = GetConVar
local tostring = tostring
local SysTime = SysTime
local SPlayFile = sound.PlayFile
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

UltrakillBase.mMusic = UltrakillBase.mMusic or {}


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


if SERVER then


  function UltrakillBase.PlayMusic( ... )

    UBCallOnClient( "PlayMusic", ... )

  end


  function UltrakillBase.ChangeMusic( ... )

    UBCallOnClient( "ChangeMusic", ... )

  end


  function UltrakillBase.StopMusic( ... )

    UBCallOnClient( "StopMusic", ... )

  end


  function UltrakillBase.TransferOwnershipMusic( ... )

    UBCallOnClient( "TransferOwnershipMusic", ... )

  end


  function UltrakillBase.StopCurrentMusic( ... )

    UBCallOnClient( "StopCurrentMusic", ... )

  end


  function UltrakillBase.ChangeMusicTime( ... )

    UBCallOnClient( "ChangeMusicTime", ... )

  end

  function UltrakillBase.AddMusicTimer( ... )

    UBCallOnClient( "AddMusicTimer", ... )

  end


end


if CLIENT then



function UltrakillBase.AddMusic( sID, sPath, cConVar, bLooping, mCallback )

  if not isstring( sID ) then return false end

  UltrakillBase.mMusic[ sID ] = {

    mID = sID,
    mPath = sPath,
    mConVar = cConVar,
    mLooping = bLooping,
    mCallback = mCallback

  }

  return true

end


local fFleshPanopticonHoldTime = 3.5
local fFleshPanopticonOffset = 2
local fFleshPanopticonLerpTime = 3


local function FleshPanopticonMusic( mChannel )

  if TIsEmpty( mChannel ) or not istable( mChannel ) or not IsValid( mChannel.mAudio ) then return end
  if ( IsValid( mChannel.mEntity ) and mChannel.mEntity.IsUltrakillNextbot and not mChannel.mEntity:IsDead() and not mChannel.mEntity:IsDying() ) then return end

  if not mChannel.mFleshPanopticonPitchUpTime then mChannel.mFleshPanopticonPitchUpTime = CurTime() end

  local eEntity = mChannel.mEntity
  local fTime = mChannel.mFleshPanopticonPitchUpTime
  local fTimeDifference = CurTime() - fTime

  if fTimeDifference > fFleshPanopticonHoldTime and fTimeDifference < fFleshPanopticonHoldTime + fFleshPanopticonOffset then

    mChannel.mPitch = 0.5

    return

  elseif fTimeDifference > fFleshPanopticonHoldTime + fFleshPanopticonOffset then

    local fDelta = ( CurTime() - ( fTime + fFleshPanopticonHoldTime + fFleshPanopticonOffset ) ) / fFleshPanopticonLerpTime

    mChannel.mPitch = Lerp( fDelta, 0.5, 2 )

    return

  end

  mChannel.mPitch = 0.01

end


local mVolumeConVar = CreateConVar( "drg_ultrakill_music_volume", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Music Volume." )
local mMinosMusicConVar = CreateConVar( "drg_ultrakill_minosmusic", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Minos Prime Music" )
local mSisyphusMusicConVar = CreateConVar( "drg_ultrakill_sisyphusmusic", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Sisyphus Prime Music" )
local mCerberusMusicConVar = CreateConVar( "drg_ultrakill_cerberusmusic", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Cerberus Music" )
local mSwordsMachineMusicConVar = CreateConVar( "drg_ultrakill_swordsmachinemusic", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables SwordsMachine Music" )
local mMaliciousFaceMusicConVar = CreateConVar( "drg_ultrakill_maliciousfacemusic", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Malicious Face Music" )
local mHideousMassMusicConVar = CreateConVar( "drg_ultrakill_hideousmassmusic", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Hideous Mass Music" )
local mGabrielMusicConVar = CreateConVar( "drg_ultrakill_gabrielmusic", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Gabriel Music" )
local mFleshPanMusicConVar = CreateConVar( "drg_ultrakill_fleshpanopticonmusic", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Flesh Panopticon Music" )


UltrakillBase.AddMusic( "ORDER", "ultrakill/music/Minos Prime.wav", mMinosMusicConVar )
UltrakillBase.AddMusic( "ORDER_Intro", "ultrakill/music/Minos Prime Intro.wav", mMinosMusicConVar, false )

UltrakillBase.AddMusic( "PANDEMONIUM", "ultrakill/music/Flesh Panopticon.wav", mFleshPanMusicConVar, true, FleshPanopticonMusic )

UltrakillBase.AddMusic( "WAR", "ultrakill/music/Sisyphus Prime.wav", mSisyphusMusicConVar )
UltrakillBase.AddMusic( "WAR_Intro", "ultrakill/music/Sisyphus Prime Intro.wav", mSisyphusMusicConVar, false )

UltrakillBase.AddMusic( "CerberusA", "ultrakill/music/Cerberus A.wav", mCerberusMusicConVar )
UltrakillBase.AddMusic( "CerberusB", "ultrakill/music/Cerberus B.wav", mCerberusMusicConVar )

UltrakillBase.AddMusic( "0-2", "ultrakill/music/0-2.wav", mSwordsMachineMusicConVar )
UltrakillBase.AddMusic( "0-1", "ultrakill/music/0-1.wav", mMaliciousFaceMusicConVar )

UltrakillBase.AddMusic( "1-3", "ultrakill/music/1-3.wav", mHideousMassMusicConVar )

UltrakillBase.AddMusic( "3-2", "ultrakill/music/Gabriel 3-2.wav", mGabrielMusicConVar )

UltrakillBase.AddMusic( "P-2", "ultrakill/music/P-2.wav" )
UltrakillBase.AddMusic( "P-2 Clean", "ultrakill/music/P-2 Clean.wav" )


if UltrakillBase.CompatibilityMode then

  return DrGBase.IncludeFile( "ultrakillbase/Includes/CustomCode/UltrakillBase_Music/Linux.lua" )

end


local mMusicQueue = {}
local fMusicQueueMax = 32

local fFadeTimeDefault = 1.5 

local mCurrentChannel = {}
local mPreviousChannel = {}
local mCurrentFadeInTrack = {}
local mCurrentFadeOutTrack = {}

local mMusic = UltrakillBase.mMusic


local function CheckConVar( sID )

  if not isstring( sID ) or mMusic[ sID ] == nil or mMusic[ sID ].mConVar == nil then return true end

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


local function PushToQueue( eEntity, sID, fTime, fFadeIn )

  if #mMusicQueue >= fMusicQueueMax then return false end

  mMusicQueue[ #mMusicQueue + 1 ] = {

    mEntity = eEntity,
    mID = sID,
    mTime = fTime,
    mFadeIn = fFadeIn

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

  UltrakillBase.PlayMusic( mNextInQueue.mEntity, mNextInQueue.mID, mNextInQueue.mTime, mNextInQueue.mFadeIn )

end


local function IsNextInQueueValid()

  if #mMusicQueue <= 0 then return false end

  local mNextInQueue = mMusicQueue[ 1 ]

  return IsValid( mNextInQueue.mEntity )

end


local function CheckForErrors( aAudio, fErrorCode, sErrorName )
  
  if IsValid( aAudio ) or GetConVar( "developer" ):GetInt() >= 1 then return false end

  DrGBase.Error( "UltrakillBase.Music has encountered an Error. ErrorCode: " .. tostring( fErrorCode ) .. " ErrorString: " .. sErrorName, { chat = true } ) 

end


local function HandleAudioInitialize( eEntity, sID, aAudio, fTime, bLooping, fFadeIn, iErrorCode, sErrorName )

  if CheckForErrors( aAudio, iErrorCode, sErrorName ) then return false end

  aAudio:SetVolume( 0 )
  aAudio:EnableLooping( bLooping == nil and true or bLooping )
  aAudio:SetTime( fTime or 0, true )
  aAudio:Play()

  mCurrentChannel = {
  
    mAudio = aAudio,
    mEntity = eEntity,
    mID = sID,
    mPitch = 1,
    mVolume = 1,
    mPauseTime = 0,
    mCallback = mMusic[ sID ].mCallback,
    mTimers = {}

  }

  if fFadeIn ~= nil and isnumber( fFadeIn ) and TIsEmpty( mCurrentFadeInTrack ) then FadeInMusic( mCurrentChannel.mAudio, fFadeIn ) end

end


-- UltrakillBase.Music Functions --


function UltrakillBase.PlayMusic( eEntity, sID, fTime, fFadeIn )

  if not CheckConVar( sID ) or not IsValid( eEntity ) or ( IsValid( eEntity ) and eEntity.IsDrGNextbot and eEntity:IsDead() ) then return false end
  if not istable( mMusic[ sID ] ) then return false end
  if IsMusicValid( mCurrentChannel ) then return PushToQueue( eEntity, sID, fTime, fFadeIn ) end

  local bLooping = mMusic[ sID ].mLooping
  local sSoundParam = ( fTime or 0 ) <= 0 and "noblock" or ""

  SPlayFile( "sound/" .. mMusic[ sID ].mPath, sSoundParam .. "noplay", function( aAudio, iErrorCode, sErrorName )

    HandleAudioInitialize( eEntity, sID, aAudio, fTime, bLooping, fFadeIn, iErrorCode, sErrorName )

  end )

end


function UltrakillBase.TransferOwnershipMusic( eOldEntity, eEntity )

  if TIsEmpty( mCurrentChannel ) or not IsValid( eOldEntity ) or eEntity ~= mCurrentChannel.mEntity then return end

  mCurrentChannel.mEntity = eEntity

end


function UltrakillBase.StopCurrentMusic( eEntity, ... )

  return UltrakillBase.StopMusic( eEntity, mCurrentChannel.mID, ... )

end


function UltrakillBase.StopMusic( eEntity, sID, bBypassStack, fFadeOut )

  if IsValid( mCurrentChannel.mAudio ) and mCurrentChannel.mEntity ~= eEntity and mCurrentChannel.mID ~= sID then return RemoveFromQueue( eEntity, sID ) end
  if not IsValid( mCurrentChannel.mAudio ) or IsValid( mCurrentChannel.mEntity ) and mCurrentChannel.mEntity ~= eEntity then return end

  if ( fFadeOut ~= nil or IsNextInQueueValid() ) and TIsEmpty( mCurrentFadeOutTrack ) then

    mPreviousChannel = TCopy( mCurrentChannel )
    FadeOutMusic( mPreviousChannel.mAudio, isbool( fFadeOut ) and fFadeTimeDefault or fFadeOut )

  else

    mCurrentChannel.mAudio:Stop()

  end

  mCurrentChannel = {}

  if bBypassStack ~= true then PlayNextInQueue() end

end


function UltrakillBase.ChangeMusic( eEntity, sMusicFrom, sMusicTo, fFadeInOut, fTime )

  if sMusicFrom == nil and mCurrentChannel.mID then sMusicFrom = mCurrentChannel.mID end

  UltrakillBase.StopMusic( eEntity, sMusicFrom, true, fFadeInOut )
  UltrakillBase.PlayMusic( eEntity, sMusicTo, fTime or 0, fFadeInOut )

end


function UltrakillBase.ChangeMusicTime( eEntity, fTime, fFadeInOut )

  if not IsValid( mCurrentChannel.mAudio ) or IsValid( mCurrentChannel.mEntity ) and mCurrentChannel.mEntity ~= eEntity then return end

  if fFadeInOut ~= nil and isnumber( fFadeInOut ) and TIsEmpty( mCurrentFadeOutTrack ) and TIsEmpty( mCurrentFadeInTrack ) then

    mPreviousChannel = TCopy( mCurrentChannel )
    FadeOutMusic( mPreviousChannel.mAudio, fFadeInOut )

    mCurrentChannel = {}

    UltrakillBase.PlayMusic( mPreviousChannel.mEntity, mPreviousChannel.mID, fTime, fFadeInOut )

    return

  end

  mCurrentChannel.mAudio:SetTime( fTime or 0, true )
  
end


function UltrakillBase.AddMusicTimer( sTimerID, fTime, iReps, sCallback, ... )

  if not IsValid( mCurrentChannel.mAudio ) or not IsMusicValid( mCurrentChannel ) then return end

  sCallback = UltrakillBase[ sCallback ]

  if not mCurrentChannel.mTimers then mCurrentChannel.mTimers = {} end

  mCurrentChannel.mTimers[ sTimerID ] = {

    mTime = fTime,
    mPrevTime = 0,
    mReps = iReps or 0,
    mCallback = sCallback,
    mArgs = { ... }

  }

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

  if IsValid( aAudio ) then

    aAudio:SetVolume( fVolume * fFadeInVolume * fMuffleAudioVolume )
    aAudio:SetPlaybackRate( fPitch * fTimescale * fMuffleAudioPitch )

  end

  if IsValid( aPrevAudio ) then

    aPrevAudio:SetVolume( fPrevVolume * fFadeOutVolume * fMuffleAudioVolume )
    aPrevAudio:SetPlaybackRate( fPrevPitch * fTimescale * fMuffleAudioPitch )

  end

  local mTimers = mCurrentChannel.mTimers

  for iIndex, mInfo in pairs( mTimers or {} ) do

    if not IsValid( aAudio ) then break end
    if TIsEmpty( mInfo ) then continue end

    local fTime = mInfo.mTime
    local mArgs = mInfo.mArgs
    local iReps = mInfo.mReps
    local mTimerCallback = mInfo.mCallback
    local fPrevTime = mInfo.mPrevTime
    local fCurTime = aAudio:GetTime()

    if fCurTime >= fTime and fPrevTime < fCurTime and iReps == 0 then

      mTimerCallback( unpack( mArgs ) )
      TRemove( mTimers, iIndex )

    end

    mInfo.mReps = iReps >= 0 and iReps - 1 or iReps
    mInfo.mPrevTime = aAudio:GetTime()

  end

  if isfunction( mCallback ) then mCallback( mCurrentChannel ) end
  if isfunction( mPrevCallback ) then mPrevCallback( mPreviousChannel ) end

end


HAdd( "Tick", "UltrakillBase_Music_Update", ProcessMusic )


end

-- Custom Music -- As of 2023-10-08, You can now add your own custom music via a single lua file.
-- Import All Lua files under lua/ultrakillbase/Includes/CustomMusic --
-- While you don't need to do it in this directory it is recommended to safeguard against your custom lua file being ran first. --

DrGBase.IncludeFolder( "ultrakillbase/Includes/CustomMusic" )