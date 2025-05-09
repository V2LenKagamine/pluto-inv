if not ENT then return end


local istable = istable
local SFind = string.find
local SLower = string.lower
local UltrakillBase = UltrakillBase
local isnumber = isnumber
local isstring = isstring
local pairs = pairs
local ipairs = ipairs
local isfunction = isfunction
local table = table


function ENT:GetCurrentSequenceName()

  return self:GetSequenceName( self:GetSequence() ) or ""

end


  -- Check if an Anim is marked as an Intro. --


function ENT:IsIntro( Anim )

  if self:GetNW2Bool( "UltrakillBaseIntro/" .. Anim ) then 

    return true

  else

    return SFind( SLower( Anim ), "intro" ) ~= nil 

  end

end


  -- Calculate Overall Animrate based on multiple variables. --


function ENT:CalculateAnimRate( Seq )

  local DifficultyRate = 1

  if self.UltrakillBase_Difficulty == 0 then

    DifficultyRate = 0.75

  elseif self.UltrakillBase_Difficulty == 1 then

    DifficultyRate = 0.85

  elseif self.UltrakillBase_Difficulty == 2 then

    DifficultyRate = 0.9

  else

    DifficultyRate = 1

  end

  local AnimRate = 1
  local EnragedRate = ( self:IsEnraged() and self.UltrakillBase_EnragedRate or 1 ) or 1
  local RadiantRate = self:IsRadiant() and self:GetRadiantData().Speed or 1
  local EntityRate = self.UltrakillBase_RateMult or 1

  Seq = isnumber( Seq ) and self:GetSequenceName( Seq ) or Seq

  if isnumber( Seq ) and Seq then Seq = self:GetSequenceName( Seq ) end

  if istable( self.UltrakillBase_AnimRateInfo ) and isstring( Seq ) and self.UltrakillBase_AnimRateInfo[ Seq ] then

    AnimRate = self.UltrakillBase_AnimRateInfo[ Seq ]

  end

  if isstring( Seq ) and self:IsIntro( Seq ) then

    return 1 * AnimRate

  end

  return AnimRate * DifficultyRate * EnragedRate * RadiantRate * EntityRate -- Multiply them all together.

end


function ENT:CalculateRate()

  return self:CalculateAnimRate( self:GetSequence() )

end


  -- Mark an Animation as an Intro Anim --


if SERVER then


  function ENT:SetIntro( Anim, Bool )

    self:SetNW2Bool( "UltrakillBaseIntro/" .. Anim, Bool)

  end


end


  -- Fixed a bug with DrGBase. --


function ENT:_PlaySequenceEvents( Seq, CurCycle )
  
	local Events = self._DrGBaseSequenceEvents[ Seq ]

	for Cycle, Event in pairs( istable( Events ) and Events or {} ) do

		if ( CurCycle > Cycle and self._DrGBaseLastAnimCycle <= Cycle ) or ( CurCycle < self._DrGBaseLastAnimCycle and CurCycle >= Cycle ) or ( CurCycle < self._DrGBaseLastAnimCycle and self._DrGBaseLastAnimCycle <= Cycle ) then
			
      for I, Data in ipairs( Event ) do

        if not isfunction( Data.callback ) then continue end -- Fix.

        Data.callback( self, table.DrG_Unpack( Data.args, Data.n ) ) 

      end

		end

	end


end
