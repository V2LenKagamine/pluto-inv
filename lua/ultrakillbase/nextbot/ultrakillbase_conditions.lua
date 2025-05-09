if not ENT then return end


local istable = istable
local UltrakillBase = UltrakillBase
local ParticleEffect = ParticleEffect
local ParticleEffectAttach = ParticleEffectAttach
local isnumber = isnumber


  -- Enraged Condition --


function ENT:SetEnraged( Bool )

  return self:SetNW2Bool( "UltrakillBase_Enraged", Bool )

end


function ENT:GetEnraged()

  return self:GetNW2Bool( "UltrakillBase_Enraged" )

end


function ENT:IsEnraged()

  return self:GetEnraged()

end


  -- Sanded Condition --


function ENT:SetSand( Bool )

  return self:SetNW2Bool( "UltrakillBase_Sand", Bool )

end


function ENT:GetSand()

  return self:GetNW2Bool( "UltrakillBase_Sand" )

end


function ENT:IsSand()

  return self:GetSand()

end



function ENT:SetSandable( Bool )

  return self:SetNW2Bool( "UltrakillBase_Sandable", Bool )

end


function ENT:GetSandable()

  return self:GetNW2Bool( "UltrakillBase_Sandable" )
  
end


function ENT:IsSandable()

  return self:GetSandable()
  
end


  -- Blessed Condition --


function ENT:SetBlessed( Bool )

  return self:SetNW2Bool( "UltrakillBase_Blessed", Bool )

end


function ENT:GetBlessed()

  return self:GetNW2Bool( "UltrakillBase_Blessed" )

end


function ENT:IsBlessed()

  return self:GetBlessed()

end


  -- Radiant Condition --


function ENT:SetRadiant( Bool )

  return self:SetNW2Bool( "UltrakillBase_Radiant", Bool )

end


function ENT:GetRadiantData()

  return self.UltrakillBase_RadianceInfo or {}

end


function ENT:GetRadiant()

  return self:GetNW2Bool( "UltrakillBase_Radiant" ), self:GetRadiantData()

end


function ENT:IsRadiant()

  return self:GetRadiant()

end


  -- Condition Functions. Enrage is excluded due to how it isn't universal like the rest. --


if SERVER then


  -- Function to Apply the Sand Condition + FX! --


function ENT:Sand()

  if not self:IsSandable() or self:IsSand() then return end

  UltrakillBase.SoundScript( "Ultrakill_Stalker_Explosion", self:GetPos(), self )

  ParticleEffect( "Ultrakill_SandExplosion", self:WorldSpaceCenter(), self:GetAngles() )
  ParticleEffectAttach( "Ultrakill_Sand_Drip" , PATTACH_ABSORIGIN_FOLLOW, self, 0 )

  self:SetSand( true )

end


  -- Function to Apply the Radiant Condition + FX! --


local RadiantFormulas = {

  Health = function( Tier, Multiplier )

    return 1 + 0.5 * Tier * Multiplier

  end,

  Speed = function( Tier, Multiplier )

    return 1 + 0.25 * Tier * Multiplier

  end,

  Damage = function( Tier, Multiplier )

    return 1 + 0.25 * Tier * Multiplier

  end,

}


function ENT:Radiance( Tier, HealthMult, SpeedMult, DamageMult )

  if self:IsRadiant() then return end

  if Tier < 1 or not isnumber( Tier ) then Tier = 1 end

  UltrakillBase.SoundScript( "Ultrakill_Radiance", self:GetPos(), self )

  ParticleEffect( "Ultrakill_Radiance", self:WorldSpaceCenter(), self:GetAngles() )

  self:SetRadiant( true )

  self.UltrakillBase_RadianceInfo = {

    Tier = Tier,
    HP = RadiantFormulas.Health( Tier, HealthMult or 1 ),
    Speed = RadiantFormulas.Speed( Tier, SpeedMult or 1 ),
    Damage = RadiantFormulas.Damage( Tier, DamageMult or 1 ),
    OldHP = self:GetMaxHealth()

  }

  local HPToMaxRatio = self:Health() / self:GetMaxHealth()

  self:SetMaxHealth( self:GetMaxHealth() * self.UltrakillBase_RadianceInfo.HP )
  self:SetHealth( HPToMaxRatio * self:GetMaxHealth() )

end


  -- Function to Apply the Blessed Condition + FX! --


function ENT:Bless()

  -- Empty for Now --

end



end

