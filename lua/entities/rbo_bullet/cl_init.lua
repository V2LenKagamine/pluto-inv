include("shared.lua")

local function Sign(p1,p2,dir)
	local dif=p2-p1
	dif:Normalize()
	return dir:Dot(dif)
end

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_NONE)
	self.curtime=UnPredictedCurTime()
	self.delta_time=0
	self.position=self:GetDTVector(RBO_BULLET_VEC_POSITION)
	self.velocity=self:GetDTVector(RBO_BULLET_VEC_VELOCITY)
	self.acceleration=self:GetDTVector(RBO_BULLET_VEC_ACCELERATION)
	self.source=self:GetDTEntity(RBO_BULLET_ENT_SHOOTER)
	self.last_position=self.position
	self.initialized=true
	local ammotype=self:GetDTString(RBO_BULLET_STR_AMMOTYPE)
	self.rbodata=RBOGetSupported(ammotype)
end

function ENT:Whiz()
    if(not self) then return end
    if(not GetViewEntity() or not self.source) then return end
	if (self.wizz or GetViewEntity()==self.source:GetOwner()) then
		return
	end
	local listenpos=GetViewEntity():EyePos()
	local vn=self.velocity:GetNormalized()
	if Sign(self.position,listenpos,vn)>0 then
		self.last_position=self.position
		return
	end
	if Sign(self.last_position,listenpos,vn)>0 then
		local s,p,t=util.DistanceToLine(self.last_position,self.position,listenpos)
		self.rbodata.Passby(s,p)
	end
	self.wizz=true
	self.last_position=self.position
end


function ENT:Draw()

end