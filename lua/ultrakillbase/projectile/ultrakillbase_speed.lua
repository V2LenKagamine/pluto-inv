local istable = istable
local IsValid = IsValid
local UltrakillBase = UltrakillBase

if not ENT then return end


function ENT:CalculateRate()

  if self.UltrakillBase_Difficulty == 0 then

    return 0.75

  elseif self.UltrakillBase_Difficulty == 1 then

    return 0.85

  elseif self.UltrakillBase_Difficulty == 2 then

    return 0.9

  else

    return 1

  end

end