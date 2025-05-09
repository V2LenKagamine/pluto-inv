if not ENT then return end


local istable = istable
local CreateConVar = CreateConVar
local UltrakillBase = UltrakillBase
local IsValid = IsValid
local Vector = Vector


local ParryProjConVar = CreateConVar( "drg_ultrakill_parry_projectile", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enables Parrying for players." )


  -- Parry --
  

function ENT:SetParryable( Bool )

  if not ParryProjConVar:GetBool() then 
    
    return self:SetNW2Bool( "UltrakillBase_Projectile_Parryable", false )

  end

  return self:SetNW2Bool( "UltrakillBase_Projectile_Parryable", Bool )

end


function ENT:GetParryable()

  if not ParryProjConVar:GetBool() then 

    return false

  end

  return self:GetNW2Bool( "UltrakillBase_Projectile_Parryable" )

end


function ENT:SetParried( Bool )

  return self:SetNW2Bool( "UltrakillBase_Projectile_Parried", Bool )

end


function ENT:GetParried()

  return self:GetNW2Bool( "UltrakillBase_Projectile_Parried" )

end


function ENT:IsParried()

  return self:GetParried()

end


if SERVER then


function ENT:OnParry( Ply, Dmg )

  self:SetParried( true )

  self.Damage = self.Damage

  UltrakillBase.HitStop( 0.25 )

  self:SetOwner( Ply )

  UltrakillBase.SoundScript( "Ultrakill_Parry", self:GetPos() )

  local Aim = Ply:GetAimVector()

  self:SetAngles( Aim:Angle() )
  self:SetVelocity( Aim * 5000 )

  local Phys = self:GetPhysicsObject()

  if IsValid( Phys ) then

    Phys:SetAngleVelocity( vector_origin ) 
    Phys:EnableGravity( false )

  end

  UltrakillBase.OnParryPlayer( Ply )

end


function ENT:CheckParry( Dmg )

  if not ParryProjConVar:GetBool() then return end

  local Ply = Dmg:GetAttacker()

  if IsValid( Ply ) and Ply:IsPlayer() and self:GetParryable() and not self:GetParried() and self:IsInRange( Ply, 250 ) then

    if Dmg:IsDamageType( DMG_CLUB + DMG_SLASH ) then

      self.UltrakillBase_CustomCollisionIsCollidingSoon = false
      self:OnParry( Ply, Dmg )

    end

  end

end


function ENT:ParryCollide( fDamage, bRemove )

  UltrakillBase.SoundScript( "Ultrakill_Explosion_1", self:GetPos() )

  self:Explosion( self:GetPos(), fDamage, nil, 150, 0.25, self:GetOwner(), true )
  self:CreateExplosion( self:GetPos(), self:GetAngles() )

  if bRemove then self:Remove() end

end


end -- End of SERVER