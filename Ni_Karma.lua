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
-- The Ni_Karma.toc file is granted to the public domain, so it can be updated without issue.

function Karma_OnLoad(event)

  this:RegisterEvent("ADDON_LOADED"); 
  this:RegisterEvent("CHAT_MSG_WHISPER"); 

  -- add command
  SlashCmdList["KARMA"] = Karma_command;
  SLASH_KARMA1 = "/km";
  SLASH_KARMA2 = "/karma";

  -- Capture chat echos for filtering
  nks.Orig_ChatFrame_OnEvent = ChatFrame_OnEvent;
  ChatFrame_OnEvent = Karma_ChatFrame_OnEvent;
end

-- This function captures the events sent to the WoW chat window
-- We are filtering out 'Karma: ' whisper echos to users
function Karma_ChatFrame_OnEvent(self,event,...)

  local Suppressed = false
  local cmd,extra = Karma_GetToken(arg1);
  cmd = Karma_StripTok(cmd);

  -- Check if enabled
  if (nks.Active) then
    if (event == "CHAT_MSG_WHISPER_INFORM" and string.find(arg1, "KarmaBot: ")
        and (not KarmaConfig["SHOW_WHISPERS"])) then
      Suppressed = true;
     
    elseif (event == "CHAT_MSG_WHISPER" and cmd == "km" 
        and (not KarmaConfig["SHOW_WHISPERS"])) then
      Suppressed = true;

    end
  end

  if (not Suppressed) then
    nks.Orig_ChatFrame_OnEvent(self,event,...);
  end
end

-- Main event handler
function Karma_OnEvent(event)

    Ni_Debug(4,"event recv: "..event)
    if (event == "ADDON_LOADED") then
	Karma_message("Ni Karma System (www.knights-who-say-ni.com/NKS) ".. nks.Version .. nks.KMSG.LOADED);
	Karma_Config();

	if (KarmaConfig["DATAVERSION"] < nks.DataVersion) then
	    -- version conflict with data, needs to be updated!
	    Karma_update_data_popup();
	end
	KarmaConfig["VERSION"] = nks.Version;

	if ni_vars[nks.addon] == nil then
	    ni_vars[nks.addon] = {}
	    ni_vars[nks.addon].prefix = nks.prefix
	    Ni_Print("debug: ni_vars empty?")
	end
	this:UnregisterEvent("ADDON_LOADED")
    end

    if (not nks.Active) then 
	return;
    end
      
    if (event == "CHAT_MSG_WHISPER" and string.lower(string.sub(arg1,1,2)) == "km") then
	local cmd, extra = Karma_GetToken(arg1);
	cmd = Karma_StripTok(cmd);
	    Karma_debug(1, "debug: cmd" .. cmd .. " extra:" .. extra)
	Karma_Player_Request(string.lower(arg2), extra);
    end
end

function Karma_update_data_popup()
	  Karma_message(nks.KMSG.VERMISMATCH1 .. KarmaConfig["DATAVERSION"]);
	  StaticPopup_Show("NKSVERSION");
end

-- Main command routine
function Karma_command(msg)

  if (msg) then
    local cmd, subcmd = Karma_GetToken(msg);
	cmd = Karma_StripTok(cmd);

	-- if out of date, popup conversion if any command is entered
	-- will force reentering command.
    if (KarmaConfig["DATAVERSION"] < nks.DataVersion) then
	  Karma_update_data_popup();
	  return;
	end

    if (cmd == nks.KMSG.CUSE or cmd == nks.KMSG.CCREATE) then
      if (subcmd == "") then
        Karma_message(nks.KMSG.USERAID);
        Karma_Help();
        return;
      end

	  if (cmd == nks.KMSG.CCREATE) then
	    if (KarmaList[subcmd] == nil) then
		  KarmaList[subcmd] = {};
		  Karma_message(nks.KMSG.CREATED .. subcmd .. ")");
		else
		  Karma_message(nks.KMSG.EXISTS);
		end
	  end

	  if (KarmaList[subcmd] == nil) then		-- /km use failed, do nothing
        Karma_message(nks.KMSG.NOTFOUND);
		return;
      end
      Raid_Name = subcmd;
      nks.Active = true;
	  KarmaConfig["CURRENT RAID"] = Raid_Name;
      Karma_message(nks.KMSG.USINGRAID .. Raid_Name .. ")");

    elseif (cmd == "help" or cmd == nks.KMSG.HELP) then
      Karma_Help();

    elseif (cmd ==nks.KMSG.COPTION) then
      Karma_Options(subcmd);
 
    elseif (cmd == nks.KMSG.CCOMPACT) then
      Karma_Compact(subcmd);
      
    elseif (cmd == nks.KMSG.CINFO) then
      if (nks.Active) then
        Karma_message(nks.KMSG.USINGRAID .. Raid_Name .. ")");
      else
        Karma_message(nks.KMSG.DISABLED);
      end
	elseif (cmd == nks.KMSG.CSPAM) then
	  Karma_message(nks.KMSG.SPAM, nks.KARMA_SHOWTO_RAID);
	elseif (not nks.Active or cmd == nks.KMSG.COFF) then
      nks.Active = false;
	  KarmaRollFrame:Hide();
	  KarmaConfig["CURRENT RAID"] = nil;
      Karma_message(nks.KMSG.DISABLED);
