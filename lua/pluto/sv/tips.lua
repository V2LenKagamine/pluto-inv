local nextTipThink = CurTime() + 300

local plutoTips = {
    "You can vote for the current gamemode with the command '!votegm'. 60% or more votes will change the GM!",
    "Chat commands accept '!','.' and '/' as valid starters.",
    "Crates are given for playing rounds,completing raids, or rarely from raid mobs.",
    "You can do 'pluto_show_all_unbox 1' in console to have the unbox tab show all crates; instead of just ones you have.",
    "You can hold SHIFT when using currencies on a weapon to not have to pick up a new currency after clicking!",
    "Objects in your 'Buffer' tab are automatically destroyed when they are pushed off the end. Move what you want to keep!",
    "Ideas are always welcome, anything could get added with a good enough arguement on why!",
    "Bored and no one on? Try doing '!votegm raids' and prepare yourself!",
    "Something not look right in your inventory? Try 'pluto_fullupdate' in console; and no, spamming it won't work.",
    "Deagles are wildly inaccurate when fired in quick succession, space your shots.",
}
local text_white = Color(255,255,255)
local pluto_color = Color(155,155,155)
hook.Add("Think","pluto_tips_auto",function()
    if(nextTipThink >= CurTime() or #player.GetAll() <=0) then return end
    nextTipThink = CurTime() + 300
    for _,ply in ipairs(player.GetAll()) do
        ply:ChatPrint(pluto_color,"Pluto Tip: ",text_white,plutoTips[math.random(#plutoTips)])
    end
end)

concommand.Add("pluto_givemeatip",function ()
    if(not pluto.cancheat) then return end
    nextTipThink = CurTime() + 1
end)