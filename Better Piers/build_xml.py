from xml.etree import cElementTree as ET
import math

# unfinished/unfertig, Text='Pier' ist doch keine moeglichkeit alle piers zu finden, besser wäre "(Pier)" im teil des namens

# bzw. die normalen piers evlt darüber finden, dass sie BaseAssetGUID vom ersten pier nutzen?

## Read the assets.xml file.
assets_path = "D:/CDesktopLink/Unterlagen/Mods/Anno 1800/Anno1800 RDA unpacked/data25/data/config/export/main/asset/assets.xml"
root = ET.parse(assets_path)


piers = root.findall(".//Asset/Values/Text/LocaText/English[Text='Pier']/../..")
adv_piers = root.findall(".//Asset/Values/Text/LocaText/English[Text='Advanced Pier']/../..")

base_text = """
    <!--{Name}-->
    <ModOp Type="add" GUID="{GUID}" Path="/Values/ModuleOwner">     
        <AdditionalModuleMustBeMainBuildingAdjacent>0</AdditionalModuleMustBeMainBuildingAdjacent>
    </ModOp>
    <ModOp Type="merge" GUID="{GUID}" Path="/Values/ModuleOwner">        
        <ModuleBuildRadius>{Radius}</ModuleBuildRadius>
    </ModOp>
"""

with open("betterpiers_assets.xml", "w") as assets_file:
    assets_file.write("<ModOps>\n")
    for node in results:
        guid = node.find("./Values/Standard/GUID").text
        name = node.find("./Values/Standard/Name").text
        result = base_text.format(Radius = radius_function(limit), Name = name, GUID = guid)
        assets_file.write(result)
       
    assets_file.write("</ModOps>")

