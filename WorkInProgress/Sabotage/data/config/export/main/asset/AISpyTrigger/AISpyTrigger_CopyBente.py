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











# Code to copy the AITrigger_Bente from sabotage mod to all the other AIs


Path = "D:/CDesktopLink/Unterlagen/Mods/Anno 1800/build_xml skripte/Kopiesourceresult"
filename = "AITrigger_Bente.include.xml"
resultfilename = "AITrigger_XXX.include.xml"

tree = etree.parse(f"{Path}/{filename}",parser=etree.XMLParser(remove_blank_text=True,remove_comments=True,ns_clean=True))
etree.indent(tree, space="  ") # ohne das sind besonders lange einschübe alle auf selber ebene


StartGUID = 1500001735
CurrentGUID = StartGUID

AIs = {
  "Second_ai_02_Qing":{"Unlock":1500001603},
  "Second_ai_03_Wibblesock":{"Unlock":1500001604},
  "Second_ai_04_Smith":{"Unlock":1500001605},
  "Second_ai_05_OMara":{"Unlock":1500001606},
  "Second_ai_06_Gasparov":{"Unlock":1500001607},
  "Second_ai_07_von_Malching":{"Unlock":1500001608},
  "Second_ai_08_Gravez":{"Unlock":1500001609},
  "Second_ai_09_Silva":{"Unlock":1500001610},
  "Second_ai_10_Hunt":{"Unlock":1500001611},
  "Second_ai_11_Mercier":{"Unlock":1500001612},
}

for AI,info in AIs.items():

  treecopy = deepcopy(tree)
  ModOps_root = doxpath(treecopy,"//ModOps",listentrynumber=0,default=None)
  
  AIShortname = AI.split("_")[-1]
  AITriggers = []
  
  ModOpNodes = doxpath(ModOps_root,"ModOp",listentrynumber=None,default=[])
  for ModOp in ModOpNodes:
    Assets = doxpath(ModOp,"Asset",listentrynumber=None,default=[])
    for Asset in Assets:
      
      Assetcopy = Asset # wenn wir das original direkt verändern wollen, brauchen wir keine kopie
      
      GUIDnode = doxpath(Assetcopy,f"//GUID",listentrynumber=0,default=None)
      GUIDnode.text = str(CurrentGUID)
      
      Namenode = doxpath(Assetcopy,f"//Name",listentrynumber=0,default=None)
      Namenode.text = Namenode.text.replace("Bente",AIShortname)
      
      jorgensons = doxpath(Assetcopy,f"//*[text()='Second_ai_01_Jorgensen']",listentrynumber=None,default=[])
      for jorg in jorgensons:
        jorg.text = AI
        
      labels = doxpath(Assetcopy,f"//*[contains(text(),'BenteSpyVS')]",listentrynumber=None,default=[])
      for label in labels:
        label.text = label.text.replace("Bente",AIShortname)
        
      Playerunlocks = doxpath(Assetcopy,f"//*[text()='1500001602']",listentrynumber=None,default=[])
      for unlock in Playerunlocks:
        unlock.text = str(info["Unlock"])

      ModOp.append(Assetcopy)
      
      AITriggers.append(str(CurrentGUID))
      
      CurrentGUID += 1
      
    # und jetzt nochmal im ersten Asset die TriggerAsset Einträge anpassen. sortiert in derselben Reihenfolge wie sie im ersten Trigger vorkommen und wie sie auch danach als ASset vorkommen
    TriggerAssetNode = doxpath(Assets[0],f"//TriggerAsset[text()='1500001596']",listentrynumber=0,default=None)
    TriggerAssetNode.text = AITriggers[1]
    TriggerAssetNode = doxpath(Assets[0],f"//TriggerAsset[text()='1500001196']",listentrynumber=0,default=None)
    TriggerAssetNode.text = AITriggers[2]
    TriggerAssetNode = doxpath(Assets[0],f"//TriggerAsset[text()='1500001598']",listentrynumber=0,default=None)
    TriggerAssetNode.text = AITriggers[3]
    TriggerAssetNode = doxpath(Assets[0],f"//TriggerAsset[text()='1500001700']",listentrynumber=0,default=None)
    TriggerAssetNode.text = AITriggers[4]
    TriggerAssetNode = doxpath(Assets[0],f"//TriggerAsset[text()='1500001702']",listentrynumber=0,default=None)
    TriggerAssetNode.text = AITriggers[5]
    TriggerAssetNode = doxpath(Assets[0],f"//TriggerAsset[text()='1500001704']",listentrynumber=0,default=None)
    TriggerAssetNode.text = AITriggers[6]
      
  AIresultfilename = resultfilename.replace("XXX",AIShortname)
      
  xmlstring = etree.tostring(ModOps_root, pretty_print=True, encoding="unicode")
  with open(f"{Path}/{AIresultfilename}", "w") as f:
    f.write(xmlstring)
  


