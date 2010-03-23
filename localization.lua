
-- Ni Karma System localization file
-- Got a translation?  Send it to me at stef+nks@ swcp.com
-- otherwise, I'm going to translate it using google, and that can't be good! :-)


-----------------------------------------------
-- Don't change this stuff here - same for all locales
-----------------------------------------------

BINDING_HEADER_KARMA = "Ni Karma System";

-- Only for local output, doesn't work in tells
local BLU = "|cff6666ff";
local GRY = "|cff999999";
local GRE = "|cff66cc33";
local RED = "|cffcc6666";
local ORN = "|cffcc9933";
local YEL = "|cffffff00";

-----------------------------------------------
-- English localization (Default)
-----------------------------------------------
BINDING_NAME_ROLLWINDOW = "Open/Close Roll Window";

nks.KMSG.LOADED = " loaded."
nks.KMSG.VERMISMATCH1 = RED .. "Ni Karma System Warning:" .. YEL .."  Need to upgrade from database version "
nks.KMSG.VERMISMATCH = RED .. "Ni Karma System Warning:\n" .. YEL .."Database version is outdated.  New databases may not be backward compatible with older program versions!\nClick OKAY to upgrade the database."
nks.KMSG.UPDATING = "Updating data from version "
--
-- silliness:
StaticPopupDialogs["NKSVERSION"] = {
	text = nks.KMSG.VERMISMATCH,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		Karma_update_data();
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};


--commands
nks.KMSG.CUSE = "use"
nks.KMSG.CCREATE = "create"
nks.KMSG.COPTION = "option"
nks.KMSG.CCOMPACT = "compact"
nks.KMSG.CINFO = "info"
nks.KMSG.COFF = "off"
nks.KMSG.CROLL = "roll"
nks.KMSG.CSHOW = "show"
nks.KMSG.CADD = "add"
nks.KMSG.CSUB = "sub"
nks.KMSG.CADDITEM = "additem"
nks.KMSG.CSPAM = "spam"


-- standard bonus/nobonus
nks.KMSG.DECLARE = {}
nks.KMSG.REPLY = {}

nks.KMSG.DECLARE.BONUS = {"bonus", "bonsu"}
nks.KMSG.REPLY.BONUS = {"Your Karma of ", "will be added to your roll"}

nks.KMSG.DECLARE.NOBONUS = {"nobonus", "no bonus", "nobonsu", "no bonsu"}
nks.KMSG.REPLY.NOBONUS = {"Not using Karma on next roll"}

-- don't want to roll, but don't let it get sharded
nks.KMSG.DECLARE.NOSHARD = {"noshard", "shard", "no shard"}
nks.KMSG.REPLY.NOSHARD = {"Okay, this item will not be sharded"}

-- Additional modifiers ADDED TO END of bonus/nobonus:
--
-- don't want to roll against main specs, but will roll with bonus/nobonus
nks.KMSG.DECLARE.OFFSPEC = {"offspec", "off spec"}
nks.KMSG.REPLY.OFFSPEC = {"Declared as offspec (passing to any main specs)"}

-- might want to pass to someone if they're rolling, so don't drop it on me immediately
nks.KMSG.DECLARE.PASS = {"pass"}
nks.KMSG.REPLY.PASS = {"Will check if you want to pass, after the roll"}

nks.KMSG.BONUS = "bonus"
nks.KMSG.NOBONUS = "nobonus"
-- for splitting the words... allow "no bonus" in addition to "nobonus"
nks.KMSG.NOBONUS1 = "no"
nks.KMSG.NOBONUS2 = "bonus"


nks.KMSG.REPLYBONUS1 = "Your Karma of "
nks.KMSG.REPLYBONUS2 = " will be added to your roll"
nks.KMSG.REPLYNOBONUS = "Not using Karma on next roll"

-- command arguments, including player commands
nks.KMSG.HELP = "help"
nks.KMSG.ALL = "all"
nks.KMSG.HISTORY = "history"
nks.KMSG.ITEMS = "items"
nks.KMSG.KARMA = "karma"

nks.KMSG.HELP2 = "Fields in [brackets] are optional\nThe database name is case sensitive";
nks.KMSG.HELP3 = "/KM command\nCommands:\n  HELP\n  OFF\n  INFO\n  ROLL\n  CREATE database\n  USE database\n  SHOW (playername\|class\|ALL) [KARMA\|ITEMS\|HISTORY] [TO\|RD]\n  ADD [-]# (ALL, player) [reason]\n  ADDITEM [-]# (ALL, player) itemlink [comment]\n  OPTION SHOW \| setting=ON\|OFF\|#\n  COMPACT #ofdays\n  SPAM";