--
-- Active raid only at this point
--
    elseif (cmd == nks.KMSG.CROLL) then
      KarmaRollFrame:Show();

    elseif (cmd == nks.KMSG.CSHOW) then
      Karma_Show(subcmd);
      
    elseif (cmd == nks.KMSG.CADD) then
      Karma_Add(subcmd, "P");

    elseif (cmd == nks.KMSG.CADDITEM) then
      Karma_Add(subcmd, "I");

    else
      Karma_Help();

    end 
  end
end

function Karma_Config()
  if (KarmaConfig["VERSION"] == nil) then
    KarmaConfig["VERSION"] = nks.KarmaDefaults.VERSION;
  end
  if (KarmaConfig["SHOW_WHISPERS"] == nil) then
    KarmaConfig["SHOW_WHISPERS"] = nks.KarmaDefaults.SHOW_WHISPERS;
  end
  if (KarmaConfig["NOTIFY_ON_CHANGE"] == nil) then
    KarmaConfig["NOTIFY_ON_CHANGE"] = nks.KarmaDefaults.NOTIFY_ON_CHANGE;
  end
  if (KarmaConfig["MAX_KARMA_CLASS_DEDUCTION"] == nil) then
    KarmaConfig["MAX_KARMA_CLASS_DEDUCTION"] = nks.KarmaDefaults.MAX_KARMA_CLASS_DEDUCTION;
  end
  if (KarmaConfig["MIN_KARMA_CLASS_DEDUCTION"] == nil) then
    KarmaConfig["MIN_KARMA_CLASS_DEDUCTION"] = nks.KarmaDefaults.MIN_KARMA_CLASS_DEDUCTION;
  end
  if (KarmaConfig["MAX_KARMA_NONCLASS_DEDUCTION"] == nil) then
    KarmaConfig["MAX_KARMA_NONCLASS_DEDUCTION"] = nks.KarmaDefaults.MAX_KARMA_NONCLASS_DEDUCTION;
  end
  if (KarmaConfig["MIN_KARMA_NONCLASS_DEDUCTION"] == nil) then
    KarmaConfig["MIN_KARMA_NONCLASS_DEDUCTION"] = nks.KarmaDefaults.MIN_KARMA_NONCLASS_DEDUCTION;
  end
  if (KarmaConfig["ALLOW_NEGATIVE_KARMA"] == nil) then
    KarmaConfig["ALLOW_NEGATIVE_KARMA"] = nks.KarmaDefaults.ALLOW_NEGATIVE_KARMA;
  end
  if (KarmaConfig["KARMA_ROUNDING"] == nil) then
    KarmaConfig["KARMA_ROUNDING"] = nks.KarmaDefaults.KARMA_ROUNDING;
  end
  if (KarmaConfig["DATAVERSION"] == nil) then
    KarmaConfig["DATAVERSION"] = nks.KarmaDefaults.DATAVERSION;
  end
  if (KarmaConfig["LASTUPDATE"] == nil) then
    KarmaConfig["LASTUPDATE"] = nks.KarmaDefaults.LASTUPDATE;
  end
  KarmaConfig["CURRENT RAID"] = nil; -- used to see if active or not
end

function Karma_Default_Config()
    KarmaConfig["VERSION"] = nks.KarmaDefaults.VERSION;
    KarmaConfig["SHOW_WHISPERS"] = nks.KarmaDefaults.SHOW_WHISPERS;
    KarmaConfig["NOTIFY_ON_CHANGE"] = nks.KarmaDefaults.NOTIFY_ON_CHANGE;
    KarmaConfig["MAX_KARMA_CLASS_DEDUCTION"] = nks.KarmaDefaults.MAX_KARMA_CLASS_DEDUCTION;
    KarmaConfig["MIN_KARMA_CLASS_DEDUCTION"] = nks.KarmaDefaults.MIN_KARMA_CLASS_DEDUCTION;
    KarmaConfig["MAX_KARMA_NONCLASS_DEDUCTION"] = nks.KarmaDefaults.MAX_KARMA_NONCLASS_DEDUCTION;
    KarmaConfig["MIN_KARMA_NONCLASS_DEDUCTION"] = nks.KarmaDefaults.MIN_KARMA_NONCLASS_DEDUCTION;
    KarmaConfig["ALLOW_NEGATIVE_KARMA"] = nks.KarmaDefaults.ALLOW_NEGATIVE_KARMA;
    KarmaConfig["KARMA_ROUNDING"] = nks.KarmaDefaults.KARMA_ROUNDING;
    KarmaConfig["DATAVERSION"] = nks.KarmaDefaults.DATAVERSION;
    KarmaConfig["LASTUPDATE"] = nks.KarmaDefaults.LASTUPDATE;
