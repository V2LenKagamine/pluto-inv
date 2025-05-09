if not ENT then return end


local istable = istable
local isstring = isstring
local CreateClientConVar = CreateClientConVar
local pairs = pairs
local DynamicLight = DynamicLight
local CurTime = CurTime


ENT.UltrakillBase_LightData = {}


function ENT:CreateLight( Index, Col, Radius, Brightness, Style, Attachment )

    if SERVER then

        self:CallOnClient( "CreateLight", Index, Col, Radius, Brightness, Style, Attachment )

    end

    if isstring( Attachment ) then Attachment = self:LookupAttachment( Attachment ) end

    self.UltrakillBase_UsingLights = true

    self.UltrakillBase_LightData[ Index ] = {

        Index = Index,
        Colour = Col,
        Radius = Radius,
        Brightness = Brightness,
        Style = Style,
        Attachment = Attachment

    }

end


function ENT:GetLight()

    return self.UltrakillBase_LightData or {}
  
end


if SERVER then return end


local LightConVar = CreateClientConVar( "drg_ultrakill_lights", 1, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Enable Dynamic Lights" )


function ENT:RenderLight()

    if not self.UltrakillBase_UsingLights or LightConVar:GetBool() ~= true then return end

    for Index, LightData in pairs( self.UltrakillBase_LightData ) do

        local Light = DynamicLight( self:EntIndex() + Index )
        local Pos = self:GetAttachment( LightData.Attachment ).Pos
        local Colour = LightData.Colour

        Light.pos = Pos
        Light.r = Colour.r
        Light.g = Colour.g
        Light.b = Colour.b
        Light.brightness = LightData.Brightness
        Light.decay = 1000
        Light.size = LightData.Radius
        Light.dietime = CurTime() + 1

    end

end