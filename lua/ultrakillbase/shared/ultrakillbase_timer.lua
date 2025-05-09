if not ENT then return end


local istable = istable
local unpack = unpack
local TExists = timer.Exists
local TRemove = timer.Remove
local TCreate = timer.Create


function ENT:TimerIdentified( mID, fDelay, iRep, mCallback, ... )

  if TExists( mID ) then TRemove( tostring( self ) .. mID ) end


  local mArgs = { ... }

  TCreate( tostring( self ) .. mID, fDelay, iRep, function()

    mCallback( self, unpack( mArgs ) )

  end )


  self:CallOnRemove( mID, function( self, mID )

    TRemove( tostring( self ) .. mID )

  end, mID )

end