end


nks.configpanel.name = "Ni Karma System";
nks.configpanel.okay =
		function (self)
			self.originalValue = MY_VARIABLE;
		end

nks.configpanel.cancel =
		function (self)
			MY_VARIABLE = self.originalValue;
		end

function ConfigPanel_OnLoad (panel)
    local subpanel = CreateFrame("FRAME","Ni Karma System");
  -- panel = CreateFrame("FRAME", "ConfigPanel");
    panel.name = nks.configpanel.name;
    panel.okay = nks.configpanel.okay;
    panel.cancel = nks.configpanel.cancel;
    panel.defaults = Karma_Default_Config;

	subpanel.name = "test subpanel"

    InterfaceOptions_AddCategory(panel);
end 



function Karma_Help()
  Karma_message(nks.KMSG.HELP1 .. nks.Version);
  Karma_message(nks.KMSG.HELP2);
  Karma_message(nks.KMSG.HELP3);
end

function Karma_Player_Help(player)
  Karma_message(nks.KMSG.PLAYER_HELP1, nks.KARMA_SHOWTO_PLAYER, player);
  Karma_message(nks.KMSG.PLAYER_HELP2, nks.KARMA_SHOWTO_PLAYER, player);
  Karma_message(nks.KMSG.PLAYER_HELP3, nks.KARMA_SHOWTO_PLAYER, player);
end

-- returns classname stored in db.  This is non-localized.
function Karma_GetDBClass(class)
    if class == nil then
        return nil
	end
    return nks.KMSG.CLASS[string.lower(class)]
end

function Karma_Show(cmd)

  if (cmd ~= "") then
    -- Get name and optional TO
    local player, extra = Karma_GetToken(cmd);
	local dbclass = Karma_GetDBClass(player);

    -- Check for class display
    -- Note that this can fail if some imaginative idiot names his character the same as a class.
	-- I check class first, so that it won't break functionality of showing an entire class.
    if (dbclass ~= nil) then

	-- Loop through raid members, showing matching class
      local raidcnt = GetNumRaidMembers();
      for i = 1, raidcnt do
        local name, _, _, _, class = GetRaidRosterInfo(i);
        if (dbclass == Karma_GetDBClass(class)) then
          Karma_Show_Detail(string.lower(name), extra);
        end
      end

    elseif (player == nks.KMSG.ALL) then
      
      -- Loop through all raid members
      local raidcnt = GetNumRaidMembers();
      for i = 1, raidcnt do
        local name, _, _, _, _ = GetRaidRosterInfo(i);
        Karma_Show_Detail(string.lower(name), extra);
      end
      
    else
      Karma_Show_Detail(player, extra);
    end

  else
    Karma_message(nks.KMSG.BADCOMMAND);
    Karma_Help();
  end
end


-- return lowercase name/index, name as seen, and class
-- if not found in raid but found in db, return name/name/class
-- if not found in raid or db, return name/name/unknown
function Karma_Getstats(player_name)
  player = string.lower(player_name);  -- index is lowercase

  local fullname, class, i, dbclass;
  local raidcnt = GetNumRaidMembers();
  for i = 1, raidcnt do
    fullname, _, _, _, class = GetRaidRosterInfo(i);
	dbclass = Karma_GetDBClass(class)
	if (dbclass == nil) then
	  dbclass = nks.class_broken
    end
    if (string.lower(fullname) == player) then 
      return player, fullname, class;
    end
  end
  if (KarmaList[Raid_Name][player] ~= nil) then
	  return player, KarmaList[Raid_Name][player].fullname, KarmaList[Raid_Name][player].class
  end
  return player, player, nks.class_unknown;
end


