include('shared.lua')

function ENT:Initialize()
	local TEMP_Emitter = ParticleEmitter(self:GetPos(), false)
	
	if(IsValid(TEMP_Emitter)) then
		local TEMP_PDif = 10

		local TEMP_Particle = TEMP_Emitter:Add( "effects/blood_core", self:GetPos()+
		Vector(math.Rand(-TEMP_PDif,TEMP_PDif),math.Rand(-TEMP_PDif,TEMP_PDif),math.Rand(-TEMP_PDif,TEMP_PDif)))
		TEMP_Particle:SetDieTime( 1 )
		TEMP_Particle:SetStartAlpha( 255 )
		TEMP_Particle:SetEndAlpha( 0 )
		TEMP_Particle:SetStartSize( 32 )
		TEMP_Particle:SetEndSize( 55 )
		TEMP_Particle:SetColor( 90, 0, 0 )
		TEMP_Particle:SetGravity(Vector(0,0,-10))
		TEMP_Particle:SetCollide(false)
		
		
		TEMP_Emitter:Finish()
		
	end
		
	self.PartEnd = CurTime()+math.Rand(0.7,2)
	self.NextPart = CurTime()+0.05
end

function ENT:PhysicsCollide()
	self.PartEnd = 0
end

function ENT:Think()
	if(self.PartEnd>CurTime()&&self.NextPart<CurTime()) then
		self.NextPart = CurTime()+0.05
		
		local TEMP_Emitter = ParticleEmitter(self:GetPos(), false)
		
		if(IsValid(TEMP_Emitter)) then
			local TEMP_PDif = 1
			
			local TEMP_Particle = TEMP_Emitter:Add( "effects/blood_drop", self:GetPos()+
			Vector(math.Rand(-TEMP_PDif,TEMP_PDif),math.Rand(-TEMP_PDif,TEMP_PDif),math.Rand(-TEMP_PDif,TEMP_PDif)))
			TEMP_Particle:SetDieTime( 0.6 )
			TEMP_Particle:SetStartAlpha( 255 )
			TEMP_Particle:SetEndAlpha( 0 )
			TEMP_Particle:SetStartSize( 1 )
			TEMP_Particle:SetEndSize( 1 )
			TEMP_Particle:SetColor( 90, 0, 0 )
			TEMP_Particle:SetGravity(Vector(0,0,-100))
			TEMP_Particle:SetCollide(false)
			
			TEMP_PDif = 2
			
			local TEMP_Particle = TEMP_Emitter:Add( "effects/blood_core", self:GetPos()+
			Vector(math.Rand(-TEMP_PDif,TEMP_PDif),math.Rand(-TEMP_PDif,TEMP_PDif),math.Rand(-TEMP_PDif,TEMP_PDif)))
			TEMP_Particle:SetDieTime( 0.3 )
			TEMP_Particle:SetStartAlpha( 205 )
			TEMP_Particle:SetEndAlpha( 0 )
			TEMP_Particle:SetStartSize( 8 )
			TEMP_Particle:SetEndSize( 13 )
			TEMP_Particle:SetColor( 90, 0, 0 )
			TEMP_Particle:SetGravity(Vector(0,0,-10))
			TEMP_Particle:SetCollide(false)
			
			TEMP_Emitter:Finish()
			
		end
	end
end



function ENT:Draw()
	self:DrawModel()
end