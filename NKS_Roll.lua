-- Ni Karma System (NKS) for raid loot distribution
-- The Ni Karma System was designed by Vuelhering (stef+nks @swcp.com) and Qed of Icecrown
-- 
-- Plugin coded by Mavios of Icecrown (althar @gmail.com).  Thanks Mavios, you rock.
-- Code maintenance and additional programming by Mavios and Vuelhering
-- Instructions for use at http://www.knights-who-say-ni.com/NKS
-- 
-- Copyright 2006-2009, Mavios and Vuelhering, Knights who say Ni, Icecrown
-- 
-- Permission granted for use, modification, and distribution provided:
-- 1. Any distributions include the original distribution in its entirety, OR a working URL to freely get the entire original distribution is clearly listed in the documentation.
-- 2. Any modified distributions clearly mark YOUR changes, or document the changes somehow.
-- 3. Any modified distributions MUST NOT imply in any way that it is an official upgrade version of this software (such as NKS+ or Enhanced Karma System, or probably anything with "NKS" or "Karma" in the name).  If you want your changes in the official distribution, write (stef+nks @swcp.com) and it might get included.
-- 4. No fee is charged for any distribution of this software (modified or original).
-- 
-- Snippets of code "borrowed" (fewer than 100 total lines) can merely include the URL http://www.knights-who-say-ni.com/NKS and credit for the code used.


---------------------------------------
----    Karma Roll Window Routines ----
---------------------------------------
function KarmaRoll_OnLoad()
    this:RegisterEvent("ADDON_LOADED"); 
    this:RegisterEvent("CHAT_MSG_SYSTEM"); 
    this:RegisterEvent("CHAT_MSG_WHISPER"); 

    hooksecurefunc("HandleModifiedItemClick", KarmaLootItem_OnClick)
    hooksecurefunc("SetItemRef", Karma_SetItemRef) 
end

-- Main event handler
function KarmaRoll_OnEvent(event)

    if (event == "ADDON_LOADED") then
	KarmaRollFrameItem:SetText("");
	KarmaRollFrameBaseCost:SetText("0");
	KarmaRollFrameBaseCost:SetNumeric(1);
	KarmaRollFrameFinalKarma:SetText("0");
	KarmaRollFrameFinalKarma:SetNumeric(1);

    elseif (nks.Active and event == "CHAT_MSG_WHISPER") then
	local cmd, extra = Karma_GetToken(arg1);
	cmd = Karma_StripTok(cmd);
	local cmd2, extra2 = Karma_GetToken(extra);
	cmd2 = Karma_StripTok(cmd2);
	if (cmd == nks.KMSG.BONUS or cmd == nks.KMSG.NOBONUS or (cmd == nks.KMSG.NOBONUS1 and cmd2 == nks.KMSG.NOBONUS2)) then
	    KarmaRoll_AddPlayer(arg2, cmd == nks.KMSG.BONUS);
	end
    elseif (nks.Active and event == "CHAT_MSG_SYSTEM" and string.find(arg1, nks.KMSG.SYS.ROLLS) and string.find(arg1, "%(1%-100%)")) then 
	_, _, player_name, player_roll = string.find(arg1, "(.+) " .. nks.KMSG.SYS.ROLLS .. " (%d+)");
	if (player_name ~= nil and player_roll ~= nil) then
	    KarmaRoll_Roll(player_name, player_roll);
	end
    end 
end


