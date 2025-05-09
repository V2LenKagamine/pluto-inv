if not ENT then return end


local istable = istable
local CurTime = CurTime


  -- This Code is used to acquire an Entities Tick Interval. --


ENT.LastUpdateTime = nil
ENT.UpdateInterval = nil


function ENT:CalculateUpdateInterval()

  if self.LastUpdateTime then

    local Interval = CurTime() - self.LastUpdateTime

    if Interval > 0.0001 then

      self.UpdateInterval = Interval
      self.LastUpdateTime = CurTime()

    end

    return Interval, CurTime()

  end

  self.UpdateInterval = 0.033
  self.LastUpdateTime = CurTime() - self.UpdateInterval

  return 0.033, CurTime() - 0.033

end


function ENT:GetUpdateInterval()

  return self.UpdateInterval

end


