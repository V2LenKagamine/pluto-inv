if not ENT then return end


local istable = istable
local CreateConVar = CreateConVar
local UltrakillBase = UltrakillBase
local IsValid = IsValid
local isstring = isstring
local isnumber = isnumber
local Vector = Vector
local Color = Color


function ENT:SetParryable( Bool )

  self:SetNW2Bool( "UltrakillBase_Parryable", Bool )

end


function ENT:GetParryable()

  return self:GetNW2Bool( "UltrakillBase_Parryable" )

end

function ENT:IsParryable()

  return self:GetParryable()

end



function ENT:SetParryInterrupted( Bool )

  self:SetNW2Bool( "UltrakillBase_ParryInterrupted", Bool )

end


function ENT:GetParryInterrupted()

  return self:GetNW2Bool( "UltrakillBase_ParryInterrupted" )

end


function ENT:IsParryInterrupted()

  return self:GetParryInterrupted()

end


function ENT:SetInterruptable( Bool )

  self:SetNW2Bool( "UltrakillBase_Interruptable", Bool )

end


function ENT:GetInterruptable()

  return self:GetNW2Bool( "UltrakillBase_Interruptable" )
  
end


function ENT:IsInterruptable()

  return self:GetInterruptable()
  
end


local ParryConVar = CreateConVar( "drg_ultrakill_parry", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enables Parrying for players." )


function ENT:OnParry( Ply, CDamageInfo )

  if not CDamageInfo:IsDamageType( DMG_DIRECT ) then
    
    CDamageInfo:SetDamage( CDamageInfo:GetDamage() + 5000 )
    CDamageInfo:SetDamageType( CDamageInfo:GetDamageType() + DMG_DIRECT )

  end

  UltrakillBase.SoundScript( "Ultrakill_Parry", self:GetPos() )
  UltrakillBase.HitStop( 0.25 )

  self:SetParryable( false )

  UltrakillBase.OnParryPlayer( Ply )

end


local function IsParryMelee( self, Ply, CDamageInfo )

  if not IsValid( Ply ) or not Ply:IsPlayer() then return false end
  if not self:IsParryable() then return false end
  if CDamageInfo:IsDamageType( DMG_BUCKSHOT ) then return false end

  return CDamageInfo:IsDamageType( DMG_CLUB + DMG_SLASH ) and self:IsInRange( Ply, 85 + self:BoundingRadius() * 1.2 )

end


local function IsParryShotgun( self, Ply, CDamageInfo )

  if not IsValid( Ply ) or not Ply:IsPlayer() then return false end
  if not self:IsParryable() then return false end
  if CDamageInfo:IsDamageType( DMG_CLUB + DMG_SLASH ) then return false end

  return CDamageInfo:IsDamageType( DMG_BUCKSHOT ) and self:IsInRange( Ply, 25 + self:BoundingRadius() * 0.4 )

end


function ENT:CheckParry( CDamageInfo )

  if not ParryConVar:GetBool() then return end

  local Ply = CDamageInfo:GetAttacker()

  if IsParryMelee( self, Ply, CDamageInfo ) or IsParryShotgun( self, Ply, CDamageInfo ) then self:OnParry( Ply, CDamageInfo ) end

end


function ENT:CheckInterrupt( CDamageInfo, Attachment )

  if isstring( Attachment ) then Attachment = self:GetAttachment( self:LookupAttachment( Attachment ) )
  elseif isnumber( Attachment ) then Attachment = self:GetAttachment( Attachment )
  elseif not isnumber( Attachment ) and not isstring( Attachment ) then return end

  local Pos = CDamageInfo:GetDamagePosition()
  local Ply = CDamageInfo:GetAttacker()

  if not IsValid( Ply ) or not Ply:IsPlayer() or not CDamageInfo:IsBulletDamage() or CDamageInfo:IsDamageType( DMG_BUCKSHOT ) or not self:GetInterruptable() or Attachment.Pos:DistToSqr( Pos ) > ( 30 * self:GetModelScale() ) ^ 2 then return end

  self:Explosion( self:GetPos(), 500, Vector( 450, 0, 150 ), 150, 0.25, Ply, true )

  UltrakillBase.SoundScript( "Ultrakill_Ricochet", self:GetPos() )
  UltrakillBase.SoundScript( "Ultrakill_Explosion_1", self:GetPos() )

  UltrakillBase.HitStop( 0.25 )

  Ply:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 40 ), 0.1, 0.25 )

  self:SetInterruptable( false )

  self:CreateExplosion( Attachment.Pos, Attachment.Ang )

end