-- A player declared intention to roll, add them to list
function KarmaRoll_AddPlayer(player_name, use_bonus)
    local player, fullname, class = Karma_Getstats(player_name);

    if (KarmaList[Raid_Name][player] == nil) then
	-- Add player to system
	Karma_Newplayer(player);
    end

    -- Check if they are already in list  
    for i=1, #(nks.RollList) do
	if (nks.RollList[i][1] == fullname) then
	    if (nks.RollList[i][4] > 0) then
		Karma_message(nks.KMSG.PLAYER .. fullname .. nks.KMSG.ROLLED .. tostring(nks.RollList[i][4]) .. nks.KMSG.REROLLED);
	    end
	    table.remove(nks.RollList, i);
	    break;
	end
    end

    if (class) then
	-- Player is in the raid if we found their class
	if (KarmaList[Raid_Name][player]["points"] < 0) then
	    use_bonus = true; -- always bonus if you're negative muahhaa
	end

	table.insert(nks.RollList, {fullname, class, 0, 0, 0, use_bonus});
	if (not nks.OpenRoll) then
	    if (use_bonus) then
		Karma_message(nks.KMSG.REPLYBONUS1 .. KarmaList[Raid_Name][player]["points"] .. nks.KMSG.REPLYBONUS2, nks.KARMA_SHOWTO_PLAYER, player);
	    else
		Karma_message(nks.KMSG.REPLYNOBONUS, nks.KARMA_SHOWTO_PLAYER, player);
	    end
	end
	KarmaRollList_Update();

    else
	Karma_message(nks.KMSG.PLAYER .. player_name .. nks.KMSG.NOTINRAID);
    end
end

-- A /roll was detected, update the list if they are in it

function KarmaRoll_Roll(player_name, player_roll)
    local player=string.lower(player_name);
-- If it's an open (no bonus declaration required) roll then add them to the list when they /roll
    if (nks.OpenRoll) then
	if (KarmaList[Raid_Name][player] == nil) then
	    Karma_Newplayer(player_name);
	end
	KarmaRoll_AddPlayer(player_name, false)
    end

    for i=1, #(nks.RollList) do
	if (string.lower(nks.RollList[i][1]) == player) then
	    if (nks.RollList[i][4] > 0) then
		Karma_message(nks.KMSG.PLAYER .. player_name .. nks.KMSG.ROLLED .. tostring(nks.RollList[i][4]) .. nks.KMSG.REROLLED);
	    else
		nks.RollList[i][4] = tonumber(player_roll);
	    end
	    nks.RollList[i][5] = nks.RollList[i][3] + nks.RollList[i][4];
	    break;
	end
    end

    KarmaRollList_Update();
end

-- Sort the rolls
function KarmaRoll_Sort(a, b)
    if (a[5] == b[5]) then
      return (a[1] < b[1]);
    else
      return (a[5] > b[5]);
    end;
end

