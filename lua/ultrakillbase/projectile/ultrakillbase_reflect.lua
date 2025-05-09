if not ENT or not SERVER then return end


local istable = istable
local MMax = math.max
local IsValid = IsValid


function ENT:OnReflect( mAttacker, CDamageInfo )

  self:SetOwner( mAttacker )

  local DamagePos = CDamageInfo:GetDamagePosition()

  local vDirection = ( self:GetPos() - DamagePos ):GetNormalized()

  local vVelocity = self:GetVelocity():Length()

  self:SetAngles( vDirection:Angle() )
  self:AddVelocity( vDirection * MMax( vVelocity * 0.9, 1000 ) )

  self.UltrakillBase_Reflected = true

end


function ENT:CheckReflect( CDamageInfo )

  local mAttacker = CDamageInfo:GetAttacker()
  if not IsValid( mAttacker ) or not CDamageInfo:IsDamageType( DMG_BLAST, DMG_BLAST_SURFACE ) then return end

  self:OnReflect( mAttacker, CDamageInfo )

end