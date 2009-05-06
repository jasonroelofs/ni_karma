Ni Karma System
Designed by Vuelhering and Qed of Icecrown (stef+nks@swcp-dot-com)
Plugin originally written by Mavios of Icecrown, with extensive changes by Vuelhering.

Read and understand the system.  This plugin helps you implement the system, but it cannot do it automatically.  You *must* understand how it works or this plugin will do you no good, so look in the Documentation folder.  The way it works looks scary at first, but it's fairly easy to understand once you figure it out.

Install the Ni_Karma and Ni_Loader folders in <wowdir>/Interface/AddOns and make sure that you see it on the addons button at the character select screen.

If your website is capable of running php, install the karma.php and karma.css scripts on your website.  After running the plugin and assigning loot, the loot master must upload the Karma data to the same directory as the php script on the website.  The datafile to upload is <wowdir>/WTF/Account/<login>/SavedVariables/Ni_Karma.lua
This is where WoW automatically saves variables, which are written out when the game exits, and loaded when the game starts.

After it's uploaded, you can access the NKS info by going to http://www.yourwebsite.com/karma.php

Note - DO NOT ASK ME about your website... ask your ISP if you have questions about running php scripts on your webserver.




-- Copyright 2006-2009, Mavios and Vuelhering, Knights who say Ni, Icecrown
-- 
-- Permission granted for use, modification, and distribution provided:
-- 1. Any distributions include the original distribution in its entirety, OR a working URL to freely get the entire original distribution is clearly listed in the documentation.
-- 2. Any modified distributions clearly mark YOUR changes, or document the changes somehow.
-- 3. Any modified distributions MUST NOT imply in any way that it is an official upgrade version of this software (such as NKS+ or Enhanced Karma System, or probably anything with "NKS" or "Karma" in the name).  If you want your changes in the official distribution, write (stef+nks @swcp.com) and it might get included.
-- 4. No fee is charged for any distribution of this software (modified or original).
-- 
-- Snippets of code "borrowed" (fewer than 100 total lines) can merely include the URL http://www.knights-who-say-ni.com/NKS and credit for the code used.
-- The Ni_Karma.toc file is granted to the public domain, and may be changed as desired.