function Karma_Newplayer(player_name)
  if (not nks.Active) then
    return;
  end
  local player, fullname, class = Karma_Getstats(player_name);
  local dbclass = Karma_GetDBClass(class);

  if (KarmaList[Raid_Name][player] ~= nil) then
	  Karma_message("Error in Karma_Newplayer - player " .. player .. " exists!");
	  return;
  end
  if (dbclass == nil) then
      dbclass = nks.class_broken
  end
  KarmaList[Raid_Name][player] = {};
  KarmaList[Raid_Name][player]["fullname"] = fullname;
  KarmaList[Raid_Name][player]["class"] = dbclass
  KarmaList[Raid_Name][player]["points"] = 0;
  KarmaList[Raid_Name][player]["lifetime"] = 0;
  KarmaList[Raid_Name][player]["lastadd"] = date();
  Karma_debug(1, "added " .. player .. " as " .. fullname .. "/" .. dbclass .. "(" .. class .. ")");
end


function Karma_Show_Detail(player, msg)

  local ShowTo = 0;

  if (KarmaList[Raid_Name][player] == nil) then
    Karma_message(nks.KMSG.PLAYER .. player .. nks.KMSG.NOHISTORY);
    return;
  end

  -- process command string
  local cmd, extra = Karma_GetToken(msg);

  if (cmd == "") then
    cmd = nks.KMSG.KARMA;
  elseif (cmd == "to") then
    cmd = nks.KMSG.KARMA;
    ShowTo = nks.KARMA_SHOWTO_PLAYER;
  elseif (cmd == "rd") then
    cmd = nks.KMSG.KARMA;
    ShowTo = nks.KARMA_SHOWTO_RAID;
  end
  if (extra == "to") then
    ShowTo = nks.KARMA_SHOWTO_PLAYER;
  elseif (extra == "rd") then
    ShowTo = nks.KARMA_SHOWTO_RAID;
  end

  -- perform command    
  if (cmd == nks.KMSG.KARMA) then
    Karma_SendTotal(player, ShowTo)

  elseif (cmd == nks.KMSG.ITEMS) then
    for id, event in pairs(KarmaList[Raid_Name][player]) do
      if (tonumber(id) and event["type"] == "I") then
        Karma_message("[".. event["DT"] .. "] " .. KarmaList[Raid_Name][player]["fullname"] .. ": " .. event["value"] .. nks.KMSG.COST .. event["reason"], ShowTo, player);
      end
    end

  elseif (cmd == nks.KMSG.HISTORY) then
    for id, event in pairs(KarmaList[Raid_Name][player]) do
      if (tonumber(id)) then
        
        Karma_message("[".. event["DT"] .. "] " .. KarmaList[Raid_Name][player]["fullname"] .. ": " .. event["value"] .. nks.KMSG.COST .. event["reason"], ShowTo, player);
      end
    end

    -- Send final total
    Karma_SendTotal(player, ShowTo)
  else
    Karma_message(nks.KMSG.BADCOMMAND);
    Karma_Help();
  end

end

function Karma_SendTotal(player, ShowTo)

  local pts = 0;
  if (KarmaList[Raid_Name][player]["points"] ~= nil) then
    pts = KarmaList[Raid_Name][player]["points"];
  end
      
  if (ShowTo == nks.KARMA_SHOWTO_PLAYER) then
    Karma_message(nks.KMSG.CURRENT1 .. pts, ShowTo, player);
  else
    Karma_message(nks.KMSG.CURRENT2 .. KarmaList[Raid_Name][player]["fullname"] ..": " .. pts, ShowTo, player);
  end
end

function Karma_Add(cmd, add_type)

  if (cmd ~= "") then
    -- Check points
    local pointsstr, extra = Karma_GetToken(cmd); -- do not strip the points token :)

    if (pointsstr == "") then
      Karma_message(nks.KMSG.ADDNOPOINTS1);
      return;
    end

    local points = tonumber(pointsstr);
    if (points == nil) then
      Karma_message(nks.KMSG.ADDNOPOINTS2);
      return;
    end

    -- Get name
    local player, reason = Karma_GetToken(extra);

    if (player == nks.KMSG.ALL) then
      -- Loop through raid members, only add to online players
      local raidcnt = GetNumRaidMembers();
	  local missedout = "";
	  local totalnames=0;
	  for i = 1, raidcnt do
        local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i);
        if (online) then
          Karma_Add_Player(string.lower(name), points, reason, add_type);
        else
		  totalnames = totalnames + 1;
		  if (totalnames > 10) then
			  missedout = missedout .. "\n" .. name;
			  totalnames = 0;
		  else
			  missedout = missedout .. " " .. name;
		  end
        end
      end
      if (missedout ~= "") then
		  Karma_message(nks.KMSG.OFFLINELIST .. missedout);
	  end

    else
      Karma_Add_Player(player, points, reason, add_type);
    end

  else
    Karma_message(nks.KMSG.BADCOMMAND);
    Karma_Help();
  end
