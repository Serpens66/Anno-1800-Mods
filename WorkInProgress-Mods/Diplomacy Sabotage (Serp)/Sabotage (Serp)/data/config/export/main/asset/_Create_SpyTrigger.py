from lxml import etree
import traceback
from copy import deepcopy

# https://lxml.de/api/lxml.etree.XMLParser-class.html
# https://lxml.de/tutorial.html

# Sabo GUIDs für Trigger 1500002182 bis einschl. 1500002499 reserviert


StartGUID = 1500002182
CurrentGUID = StartGUID

  # Aktuell noch eher ein "Copy Base und ersetze Einträge". In Base Datei muss ich also noch viel manuell machen
   # evtl. iwann mehr wie Create_DiploDecisions.py aus DiploActions mod aufbauen, dass auch wiederholende Codeteile
    # automatisch zusammengesetzt werden (aber nur falls noetig. wenn base code so eig schon fertig ist, dann lohnt der aufwand nicht)



############################################################################################
# general infos


PIDs = {
    "Human0":{"PID":0,"GUID":41},"Human1":{"PID":1,"GUID":600069},"Human2":{"PID":2,"GUID":600070},"Human3":{"PID":3,"GUID":42},
    "General_Enemy":{"PID":9,"GUID":44},"Neutral":{"PID":8,"GUID":34},"Third_party_01_Queen":{"PID":15,"GUID":75},
    "Second_ai_01_Jorgensen":{"PID":25,"GUID":47},"Second_ai_02_Qing":{"PID":26,"GUID":79},"Second_ai_03_Wibblesock":{"PID":27,"GUID":80},
    "Second_ai_04_Smith":{"PID":28,"GUID":81},"Second_ai_05_OMara":{"PID":29,"GUID":82},"Second_ai_06_Gasparov":{"PID":30,"GUID":83},
    "Second_ai_07_von_Malching":{"PID":31,"GUID":11},"Second_ai_08_Gravez":{"PID":32,"GUID":48},"Second_ai_09_Silva":{"PID":33,"GUID":84},
    "Second_ai_10_Hunt":{"PID":34,"GUID":85},"Second_ai_11_Mercier":{"PID":64,"GUID":220},
    "Third_party_03_Pirate_Harlow":{"PID":17,"GUID":73},"Third_party_04_Pirate_LaFortune":{"PID":18,"GUID":76},
    "Third_party_02_Blake":{"PID":16,"GUID":45},"Third_party_06_Nate":{"PID":22,"GUID":77},"Third_party_05_Sarmento":{"PID":19,"GUID":29},
    "Third_party_07_Jailor_Bleakworth":{"PID":23,"GUID":46},"Third_party_08_Kahina":{"PID":24,"GUID":78},"Africa_Ketema":{"PID":80,"GUID":119051},
    "Arctic_Inuit":{"PID":72,"GUID":237},
}
SupportedPIDs_2ndParty = [25,26,27,28,29,30,31,32,33,34,64]
NoSpiesProducts = {
  25:1500004024,26:1500004025,27:1500004026,28:1500004027,29:1500004028,30:1500004029,31:1500004030,32:1500004031,33:1500004032,34:1500004033,64:1500004034,
}

# <!-- Portrait GUIDs der KIs (für DecisionPortrait), die GUID des Participants zu nehmen geht leider nicht, also keins für Humans nehmen -->
  # <!-- siehe auch Anno1800 RDA unpacked\dataAlle\data\ui\2kimages\main\profiles -->
  # <!-- 100530,100663,100664,100665,100666,100667,100532,100531,100674,100587,110670 -->
  # <!-- third party: -->
  # <!-- queen:100668, Blake:100589, Harlow:100669, LaFortune:100670, Sarmento:100671, Eli:100631, Kahina:100673 General_Enemy:101894 -->
  # <!-- Nate:100672, Inuit:101019, africa_Ketema_portrait:120250,  Vasco Silva:112118 -->
  # <!-- Unknown_Silhouette:116746, GG_EnemyDark_Portrait:7925, campaign_character_01_demolition_expert (gefanger):101138 -->