-- Update the display
function KarmaRollList_Update()

    local rollOffset = FauxScrollFrame_GetOffset(KarmaRollScrollFrame);
    local base_cost = tonumber(KarmaRollFrameBaseCost:GetText());
    if (base_cost == nil) then
	base_cost = 0;
    end

    local numRolls = #(nks.RollList);
    local min_deduction = KarmaConfig["MIN_KARMA_NONCLASS_DEDUCTION"];
    local max_deduction = KarmaConfig["MAX_KARMA_NONCLASS_DEDUCTION"];

    --  (RollList, {player_name, class, karma_used, 0, karma_used, use_bonus});

    -- "nobonus" will use 2 * base cost of the item.  It will also force using bonus if
    -- your karma is less than this value, since it'll cost you anyway.
    -- ex: you have 20 pts on a 25-point class item.  It will force you to use bonus of 20 pts no matter what.
    -- ex: you have 120 pts, nobonusing on a 25-point class item.  It will use 50 karma (or 2x the min cost).
    -- ex: you have 120 pts, nobonusing a non-class item.  It will use 0 karma.

    for i=1, numRolls do
	local player,karma_used,use_bonus = nks.RollList[i][1], nks.RollList[i][3], nks.RollList[i][6];
	player = string.lower(player);
	if (nks.OpenRoll) then
	    karma_used = 0;
	elseif (use_bonus) then
	    karma_used = KarmaList[Raid_Name][player]["points"];
	else
	    karma_used = min(2 * base_cost , KarmaList[Raid_Name][player]["points"]);
	end

	nks.RollList[i][3] = karma_used;
	nks.RollList[i][5] = nks.RollList[i][3] + nks.RollList[i][4];
    end
    
    table.sort(nks.RollList, KarmaRoll_Sort);
    
    for i=1, nks.ROLLS_TO_DISPLAY do
	local rollIndex = rollOffset + i;
	button = getglobal("KarmaRollFrameButton"..i);
	button.rollIndex = rollIndex;
	local roll_info = nks.RollList[rollIndex];
	if (roll_info ~= nil) then
	    getglobal("KarmaRollFrameButton"..i.."Name"):SetText(roll_info[1]);
	    getglobal("KarmaRollFrameButton"..i.."Class"):SetText(roll_info[2]);
	    getglobal("KarmaRollFrameButton"..i.."Karma"):SetText(roll_info[3]);
	    getglobal("KarmaRollFrameButton"..i.."Roll"):SetText(roll_info[4]);
	    getglobal("KarmaRollFrameButton"..i.."Total"):SetText(roll_info[5]);
	end

	-- Lock the highlight if a roller is selected
	if ( KarmaRollFrame.selectedRoller == rollIndex ) then
	    button:LockHighlight();

	-- Here are the guts: divide the karma by 2
	-- (and drop fractions to the nearest rounding value)
	-- This is the BASIS of the zero-sum property
	    local final_value = ceil(roll_info[3] / 2 / KarmaConfig["KARMA_ROUNDING"]) * KarmaConfig["KARMA_ROUNDING"];
	    local base_cost = tonumber(KarmaRollFrameBaseCost:GetText());
	    if (base_cost == nil) then
		base_cost = 0;
	    end
	    if (final_value < base_cost) then
		KarmaRollFrameFinalKarma:SetText(base_cost);
	    else
		if (max_deduction > 0 and max_deduction < final_value) then
		    final_value = max_deduction;
		end
		KarmaRollFrameFinalKarma:SetText(final_value);
	    end
	else
	    button:UnlockHighlight();
	end

	if ( rollIndex > numRolls ) then
	    button:Hide();
	else
	    button:Show();
	end
    end  
    
    -- Enable/disable buttons
    if (KarmaRollFrame.selectedRoller ~= nil and KarmaRollFrame.selectedRoller > 0 and
			KarmaRollFrameItem:GetText() ~= "") then
	KarmaRollFrameAwardButton:Enable();
    else
	KarmaRollFrameAwardButton:Disable();
    end
    
    -- ScrollFrame stuff
    FauxScrollFrame_Update(KarmaRollScrollFrame, numRolls, nks.ROLLS_TO_DISPLAY, nks.ROLL_FRAME_ROLL_HEIGHT );

end

