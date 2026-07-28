local _l,_h,_m=_G,hook,math;
local _i=string.format("%x",_m.random(1,999999));
if TNTS_SOUNDCONTROL_SV then 
    if TNTS_SOUNDCONTROL_SV.Version and TNTS_SOUNDCONTROL_SV.Version>=1.2 then return end;
    if TNTS_SOUNDCONTROL_SV.Cleanup then TNTS_SOUNDCONTROL_SV.Cleanup()
    end 
end;
TNTS_SOUNDCONTROL_SV={Version=1.2,Identifier=_i};
local _s=TNTS_SOUNDCONTROL_SV;
CreateConVar("earringing_disable",1,{FCVAR_ARCHIVE,FCVAR_REPLICATED},"Disable tinnitus sound");
local _z=CreateConVar("tnts_earringing_disable",1,{FCVAR_ARCHIVE,FCVAR_REPLICATED},"Disable tinnitus sound");
_s.ConVars={disable=_z};local _j="TNTS.LinkConVars_".._i;
cvars.RemoveChangeCallback("tnts_earringing_disable",_j);
cvars.AddChangeCallback("tnts_earringing_disable",function(_,_,_v)
    RunConsoleCommand("earringing_disable",_v)end,_j);
    local _k="TNTS.LinkConVarsReverse_".._i;
    cvars.RemoveChangeCallback("earringing_disable",_k);
    cvars.AddChangeCallback("earringing_disable",function(_,_,_v)RunConsoleCommand("tnts_earringing_disable",_v)
    end,_k);
    _h.Remove("OnDamagedByExplosion","TNTS.DisableSound");
    _h.Add("OnDamagedByExplosion","TNTS.DisableSound",function(_p)
        if GetConVar("earringing_disable"):GetBool()then 
            if IsValid(_p)then _p:SetDSP(0,false)end;
            return true end end);
            function _s.Cleanup()cvars.RemoveChangeCallback("tnts_earringing_disable",_j);
                cvars.RemoveChangeCallback("earringing_disable",_k);
                _h.Remove("OnDamagedByExplosion","TNTS.DisableSound")end;
                _h.Add("ShutDown","TNTS.Shutdown",_s.Cleanup)