Portraits = {
  0:0,1:0,2:0,3:0,
  25:100530,26:100663,27:100664,28:100665,29:100666,30:100667,31:100532,32:100531,33:100674,34:100587,64:110670,
  17:100669,18:100670,16:100589,19:100671,22:100672,23:100631,24:100673,80:120250,72:101019,15:100668,
}
HumanMatchers = {
  "Human0":{"MatcherGUIDLandSpy":"1500001203","MatcherGUIDSpawnHelper":"1500001558","MatcherGUIDShipSpy":"1500001730"},
  "Human1":{"MatcherGUIDLandSpy":"1500001562","MatcherGUIDSpawnHelper":"1500001710","MatcherGUIDShipSpy":"1500001537"},
  "Human2":{"MatcherGUIDLandSpy":"1500001563","MatcherGUIDSpawnHelper":"1500001711","MatcherGUIDShipSpy":"1500001539"},
  "Human3":{"MatcherGUIDLandSpy":"1500001564","MatcherGUIDSpawnHelper":"1500001712","MatcherGUIDShipSpy":"1500001543"},
}
AI_Difficulty = {25:"Easy",26:"Easy",27:"Easy",
                28:"Medium",29:"Medium",30:"Medium",31:"Medium",64:"Medium",
                32:"Hard",33:"Hard",34:"Hard",
                }
DifficultyUnlocks =  {"Easy":{"Low":1500001741,"Medium":1500001742,"High":1500001743},
                      "Medium":{"Low":1500001748,"Medium":1500001749,"High":1500001750},
                      "Hard":{"Low":1500001751,"Medium":1500001752,"High":1500001753},
                      }

PIDToinfo = {}
for TargetPID in SupportedPIDs_2ndParty:
  for s,info in PIDs.items():
    if info["PID"] == TargetPID:
      PIDToinfo[TargetPID] = info
      PIDToinfo[TargetPID]["Name"] = s
for i in range(4): # 0b is 3 HumanPID
  for s,info in PIDs.items():
    if info["PID"] == i:
      PIDToinfo[i] = info
      PIDToinfo[i]["Name"] = s

############################################################################################
############################################################################################
# AISpyTrigger

filename = "AISpyTrigger/AISpyTrigger_Base.include.xml"

tree = etree.parse(f"{filename}",parser=etree.XMLParser(remove_blank_text=True,remove_comments=True,ns_clean=True))
etree.indent(tree, space="  ") # ohne das sind besonders lange einschübe alle auf selber ebene
# etree to string: https://lxml.de/apidoc/lxml.etree.html#lxml.etree.tostring
# etree.tostring(element_or_tree, *, encoding=None, method='xml', xml_declaration=None, pretty_print=False, with_tail=True, standalone=None, doctype=None, exclusive=False, inclusive_ns_prefixes=None, with_comments=True, strip_text=False)
tree_str = etree.tostring(tree,encoding='unicode',pretty_print=True)

resultfilename = "AISpyTrigger/AISpyTrigger_{TargetShortName}.include.xml"

CheckIfSendSpyIntervallAndDeleteOld = 600000 # in ms. old AI spies are removed (only for AI vs AI). 600000 ms are 10 minutes
ActivateAISpiesDelay = 60000 # how long the spawned spies are inactive. should be less then CheckIfSendSpyIntervall, since then they are removed again
SpawnAISpiesInitialTriggerDelay = 125000 # ConditionTimer at begin of Trigger. must be higher than ActivateAISpiesDelay and at least ~3000 ms 

# So AI spies may spawn every CheckIfSendSpyIntervallAndDeleteOld + SpawnAISpiesInitialTriggerDelay miliseconds with a chance




SpawnIfLessThenRep = 40 # lower Rep then this then AI will send spies (double chance if at war)
# chance: every intervall this chance is executed for each AI Spy version itself! So chance for "at least one spy" (15 in total supported) is sth like 15*Chance or so? 
# depending on difficulty setting (or by default on AI difficulty) the low/medium/high chance is used
SpawnAISpyChanceLow = 1
SpawnAISpyChanceMedium = 3
SpawnAISpyChanceHigh = 5
SpawnAISpyChanceLowDoubled = SpawnAISpyChanceLow * 2  #if at war, then double chance
SpawnAISpyChanceMediumDoubled = SpawnAISpyChanceMedium * 2
SpawnAISpyChanceHighDoubled = SpawnAISpyChanceHigh * 2

