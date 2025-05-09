if not ENT then return end


local istable = istable
local isnumber = isnumber
local CurTime = CurTime
local TIsEmpty = table.IsEmpty
local UltrakillBase = UltrakillBase


ENT.UltrakillBase_ShakeData = {}


function ENT:Shake( Amp, Freq, Duration, Offset )

  Duration = isnumber( Duration ) and Duration or math.huge
  Offset = isnumber( Offset ) and Offset or 5

  if SERVER then

    self:CallOnClient( "Shake", Amp, Freq, Duration, Offset )

  end

  self.UltrakillBase_ShakeData = {

    Amplitude = Amp,
    Frequency = Freq,
    Duration = CurTime() + Duration,
    Offset = Offset,

  }

end


function ENT:GetShake()

  return self.UltrakillBase_ShakeData or {}
  
end


function ENT:RenderShake()

  local Data = self:GetShake()

  if not istable( Data ) or TIsEmpty( Data ) then return end

  local Amplitude = Data.Amplitude
  local Frequency = Data.Frequency
  local Duration = Data.Duration
  local Offset = Data.Offset

  if CurTime() < Duration then

    self:ManipulateBonePosition( 0, UltrakillBase.VectorNoise( Amplitude, Data.Frequency, Offset ), false )

  else

    self:ManipulateBonePosition( 0, vector_origin, false )

    self.UltrakillBase_ShakeData = nil

  end

end