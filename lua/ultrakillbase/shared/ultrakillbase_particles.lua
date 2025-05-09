if not ENT or not SERVER then return end


local istable = istable
local isstring = isstring
local ECreate = SERVER and ents.Create
local IsValid = IsValid
local isvector = isvector
local isangle = isangle
local ipairs = ipairs
local tostring = tostring
local TInsert = table.insert
local isentity = isentity
local table = table
local SafeRemoveEntity = SafeRemoveEntity
local pairs = pairs
local TIsEmpty = table.IsEmpty
local TRemove = table.remove
local SafeRemoveEntityDelayed = SafeRemoveEntityDelayed


local function CreateParticleEffect( String, Data ) -- Mostly the same as DrGBase.ParticleEffect with some changes.

  if not isstring( String ) or not istable( Data ) then return end

  local Main = ECreate( "info_particle_system" )

  if not IsValid( Main ) then return NULL end

  Main:SetKeyValue( "effect_name", String )

  Main:SetName( "drg_info_particle_system_" .. Main:GetCreationID() )

  if isvector( Data.pos ) then Main:SetPos( Data.pos ) end
  if isangle( Data.ang ) then Main:SetAngles( Data.ang ) end
  if Data.active ~= false then Main:SetKeyValue( "start_active", "1" ) end

  local CPoints = {}

  for X, CPointData in ipairs( Data.cpoints or {} ) do

    local CPoint = CreateParticleEffect( String, CPointData )

    CPoint:SetName( "drg_info_particle_system_cpoint_" .. CPoint:GetCreationID() )

    Main:SetKeyValue( "cpoint"..tostring( X ), CPoint:GetName() )

    CPoint:Fire( "Stop" ) -- Stops the CPoint from emitting.

    Main:DeleteOnRemove( CPoint )

    TInsert( CPoints, CPoint )

  end

  Main:Spawn()
  Main:Activate()

  if isentity( Data.parent ) and IsValid( Data.parent ) then

    if isstring( Data.attachment ) then

      Main:SetParent( Data.parent )

      if Data.keepoffset then

        Main:Fire( "SetParentAttachmentMaintainOffset", Data.attachment )

      else 

        Main:Fire( "SetParentAttachment", Data.attachment ) 

      end

    elseif not Data.keepoffset then

      Main:SetPos( Data.parent:GetPos() )

      Main:SetParent( Data.parent )

    else

      Main:SetParent( Data.parent ) 

    end

  end

  return Main, table.DrG_Unpack( CPoints, #CPoints ) -- Return Main Particle and CPoints as a VarArg.

end


function ENT:GetParticleEffectSlot( Slot )

  if not istable( self.UltrakillBase_ParticleTable ) or not istable( self.UltrakillBase_ParticleTable[ Slot ] ) then return end

  return self.UltrakillBase_ParticleTable[ Slot ].Main, self.UltrakillBase_ParticleTable[ Slot ].CPoints

end


function ENT:ClearParticleEffectSlot( Slot )

  if not istable( self.UltrakillBase_ParticleTable[ Slot ] ) or not istable( self.UltrakillBase_ParticleTable ) then return end

  SafeRemoveEntity( self.UltrakillBase_ParticleTable[ Slot ].Main ) -- Delete Main Particle. All CPoints will be deleted alongside this.

  self.UltrakillBase_ParticleTable[ Slot ] = nil

end


function ENT:ClearAllParticleEffectSlots()

  for Slot, v in pairs( self.UltrakillBase_ParticleTable or {} ) do
    
    self:ClearParticleEffectSlot( Slot )

  end

end


function ENT:ParticleEffectSlot( Slot, ... )

  local Pack = table.DrG_Pack( CreateParticleEffect( ... ) ) -- Pack all data together.

  -- Create Table --

  if not istable( self.UltrakillBase_ParticleTable ) then

    self.UltrakillBase_ParticleTable = {}

  end

  -- Clear Previous Data --

  if not TIsEmpty( self.UltrakillBase_ParticleTable ) then

    self:ClearParticleEffectSlot( Slot )

  end

  -- Unpack Data to Table --

  local MainParticle = TRemove( Pack, 1 )

  if not IsValid( MainParticle ) then return end

  self.UltrakillBase_ParticleTable[ Slot ] = { Main = MainParticle, CPoints = Pack }

  return self.UltrakillBase_ParticleTable[ Slot ]

end


function ENT:ParticleEffectTimed( Time, ... )

  local P = CreateParticleEffect( ... )

  SafeRemoveEntityDelayed( P, Time )

  return P

end