-- player messages when sending "km <command>" tells to the loot master
nks.KMSG.PLAYER_HELP1 = "Ni Karma System Help"
nks.KMSG.PLAYER_HELP2 = "Fields in [brackets] are optional"
nks.KMSG.PLAYER_HELP3 = "/t <loot_master> <command>\n  km show\n  km show [karma [class/player]]\n  km show history\n  km show items [class/player\]\n  km help\n  Ex: To get your karma, use \"km show\".  To get a list of the warrior karma in the raid, use \"km show karma warrior\""

-- the following is a FAST description of the system, and can be spammed for new players with /km spam.
nks.KMSG.SPAM = "The Ni Karma System adds your Karma score to a /roll (1-100 + bonus) when you send me a tell of \"" .. nks.KMSG.BONUS .. "\" and does a normal roll (1-100) when you send me a tell of \"" .. nks.KMSG.NOBONUS .. "\".\nWhen asked to declare on items, send me only \"" .. nks.KMSG.BONUS .. "\" or \"" .. nks.KMSG.NOBONUS .. "\", and /roll when told.\nOnly those within 50 karma of the highest \"bonus\" score can roll.\nIf you win and are using Karma bonus, you lose half.  There is no loss if you don't use bonus, or don't win, but class-specific items have a min/max loss, usually 25/100 pts."

nks.KMSG.NORAID = "No active raid";
nks.KMSG.BADCOMMAND = "Invalid Command";

nks.KMSG.YOU = "You"
nks.KMSG.PLAYER = "Player: "
nks.KMSG.NOHISTORY = " is not in raid history"
nks.KMSG.CURRENT1 = "Your current Karma: "
nks.KMSG.CURRENT2 = "Current Karma of "

nks.KMSG.ADDNOPOINTS1 = "You must specify amount of karma to ADD"
nks.KMSG.ADDNOPOINTS2 = "Karma to ADD must be a number (positive or negative)"
nks.KMSG.OFFLINELIST = "Offline (no karma added): "

nks.KMSG.ADDITEM = "You must specify an item"
nks.KMSG.USERAID = "You must specify a database"
nks.KMSG.NOTFOUND = "Database not found.  (Check your spelling and capitalization, or " .. BLU .. "/km create <dbname>"..YEL.." to create a new database)"
nks.KMSG.EXISTS = "Database already exists and will not be created again"
nks.KMSG.CREATED = "Creating new database ("
nks.KMSG.USINGRAID = "Karma running on database ("
nks.KMSG.DISABLED = "Karma is off.  " .. BLU .. "/km use <Database>" .. YEL .. " to load one, or " .. BLU .. "/km create <Database>" .. YEL .. " to create a new database"

nks.KMSG.ON = "ON" -- uppercase
nks.KMSG.OFF = "OFF"

-- options are ONLY the words, do not use for table indices
nks.KMSG.SHOW_WHISPERS = "SHOW_WHISPERS"
nks.KMSG.NOTIFY_ON_CHANGE = "NOTIFY_ON_CHANGE"
nks.KMSG.ALLOW_NEGATIVE_KARMA = "ALLOW_NEGATIVE_KARMA"
nks.KMSG.MIN_KARMA_CLASS_DEDUCTION = "MIN_KARMA_CLASS_DEDUCTION"
nks.KMSG.MAX_KARMA_CLASS_DEDUCTION = "MAX_KARMA_CLASS_DEDUCTION"
nks.KMSG.MIN_KARMA_NONCLASS_DEDUCTION = "MIN_KARMA_NONCLASS_DEDUCTION"
nks.KMSG.MAX_KARMA_NONCLASS_DEDUCTION = "MAX_KARMA_NONCLASS_DEDUCTION"
nks.KMSG.KARMA_ROUNDING = "KARMA_ROUNDING"
nks.KMSG.BADOPTION = "Unknown option"

nks.KMSG.NORECORD = "No record of you in current database"

nks.KMSG.RECENT1 = "Your recent events:"
nks.KMSG.RECENT2 = "Recent events for "

nks.KMSG.DEDUCTED = " karma deducted for "
nks.KMSG.ADDED = " karma added for "
nks.KMSG.COST = " karma for "
nks.KMSG.BADSHOW = "Invalid SHOW command"

