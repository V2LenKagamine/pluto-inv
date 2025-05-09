if not ENT then return end


-- Getters & Setters --


function ENT:GetPhase()
  
  return self:GetNW2Int( "UltrakillBase_Phase" )
  
end


function ENT:SetPhase( Int )
  
  return self:SetNW2Int( "UltrakillBase_Phase", Int )
  
end


function ENT:GetTotalPhases()
  
  return self:GetNW2Int( "UltrakillBase_TotalPhases" )
  
end


function ENT:SetTotalPhases( Int )
  
  return self:SetNW2Int( "UltrakillBase_TotalPhases", Int )
  
end


-- Hook --


function ENT:OnPhaseChange( Phase, PrevPhase ) end


-- Overhauled PhaseUpdate --


function ENT:UpdatePhase()

  local TotalPhases = self:GetTotalPhases()
  local Phase = self:GetPhase()

  if TotalPhases <= 1 then return end

  local MaxHP = self:GetMaxHealth()
  local HP = self:Health()

  for I = 1, TotalPhases do

    if Phase >= I then continue end

    local TrueI = TotalPhases + ( ( ( I - 1 ) / ( TotalPhases - 1 ) ) * ( 1 - TotalPhases ) )
    local Threshold = TrueI / TotalPhases
    local NextThreshold = ( TrueI - 1 ) / TotalPhases

    if HP < MaxHP * NextThreshold then continue -- Skip Phases.
    elseif HP <= MaxHP * Threshold then

      self:SetPhase( I ) -- Change Networked Phase Var.
      self:OnPhaseChange( I, Phase ) -- Call Phase Hook.

    end

  end

end