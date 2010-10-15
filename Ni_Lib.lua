-- Ni Loader
--
-- Copyright 2009, Vuelhering, Knights who say Ni, Icecrown (stef+nks @swcp.com)
-- (http://www.stunt-programmers.com)
--
-- Permission granted for use, modification, and distribution provided:
-- 1. Any distributions include the original distribution in its entirety, OR a working URL to freely get the entire original distribution is clearly listed in the documentation.
-- 2. Any modified distributions clearly mark YOUR changes, or document the changes somehow.
-- 3. Any modified distributions MUST NOT imply in any way that it is an official upgrade version of this software.  If you want your changes in the official distribution, write (stef+nks @swcp.com) and it might get included.
-- 4. No fee is charged for any distribution of this software (modified or original).
--
-- Snippets of code "borrowed" (fewer than 100 total lines) can merely include the URL http://www.knights-who-say-ni.com/NKS and credit for the code used, but must also follow the rules above.
-- You may use note as follows:
-- "Some code borrowed with permission from <this software project>.  Full distribution of that
-- project is available at http://www.knights-who-say-ni.com/NKS"
--
-- The ".toc" file is granted to the public domain, so it can be updated without issue.


function Ni_GetToken(msg)
  if (msg) then
    local a,b,token,extra= string.find(msg, "([^%s]+)%s*(.*)");
    if (a) then
      token= string.lower(token);
      Ni_Debug(5, "gettoken: t="..token.."|"..extra);
      return token, extra;
    end
  end
  return "", "";
end

-- strip punctuation
function Ni_StripTok(token)
  local a,b,newtok = string.find(token, "([^%s%p]+)");
  if (not a) then
    newtok = "";
  end
  if (string.len(token) > 0) then
    Ni_Debug(5, "striptok: "..token..">"..newtok);
  end
  return newtok;
end


function Ni_AddonName()
  local s=debugstack(3,1,0)
  local name = string.match(s, "(.+)[\\/]", 18)
  return name
end


function Ni_Print(msg)
  local addon = Ni_AddonName()
  if addon == nil then
    addon = "Ni"
  end
  if ( DEFAULT_CHAT_FRAME ) then
    for m in string.gmatch(msg, "([^\n]*)\n*") do
      if (m ~= "") then
        DEFAULT_CHAT_FRAME:AddMessage(addon .. ": ".. m, 1.0, 1.0, 0);
      end
    end
  end
end


function Ni_Debug(lev,str)
  local addon = Ni_AddonName()
  if addon == nil then
    addon = "Ni"
  end
  if ni_vars ~= nil and ni_vars[addon] ~= nil and ni_vars[addon].prefix ~= nil then
    addon = ni_vars[addon].prefix
  end
  if nidebug ~= nil and nidebug >= lev then
    DEFAULT_CHAT_FRAME:AddMessage(addon .. " debug: " .. str);
  end
end


