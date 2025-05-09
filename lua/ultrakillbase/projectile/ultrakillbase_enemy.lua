if not ENT then return end


local istable = istable
local IsValid = IsValid


function ENT:GetEnemy()

  return self:GetNW2Entity( "UltrakillBase_Projectile_Enemy" )

end



function ENT:SetEnemy( Enemy )

  return self:SetNW2Entity( "UltrakillBase_Projectile_Enemy", Enemy )

end



function ENT:HasEnemy()

  return IsValid( self:GetEnemy() )

end



function ENT:UpdateEnemy()

  local Owner = self:GetOwner()

  if not IsValid( Owner ) or IsValid( Owner ) and not Owner.IsDrGNextbot then return end
  if not IsValid( Owner:GetEnemy() ) then return end

  self:SetEnemy( Owner:GetEnemy() )

end

