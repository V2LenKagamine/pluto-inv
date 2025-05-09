local CreateConVar = CreateConVar
local UltrakillBase = UltrakillBase or {}

UltrakillBase.ConVar_Difficulty = CreateConVar( "drg_ultrakill_difficulty", "VIOLENT", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "Ultrakill Difficulty( Enemy Speed )" )

local cvDifficulty = UltrakillBase.ConVar_Difficulty


local mDifficultyEnums = {

  [ "HARMLESS" ] = 0,
  [ "LENIENT" ] = 1,
  [ "STANDARD" ] = 2,
  [ "VIOLENT" ] = 3,
  [ "BRUTAL" ] = 4,
  [ "ULTRAKILL MUST DIE" ] = 5,
  [ "HIDDEN MANSION" ] = 6,

}


function UltrakillBase.GetDifficulty()

  return mDifficultyEnums[ cvDifficulty:GetString() ] or 3

end