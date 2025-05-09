local istable = istable
local isstring = isstring
local isnumber = isnumber
local isvector = isvector
local Vector = Vector
local isfunction = isfunction
local CurTime = CurTime
local MClamp = math.Clamp
local CRCreate = coroutine.create
local IsValid = IsValid
local ECreate = SERVER and ents.Create
local ipairs = ipairs
local isentity = isentity
local Angle = Angle
local UltrakillBase = UltrakillBase
local MAbs = math.abs
local DrGBase = DrGBase
local MRandom = math.random
local util = util
local GetConVar = GetConVar

if not ENT then return end


if SERVER then


function ENT:PlaySequenceAndFly( Seq, Options, Callback )

  if isstring( Seq ) then Seq = self:LookupSequence( Seq )

  elseif not isnumber( Seq ) then return end

  if Seq == -1 then return end

  if isnumber( Options ) then Options = { rate = Options }
  elseif not istable( Options ) then Options = {} end

  if Options.gravity == nil then Options.gravity = true end
  if Options.collisions == nil then Options.collisions = true end
  if Options.rate == nil then Options.rate = 1 end

  local PreviousCycle = 0

  local PreviousPos = self:GetPos()

  local Res = self:PlaySequenceAndWait( Seq, Options.rate, function( self, Cycle )

    local Success, Vec, Angles = self:GetSequenceMovement( Seq, PreviousCycle, Cycle )

    if Success then

      if isvector( Options.multiply ) then

        Vec = Vector( Vec.x * Options.multiply.x, Vec.y * Options.multiply.y, Vec.z * Options.multiply.z)

      end

      local RotateAngle = self:GetAngles()

      local TempVec = Vector()

      TempVec:Set( Vec )

      TempVec:Rotate( self:GetAimAngles() )

      if not self:TraceHull( TempVec ).Hit then

        RotateAngle = self:GetAimAngles()

      end

      Vec:Rotate( RotateAngle )

      self:SetAngles( self:LocalToWorldAngles( Angles ) )

      local CollisionTrace = self:TraceHull( Vec, { step = self:IsOnGround() } )
      
      if not Options.collisions or not CollisionTrace.Hit then

        if not Vec:IsZero() then

          PreviousPos = self:GetPos() + ( Vec * self:GetModelScale() )

          self:SetPos( PreviousPos )

        else PreviousPos = self:GetPos() end

      elseif Options.stoponcollide then return true end

    end

    PreviousCycle = Cycle

    self:SetVelocity( vector_origin )

    if isfunction( Callback ) then return Callback( self, Cycle ) end

  end )

  self:SetVelocity( vector_origin )

  return Res

end


function ENT:PlaySequenceAndMove( Seq, Options, Callback )

  if isstring( Seq ) then Seq = self:LookupSequence( Seq )

  elseif not isnumber( Seq ) then return end

  if Seq == -1 then return end

  if isnumber( Options ) then Options = { rate = Options }
  elseif not istable( Options ) then Options = {} end

  if Options.gravity == nil then Options.gravity = true end
  if Options.collisions == nil then Options.collisions = true end
  if Options.rate == nil then Options.rate = 1 end

  local PreviousCycle = 0

  local PreviousPos = self:GetPos()

  local Res = self:PlaySequenceAndWait( Seq, Options.rate, function( self, Cycle )

    local Success, Vec, Angles = self:GetSequenceMovement( Seq, PreviousCycle, Cycle )

    if Success then

      if isvector( Options.multiply ) then

        Vec = Vector( Vec.x * Options.multiply.x, Vec.y * Options.multiply.y, Vec.z * Options.multiply.z)

      end

      local RotateAngle = self:GetAngles()

      if Options.rotate then

        local TempVec = Vector()

        TempVec:Set( Vec )

        TempVec:Rotate( self:GetAimAngles() )

        if not self:TraceHull( TempVec ).Hit then

          RotateAngle = self:GetAimAngles()

        end

      end

      Vec:Rotate( RotateAngle )

      self:SetAngles( self:LocalToWorldAngles( Angles ) )

      local CollisionTrace = self:TraceHull( Vec, { step = self:IsOnGround() } )
      
      if not Options.collisions or not CollisionTrace.Hit then

        if not Options.gravity then

          PreviousPos = PreviousPos + ( Vec * self:GetModelScale() )

          self:SetPos( PreviousPos )

          self:SetVelocity( vector_origin )

        elseif not Vec:IsZero() then

          PreviousPos = self:GetPos() + ( Vec * self:GetModelScale() )

          self:SetPos( PreviousPos )

        else PreviousPos = self:GetPos() end

      else

        if IsValid( CollisionTrace.Entity ) then self:OnContact( CollisionTrace.Entity ) end
        if Options.stoponcollide then return true
        elseif not Options.gravity then self:SetPos( PreviousPos ) end

      end

    end

    PreviousCycle = Cycle

    if isfunction( Callback ) then return Callback( self, Cycle ) end

  end )

  if not Options.gravity then self:SetVelocity( vector_origin ) end

  return Res

