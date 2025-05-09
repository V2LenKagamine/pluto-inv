local istable = istable
local IsValid = IsValid

if not ENT then return end



if SERVER then

  

function ENT:GetRelationship( Ent, Absolute )

  if not IsValid( Ent ) or not IsValid( self:GetOwner() ) or not self:GetOwner().IsUltrakillNextbot then return D_ER end

  if self:GetOwner() == Ent then return D_LI end

  if Ent.IsDrGProjectile and IsValid( Ent:GetOwner() ) then return self:GetRelationship( Ent:GetOwner(), Absolute ) end

  local Disp = self:GetOwner()._DrGBaseRelationships[ Ent ]

  if not Absolute and self:GetOwner():IsIgnored( Ent ) then

    return D_NU

  else return Disp or D_NU end

end



function ENT:GetPriority( Ent )

  if not IsValid( self:GetOwner() ) or not IsValid( Ent ) or self:GetOwner() == Ent then return -1 end
  
  return self:GetOwner()._DrGBaseRelPriorities[ Ent ] or DEFAULT_PRIO

end



function ENT:IsAlly( Ent )
  
  return self:GetRelationship(Ent) == D_LI

end



function ENT:IsEnemy( Ent )
  
  return self:GetRelationship(Ent) == D_HT

end



function ENT:IsAfraidOf( Ent )
  
  return self:GetRelationship(Ent) == D_FR

end



function ENT:IsHostile( Ent )
  
  local Disp = self:GetRelationship( Ent )
  
  return Disp == D_HT or Disp == D_FR

end



function ENT:IsNeutral( Ent )
  
  return self:GetRelationship( Ent ) == D_NU

end


end

