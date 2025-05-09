if not ENT then return end


local istable = istable
local MMax = math.max
local isnumber = isnumber
local MClamp = math.Clamp

  
  -- Hooks --



function ENT:OnStaminaDepleted() end

function ENT:OnStaminaLost() end




  -- Getters & Setters --




function ENT:SetStaminaMax( Int )

  return self:SetNW2Int( "UltrakillBase_StaminaMax", Int )

end

function ENT:SetStamina( Int )

  return self:SetNW2Int( "UltrakillBase_Stamina", Int )
  
end



function ENT:GetStaminaMax()

  return self:GetNW2Int( "UltrakillBase_StaminaMax" )

end

function ENT:GetStamina()

  return self:GetNW2Int( "UltrakillBase_Stamina" )

end



  -- Stamina Functions --



function ENT:RefillStamina()

  return self:SetStamina( self:GetStaminaMax() )

end



function ENT:AddStamina( Int )

  return self:SetStamina( self:GetStamina() + Int )

end



function ENT:IsStaminaDepleted()

  return self:GetStamina() <= 0

end



function ENT:Stamina( ID, Subtract ) -- Called in Coroutine.

  local CurStamina = MMax( self:GetStamina(), 0 )

  if not isnumber( Subtract ) then Subtract = 1 end

  CurStamina = MClamp( CurStamina - Subtract, 0, math.huge )

  self:SetStamina( CurStamina )

  self:SetCooldown( ID, 3 )

  self:CallInCoroutine( function( self, ID, Subtract, CurStamina ) 

    self:OnStaminaLost( ID, Subtract, CurStamina ) -- Used to Create Cooldowns with the ID Specified.

    if CurStamina <= 0 then

      self:OnStaminaDepleted()

    end

  end, ID, Subtract, CurStamina )

end