end

function Karma_Add_Player(player_name, points, reason, add_type)
        
  if (reason == "" and add_type == "I") then
    -- If adding an item, reason can't be empty, it should contain item link
    Karma_message(nks.KMSG.ADDITEM);
    return;
  end

  if (player_name == nks.KMSG.ALL) then
    Karma_debug(1, "Debug: bad call in Karma_Add_Player");
	return;
  end

  local player, fullname, class = Karma_Getstats(player_name);

  if (KarmaList[Raid_Name][player] == nil) then
	Karma_Newplayer(player);
  else
	-- fix previous errors of them being added while not in raid
    if (fullname ~= nil and fullname ~= "") then
      KarmaList[Raid_Name][player]["fullname"] = fullname;
	  if (KarmaList[Raid_Name][player]["class"] ~= nil
			and KarmaList[Raid_Name][player]["class"] ~= nks.class_unknown
			and KarmaList[Raid_Name][player]["class"] ~= nks.class_broken) then
		KarmaList[Raid_Name][player]["class"] = class;
	  end
    end
  end

  Karma_Mod_Player(player, add_type, points, reason)
end

function Karma_Mod_Player(kplayer, ktype, kvalue, kreason)

  -- Find the last used entry number
  local lastid = 0, data;
  for id, data in pairs(KarmaList[Raid_Name][kplayer]) do
    if (tonumber(id)) then
      if (id > lastid) then
        lastid = id;
      end
    end
  end
  
  -- check if you can go negative
  if ((not KarmaConfig["ALLOW_NEGATIVE_KARMA"]) and (KarmaList[Raid_Name][kplayer]["points"] + kvalue) < 0 and kvalue < 0) then
    kvalue = -KarmaList[Raid_Name][kplayer]["points"];
  end

  -- Increment for new entry
  lastid = lastid + 1;
  KarmaList[Raid_Name][kplayer][lastid] = { };
  KarmaList[Raid_Name][kplayer][lastid]["DT"] = date();
  KarmaList[Raid_Name][kplayer][lastid]["type"] = ktype;
  KarmaList[Raid_Name][kplayer][lastid]["value"] = kvalue;
  KarmaList[Raid_Name][kplayer][lastid]["reason"] = kreason;

  -- Add to points
  KarmaList[Raid_Name][kplayer]["points"] = KarmaList[Raid_Name][kplayer]["points"] + kvalue;

  -- Add to lifetime karma: all point add/subtracts, but not item subtracts (spending karma)
  if (ktype == "P") then
	KarmaList[Raid_Name][kplayer]["lifetime"] = KarmaList[Raid_Name][kplayer]["lifetime"] + kvalue;
  end

  -- Notify self and the player
  local addsub = nks.KMSG.ADDED;
  if (kvalue < 0) then
    addsub = nks.KMSG.DEDUCTED;
    kvalue = abs(kvalue);
  else
	KarmaList[Raid_Name][kplayer]["lastadd"] = date();
  end

  local msg = kvalue .. addsub .. kreason;
  Karma_message(kplayer ..": ".. msg);
  if (KarmaConfig["NOTIFY_ON_CHANGE"]) then
    Karma_message(msg, nks.KARMA_SHOWTO_PLAYER, kplayer);
  end
end


