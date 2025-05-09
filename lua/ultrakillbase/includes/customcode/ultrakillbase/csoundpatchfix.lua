local CSoundPatchMeta = FindMetaTable( "CSoundPatch" )
local CSoundPatchIsValid = CSoundPatchMeta.IsValid


if isfunction( CSoundPatchIsValid ) then return end


function CSoundPatchMeta:IsValid()

    return self ~= nil

end