-- Generic click handler for roller list
function KarmaRollFrameRollButton_OnClick(button)

    if ( button == "LeftButton" ) then
	KarmaRollFrame.selectedRoller = getglobal("KarmaRollFrameButton"..this:GetID()).rollIndex;
	KarmaRollList_Update();
    else
	-- Remove from list
	local roller = getglobal("KarmaRollFrameButton"..this:GetID()).rollIndex
	table.remove(nks.RollList, roller);

    -- If we removed the last one, move bar up
    if (KarmaRollFrame.selectedRoller > #(nks.RollList)) then
	KarmaRollFrame.selectedRoller = #(nks.RollList);
    end
    KarmaRollList_Update();
  end
  
end

-- Clear the rollers list
function KarmaRollFrame_Clear()
    nks.RollList = {};
    KarmaRollFrame.selectedRoller = 0;
    Karma_Clearitem();
    nks.OpenRoll = false;
    KarmaRollFrameOpenCheckButton:SetChecked(nks.OpenRoll);
    KarmaRollList_Update();
end

-- Declare winner
function KarmaRollFrameAwardButton_OnClick()

    local player = nks.RollList[KarmaRollFrame.selectedRoller][1];
    local value = -tonumber(KarmaRollFrameFinalKarma:GetText());
    if (KarmaRollFrameItem:GetText() == "") then
	-- If adding an item, reason can't be empty, it should contain item link
	Karma_message(nks.KMSG.ADDITEM);
	return;
    end
    Karma_message(player .. nks.KMSG.WINS .. KarmaRollFrameItem:GetText() .. nks.KMSG.USING .. nks.RollList[KarmaRollFrame.selectedRoller][3] .. nks.KMSG.TOTAL .. nks.RollList[KarmaRollFrame.selectedRoller][5] .. " (" .. KarmaRollFrameFinalKarma:GetText() .. nks.KMSG.PAYING .. ")" , nks.KARMA_SHOWTO_RAID);
    Karma_Add_Player(string.lower(player), value, KarmaRollFrameItem:GetText(), "I");
    KarmaRollFrameAwardButton:Disable();

end


function Karma_SetTip(link)
    KarmaTooltip:ClearLines()
    if (link ~= "" and string.match(link, "item:")) then
	KarmaTooltip:SetHyperlink(link)
    end
end


function Karma_SetItemRef(link, text, button)
    Karma_debug(3, "chatlink: link="..link);
    if ( not nks.Active ) then
        return
    end

    if (IsAltKeyDown()) then
	showWoWLoot(link);
    	Karma_SetTip(link);
    	Karma_update_rollframe(KarmaTooltip, text);
    end
end


function KarmaLootItem_OnClick(link)
    Karma_debug(3, "itemclick: link="..link);
    if ( not nks.Active ) then
        return
    end

    if (IsAltKeyDown()) then
	showWoWLoot(link)
    	Karma_SetTip(link)
    	Karma_update_rollframe(KarmaTooltip, link)
    end
end

function showWoWLoot(lootLink)
   -- Get the specs from wow-loot
   SendChatMessage("Bidding is now open for " .. lootLink, "RAID_WARNING")
   if WowLoot then
     local primary, secondary, tertiary = WowLoot:getAllFor(lootLink);
     if primary ~= "" then 
	     Karma_message("Primary - " .. primary, nks.KARMA_SHOWTO_RAID);
	     if secondary ~= "" then 
		     Karma_message("Secondary - " .. secondary, nks.KARMA_SHOWTO_RAID);
	     end
	     if tertiary ~= "" then
		     Karma_message("Tertiary - " .. tertiary, nks.KARMA_SHOWTO_RAID);
	     end
     else
	     Karma_message("The item " .. lootLink .. " is not in the WowLoot database yet");
     end
   end
end

function Karma_SetClassItem(tooltip)
    if (nks.OpenRoll) then
	KarmaRollFrameBaseCost:SetText(0);
    else
	local min_deduction = KarmaConfig["MIN_KARMA_NONCLASS_DEDUCTION"];
	local max_deduction = KarmaConfig["MAX_KARMA_NONCLASS_DEDUCTION"];
	local numlines = tooltip:NumLines();
	for n=1, numlines do
	    local text_field = getglobal(tooltip:GetName().."TextLeft".. n);
	    if (text_field) then
		local item_text = text_field:GetText();
		if (strfind(item_text, nks.KMSG.CLASSES)) then
		    min_deduction = KarmaConfig["MIN_KARMA_CLASS_DEDUCTION"];
		    max_deduction = KarmaConfig["MAX_KARMA_CLASS_DEDUCTION"];
		    break;
		end
	    end
	end
	KarmaRollFrameBaseCost:SetText(min_deduction);
    end
end


function Karma_Clearitem()
    KarmaRollFrameItem:SetText("");
    KarmaRollFrameBaseCost:SetText("0");
    KarmaRollFrameFinalKarma:SetText("0");
    KarmaRollList_Update();
end


function Karma_update_rollframe(tooltip, link)
    Karma_debug(3, "update rollframe: link="..link);	  

    -- there's one goofy bug here, if you have a tooltip up and click a link in chat, this
    -- will not search the tooltip for "Classes:" correctly (as it will hide the tooltip).
    if (string.match(link, "item:") and KarmaRollFrameItem:GetText() == "") then
	Karma_Clearitem();
	Karma_SetClassItem(tooltip);
	KarmaRollFrameItem:SetText(link);
    end
end


function KarmaRoll_OpenToggle()
    nks.OpenRoll = not nks.OpenRoll;
    -- KarmaRollFrameOpenCheckButton.checked = nks.OpenRoll;
    KarmaRollFrameOpenCheckButton:SetChecked(nks.OpenRoll);
end