for TargetPID in SupportedPIDs_2ndParty:
  TargetName = PIDToinfo[TargetPID]["Name"]
  TargetShortName = TargetName.split("_")[-1]
  DifficultyUnlockLowChance = DifficultyUnlocks[AI_Difficulty[TargetPID]]["Low"]
  DifficultyUnlockMediumChance = DifficultyUnlocks[AI_Difficulty[TargetPID]]["Medium"]
  DifficultyUnlockHighChance = DifficultyUnlocks[AI_Difficulty[TargetPID]]["High"]
  filename = resultfilename.format(TargetShortName=TargetShortName)
  GUIDs = []
  for i in range(9): # 0 bis 8 ACHTUNG: Anzahl an GUIDs in Datei prüfen und hier anpassen
    GUIDs.append(CurrentGUID)
    CurrentGUID += 1
    
  finalcode = tree_str.format(TargetShortName=TargetShortName,TargetPID=TargetPID,TargetName=TargetName,
    GUID_1=GUIDs[0],GUID_2=GUIDs[1],GUID_3=GUIDs[2],GUID_4=GUIDs[3],GUID_5=GUIDs[4],GUID_6=GUIDs[5],GUID_7=GUIDs[6],GUID_8=GUIDs[7],GUID_9=GUIDs[8],
    SpawnAISpyChanceLow=SpawnAISpyChanceLow,SpawnAISpyChanceMedium=SpawnAISpyChanceMedium,SpawnAISpyChanceHigh=SpawnAISpyChanceHigh,
    SpawnAISpyChanceLowDoubled=SpawnAISpyChanceLowDoubled,SpawnAISpyChanceMediumDoubled=SpawnAISpyChanceMediumDoubled,SpawnAISpyChanceHighDoubled=SpawnAISpyChanceHighDoubled,
    CheckIfSendSpyIntervallAndDeleteOld = CheckIfSendSpyIntervallAndDeleteOld, ActivateAISpiesDelay=ActivateAISpiesDelay,
    SpawnIfLessThenRep=SpawnIfLessThenRep,DifficultyUnlockLowChance=DifficultyUnlockLowChance,DifficultyUnlockMediumChance=DifficultyUnlockMediumChance,DifficultyUnlockHighChance=DifficultyUnlockHighChance,
    NoSpiesAgreementProduct=NoSpiesProducts[TargetPID],SpawnAISpiesInitialTriggerDelay=SpawnAISpiesInitialTriggerDelay,
  )
  with open(f"{filename}", "w") as f:
    f.write(finalcode)
    print(f'<Include File="/data/config/export/main/asset/{filename}" />')

####################################################################
####################################################################
# AIDefenseTrigger


filename = "AIDefenseTrigger/AIDefenseTrigger_Base.include.xml"
tree = etree.parse(f"{filename}",parser=etree.XMLParser(remove_blank_text=True,remove_comments=True,ns_clean=True))
etree.indent(tree, space="  ") # ohne das sind besonders lange einschübe alle auf selber ebene
# etree to string: https://lxml.de/apidoc/lxml.etree.html#lxml.etree.tostring
# etree.tostring(element_or_tree, *, encoding=None, method='xml', xml_declaration=None, pretty_print=False, with_tail=True, standalone=None, doctype=None, exclusive=False, inclusive_ns_prefixes=None, with_comments=True, strip_text=False)
tree_str = etree.tostring(tree,encoding='unicode',pretty_print=True)

resultfilename = "AIDefenseTrigger/AIDefenseTrigger_{HumanName}.include.xml"

for HumanPID in range(4): # 0 bis 3
  HumanName = PIDToinfo[HumanPID]["Name"]
  filename = resultfilename.format(HumanName=HumanName)
  GUIDs = []
  for i in range(11): # 0 bis 10 ACHTUNG: Anzahl an GUIDs in Datei prüfen und hier anpassen
    GUIDs.append(CurrentGUID)
    CurrentGUID += 1
  
  finalcode = tree_str.format(HumanName=HumanName,HumanPID=HumanPID,
    GUID_1=GUIDs[0],GUID_2=GUIDs[1],GUID_3=GUIDs[2],GUID_4=GUIDs[3],GUID_5=GUIDs[4],GUID_6=GUIDs[5],GUID_7=GUIDs[6],
    GUID_8=GUIDs[7],GUID_9=GUIDs[8],GUID_10=GUIDs[9],GUID_11=GUIDs[10],
    MatcherGUIDLandSpy=HumanMatchers[HumanName]["MatcherGUIDLandSpy"],MatcherGUIDSpawnHelper=HumanMatchers[HumanName]["MatcherGUIDSpawnHelper"],MatcherGUIDShipSpy=HumanMatchers[HumanName]["MatcherGUIDShipSpy"],
  )
  with open(f"{filename}", "w") as f:
    f.write(finalcode)
    print(f'<Include File="/data/config/export/main/asset/{filename}" />')


print("")
print("highest used GUID ",CurrentGUID)
if CurrentGUID > 1500002499:
  print("ACHTUNG!! TOO HIGH GUID")