end


local function ResetSequence( self, Seq )

  local Res = self:SetSequence( Seq )

  self:ResetSequenceInfo()
  self:SetCycle( 0 )

  return Res

end


function ENT:PlaySequenceAndLoop( Time, Seq, Rate, Callback )

  if self._DrGBaseDisablePSAW then return end

  if isstring( Seq ) then Seq = self:LookupSequence( Seq )

  elseif not isnumber( Seq ) then return end

  if Seq == -1 then return end

  local CurSeq = self:GetSequence()

  if Seq == self:GetSequence() or self:OnAnimChange( self:GetSequenceName( CurSeq ), self:GetSequenceName( Seq ) ) ~= false then

    self._DrGBasePlayingAnimation = Seq

    ResetSequence( self, Seq )

    self:SetCycle( 0 )

    self:SetPlaybackRate( ( Rate or 1 ) * self:CalculateAnimRate( Seq ) )

    local Now = CurTime()

    local LastCycle = -1

    local LastRate = ( Rate or 1 ) * self:CalculateAnimRate( Seq )

    while self:IsPlayingSequence( Seq ) do

      if isnumber( Time ) and CurTime() - Now > Time then break end

      if self:GetSequence() ~= Seq then

        self:SetSequence( Seq )
        self:SetCycle( LastCycle > 0 and LastCycle or 0 )
        self:SetPlaybackRate( LastRate )

      end

      local Cycle = self:GetCycle()

      LastCycle = Cycle

      if self:GetTurning() then

        self:FaceEnemy()
  
      end

      if self:HadEnemy() then

        self:UpdateEnemy()

      end

      if isfunction( Callback ) then

        self._DrGBaseDisablePSAW = true

        local Res = Callback( self, Cycle, MClamp( CurTime() - Now, 0, Time or 3600 ) )

        self._DrGBaseDisablePSAW = false

        if Res then break end

      end

      self:YieldCoroutine( false )

    end

    self._DrGBasePlayingAnimation = nil

    self:Timer( 0, function()

      self:UpdateAnimation()
      self:UpdateSpeed()

    end )

    return CurTime() - Now

  end

end


