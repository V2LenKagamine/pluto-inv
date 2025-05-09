if CLIENT then return end


local FindMetaTable = FindMetaTable
local UltrakillBase = UltrakillBase
local UIsValidRagdoll = util.IsValidRagdoll
local ECreate = SERVER and ents.Create
local IsValid = IsValid
local DamageInfo = DamageInfo
local isvector = isvector
local GetConVar = GetConVar
local UReplaceEntity = SERVER and undo.ReplaceEntity
local CReplaceEntity = SERVER and cleanup.ReplaceEntity
local MClamp = math.Clamp


local EntMETA = FindMetaTable( "Entity" )
UltrakillBase.OLD_SetPos = UltrakillBase.OLD_SetPos or EntMETA.SetPos


function EntMETA:SetPos( Pos )

  if self.IsUltrakillNextbot then

    self:PhysicsDestroy()

    local Res = UltrakillBase.OLD_SetPos( self, Pos )

    self:PhysicsInitShadow()

    return Res

  else

    return UltrakillBase.OLD_SetPos( self, Pos ) 

  end

end


function EntMETA:DrG_CreateRagdoll( Dmg )

  local RagdollModel = self.RagdollReplacement or self:GetModel()

  if not UIsValidRagdoll( RagdollModel ) then return NULL end

  local Ragdoll = ECreate( "prop_ragdoll" )

  if IsValid( Ragdoll ) then

    if not Dmg then Dmg = DamageInfo() end

    Ragdoll:SetPos( self:GetPos() )
    Ragdoll:SetAngles( self:GetAngles() )
    Ragdoll:SetModel( RagdollModel )
    Ragdoll:SetSkin( self:GetSkin() )
    Ragdoll:SetColor( self:GetColor() )
    Ragdoll:SetModelScale( self:GetModelScale() )
    Ragdoll:SetBloodColor( self:GetBloodColor() )

    for I = 1, #self:GetBodyGroups() do

      Ragdoll:SetBodygroup( I - 1, self:GetBodygroup( I - 1 ) )

    end

    Ragdoll:Spawn()

  
    for I = 0, Ragdoll:GetPhysicsObjectCount() - 1 do

      local Bone = Ragdoll:GetPhysicsObjectNum( I )

      if not IsValid( Bone ) then continue end

      local Pos, Angles = self:GetBonePosition( Ragdoll:TranslatePhysBoneToBone( I ) )

      Bone:SetPos( Pos )

      Bone:SetAngles( Angles )

    end

    local Phys = Ragdoll:GetPhysicsObject()

    Phys:SetVelocity( self:GetVelocity() )

    local Force = Dmg:GetDamageForce()

    local Position = Dmg:GetDamagePosition()

    if IsValid( Phys ) and isvector( Force ) and isvector( Position ) then

      Phys:ApplyForceOffset( Force, Position )

    end

    if Dmg:IsDamageType( DMG_DISSOLVE ) then Ragdoll:DrG_Dissolve()

    elseif self:IsOnFire() then Ragdoll:Ignite( 10 ) end

    local Attacker = Dmg:GetAttacker()

    if IsValid( Attacker ) and Attacker.IsDrGNextbot then

      Attacker:SpotEntity( Ragdoll )

    end

    Ragdoll.EntityClass = self:GetClass()

    return Ragdoll

  else return NULL end

end


local NextbotMETA = FindMetaTable( "NextBot" )
local Old_BecomeRagdoll = NextbotMETA.BecomeRagdoll


function NextbotMETA:BecomeRagdoll( Dmg )

  local RagdollModel = self.RagdollReplacement or self:GetModel()

  local RemoveRagdolls = GetConVar( "drgbase_remove_ragdolls" )
  local RagdollFadeOut = GetConVar( "drgbase_ragdoll_fadeout" )
  local DisableRagCollisions = GetConVar( "drgbase_ragdoll_collisions_disabled" )

  if self.IsDrGNextbot then

    if self:IsFlagSet(FL_KILLME) or self:IsMarkedForDeletion() or self._DrGBaseRemoved then return NULL end

    if not Dmg then Dmg = DamageInfo() end

    if not self.IsDrGNextbotSprite and UIsValidRagdoll( RagdollModel ) and not Dmg:IsDamageType( DMG_REMOVENORAGDOLL ) and not self:IsFlagSet( FL_DISSOLVING ) and not self:IsFlagSet( FL_TRANSRAGDOLL ) then

      self:AddFlags( FL_TRANSRAGDOLL )

      local Ragdoll = self:DrG_CreateRagdoll( Dmg )

      if IsValid( Ragdoll ) then

        UReplaceEntity( self, Ragdoll )

        CReplaceEntity( self, Ragdoll )

        if not GetConVar( "ai_serverRagdolls" ):GetBool() or DisableRagCollisions:GetBool() then

          Ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

        end

        if not self.OnRagdoll( Ragdoll, Dmg ) and RemoveRagdolls:GetFloat() >= 0 then

          Ragdoll:Fire( "fadeandremove", MClamp( RagdollFadeOut:GetFloat(), 0, math.huge ), RemoveRagdolls:GetFloat() )

        end

      end

      self:Remove()

      return Ragdoll

    else

      self:Remove()

      return NULL

    end

  else

    return Old_BecomeRagdoll( self, Dmg )

  end

end