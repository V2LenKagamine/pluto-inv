
function UltrakillBase.AddBoss( self, Title, Splits, Secondary )

  UltrakillBase.CallOnClient( "AddBoss", self, Title, Splits, Secondary )

end


function UltrakillBase.RemoveBoss( self )

  UltrakillBase.CallOnClient( "RemoveBoss", self )

end


if not CLIENT then return end


-- Localize Libaries & Functions --


local UltrakillBase = UltrakillBase
local CreateClientConVar = CreateClientConVar
local Color = Color
local IsValid = IsValid
local isstring = isstring
local isentity = isentity
local DRoundedBox = CLIENT and draw.RoundedBox
local ScreenScaleH = ScreenScaleH
local MRand = math.Rand
local MClamp = math.Clamp
local HAdd = hook.Add
local TSimple = timer.Simple
local SSetFont = surface.SetFont
local SGetTextSize = surface.GetTextSize
local SSetTextPos = surface.SetTextPos
local SSetTextColor = surface.SetTextColor
local SDrawText = surface.DrawText
local DRoundedBox = draw.RoundedBox
local TRemove = table.remove
local TRemoveByValue = table.RemoveByValue
local TAdd = table.insert
local MRemap = math.Remap
local MMin = math.min
local CurTime = CurTime
local istable = istable
local Lerp = Lerp
local ipairs = ipairs
local ScrH = ScrH
local ScrW = ScrW
local OutCubic = math.ease.OutCubic
local OutCirc = math.ease.OutCirc


local HealthBarConVar = CreateClientConVar( "drg_ultrakill_healthbar", 1, { FCVAR_ARCHIVE, FCVAR_LUA_CLIENT }, "Enables Boss HP Bar" )
local HealthLostColor = Color( 255, 161, 0, 255 )
local HealthColor = Color( 255, 0, 0, 255 )
local HealthGainedColor = Color( 0, 255, 0, 255)
local BackgroundColor = Color( 0, 0, 0, 99.45 )
local HealthBackgroundColor = Color( 0, 0, 0, 170 )

UltrakillBase.DefaultSecondaryBarColor = Color( 0, 255, 0 )
UltrakillBase.DefaultSecondaryBarEnragedColor = Color( 255, 7, 23, 255 )
UltrakillBase.DefaultSecondaryBarBlackColor = Color( 0, 0, 0, 0 )
UltrakillBase.DefaultSecondaryBarYellowColor = Color( 255, 255, 0 )


local function DefaultSecondaryBarFunction( self )

  return 0, UltrakillBase.DefaultSecondaryBarColor

end


local MaxHealthBarsPerRender = 12

UltrakillBase.BossTable = UltrakillBase.BossTable or {}
UltrakillBase.BossEntityData = UltrakillBase.BossEntityData or {}

local BossTable = UltrakillBase.BossTable
local BossEntityData = UltrakillBase.BossEntityData


