from lxml import etree
import traceback
from copy import deepcopy

# https://lxml.de/api/lxml.etree.XMLParser-class.html
# https://lxml.de/tutorial.html

# root = etree.Element("ModOps")
# ModOp1 = etree.SubElement(root, "ModOp", Type="addNextSibling", GUID="130248")
# Asset1 = etree.SubElement(ModOp1, "Asset")
# root.append(deepcopy(ModOp1))
# print(etree.tostring(root, pretty_print=True, encoding="unicode"))

# ModOps_root = doxpath(tree,"//ModOps",listentrynumber=0,default=None)
# ModOp1 = doxpath(ModOps_root,"ModOp",listentrynumber=0,default=None)
# Asset1 = doxpath(ModOp1,"Asset[Values/Standard/GUID/text()='1500001437']",listentrynumber=0,default=None)

def doxpath(node,path,listentrynumber=0,default=None):
    try:
        r = node.xpath(path)
        if r:
            if listentrynumber is not None:
                return r[listentrynumber]
            else:
                return r
        else:
            return default
    except Exception as err:
        print(f"Fehler: bei path {path}, {err}\n{traceback.format_exc()}")






# Code to copy the TriggerAIDefense_Human0 from sabotage mod to all the other humans


Path = "D:/CDesktopLink/Unterlagen/Mods/Anno 1800/build_xml skripte/Kopiesourceresult"
filename = "TriggerAIDefense_Human0.include.xml"
resultfilename = "TriggerAIDefense_XXX.include.xml"

tree = etree.parse(f"{Path}/{filename}",parser=etree.XMLParser(remove_blank_text=True,remove_comments=True,ns_clean=True))
etree.indent(tree, space="  ") # ohne das sind besonders lange einschübe alle auf selber ebene


StartGUID = 1500001805
CurrentGUID = StartGUID

# 1500001203 , 1500001558, 1500001730, 1500001613
Players = {
  "Human1":{"MatcherGUIDLandSpy":"1500001562","MatcherGUIDSpawnHelper":"1500001710","MatcherGUIDShipSpy":"1500001537","Unlock":"1500001614",},
  "Human2":{"MatcherGUIDLandSpy":"1500001563","MatcherGUIDSpawnHelper":"1500001711","MatcherGUIDShipSpy":"1500001539","Unlock":"1500001615",},
  "Human3":{"MatcherGUIDLandSpy":"1500001564","MatcherGUIDSpawnHelper":"1500001712","MatcherGUIDShipSpy":"1500001543","Unlock":"1500001616",},
}

for Player,info in Players.items():

  treecopy = deepcopy(tree)
  ModOps_root = doxpath(treecopy,"//ModOps",listentrynumber=0,default=None)
  
  PlayerShortname = Player
  Trigger1500001567,Trigger1500001487,Trigger1500001488 = None,None,None
  
  ModOpNodes = doxpath(ModOps_root,"ModOp",listentrynumber=None,default=[])
  for ModOp in ModOpNodes:
    Assets = doxpath(ModOp,"Asset",listentrynumber=None,default=[])
    for Asset in Assets:
      
      GUIDnode = doxpath(Asset,f"//GUID",listentrynumber=0,default=None)
      if GUIDnode.text=="1500001567":
        Trigger1500001567 = str(CurrentGUID)
      elif GUIDnode.text=="1500001487":
        Trigger1500001487 = str(CurrentGUID)
      elif GUIDnode.text=="1500001488":
        Trigger1500001488 = str(CurrentGUID)
      GUIDnode.text = str(CurrentGUID)
        
      labels = doxpath(Asset,f"//*[contains(text(),'Human0')]",listentrynumber=None,default=[])
      for label in labels:
        label.text = label.text.replace("Human0",PlayerShortname)
      
      stuffs = doxpath(Asset,f"//*[text()='1500001203']",listentrynumber=None,default=[])
      for stuff in stuffs:
        stuff.text = info["MatcherGUIDLandSpy"]
      stuffs = doxpath(Asset,f"//*[text()='1500001558']",listentrynumber=None,default=[])
      for stuff in stuffs:
        stuff.text = info["MatcherGUIDSpawnHelper"]
      stuffs = doxpath(Asset,f"//*[text()='1500001730']",listentrynumber=None,default=[])
      for stuff in stuffs:
        stuff.text = info["MatcherGUIDShipSpy"]
      stuffs = doxpath(Asset,f"//*[text()='1500001613']",listentrynumber=None,default=[])
      for stuff in stuffs:
        stuff.text = info["Unlock"]

      ModOp.append(Asset)
            
      CurrentGUID += 1
      
    # und jetzt nochmal über die TriggerGUID Einträge anpassen.
    for Asset in Assets:
      TriggerAssetNode = doxpath(Asset,f"//*[text()='1500001567']",listentrynumber=0,default=None)
      if TriggerAssetNode is not None:
        TriggerAssetNode.text = Trigger1500001567
      TriggerAssetNode = doxpath(Asset,f"//*[text()='1500001487']",listentrynumber=0,default=None)
      if TriggerAssetNode is not None:
        TriggerAssetNode.text = Trigger1500001487
      TriggerAssetNode = doxpath(Asset,f"//*[text()='1500001488']",listentrynumber=0,default=None)
      if TriggerAssetNode is not None:
        TriggerAssetNode.text = Trigger1500001488
      
  AIresultfilename = resultfilename.replace("XXX",PlayerShortname)
      
  xmlstring = etree.tostring(ModOps_root, pretty_print=True, encoding="unicode")
  with open(f"{Path}/{AIresultfilename}", "w") as f:
    f.write(xmlstring)
  


