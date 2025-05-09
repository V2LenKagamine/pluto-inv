local isnumber = isnumber
local CurTime = CurTime
local MMax = math.max
local UltrakillBase = UltrakillBase



function UltrakillBase.CalculateIFrameTime( Ent, Damage )

  if not isnumber( Damage ) and Damage:GetDamage() then Damage = Damage:GetDamage() end

  if Damage >= 500 then

    return 0.8

  else

    return 0.5

  end

end



function UltrakillBase.SetIFrames( self, Time )

  return self:SetNW2Float( "UltrakillBase_IFrames", CurTime() + Time )

end



function UltrakillBase.GetIFrames( self )

  return MMax( self:GetNW2Float( "UltrakillBase_IFrames" ) - CurTime(), 0 )

end



function UltrakillBase.CheckIFrames( self )
  
  return UltrakillBase.GetIFrames( self ) > 0

end

