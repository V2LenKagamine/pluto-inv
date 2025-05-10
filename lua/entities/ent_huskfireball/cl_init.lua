include('shared.lua')

killicon.Add( "ent_huskfireball", "HUD/killicons/husk_gun", Color( 255, 255, 255, 255 ) )

local ID = tostring(self)

ENT.DLight = {}
ENT.Lighted = true

function ENT:Initialize()
	self.Lighted = false
	local var = GetConVar("kf_npc_dlight")
	if var then
		self.Lighted = (var:GetInt()>0) and true or false
	end
	if(self.Lighted) then
		self.DLight = DynamicLight( self:EntIndex() )
		
		if ( self.DLight ) then
			self.DLight.r = 240
			self.DLight.g = 247
			self.DLight.b = 22
		
			self.DLight.pos = self:GetPos()
			self.DLight.brightness = 3
			self.DLight.Size = 86
			self.DLight.DieTime = CurTime() + 1
		end
	end
end


function ENT:Think()
	if(IsValid(self)&&self!=nil&&self!=NULL) then
		if(self.Lighted) then
			if(self:GetNoDraw()==false) then
				self.DLight.DieTime = CurTime()+1
				self.DLight.pos = self:GetPos()
			else
				self.DLight.brightness = 0
				self.DLight.Size = 0
				self.Lighted = false
			end
		end
	end
end
net.Receive("ExplodeHuskFireball",function()
	local ent = net.ReadEntity()
	local pos = net.ReadVector()
	
	if(IsValid(ent)&&ent!=nil&&ent!=NULL) then
		
		local TEMP_Emitter = ParticleEmitter(pos, false)
		
		for P=1, 7 do
			local TEMP_TBL = { -1, 1 }
			local Vel = Vector(TEMP_TBL[math.random(1,2)],TEMP_TBL[math.random(1,2)],TEMP_TBL[math.random(1,2)])*math.random(79,93)
			
			local particle = TEMP_Emitter:Add( "particles/HuskGunFireballExplosionFlare", pos)
			particle:SetDieTime( 2 )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 10 )
			particle:SetStartSize( 2 )
			particle:SetEndSize( 0 )
			particle:SetVelocity(Vel)
			particle:SetColor( 255, 255, 255 )
			particle:SetCollide(true)
			particle:SetCollideCallback( function( part )
				part:SetDieTime(-1)
			end )
			
			local Vel = Vector(TEMP_TBL[math.random(1,2)],TEMP_TBL[math.random(1,2)],math.random(80,150)/100)*math.random(29,33)
			
			local particle = TEMP_Emitter:Add( "effects/fire_cloud"..math.random(1,2), pos)
			particle:SetDieTime( 1 )
			particle:SetStartAlpha( 215 )
			particle:SetEndAlpha( 10 )
			particle:SetStartSize( 37 )
			particle:SetEndSize( 73 )
			particle:SetVelocity(Vel)
			particle:SetColor( 255, 255, 255 )
			particle:SetCollide(true)
		end
		
		local particle = TEMP_Emitter:Add( "effects/fire_cloud1", pos+Vector(0,0,25))
		particle:SetDieTime( 1 )
		particle:SetStartAlpha( 220 )
		particle:SetEndAlpha( 10 )
		particle:SetStartSize( 35 )
		particle:SetEndSize( 75 )
		particle:SetColor( 255, 255, 255 )
		particle:SetGravity(Vector(0,0,30))
		particle:SetCollide(true)
		
		TEMP_Emitter:Finish()
	end
end)

function ENT:Draw()
	cam.Start3D()
		render.SetMaterial( Material("effects/fire_cloud1") )
		render.DrawSprite( self:GetPos(), 20, 20, Color(255,255,25,255) ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
	cam.End3D()
    //self:DrawModel()
end