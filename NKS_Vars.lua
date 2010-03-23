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



-- Globals

KarmaList = {};
KarmaConfig = {};
nks = {}			-- all other globals

-- Initializations
--

nks.addon = "Ni_Karma"
nks.prefix = "Karma"

nks.KMSG = {};			-- localized text messages

nks.ROLLS_TO_DISPLAY = 17;
nks.KARMA_SHOWTO_LEADER = 0;
nks.KARMA_SHOWTO_PLAYER = 1;
nks.KARMA_SHOWTO_RAID = 2;
nks.ROLL_FRAME_ROLL_HEIGHT = 16;

nks.KMSG.HELP1 = "Ni Karma System ";

nks.Active = false;
nks.Raid_Name = "";
nks.RollOff = false;
nks.RollList = {};
nks.Version = "3.0 rel 03";
nks.DataVersion = 1;
nks.OpenRoll = false;

nks.class_broken = "fixlocal"
nks.class_unknown = "unknown"

nks.configpanel = {};	-- interface config panel
nks.KarmaDefaults = {};


nks.KarmaDefaults["VERSION"] = Version;
nks.KarmaDefaults["SHOW_WHISPERS"] = false;
nks.KarmaDefaults["NOTIFY_ON_CHANGE"] = true;
nks.KarmaDefaults["MAX_KARMA_CLASS_DEDUCTION"] = 100;
nks.KarmaDefaults["MIN_KARMA_CLASS_DEDUCTION"] = 25;
nks.KarmaDefaults["MAX_KARMA_NONCLASS_DEDUCTION"] = 0;
nks.KarmaDefaults["MIN_KARMA_NONCLASS_DEDUCTION"] = 5;
nks.KarmaDefaults["ALLOW_NEGATIVE_KARMA"] = false;
nks.KarmaDefaults["KARMA_ROUNDING"] = 5;
nks.KarmaDefaults["DATAVERSION"] = 0;
nks.KarmaDefaults["LASTUPDATE"] = "unknown";
nks.KarmaDefaults["CURRENT RAID"] = nil; -- used to see if active or not

