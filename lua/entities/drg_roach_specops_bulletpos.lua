
AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then return end

function ENT:Draw() self:DrawModel() end
function ENT:DrawTranslucent() self:Draw() end

scripted_ents.Register(ENT,"obj_warlord_ENT")