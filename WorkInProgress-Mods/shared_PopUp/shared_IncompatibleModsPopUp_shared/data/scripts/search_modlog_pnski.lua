--[[ Author: Pnski https://github.com/Pnski/Anno1800SearchModLog/blob/main/ModLog.lua (slightly adjusted by Serp) ]]
--[[ What does it do?
As a Library it will read all stuff of the ModLoader log if it is in the default directory, since a search might collide (again) with ubisoft
All given lines will be stored in a table
the given table will be reduced by case search to the stuff the Coder needs ]]

--[[ Usage

if SearchModLog_Pnski==nil then
  console.startScript("data/scripts/search_modlog_pnski.lua")
end

local function DoSomething()
    local coolTable = SearchModLog_Pnski("info")
    for k,v in pairs(coolTable) do
        print(v)
    end
end
]]


local function readFile()
    DefaultPath = os.getenv("USERPROFILE")..[[\Documents\Anno 1800\log\mod-loader.log]] -- c:\User\<Username>\Documents\Anno 1800\log\mod-loader.log
    local _File = io.open(DefaultPath, "r")
    if _File~=nil then
      local _content = {}
      for k in _File:lines() do
          table.insert(_content,k)
      end
      _File:close()
      return _content
    else
      print("shared_IncompatibleModsPopUp: failed to load mod-loader.log to check for incompatible mods")
    end
end

local function searchTable(_table, KeyWord)
    local trimtable = {}
    for k,v in pairs(_table) do
        if KeyWord==nil or string.find(v,KeyWord) then
            trimtable[k] = v -- keep the index
        end
    end
    return trimtable
end


local IncompTranslation = {} -- gogo chatgpt power. Sorted by Index returned by ts.Options.TextLanguage
IncompTranslation[0] = " is incompatible with: "    -- English
IncompTranslation[1] = " est incompatible avec : "  -- Francais
IncompTranslation[2] = " jest niekompatybilny z: "  -- Polski
IncompTranslation[3] = " несовместимо с: "          -- Russian
IncompTranslation[4] = " es incompatible con: "     -- Espanol
IncompTranslation[5] = " ist inkompatibel mit: "    -- German
IncompTranslation[6] = " 与...不兼容： "              --  simple chin 
IncompTranslation[7] = " 與...不相容： "              --  traditional 
IncompTranslation[8] = " と互換性がありません： "          -- japanese
IncompTranslation[9] = " 와(과) 호환되지 않습니다: "       -- korean
IncompTranslation[10] = " è incompatibile con: "    -- italiano
-- we dont need the translation here, we can use a normal Text Asset with GUID in text_langauge.xml files (but good to know how to get game language)
local function GetIncompText()
  local language_index = ts.Options.TextLanguage
  return IncompTranslation[language_index]
end



function SearchModLog_Pnski(GivenTag)
    local _content = searchTable(readFile(),GivenTag)
    return _content
end


function listIncompatible_Pnski()
    local inc_mods_list = {}
    
    -- first check at what line the newest modloading happens
    local modsloaded = SearchModLog_Pnski("Load mods") -- "[info] Load mods" does not work for whatever reason, but not so important
    -- print(modsloaded)
    local last_modsloaded_linenumber = 0
    for linenumber,line in pairs(modsloaded) do -- unsorted iteration!
      if linenumber > last_modsloaded_linenumber then
        last_modsloaded_linenumber = linenumber
      end
    end
    -- print(last_modsloaded_linenumber)
    local incompatible_logs = SearchModLog_Pnski("is incompatible with:")
    -- print(incompatible_logs)
    for linenumber,line in pairs(incompatible_logs) do
      if linenumber > last_modsloaded_linenumber then
        local inc_mod1,inc_mod2 = string.match(line,".*%] (.*) is incompatible with: .*%] (.*)") -- eg. "[2024-08-15 22:35:39.877] [error] [Gameplay] testmod is incompatible with: shared_IncompatibleModsPopUp"
        if inc_mod2==nil then -- eg if it does not have a Category in brackets (mod1 always has brackets in front, eg [error])
          inc_mod1,inc_mod2 = string.match(line,".*%] (.*) is incompatible with: (.*)")
        end
        -- print(inc_mod1,inc_mod2)
        if inc_mod1~=nil and inc_mod2~=nil then
          table.insert(inc_mods_list,{inc_mod1,inc_mod2}) -- inc_mod1 is a ModName, while inc_mod2 is a ModID
        else
          print("lua listIncompatible_Pnski: Error reading out mod-loader.log for incompatible mods (may adjust string.match) line: "..tostring(line))
        end
      end
    end
    return inc_mods_list
end