function ENT:PlaySequenceAndWait( Seq, Rate, Callback )

  if self._DrGBaseDisablePSAW then return end

  if isstring( Seq ) then Seq = self:LookupSequence( Seq )

  elseif not isnumber( Seq ) then return end

  if Seq == -1 then return end

  local Current = self:GetSequence()

  if Seq == self:GetSequence() or self:OnAnimChange( self:GetSequenceName( Current ), self:GetSequenceName( Seq ) ) ~= false then

    self._DrGBasePlayingAnimation = Seq

    ResetSequence( self, Seq )

    self:SetPlaybackRate( ( Rate or 1 ) * self:CalculateAnimRate( Seq ) )

    local Now = CurTime()

    local LastCycle = -1

    local LastRate = ( Rate or 1 ) * self:CalculateAnimRate( Seq )

    while self:IsPlayingSequence( Seq ) do

      if self:GetSequence() ~= Seq then

        self:SetSequence( Seq )
        self:SetCycle( LastCycle > 0 and LastCycle or 0 )
        self:SetPlaybackRate( LastRate )

      end

      local Cycle = self:GetCycle()

      if LastCycle == Cycle and Cycle == 1 or LastCycle > Cycle then break end

      LastCycle = Cycle

      if self:GetTurning() then

        self:FaceEnemy()
  
      end

      if self:HadEnemy() then

        self:UpdateEnemy()

      end

      if isfunction( Callback ) then

        self._DrGBaseDisablePSAW = true

        local Res = Callback( self, Cycle )

        self._DrGBaseDisablePSAW = false

        if Res then break end

      end

      self:YieldCoroutine( false )

    end

    self._DrGBasePlayingAnimation = nil

    self:Timer( 0, function()

      self:UpdateAnimation()
      self:UpdateSpeed()

    end )

    return CurTime() - Now

  end

end



function ENT:CallOverCoroutine( NewCoroutine, RestartBehaviour, ... )

  local OldThread = self.BehaveThread
  local Args = { ... }

  self.BehaveThread = CRCreate( function()

    NewCoroutine( self, unpack( Args ) )

    if RestartBehaviour then

      self.BehaveThread = nil

      return self:BehaveStart()

    end

    self.BehaveThread = OldThread

  end )

end


function ENT:CreateProjectile( Class, ProjOnRemove )

  local Proj = ECreate( Class )

  if not IsValid( Proj ) then return NULL end

  Proj:SetOwner( self )

  if ProjOnRemove then

    self:DeleteOnRemove( Proj )

  end

  Proj:Spawn()

  return Proj

end


local function LocoJump( self )

  local Seq = self:GetSequence()
  local Cycle = self:GetCycle()
  local Rate = self:GetPlaybackRate()

  self.loco:Jump()
  self:ResetSequence( Seq )
  self:SetPlaybackRate( Rate )
  self:SetCycle( Cycle )

end


local function LeaveGround( self )

  if not self:IsOnGround() then return end
  
  local JumpHeight = self.loco:GetJumpHeight()
  
  self.loco:SetJumpHeight( 1 )

  LocoJump( self )

  self.loco:SetJumpHeight( JumpHeight )

end


function ENT:PushEntity( Ent, Force )

  if istable( Ent ) then

    local Vecs = {}

    for K, V in ipairs( Ent ) do

      if not IsValid( V ) then continue end

      Vecs[ V:EntIndex() ] = self:PushEntity( V, Force )

    end

    return Vecs

  elseif isentity( Ent ) and IsValid( Ent ) then

    local Direction = self:GetPos():DrG_Direction( Ent:GetPos() )

    if Ent:IsPlayer() and Ent:InVehicle() then return Vector() end

    local VecForward = Direction

    VecForward.z = 0

    VecForward:Normalize()

    local VecRight = Vector()

    VecRight:Set( VecForward )

    VecRight:Rotate( Angle( 0, -90, 0 ) )

    local VecUp = Vector( 0, 0, 1 )

    local Vec = VecForward * Force.x + VecRight * Force.y + VecUp * Force.z

    local Phys = Ent:GetPhysicsObject()
    
    if not UltrakillBase.GetWeightData( Ent ).Push then return Vec end

    if Ent.IsDrGNextbot then

      LeaveGround( Ent )

      Ent:SetVelocity( Ent:GetVelocity() + Vec )

    elseif Ent.Type == "nextbot" then

      LeaveGround( Ent )

      Ent.loco:SetVelocity( Ent.loco:GetVelocity() + Vec )

    elseif IsValid( Phys ) and not Ent:IsPlayer() then

      Phys:AddVelocity( Vec )

    else

      Ent:SetVelocity( Ent:GetVelocity() + Vec )

    end

    return Vec

  end

