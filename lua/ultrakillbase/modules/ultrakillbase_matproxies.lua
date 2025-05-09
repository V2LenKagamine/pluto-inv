local MPAdd = CLIENT and matproxy.Add
local IsValid = IsValid

if SERVER then return end

MPAdd( {

  name = "UltrakillBase_Heat", 

  init = function( self, Mat, Values )

    self.ResultTo = Values.resultvar

  end,

  bind = function( self, Mat, Ent )

    if not IsValid( Ent ) then return end

    Mat:SetFloat( self.ResultTo, Ent:GetNW2Bool( "UltrakillBase_Heat" ) and 1 or 0 )

  end

} )