function Karma_Options(cmd)
  if (cmd ~= "") then
    -- Get option name and value
    local opt, setting = Karma_GetArgument(cmd);

    if (opt == "show") then
      if (KarmaConfig["SHOW_WHISPERS"]) then
        Karma_message(nks.KMSG.SHOW_WHISPERS .. " = " .. nks.KMSG.ON);
      else
        Karma_message(nks.KMSG.SHOW_WHISPERS .. " = " .. nks.KMSG.OFF);
      end
      if (KarmaConfig["NOTIFY_ON_CHANGE"]) then
        Karma_message(nks.KMSG.NOTIFY_ON_CHANGE .. " = " .. nks.KMSG.ON);
      else
        Karma_message(nks.KMSG.NOTIFY_ON_CHANGE .. " = " .. nks.KMSG.OFF);
      end
      if (KarmaConfig["ALLOW_NEGATIVE_KARMA"]) then
        Karma_message(nks.KMSG.ALLOW_NEGATIVE_KARMA .. " = " .. nks.KMSG.ON);
      else
        Karma_message(nks.KMSG.ALLOW_NEGATIVE_KARMA .. " = " .. nks.KMSG.OFF);
      end
      Karma_message(nks.KMSG.MIN_KARMA_CLASS_DEDUCTION .. " = " .. KarmaConfig["MIN_KARMA_CLASS_DEDUCTION"]);
      Karma_message(nks.KMSG.MAX_KARMA_CLASS_DEDUCTION .. " = " .. KarmaConfig["MAX_KARMA_CLASS_DEDUCTION"]);
      Karma_message(nks.KMSG.MIN_KARMA_NONCLASS_DEDUCTION .. " = ".. KarmaConfig["MIN_KARMA_NONCLASS_DEDUCTION"]);
      Karma_message(nks.KMSG.MAX_KARMA_NONCLASS_DEDUCTION .. " = ".. KarmaConfig["MAX_KARMA_NONCLASS_DEDUCTION"]);
      Karma_message(nks.KMSG.KARMA_ROUNDING .. " = ".. KarmaConfig["KARMA_ROUNDING"]);
      return;
    end

    if (opt == "" or setting == "") then
      Karma_message(nks.KMSG.BADCOMMAND);
      Karma_Help();

    else
      opt = string.upper(opt);
      -- Check if option exists
      if (KarmaConfig[opt] ~= nil) then
        -- It does, change setting
        if (opt == nks.KMSG.SHOW_WHISPERS) then
          KarmaConfig[opt] = (string.upper(setting) == nks.KMSG.ON);

        elseif (opt == nks.KMSG.NOTIFY_ON_CHANGE) then
          KarmaConfig[opt] = (string.upper(setting) == nks.KMSG.ON);

        elseif (opt == nks.KMSG.ALLOW_NEGATIVE_KARMA) then
          KarmaConfig[opt] = (string.upper(setting) == nks.KMSG.ON);

        elseif (opt == nks.KMSG.MIN_KARMA_CLASS_DEDUCTION) then
          KarmaConfig[opt] = tonumber(setting);

        elseif (opt == nks.KMSG.MAX_KARMA_CLASS_DEDUCTION) then
          KarmaConfig[opt] = tonumber(setting);

        elseif (opt == nks.KMSG.MIN_KARMA_NONCLASS_DEDUCTION) then
          KarmaConfig[opt] = tonumber(setting);

        elseif (opt == nks.KMSG.MAX_KARMA_NONCLASS_DEDUCTION) then
          KarmaConfig[opt] = tonumber(setting);

        elseif (opt == nks.KMSG.KARMA_ROUNDING) then
          KarmaConfig[opt] = tonumber(setting);

        end
        
      else
        Karma_message(nks.KMSG.BADOPTION);
        Karma_Help();
      end
    end
    
  else
    Karma_message(nks.KMSG.BADCOMMAND);
    Karma_Help();
  end
end

function Karma_Player_Request(player, cmdline)

    if (KarmaList[Raid_Name][player] == nil) then
	Karma_message(nks.KMSG.NORECORD, nks.KARMA_SHOWTO_PLAYER, player);
	return;
    end

    if (cmdline ~= "") then
	local cmd, cmd1, cmd2, extra;
	cmd, extra = Karma_GetToken(cmdline);
	cmd1,extra = Karma_GetToken(extra);
	cmd2,extra = Karma_GetToken(extra);

	cmd = Karma_StripTok(cmd)
	cmd1 = Karma_StripTok(cmd1)
	cmd2 = Karma_StripTok(cmd2)

	Karma_debug(1, "debug (player_request): " .. cmd .. "+" ..
					cmd1 .. "+" .. cmd2 .. "+e="..extra);

--  km show [karma [<class in raid>|<player in raid>]] | km show history | km show items [class] | km help

--	Figure out player and target for remote command
	if (cmd == nks.KMSG.CSHOW) then
	    if (cmd1 == "") then
		Karma_Player_Request_Cmd(player, player, nks.KMSG.KARMA, cmd2)
	    elseif (cmd1 == nks.KMSG.KARMA or cmd1 == nks.KMSG.ITEMS) then
		if (cmd2 == "") then
		    Karma_Player_Request_Cmd(player, player, cmd1, cmd2)
		else
		    -- km show karma <something>
		    -- look through raid for a class or name
		    Karma_debug(3, "searching raid for " .. cmd2);
		    local raidcnt = GetNumRaidMembers();
		    for i = 1, raidcnt do
			local name, _, _, _, class = GetRaidRosterInfo(i);
			local dbclass = Karma_GetDBClass(class);
			if dbclass == nil then
			    dbclass = nks.class_broken
			end
			if (Karma_GetDBClass(cmd2) == dbclass or cmd2 == string.lower(name)) then
			    Karma_Player_Request_Cmd(player, string.lower(name), cmd1, cmd2)
			end
		    end
		end
	    elseif (cmd1 == nks.KMSG.HISTORY) then
		Karma_Player_Request_Cmd(player, player, cmd1, cmd2)
	    end
	elseif (cmd == "help" or cmd == nks.KMSG.HELP) then
	    Karma_Player_Help(player);
	else
	    Karma_message(nks.KMSG.BADCOMMAND, nks.KARMA_SHOWTO_PLAYER, player);
	    Karma_Player_Help(player);
	end
    end
