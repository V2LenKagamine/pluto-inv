--[[-------------------------------------------------------------------------


  Weight System Code.

  Reference https://preview.redd.it/h73ak4sw4um91.png?width=640&crop=smart&auto=webp&s=06870bbca8dde11a34832be3a2aa27b3ec94c16e

---------------------------------------------------------------------------]]

local UltrakillBase = UltrakillBase
local isstring = isstring

function UltrakillBase.SetWeightClass( self, sWeight )

  return self:SetNW2String( "UltrakillBase_WeightClass", sWeight or "Light" )

end


function UltrakillBase.GetWeightClass( self )
  
  return self:GetNW2String( "UltrakillBase_WeightClass" )

end


local mWeightTables = {

  [ "Light" ] = {

    Gravity = 850,
    Push = true,
    Pull = true,
    Collision = true

  },

  [ "Medium" ] = {

    Gravity = 1500,
    Push = true,
    Pull = false,
    Collision = true

  },

  [ "Heavy" ] = {

    Gravity = 2500,
    Push = false,
    Pull = false,
    Collision = true

  },

  [ "Superheavy" ] = {

    Gravity = 3500,
    Push = false,
    Pull = false,
    Collision = false

  },

}


function UltrakillBase.GetWeightData( mEntity )

  local sWeight = UltrakillBase.GetWeightClass( mEntity ) or "Light"

  if not isstring( sWeight ) or #sWeight <= 0 then sWeight = "Light" end

  return mWeightTables[ sWeight ]

end