function UltrakillBase.Subtitle( Text, HoldTime )

  UltrakillBase.CallOnClient( "Subtitle", Text, HoldTime )

end


if not CLIENT then return end


-- Localize Libaries & Functions --


local UltrakillBase = UltrakillBase
local Color = Color
local CreateClientConVar = CreateClientConVar
local isstring = isstring
local HAdd = hook.Add
local SSetFont = surface.SetFont
local SGetTextSize = surface.GetTextSize
local SSetTextPos = surface.SetTextPos
local SSetTextColor = surface.SetTextColor
local SDrawText = surface.DrawText
local DRoundedBox = draw.RoundedBox
local TAdd = table.insert
local TRemove = table.remove
local CurTime = CurTime
local Lerp = Lerp
local ipairs = ipairs
local ScrH = ScrH
local ScrW = ScrW
local InCubic = math.ease.InCubic
local OutCubic = math.ease.OutCubic


local function LerpOutCubic( X, From, To )

  return Lerp( OutCubic( X ), From, To )

end


local function LerpInCubic( X, From, To )

  return Lerp( InCubic( X ), From, To )

end


local HoldTimePerChar = 0.11
local FadeInPerChar = 0.0025
local FadeOutPerChar = 0.005

local BaseFadeIn = 0.2
local BaseHoldTime = 1.5
local BaseFadeOut = 2

local SubtitlesPerRender = 12
local SubtitleBGColor = Color( 0, 0, 0, 130 )
local SubtitleTextColor = Color( 255, 255, 255, 255 )
local SubtitleConVar = CreateClientConVar( "drg_ultrakill_subtitles", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Subtitles." )

UltrakillBase.SubtitlesTable = UltrakillBase.SubtitlesTable or {}
local Subtitles = UltrakillBase.SubtitlesTable


local function AddToSubtitles( Info )


  if not SubtitleConVar:GetBool() then return end


  local NumOfSubtitles = #Subtitles


  if NumOfSubtitles + 1 > SubtitlesPerRender then

    TRemove( Subtitles, NumOfSubtitles )

  end


  TAdd( Subtitles, 1, Info )


end


function UltrakillBase.Subtitle( Text, HoldTime )


  if not isstring( Text ) then return end


  AddToSubtitles( { String = Text, LifeTime = CurTime(), HoldTime = HoldTime } )


end


local function RenderSubtitles( I, Subtitle, SubtitleAlpha )

  SSetFont( "Ultrakill_SubFont" )
  local SubWidth = SGetTextSize( Subtitle )

  local PosX = ScrW() * 0.5
  local PosY = ScrH() * 0.860215054 - ( I - 1 ) * ScrH() * 0.0714285714
  local ScaleW = SubWidth / #Subtitle * 1.5 + SubWidth * 1.05
  local ScaleH = ScrH() * 0.0625 * 0.925

  SubtitleBGColor.a = 130 * SubtitleAlpha
  SubtitleTextColor.a = 255 * SubtitleAlpha

  DRoundedBox( 8, PosX - ScaleW * 0.5, PosY - ScaleH * 0.881057269, ScaleW, ScaleH, SubtitleBGColor )

  PosX = PosX - SubWidth * 0.5
  
  SSetTextPos( PosX, PosY - ScaleH * 0.606060606 )
  SSetTextColor( SubtitleTextColor.r, SubtitleTextColor.g, SubtitleTextColor.b, SubtitleTextColor.a )

  SDrawText( Subtitle )

end


HAdd( "HUDPaint", "UltrakillBase_Subtitles", function()

  if not SubtitleConVar:GetBool() then return end

  for I = 1, #Subtitles do

    local SubtitleInfo = Subtitles[ I ]

    if not SubtitleInfo then continue end

    local Subtitle = SubtitleInfo.String
    local SubtitleLifeTime = SubtitleInfo.LifeTime
    local SubtitleHoldTime = SubtitleInfo.HoldTime and SubtitleInfo.HoldTime or BaseHoldTime + #Subtitle * HoldTimePerChar
    local SubtitleFadeIn = BaseFadeIn + #Subtitle * FadeInPerChar
    local SubtitleFadeOut = BaseFadeOut + #Subtitle * FadeOutPerChar

    if CurTime() > SubtitleLifeTime + SubtitleFadeIn + SubtitleHoldTime + SubtitleFadeOut then TRemove( Subtitles, I ) continue end
    if I > SubtitlesPerRender then continue end

    local FadeInDelta = ( CurTime() - SubtitleLifeTime ) / SubtitleFadeIn
    local FadeOutDelta = ( CurTime() - ( SubtitleLifeTime + SubtitleHoldTime + SubtitleFadeIn ) ) / SubtitleFadeOut

    local SubtitleAlpha = LerpOutCubic( FadeOutDelta, 1, 0 ) * LerpInCubic( FadeInDelta, 0, 1 )

    RenderSubtitles( I, Subtitle, SubtitleAlpha )

  end

end )