end


function ENT:IsInRange( vPos, fRange )

  if isentity( vPos ) and not IsValid( vPos ) then return end
  if isentity( vPos ) then vPos = vPos:GetPos() end

  local vOrigin = self:GetPos()

  return vOrigin:DistToSqr( vPos ) <= fRange * fRange

end


function ENT:IsInRange2D( vPos, fRange )

  if isentity( vPos ) and not IsValid( vPos ) then return end
  if isentity( vPos ) then vPos = vPos:GetPos() end

  local vOrigin = self:GetPos()

  return vOrigin:Distance2DSqr( vPos ) <= fRange * fRange

end


function ENT:OnInjured( CDamageInfo )

  if CDamageInfo:GetDamage() <= 0 or self:GetGodMode() then

    self._DrGBaseHitGroupToHandle = false

    return CDamageInfo:ScaleDamage( 0 )

  else

    self:Timer( 0, self._UpdateHealth )

    local HitGroup = self._DrGBaseHitGroupToHandle and self:LastHitGroup() or HITGROUP_GENERIC

    local Attacker = CDamageInfo:GetAttacker()

    local Res = self:OnTakeDamage( CDamageInfo, HitGroup )

    if IsValid( Attacker ) and DrGBase.IsTarget( Attacker ) then

      if self:IsAlly( Attacker ) then

        self._DrGBaseAllyDamageTolerance[ Attacker ] = self._DrGBaseAllyDamageTolerance[ Attacker ] or 0

        self._DrGBaseAllyDamageTolerance[ Attacker ] = self._DrGBaseAllyDamageTolerance[ Attacker ] + self.AllyDamageTolerance

        self:AddEntityRelationship( Attacker, D_HT, self._DrGBaseAllyDamageTolerance[ Attacker ] )

      elseif self:IsAfraidOf( Attacker ) then

        self._DrGBaseAfraidOfDamageTolerance[ Attacker ] = self._DrGBaseAfraidOfDamageTolerance[ Attacker ] or 0

        self._DrGBaseAfraidOfDamageTolerance[ Attacker ] = self._DrGBaseAfraidOfDamageTolerance[ Attacker ] + self.AfraidDamageTolerance

        self:AddEntityRelationship( Attacker, D_HT, self._DrGBaseAfraidOfDamageTolerance[ Attacker ])

      elseif self:IsNeutral( Attacker ) then

        self._DrGBaseNeutralDamageTolerance[ Attacker] = self._DrGBaseNeutralDamageTolerance[ Attacker ] or 0

        self._DrGBaseNeutralDamageTolerance[ Attacker] = self._DrGBaseNeutralDamageTolerance[ Attacker ] + self.NeutralDamageTolerance

        self:AddEntityRelationship( Attacker, D_HT, self._DrGBaseNeutralDamageTolerance[ Attacker ] )

      end

    end

    if Res == true or self:IsDown() or self:IsDead() then

      self._DrGBaseHitGroupToHandle = false

      return CDamageInfo:ScaleDamage( 0 )

    else

      if isnumber( Res ) then CDamageInfo:SetDamage( Res ) end

      if CDamageInfo:GetDamage() >= self:Health() then

        if self:OnFatalDamage( CDamageInfo, HitGroup ) then

          self._DrGBaseHitGroupToHandle = false
          
          self:SetNW2Bool( "DrGBaseDown", true )

          self:SetNW2Int( "DrGBaseDowned", self:GetNW2Int( "DrGBaseDowned" ) + 1 )

          self:SetHealth( 1 )

          if #self.OnDownedSounds > 0 then

            self:EmitSound( self.OnDownedSounds[ MRandom( #self.OnDownedSounds ) ] )

          end

          local NoTarget = self:GetNoTarget()

          self:SetNoTarget( false )

          local Data = util.DrG_SaveDmg( CDamageInfo )

          self:CallInCoroutine( function( self )

            self:OnDowned( util.DrG_LoadDmg( Data ), HitGroup )

            if self:Health() <= 0 then self:SetHealth( 1 ) end

            self:SetNoTarget( NoTarget )
            self:SetNW2Bool( "DrGBaseDown", false )

          end )

          CDamageInfo:ScaleDamage( 0 )

        else self:SetHealth( 0 ) end

        return

      else

        self._DrGBaseHitGroupToHandle = false

        if #self.OnDamageSounds > 0 then

          self:EmitSlotSound( "DrGBaseDamageSounds", self.DamageSoundDelay, self.OnDamageSounds[MRandom(#self.OnDamageSounds)])

        end

        if isfunction( self.OnTookDamage ) then

          local Data = util.DrG_SaveDmg( CDamageInfo )

          self:ReactInCoroutine( function( self )

            if self:IsDown() then return end

            CDamageInfo = util.DrG_LoadDmg( Data )

            self:OnTookDamage( CDamageInfo, HitGroup ) 

          end )

        elseif isfunction( self.AfterTakeDamage ) then

          local Data = util.DrG_SaveDmg( CDamageInfo )

          local Now = CurTime()

          self:ReactInCoroutine( function( self )

            if self:IsDown() then return end

            CDamageInfo = util.DrG_LoadDmg( Data )

            self:AfterTakeDamage( CDamageInfo, CurTime() - Now, HitGroup )

          end )

        end

      end

    end

  end

end


local function NextbotDeath( self, CTakeDamageInfo )

  if not IsValid( self ) then return end

  if self:HasWeapon() and self.DropWeaponOnDeath then

    self:DropWeapon()

  end

  if self.RagdollOnDeath then

    return self:BecomeRagdoll( CTakeDamageInfo )

  end

  self:Remove()

end


function ENT:OnKilled( CTakeDamageInfo )

  if self:IsDead() then return end

  local HitGroup = self._DrGBaseHitGroupToHandle and self:LastHitGroup() or HITGROUP_GENERIC

  self._DrGBaseHitGroupToHandle = false

  self:SetHealth( 0 )

  self:SetNW2Bool( "DrGBaseDying", true )

  self:DrG_DeathNotice( CTakeDamageInfo:GetAttacker(), CTakeDamageInfo:GetInflictor() )

  if CTakeDamageInfo:IsDamageType( DMG_DISSOLVE ) then

    self:DrG_Dissolve()

  end

  if isfunction( self.OnDeath ) then

    local CTakeDamageData = util.DrG_SaveDmg( CTakeDamageInfo )

    self.BehaveThread = CRCreate( function()

      self:SetNW2Bool( "DrGBaseDying", false )
      self:SetNW2Bool( "DrGBaseDead", true )

      local Now = CurTime()

      CTakeDamageInfo = self:OnDeath( util.DrG_LoadDmg( CTakeDamageData ), HitGroup )

      if CTakeDamageInfo == nil then

        CTakeDamageInfo = util.DrG_LoadDmg( CTakeDamageData )

        if CurTime() > Now then

          CTakeDamageInfo:SetDamageForce( Vector( 0, 0, 1 ) )

        end

      end

      if GetConVar( "drgbase_remove_dead" ):GetBool() and GetConVar( "drgbase_remove_ragdolls" ):GetFloat() >= 0 then

        self:Timer( GetConVar( "drgbase_remove_ragdolls" ):GetFloat(), self.Remove )

      end

      NextbotDeath( self, CTakeDamageInfo )

    end )

  else

    self:SetNW2Bool( "DrGBaseDying", false )

    self:SetNW2Bool( "DrGBaseDead", true )

    NextbotDeath( self, CTakeDamageInfo )

  end

end


end