end


function Karma_Player_Request_Cmd(player, target, cmd1, cmd2)
  Karma_debug(2, "debug (player_req_cmd): "..player.. "+" .. target .. "+" .. cmd1 .. "+" .. cmd2);

  if (KarmaList[Raid_Name][target] == nil) then
    Karma_message(target .. nks.KMSG.NOHISTORY, nks.KARMA_SHOWTO_PLAYER, player);
	return;
  end

  if (cmd1 == nks.KMSG.KARMA) then
    local pts = 0;
    if (KarmaList[Raid_Name][target] ~= nil) then
      pts = KarmaList[Raid_Name][target]["points"];

      if (player ~= target) then
        Karma_message(nks.KMSG.CURRENT2 .. KarmaList[Raid_Name][target]["fullname"] ..": " .. pts, nks.KARMA_SHOWTO_PLAYER, player);
      else
        Karma_message(nks.KMSG.CURRENT1 .. pts, nks.KARMA_SHOWTO_PLAYER, player);
      end
    end

  elseif (cmd1 == nks.KMSG.HISTORY) then
	-- show only last 10, to prevent spamming (and logouts)
    local firstid, lastid=0;
    if (KarmaList[Raid_Name][target] ~= nil) then
	  lastid = #(KarmaList[Raid_Name][target])
    end

    if (lastid < 10) then
      firstid = 1;
    else
      firstid = lastid - 9;
    end

    if (player == target) then	-- not possible to get history of others (yet)
      Karma_message(nks.KMSG.RECENT1, nks.KARMA_SHOWTO_PLAYER, player);
    else
      Karma_message(nks.KMSG.RECENT2 .. KarmaList[Raid_Name][target]["fullname"]..":", nks.KARMA_SHOWTO_PLAYER, player);
    end

    for id = firstid, lastid do
      local event = KarmaList[Raid_Name][target][id]
      if event then
        if (tonumber(id)) then      
          if (player ~= target) then   
            Karma_message(KarmaList[Raid_Name][target]["fullname"] ..": [".. event["DT"] .. "] " .. event["value"] .. nks.KMSG.COST .. event["reason"], nks.KARMA_SHOWTO_PLAYER, player);
          else
            Karma_message(nks.KMSG.YOU .. ": [".. event["DT"] .. "] " .. event["value"] .. nks.KMSG.COST .. event["reason"], nks.KARMA_SHOWTO_PLAYER, player);
          end
        end
      end
    end

  elseif (cmd1 == nks.KMSG.ITEMS) then
    for id, event in pairs(KarmaList[Raid_Name][target]) do
      if (tonumber(id) and event["type"] == "I") then
        if (player ~= target) then   
          Karma_message(KarmaList[Raid_Name][target]["fullname"] ..": [".. event["DT"] .. "] " .. event["value"] .. nks.KMSG.COST .. event["reason"], nks.KARMA_SHOWTO_PLAYER, player);
        else
          Karma_message(nks.KMSG.YOU .. ": [".. event["DT"] .. "] " .. event["value"] .. nks.KMSG.COST .. event["reason"], nks.KARMA_SHOWTO_PLAYER, player);
        end
      end
    end

  else
    Karma_message(nks.KMSG.BADSHOW, nks.KARMA_SHOWTO_PLAYER, player);
    Karma_Player_Help(player);
  end
end


-- return #sec of day   "07/18/06 20:24:20"
function Karma_convdate(sdate)
    local yr = tonumber(string.sub(sdate, 7, 8)) + 2000;
    local t= time({year=yr,month=string.sub(sdate, 1, 2),day=string.sub(sdate, 4, 5), hour=string.sub(sdate, 10, 11), min=string.sub(sdate, 13, 14), sec=string.sub(sdate, 16, 17)});
	return t;
end

-- Sort by date comparitor function
-- could be off by an hour if DST is on, but that's no big deal for sorting.
-- Time is relative :)
function KarmaList_Sort(a, b)
	if (not a) then
		return false;
	elseif (not b) then
		return true;
	else
		return (Karma_convdate(a.DT) < Karma_convdate(b.DT));
	end
end

