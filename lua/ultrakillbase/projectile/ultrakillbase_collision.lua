if not ENT then return end


local istable = istable
local IsValid = IsValid
local CurTime = CurTime
local EFindInSphere = ents.FindInSphere
local ipairs = ipairs
local UltrakillBase = UltrakillBase


local function CollisionFilter( self, Ent )

  if self == Ent or Ent == self:GetOwner() or not IsValid( Ent:GetPhysicsObject() ) then return false end

  return true

end


function ENT:ProjectileShouldCollide( Ent )

  if Ent:IsWorld() or not CollisionFilter( self, Ent ) or ( self:GetParried() and Ent.IsUltrakillProjectile ) then return false end
  if UltrakillBase.CheckIFrames( Ent ) and UltrakillBase.GetWeightData( Ent ).Collision or ( Ent:IsPlayer() and ( Ent:HasGodMode() or Ent.Dashing ) or Ent.IsDrGNextbot and Ent:GetGodMode() ) then return false end
  if self.UltrakillBase_CustomCollisionRelationships[ self:GetRelationship( Ent ) ] ~= true then return false end

  return true

end