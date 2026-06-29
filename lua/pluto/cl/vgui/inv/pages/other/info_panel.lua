--[[ * This Source Code Form is subject to the terms of the Mozilla Public
     * License, v. 2.0. If a copy of the MPL was not distributed with this
     * file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]
local PANEL = {}

function PANEL:SizeTab(tab)
	tab:SetSize(self:GetWide() - 3, self:GetTall() - 3)
	tab:Center()
end

function PANEL:Init()
    self:DockPadding(1, 1, 1, pluto.ui.sizings "pluto_inventory_font")
    self:SetTooltip("For all your 'What is this' questions.")
    local faqcol = vgui.Create("DCollapsibleCategory",self)
    faqcol:Dock(TOP)
    faqcol:SetLabel("F.A.Q.")
    faqcol:DoExpansion(false)

    local btn = faqcol:Add("What is this tab?")
    btn.DoClick = function() Derma_Message("This tab is your in-game wiki so to speak,clicking on a category will expand it, and clicking on anything inside will explain the topic, or elaborate on it.","Answer:","Neat!") end

    btn = faqcol:Add("Where can I make feedback?")
    btn.DoClick = function() Derma_Message("We have a discord! However, until a permenant link can be established, you might have to ask for it!","Answer:","Neat!") end

    btn = faqcol:Add("What is this server?")
    btn.DoClick = function() Derma_Message("This is a kinda hybrid TTT/PVE Inventory server, where you can play to get items for drip or to use during rounds. There are two current 'gamemodes',TTT, and RAIDS.","Answer:","Neat!") end

    btn = faqcol:Add("How is everyone so fast?")
    btn.DoClick = function() Derma_Message("This server has auto-B-hop, just hold space for jumping, no spam required!\nDo note, doing so will heavily affect your accuracy, don't expect to hit anything at speed or while jumping!","Answer:","Neat!") end

    btn = faqcol:Add("What commands can I use?")
    btn.DoClick = function() Derma_Message("Doing '/help' in chat should assist you there, it shows all the commands you can run.","Answer:","Neat!") end

    btn = faqcol:Add("Why are my crouches slow/not registering?")
    btn.DoClick = function() Derma_Message("Anti-crouch spam. Hitting crouch too much and too fast will cause a slower crouch.\nThis avoids your head hitbox being in effectively two places at once. Wouldn't want that would you?","Answer:","Ok!") end

    btn = faqcol:Add("Where is the donate button?")
    btn.DoClick = function() Derma_Message("For now, there is none, funding is not currently an issue, worry not. Enjoy the server!","Answer:","Ok!") end

    btn = faqcol:Add("Will there ever be a donator shop?")
    btn.DoClick = function() Derma_Message("Unlikely, if there is, rest assured there will never be anything game-play altering. Drip and jokes only.","Answer:","Sweet!") end

    btn = faqcol:Add("This doesn't look like the other servers, where did you get the code?")
    btn.DoClick = function() Derma_Message("It is a long story, I will shorten it. There was once a great TTT server called Pluto, that is the basis for much of what you see today. As time went on, the community grew.\nTo my [Len's] understanding, the owner, for one reason or another, was forced to stop developing the server due to life issues. No one was able to uphold the code at the time, and it fell into disrepair, and eventually sat dormant.\nWith the owners permission, I was allowed to pick up what was left, trim and tailor to my liking, into what you see before you today.","Answer:","Oh.") end

    btn = faqcol:Add("Im out of the loop, what's an inventory server?")
    btn.DoClick = function() Derma_Message("It's just like normal TTT in rules, but you get to keep specific items in your 'Inventory' with you between rounds! It's like a progression system of kinds, models, hats, even weapons you can spawn with every round.\nTheres also trading and a market, for those interested.","Answer:","Neat!") end

    btn = faqcol:Add("What does 'Rolls Rarity Descending' mean?")
    btn.DoClick = function() Derma_Message("'Rolls Rarity Descending' means that you will roll for the rarest item first, then the second, and so on.\nTake example crate A with items 1,2,3 and 4, with chances 10,20,30,and 30 respectively.\nRarity Descending Dictates we roll for the rarest, or 1, first, then 2 if we fail 1, and then we are guarenteed 3 or 4 if we fail both 1 and 2.\nWhen Rolling Rarity Descending, items of the same chance are truely random, they all have the same odds as each-other if that 'rarity' is picked.","Answer:","Neat!") end

    btn = faqcol:Add("How is 'Rarity Descending' different from normal RNG?")
    btn.DoClick = function() Derma_Message("The calculations for odds are slightly different. With 'Normal' RNG, the odds of getting any one item can be described as its weight over the sum of all weights as a percentage.\nWith 'Rarity Descending' the odds can be described as the odds to roll that tier over the number of items in that tier.\nBecause 'Weight' can be hidden in code, but you can always just count how many things have the same percent, the creator prefers Rarity Descending.\nAt the end of the day though, it's basically luck of the draw.","Answer:","Neat!") end

    btn = faqcol:Add("Why is everything errors.")
    btn.DoClick = function() Derma_Message("Firstly, it might be loading models, just give your game a second. If it stays errors, you're missing content.\nWhile content normally autodownloads, sometimes it fails. You can subscribe to the collection with id '3463787282' on the workshop or 'retry' in console.\nRestarting your game after the previous may also fix any issues with missing content, as well as either owning CS:S or having its assets for Gmod to load.","Answer:","Ok!") end
    local invcol = vgui.Create("DCollapsibleCategory",self)
    invcol:Dock(TOP)
    invcol:SetLabel("Inventory")
    invcol:DoExpansion(false)

    btn = invcol:Add("What is my inventory?")
    btn.DoClick = function() Derma_Message("Your inventory is the tab named 'Inventory' in your 'Loadout' tab, there is also the 'Drops' tab, which has anything you recently obtained, and the 'Storage' tab, which are basically extra inventory pages.\nAny Items you obtain are first sent to your 'Drops' tab in 'Loadout'. They will be deleted forever if they reach the end and you drop something new, so if you want to keep them, move them to your 'Inventory'!\nYou can rename 'Storage' tabs as you please, and get more by consuming the currency 'Golden Coin'","Answer:","Ok!") end

    btn = invcol:Add("How do I equip things?")
    btn.DoClick = function() Derma_Message("You equip things by simply right-clicking them in your inventory and hitting the 'equip' button. A ghost copy will automatically be put in the correct slot.\nIf you want NOTHING in that slot, you can always 'Unequip' the ghost item.","Answer:","Ok!") end

    btn = invcol:Add("How long do things stay in my inventory?")
    btn.DoClick = function() Derma_Message("Items in your inventory will not leave your inventory unless you destroy or trade them.\nItems in your drops tab will be removed when they reach the bottom rightmost slot and you drop a new item. Move items you want to keep to your inventory!","Answer:","Ok!") end

    btn = invcol:Add("How do I get more equipment/guns?")
    btn.DoClick = function() Derma_Message("The main method is simply playing rounds to get end-round crates. You can open them for weapons.\nTrade and events may be other viable options.","Answer:","Ok!") end

    btn = invcol:Add("How do I get more inventory?")
    btn.DoClick = function() Derma_Message("There is only one method, using a 'Golden Coin' will give you 1 extra page of inventory.\nYou can do this as much as you like,but they are rather rare, and have other uses, like crafting.","Answer:","Ok!") end

    local currcol = vgui.Create("DCollapsibleCategory",self)
    currcol:Dock(TOP)
    currcol:SetLabel("Currency")
    currcol:DoExpansion(false)

    btn = currcol:Add("What are Currencies?")
    btn.DoClick = function() Derma_Message("Currencies are items that are identical enough to stack and go into their own tab for easy storage.\nThere are 3 types, Modify, Unbox, and Other. With each type going into their own tab.\nCurrencies in 'Modify' will do something when picked up and placed onto a weapon or item!","Answer:","Ok!") end

    btn = currcol:Add("How do I use Currencies?")
    btn.DoClick = function() Derma_Message("You can use 'Modify' currencies by clicking to pick them up, and clicking them on a weapon to use them.\nHolding 'Shift' while doing so will keep the currency selected for use again.\nCurrency in 'Unbox' and 'Other' simply need clicked on.","Answer:","Ok!") end

    btn = currcol:Add("How do I get Currencies?")
    btn.DoClick = function() Derma_Message("Currencies will spawn as small floating icons on the map during rounds. Performing well in rounds may spawn more.\nCurrencies will persist between rounds, and into the next map, but no further!\nTo collect them, just walk into them, they will be put into your inventory.","Answer:","Ok!") end

    btn = currcol:Add("How do I know when I get something rare?")
    btn.DoClick = function() Derma_Message("When a rare currency spawns, you will recieve a message in chat, with a color indicating what rare currency might have spawned.\nRemember currency will last the remaining rounds of the map,and all of the next map, so don't feel rushed!","Answer:","Ok!") end

    btn = currcol:Add("How much is 'X' worth?")
    btn.DoClick = function() Derma_Message("Well, thats a hard question, value is subjective. All trade is done with barter, as there is no 'money' per say.\nAt the end of the day, good traders will walk away with both sides satisfied and feeling richer,remember that.","Answer:","Ok!") end
    
    local weapcol = vgui.Create("DCollapsibleCategory",self)
    weapcol:Dock(TOP)
    weapcol:SetLabel("Weapons")
    weapcol:DoExpansion(false)

    btn = weapcol:Add("What are Weapon Mods?")
    btn.DoClick = function() Derma_Message("Weapon mods are modifiers on your weapons that alter their base stats in some way. A lower number is more 'Pure' or 'Better'.\nWeapon mods come in three types,'Implicit','Prefix',and'Suffix', each with their own archetype.","Answer:","Ok!") end
    
    btn = weapcol:Add("What are Implicit Mods?")
    btn.DoClick = function() Derma_Message("Implicit mods are mods that are gained by crafting or are otherwise built into the gun 'from the start'.\nThey are special, and are not generally removable or modifyable,and commonly obtained via crafting.","Answer:","Ok!") end

    btn = weapcol:Add("What are Prefix Mods?")
    btn.DoClick = function() Derma_Message("Prefix mods are things that directly affect weapon stats. Damage, RPM, the likes.\nYou can only ever have up to three on a weapon, no matter what.\nWhile they do raise one stat, they will lower an opposing stat slightly, but to a much lesser degree.","Answer:","Ok!") end

    btn = weapcol:Add("What are Suffix Mods?")
    btn.DoClick = function() Derma_Message("Suffix mods are mods that indirectly affect your combat ability. Ignite your enemies, see currencies through walls, and more!\nYou can have as many of these as you have mod slots on your weapon availible,there is no inherent 'cap', but they do not stack.","Answer:","Ok!") end

    btn = weapcol:Add("How many mods can I have on a weapon?")
    btn.DoClick = function() Derma_Message("Every weapon has a different number of mod slots, but you can only ever have up to 3 Prefix's.\nIf you find a weapon you like, you can always try to get a higher tier of it for more mods!\nThe highest tier shards currently have capacity for 6 mods.","Answer:","Ok!") end

    btn = weapcol:Add("How do I craft a weapon?")
    btn.DoClick = function() Derma_Message("The first step is to get 3 weapon shards, obtained at 50% chance when destroying weapons.\nYou can then combine three of any shards in the craft tab to make a new random weapon.\nThere is also a single slot to add a currency, which may add an implicit to the resulting item.\nLastly,there are four slots to sacrifice specific weapons, to make that weapon more, or less, likely to be the result.","Answer:","Ok!") end

    btn = weapcol:Add("How exactly do crafted weapons work?")
    btn.DoClick = function() Derma_Message("A crafted weapon will take the mod capacity of one shard, the traits of another, and nothing in particular of the third.\n The color will be a blend of all three, but the order of the shards does not matter, it is random which contributes what.","Answer:","Ok!") end

    btn = weapcol:Add("What are weapon constellations?")
    btn.DoClick = function() Derma_Message("Weapon Constellations are similar to weapon mods, but require EXP from gun use to unlock.\nOnce unlocked with stardust, you pick the two constellation groups that are adjacent with the arrows to unlock.\nIf you decide you don't like any, or want to change them later, you can re-roll them, but you wont be refunded for any nodes unlocked.","Answer:","Ok!") end

    btn = weapcol:Add("What rarities are worth holding onto?")
    btn.DoClick = function() Derma_Message("Every rarity has a purpose. For crafting, ideally you want high mod capacity.\nShards of 4+ mods are considered semi-valuable, and might be worth holding onto.\nOtherwise, any weapon you like really!","Answer:","Ok!") end

    local gamercol = vgui.Create("DCollapsibleCategory",self)
    gamercol:Dock(TOP)
    gamercol:SetLabel("Gamemodes - Raids")
    gamercol:DoExpansion(false)

    btn = gamercol:Add("What are Raids?")
    btn.DoClick = function() Derma_Message("Raids are a gamemode activatable when there are few players on the server. During a raid, all players are on the same team.\nWaves of enemies will spawn somewhere on the map, and make their way to the nearest player in attempt to defeat them.\nThe players goal is to eliminate the increasing amount of enemies until the raid is 'cleared'.","Answer:","Ok!") end

    btn = gamercol:Add("Why should I do Raids?")
    btn.DoClick = function() Derma_Message("Simple, rewards. Killing enemies in a Raid and progressing in them gives rewards similar to playing rounds of TTT.\nYou can also do Raids alone, or while waiting for more people to play TTT.","Answer:","Ok!") end
    
    btn = gamercol:Add("How do I start a raid?")
    btn.DoClick = function() Derma_Message("The command 'votegm' allows players to vote between playing TTT or Raids.\nFor performance reasons, you can only do Raids when there are less than a certain number of people on.","Answer:","Ok!") end

end
vgui.Register("pluto_inventory_other_info", PANEL, "EditablePanel")