function Karma_Compact(cmd)
  if (cmd ~= "") then
    -- Get option name and value
    local days = tonumber(cmd);

    for rname, rdata in pairs(KarmaList) do
	  Karma_message(nks.KMSG.COMPACTING .. rname);
      for player, pdata in pairs(KarmaList[rname]) do
        -- Add totals entry if it doesn't exist
        if (KarmaList[rname][player][0] == nil) then
          KarmaList[rname][player][0] = { };
          KarmaList[rname][player][0]["type"] = "P";
          KarmaList[rname][player][0]["value"] = 0;
          KarmaList[rname][player][0]["reason"] = nks.KMSG.OLDENTRIES;
        end
        KarmaList[rname][player][0]["DT"] = date();

        for id, data in pairs(KarmaList[rname][player]) do
          if (tonumber(id)) then
            if (id > 0) then
              local sdate = Karma_convdate(KarmaList[rname][player][id]["DT"]);
              local diff = (time() - sdate) / 86400;
              if ((KarmaList[rname][player][id]["type"] == "P") and (diff > days)) then
                KarmaList[rname][player][0]["value"] = KarmaList[rname][player][0]["value"] + KarmaList[rname][player][id]["value"];
                KarmaList[rname][player][id] = nil;
              end
            end
          end
        end
		table.sort(KarmaList[rname][player], KarmaList_Sort)
      end
    end
  end

  Karma_message(nks.KMSG.COMPACTED);
end

function Karma_update_data()
  local oldver=KarmaConfig["DATAVERSION"];

  Karma_message(nks.KMSG.UPDATING .. KarmaConfig["DATAVERSION"]);

-- update to version 1
  if (oldver == 0) then
    Karma_recompute_lifetime();
	KarmaConfig["LASTUPDATE"] = date();

    oldver = 1;		-- now using version 1
    KarmaConfig["DATAVERSION"] = oldver;
  end

-- update to version 2
  if (oldver == 1) then
	-- up to date for the moment!
  end

end


function Karma_recompute_lifetime()
  local rname, rdata, player, pdata;

  for rname, rdata in pairs(KarmaList) do
	for player, pdata in pairs(KarmaList[rname]) do
	  -- Add compressed karma entries if they doesn't exist
	  if (KarmaList[rname][player][0] == nil) then
		KarmaList[rname][player][0] = { };
		KarmaList[rname][player][0]["type"] = "P";
		KarmaList[rname][player][0]["value"] = 0;
		KarmaList[rname][player][0]["reason"] = nks.KMSG.OLDENTRIES;
		KarmaList[rname][player][0]["DT"] = date();
	  end

	  if (KarmaList[rname][player]["lastadd"] == nil) then
		KarmaList[rname][player]["lastadd"] = "unknown";
	  end

	  KarmaList[rname][player]["lifetime"] = KarmaList[rname][player][0]["value"];

	  -- compute all the point additions to get lifetime karma
	  for id, data in pairs(KarmaList[rname][player]) do
		if (tonumber(id) and id > 0) then
		  if (KarmaList[rname][player][id]["type"] == "P") then
			KarmaList[rname][player]["lifetime"] = KarmaList[rname][player]["lifetime"] + KarmaList[rname][player][id]["value"];
		  end
		end
	  end
	  table.sort(KarmaList[rname][player], KarmaList_Sort)
	end
  end
end



-- Utility functions
function Karma_message(msg, ...)
-- spit out a message from Karmabot.  Split across newlines.
  local m;
  if (select('#', ...) > 0) then
    if (select('1', ...) == nks.KARMA_SHOWTO_PLAYER) then
      -- This whisper can be filtered out of raid leader's chat
      for m in string.gmatch(msg, "([^\n]*)\n*") do
          if (m ~= "") then
            SendChatMessage("KarmaBot: ".. m, "WHISPER", this.language, select('2', ...));
          end
      end
    elseif (select('1', ...) == nks.KARMA_SHOWTO_RAID) then
      -- This message will appear in raid chat
      for m in string.gmatch(msg, "([^\n]*)\n*") do
          if (m ~= "") then
            SendChatMessage("Karma: ".. m, "RAID", this.language, "");
          end
      end
    elseif (select('1', ...) == nks.KARMA_SHOWTO_LEADER) then
      -- Add message to raid leader's chat
      if ( DEFAULT_CHAT_FRAME ) then
          for m in string.gmatch(msg, "([^\n]*)\n*") do
          if (m ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("Karma: ".. m, 1.0, 1.0, 0);
          end
        end
      end
    end

  else
    -- Add message to raid leader's chat
    if ( DEFAULT_CHAT_FRAME ) then
      for m in string.gmatch(msg, "([^\n]*)\n*") do
        if (m ~= "") then
          DEFAULT_CHAT_FRAME:AddMessage("Karma: ".. m, 1.0, 1.0, 0);
        end
      end
    end
  end
end