function UltrakillBase.AddBoss( self, Title, Splits, Secondary )

  if not IsValid( self ) or BossEntityData[ self ] then return end

  Title = isstring( Title ) and Title or self:GetClass()
  Splits = Splits or 1

  BossTable[ #UltrakillBase.BossTable + 1 ] = self
  BossEntityData[ self ] = {

    Title = Title,
    Splits = Splits,
    Secondary = Secondary

  }

end


function UltrakillBase.IsBoss( self )

  if not isentity( self ) then return false end

  return BossEntityData[ self ] ~= nil

end


function UltrakillBase.RemoveBoss( self )

  if not isentity( self ) then return end

  TRemoveByValue( BossTable, self )
  BossEntityData[ self ] = nil

end


-- New --

-- Initialize Main HealthBar --
-- New Format: EntityData.Main_Test = 0

local function HudInit( Ent ) -- Denest Tables, I Need to Use a Table, but I should reduce how many I use.

  local EntityData = BossEntityData[ Ent ] -- This is why a Table is necessary. I need to store independant data on each entity.

  if not EntityData then return end

  local Splits = EntityData.Splits

  if not IsValid( Ent ) or EntityData.Main_Initialized then return end

  EntityData.Main_Intro = true
  EntityData.Main_IntroTime = CurTime() + 1.25
  EntityData.Main_DieTime = CurTime()
  EntityData.Main_LerpTime = 1.25
  EntityData.Main_LerpTime_Lost = 1.25
  EntityData.Main_CurHP = Ent:Health()
  EntityData.Main_CurHP_Lost = Ent:Health()
  EntityData.Main_PrevHP = 0
  EntityData.Main_PrevHP_Lost = 0
  EntityData.Main_Delay = 0
  EntityData.Main_Segmented = {}
  EntityData.Main_HPGainedTime = 0
  EntityData.Main_HPGain = 0
  EntityData.Main_Initialized = true

end


local function HudInitS( Ent )

  local EntityData = BossEntityData[ Ent ]

  if not EntityData or not IsValid( Ent ) or EntityData.Secondary_Initialized then return end

  local DeclareFunction = Ent.GetSecondaryBarValues or DefaultSecondaryBarFunction

  EntityData.Secondary_DieTime = CurTime()
  EntityData.Secondary_LerpTime = 0.333333
  EntityData.Secondary_Cur = DeclareFunction( Ent )
  EntityData.Secondary_Prev = 0
  EntityData.Secondary_Initialized = true

end


-- Calculate HPLost LerpTime & Delay --


local function HPLostFormulas( LerpHP, HP, MaxHP )

  local HPDiff = LerpHP - HP

  local Time = MClamp( HPDiff / ( MaxHP * 0.2 ), 0.1, 0.65 )
  local Delay = MClamp( HPDiff / ( MaxHP * 0.45 ), 0.25, 0.45 )

  return Time, Delay

end


local function HudUpdate( Ent, HP, MaxHP, LerpHP, LerpHPLost )

  local EntityData = BossEntityData[ Ent ]

  if EntityData.Main_Intro then

    if HP ~= MaxHP then

      EntityData.Main_CurHP = HP
      EntityData.Main_CurHP_Lost = HP
      EntityData.Main_Intro = false
      EntityData.Main_LerpTime = 0.1

    end

    if CurTime() > EntityData.Main_IntroTime then

      EntityData.Main_Intro = false

    end

  end

  if EntityData.Main_CurHP ~= HP then

    if LerpHP ~= HP then

      EntityData.Main_CurHP = LerpHP

    end

    if not EntityData.Main_Intro then

      EntityData.Main_LerpTime = 0.1

    end

    if EntityData.Main_CurHP < HP then

      EntityData.Main_LerpTime = 0.2
      EntityData.Main_HPGainedTime = CurTime()
      EntityData.Main_HPGain = EntityData.Main_CurHP

      EntityData.Main_LerpTime_Lost = 0
      EntityData.Main_Delay = 0
      EntityData.Main_PrevHP_Lost = EntityData.Main_CurHP
      EntityData.Main_CurHP_Lost = EntityData.Main_CurHP

    else

      EntityData.Main_HPGainedTime = 0
      EntityData.Main_HPGain = 0

    end

    EntityData.Main_PrevHP = EntityData.Main_CurHP
    EntityData.Main_DieTime = CurTime()
    EntityData.Main_CurHP = HP

  end

  if EntityData.Main_CurHP_Lost ~= HP then

    if LerpHP_Lost ~= HP then

      EntityData.Main_CurHP_Lost = LerpHPLost

    end

    if not EntityData.Main_Intro then

      EntityData.Main_LerpTime_Lost, EntityData.Main_Delay = HPLostFormulas( LerpHPLost, HP, MaxHP )

    end

    EntityData.Main_PrevHP_Lost = EntityData.Main_CurHP_Lost
    EntityData.Main_CurHP_Lost = HP

  end

end


local function HudUpdateS( Ent, SValue, SLerp )

  local EntityData = BossEntityData[ Ent ]

  if not EntityData or not EntityData.Secondary then return end

  if EntityData.Secondary_Cur ~= SValue then

    if SLerp ~= SValue then

      EntityData.Secondary_Cur = SLerp

    end

    EntityData.Secondary_Prev = EntityData.Secondary_Cur
    EntityData.Secondary_DieTime = CurTime()
    EntityData.Secondary_Cur = SValue

  end

end


local function HudCalculateHPRange( I, EntityData, Splits, LerpHP, LerpHPLost, MaxHP ) -- Returns A lot of Data.

  local Threshold = I / Splits
  local NextThreshold = ( I - 1 ) / Splits

  local SegmentHP, SegmentHPLost, SegmentMin, SegmentMax = 0

  SegmentHP = MClamp( LerpHP / MaxHP, NextThreshold, Threshold )
  SegmentHPLost = MClamp( LerpHPLost / MaxHP, NextThreshold, Threshold )
  SegmentMin = NextThreshold
  SegmentMax = Threshold

  return SegmentHP, SegmentHPLost, SegmentMin, SegmentMax

end


local function HudRender( Ent, PosX, PosY, ScaleX, ScaleY, PosY_NoStack, RandomShake, LerpHP, LerpHPLost, MaxHP, Gained )

  local EntityData = BossEntityData[ Ent ]
  local Splits = EntityData.Splits
  local GainHP = EntityData.Main_HPGain

  for I = 1, Splits do

    local SegmentHP, SegmentHPLost, SegmentMin, SegmentMax = HudCalculateHPRange( I, EntityData, Splits, LerpHP, LerpHPLost, MaxHP )
    local SegmentI = MRemap( I, 1, Splits, Splits, 1 )
    local SegmentGain = MClamp( GainHP / MaxHP, SegmentMin, SegmentMax )

    HealthColor.r = 255 / I

    local Delta = MRemap( SegmentHP, SegmentMin, SegmentMax, 0, 1 )
    local DeltaLost = MRemap( SegmentHPLost, SegmentMin, SegmentMax, 0, 1 )
    local DeltaGain = MRemap( SegmentGain, SegmentMin, SegmentMax, 0, 1 )

    if Delta <= 0 and DeltaLost <= 0 then continue end -- Do not render unneccesarily.

    if Delta < DeltaLost and Gained <= 0 then

      DRoundedBox( 6, PosX, PosY + RandomShake, ScaleX * DeltaLost, ScaleY, HealthLostColor )

    end

    DRoundedBox( 6, PosX, PosY + RandomShake, ScaleX * Delta, ScaleY, HealthColor )

    if DeltaGain < 1 and Gained > 0 then

      local GainScaleMult = Lerp( Gained, 1, 1.3 )
      HealthGainedColor.a = Lerp( Gained ^ 0.65, 0, 255 )

      DRoundedBox( 6, PosX, PosY - ( PosY_NoStack * ( GainScaleMult - 1 ) ) + RandomShake, ScaleX * Delta, ScaleY * GainScaleMult, HealthGainedColor )

    end

  end

end


local function HudRenderS( Ent, RandomShake, PosX, PosY, ScaleW, ScaleH, SColor, SLerp )

  local EntityData = BossEntityData[ Ent ]

  if not EntityData or not EntityData.Secondary then return end

  local SPosX = PosX - ScaleW * 0.483775937
  local SPosY = PosY + ScaleH * 0.71
  local SScaleX = ScaleW * 0.971276
  local SScaleY = ScaleH * 0.1

  DRoundedBox( 6, SPosX, SPosY + RandomShake, SScaleX, SScaleY, HealthBackgroundColor )
  DRoundedBox( 6, SPosX, SPosY + RandomShake, SScaleX * SLerp, SScaleY, SColor or DefaultSecondaryBarColor )

end


local function HudShake( HP, LerpHPLost, MaxHP )

  local Delta = ScreenScaleH( 0.444444444 )

  if HP <= 0 then

    return MClamp( MRand( -1, 1 ) * Delta * 8, -8, 8 )

  end

  local Shake = MClamp( ( LerpHPLost - HP ) / ( MaxHP * 0.05 ), 0, 8 )
  
  return MClamp( MRand( -1, 1 ) * Delta * Shake, -Shake, Shake )

end


local function HudRemove( self )

  local EntityData = BossEntityData[ self ]

  if not EntityData or EntityData.IsDeleting then return end

  EntityData.IsDeleting = true

  TSimple( 0, function()

    if not BossEntityData[ self ] then return end

    TRemoveByValue( BossTable, self )
    BossEntityData[ self ] = nil

  end )


end


local function ProcessHud()

  if not HealthBarConVar:GetBool() then return end

  for I = 1, #BossTable do

    local Ent = BossTable[ I ]

    if not IsValid( Ent ) then HudRemove( Ent ) end

    HudInit( Ent )
    HudInitS( Ent )

    local EntityData = BossEntityData[ Ent ]

    if not EntityData or not EntityData.Main_Initialized then continue end

    local HP = IsValid( Ent ) and Ent:Health() or 0
    local MaxHP = IsValid( Ent ) and Ent:GetMaxHealth() or 1

    local fCurTime = CurTime()
    local Delta = OutCubic( MClamp( ( fCurTime - EntityData.Main_DieTime ) / EntityData.Main_LerpTime, 0, 1 ) )
    local DeltaLost = OutCubic( MClamp( ( fCurTime - ( EntityData.Main_DieTime + EntityData.Main_Delay ) ) / EntityData.Main_LerpTime_Lost, 0, 1 ) )
    local DeltaGain = OutCubic( 1 - MClamp( ( fCurTime - EntityData.Main_HPGainedTime ) / 0.6, 0, 1 ) )

    local LerpHP = Lerp( Delta, EntityData.Main_PrevHP, EntityData.Main_CurHP )
    local LerpHPLost = Lerp( DeltaLost, EntityData.Main_PrevHP_Lost, EntityData.Main_CurHP_Lost )
    local Title = EntityData.Title

    local SDeclareFunc = Ent.GetSecondaryBarValues or DefaultSecondaryBarFunction
    local SValue, SColor = SDeclareFunc( Ent )

    local SDelta = OutCubic( MClamp( ( fCurTime - EntityData.Secondary_DieTime ) / EntityData.Secondary_LerpTime, 0, 1 ) )
    local SLerp = MMin( Lerp( SDelta, EntityData.Secondary_Prev, EntityData.Secondary_Cur ), 1 )

    HudUpdate( Ent, HP, MaxHP, LerpHP, LerpHPLost )
    HudUpdateS( Ent, SValue, SLerp )

    if I > MaxHealthBarsPerRender then continue end

    local RandomShake = HudShake( HP, LerpHPLost, MaxHP )

    local fWidth, fHeight = ScrW(), ScrH()

    local PosX = fWidth * 0.5
    local PosY = fHeight * 0.0333333333 + ( I - 1 ) * fHeight * 0.096153846

    local ScaleW = fWidth * 0.934579439
    local ScaleH = fHeight * 0.0763491237

    local BackgroundPosX = PosX - ScaleW * 0.5
    local BackgroundPosY = PosY - ScaleH * 0.25

    local BarPosX = PosX - ScaleW * 0.483675937
    local BarPosY = PosY - ScaleH * 0.0952380952
    local BarPosY_NoStacking = fHeight * 0.0333333333 - ScaleH * 0.0952380952

    local BarScaleX = ScaleW * 0.971276
    local BarScaleY = ScaleH * 0.727848

    local TextPosX = PosX * 1.005

    local AdditiveBackgroundScaleH = EntityData.Secondary and ScrH() * 0.0125 or 0

    DRoundedBox( 2, BackgroundPosX, BackgroundPosY, ScaleW, ScaleH + AdditiveBackgroundScaleH, BackgroundColor )
    DRoundedBox( 6, BarPosX, BarPosY + RandomShake, BarScaleX, BarScaleY, HealthBackgroundColor )

    HudRenderS( Ent, RandomShake, PosX, PosY, ScaleW, ScaleH, SColor, SLerp )
    HudRender( Ent, BarPosX, BarPosY, BarScaleX, BarScaleY, BarPosY_NoStacking, RandomShake, LerpHP, LerpHPLost, MaxHP, DeltaGain )

    SSetFont( "Ultrakill_Font" )
    local SubWidth = SGetTextSize( Title )

    TextPosX = TextPosX - SubWidth * 0.5
  
    SSetTextPos( TextPosX + RandomShake, PosY + RandomShake )
    SSetTextColor( 255, 255, 255, 255 )

    SDrawText( Title )

  end

end


HAdd( "HUDPaint", "UltrakillBase_HealthBar", ProcessHud )