nks.KMSG.COMPACTING = "Compacting old entries for "
nks.KMSG.COMPACTED = "Compact complete"
nks.KMSG.ROLLED = " roll "
nks.KMSG.REROLLED = RED .. " rerolled." .. YEL
nks.KMSG.NOTINRAID = " tried to join roll list but is not in the raid"
nks.KMSG.WINS = " is the winner of "
nks.KMSG.USING = " using "
nks.KMSG.TOTAL = " karma for a total of "
nks.KMSG.PAYING = " karma spent"

-- compacted entry
nks.KMSG.OLDENTRIES = "Karma From Old Entries"

-- OLD: not really a message, but will have localization issues
-- OLD: I'm using '|' for string searching, so it should have those at each end of each word
-- OLD: nks.KMSG.allclasses = "|druid|hunter|mage|paladin|priest|rogue|shaman|warlock|warrior|";


--
-- nks.KMSG.CLASS.localname = "db_class"
-- You can have multiple localnames and aliases if you like.
--
nks.KMSG.CLASS = { }

-- This section has two parts.  First you must have the all classes as returned by GetRaidRosterInfo
-- mapped to the english version.
-- Next, you can have aliases, mapping to the appropriate english version.
-- ex:
-- ["hexenmeister"] = "Warlock",
-- ["hexenmeisterin"] = "Warlock",
-- ["warlock"] = "Warlock"
-- ["dk"] = "Death Knight"
--
-- I didn't add all the languages here, because someone on the US client might name their warlock "Hexenmeister"
-- Add the local names as needed based on GetLocale()
--
nks.KMSG.CLASS.druid = "Druid"
nks.KMSG.CLASS.hunter = "Hunter"
nks.KMSG.CLASS.mage = "Mage"
nks.KMSG.CLASS.paladin = "Paladin"
nks.KMSG.CLASS.priest = "Priest"
nks.KMSG.CLASS.rogue = "Rogue"
nks.KMSG.CLASS.shaman = "Shaman"
nks.KMSG.CLASS.warlock = "Warlock"
nks.KMSG.CLASS.warrior = "Warrior"
nks.KMSG.CLASS["death knight"] = "Death Knight"
nks.KMSG.CLASS.deathknight = nks.KMSG.CLASS["death knight"]

-- aliases for the command /km show <class>
nks.KMSG.CLASS.dk = nks.KMSG.CLASS["death knight"]

-- roll window
nks.KMSG.ROLL = { };
nks.KMSG.ROLL.MIN = "Min Karma:"
nks.KMSG.ROLL.MAX = "Max"

-- system output
nks.KMSG.SYS = { };
nks.KMSG.SYS.ROLLS = "rolls"

nks.KMSG.CLASSES = "Classes:"


-----------------------------------------------
-- German localization
-----------------------------------------------
if ( GetLocale() == "deDE" ) then

-- system output
nks.KMSG.SYS.ROLLS = "w\195\188rfelt. Ergebnis:"

-- German names from Alexander 'Bl4ckSh33p' Spielvogel and his brother ESN
-- Thanks!
-- English names from above should also work.
nks.KMSG.CLASS = {
	["hexenmeister"] = nks.KMSG.CLASS.warlock,
	["hexenmeisterin"] = nks.KMSG.CLASS.warlock,
	["krieger"] = nks.KMSG.CLASS.warrior,
	["kriegerin"] = nks.KMSG.CLASS.warrior,
	["j\195\164ger"] = nks.KMSG.CLASS.hunter,
	["j\195\164gerin"] = nks.KMSG.CLASS.hunter,
	["magier"] = nks.KMSG.CLASS.mage,
	["magierin"] = nks.KMSG.CLASS.mage,
	["priester"] = nks.KMSG.CLASS.priest,
	["priesterin"] = nks.KMSG.CLASS.priest,
	["druide"] = nks.KMSG.CLASS.druid,
	["druidin"] = nks.KMSG.CLASS.druid,
	["paladin"] = nks.KMSG.CLASS.paladin,
	["schamane"] = nks.KMSG.CLASS.shaman,
	["schamanin"] = nks.KMSG.CLASS.shaman,
	["schurke"] = nks.KMSG.CLASS.rogue,
	["schurkin"] = nks.KMSG.CLASS.rogue,
	["todesritter"] = nks.KMSG.CLASS.deathknight,
}


-----------------------------------------------
-- French localization
-----------------------------------------------
elseif ( GetLocale() == "frFR" ) then


end

