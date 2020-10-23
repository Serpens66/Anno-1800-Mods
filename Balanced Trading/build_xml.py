################################################################################################
################################################################################################

# a python script that reads the assests.xml from the game and builds the mod xml accordingly (mod_assets.xml, you need to merge this with the assets.xml that contains also other stuff).
# The reason for this script is mostly that I want to add all existing products to all merchants and update this quickly if there is a game update.
# In additoin the current ModOp commands are very limited, so this script will make sure to always use the correct path and type, depending on current situations in assets.xml

# when there was a game update:
# set self.neu_product_GUIDS to True. set neu_Fabrik_GUIDs on the bottom to True and comment in the prints at the bottom to print Total_UKosten and product_GUIDS (if you want to replace the old ones in init. but that is not mandatory, it will just save time to save them if you need to start the script several times)


################################################################################################
################################################################################################


if __name__ == "__main__":
    from lxml import etree
    import os
    import codecs
    
    class builder:
    
        def __init__(self):
            self.out_dir = ""#"/data/config/export/main/asset"
            self.assets_path = "D:/CDesktopLink/Unterlagen/Mods/Anno 1800/Anno1800 RDA unpacked/data16/data/config/export/main/asset/assets.xml"
            self.translation_path = "D:/CDesktopLink/Unterlagen/Mods/Anno 1800/Anno1800 RDA unpacked/data16/data/config/gui/texts_german.xml"
            self.SLOW_PRODUCTION = 0.15 # x per minute GoodsProduction
            self.sell_dividend = 0.8 #(the one defined in GlobalProductBuyPriceFactor for thirdparty), we will divide the maintenance costs by this, to get the new baseprice
            
            # die fabriken, die ich zur Unterhaltskosten Ermittlung verwenden will (keine kampagne und zb Köhlerei statt Kohlemine usw, also nur eines pro Produkt)
            # to renew this list, set neu_Fabrik_GUIDs to True at the bottom and the new list will be printed and also all products that are more than once. Then delete every double entry, so every product is only used once and keep the factories that you want to use to calculate the basecost of product based on maintenance
            self.Fabrik_GUIDs = {'1010262': 'Getreidefarm', '1010263': 'Rinderfarm', '1010264': 'Hopfenplantage', '1010265': 'Kartoffelhof', '1010266': 'Holzfällerhütte', '1010267': 'Schäferei', '1010269': 'Schweinezucht', '1010558': 'Jagdhütte', '100654': 'Paprikafarm', '100655': 'Weinberg', '1010278': 'Fischerei', '1010310': 'Salpeterwerk', '1010560': 'Quarzgrube', '1010280': 'Betonwerk', '1010281': 'Siederei', '1010283': 'Ziegelei', '100451': 'Sägewerk', '1010325': 'Schneiderei', '1010286': 'Glühbirnenfabrik', '1010285': 'Fensterfabrik', '1010288': 'Segelweberei', '100416': 'Lehmgrube', '1010289': 'Kutschen-Werkhalle', '1010291': 'Bäckerei', '1010292': 'Brauerei', '1010293': 'Großküche', '1010295': 'Konservenfabrik', '1010294': 'Schnapsbrennerei', '1010316': 'Metzgerei', '100659': 'Sektkellerei', '1010296': 'Stahlwerk', '1010297': 'Hochofen', '1010298': 'Köhlerei', '1010299': 'Kanonengießerei', '1010301': 'Geschützfabrik', '1010302': 'Motorenfabrik', '1010303': 'Dampfwagenfabrik', '1010282': 'Messinghütte', '101331': 'Ölraffinerie', '1010305': 'Eisenmine', '1010307': 'Zinkmine', '1010308': 'Kupfermine', '1010309': 'Zementmine', '1010311': 'Goldmine', '1010312': 'Wasenmeisterei', '1010313': 'Mühle', '1010314': 'Mälzerei', '1010315': 'Weberei', '1010300': 'Dynamitfabrik', '1010319': 'Glashütte', '1010320': 'Kunstschreinerei', '1010321': 'Glühfadenfabrik', '1010323': 'Hochrad-Werkhalle', '1010324': 'Uhrenwerkstatt', '1010284': 'Nähmaschinenfabrik', '1010326': 'Phonographenfabrik', '1010327': 'Goldschmelze', '1010328': 'Goldschmiede', '101250': 'Brillenfabrik', '1010329': 'Zuckerrohrplantage', '1010330': 'Tabakplantage', '1010331': 'Baumwollplantage', '1010332': 'Kakaoplantage', '1010333': 'Kautschukplantage', '101251': 'Kaffeeplantage', '101263': 'Bananenplantage', '101270': 'Maisplantage', '101272': 'Alpakafarm', '1010339': 'Perlenfarm', '101262': 'Fischölfabrik', '1010318': 'Baumwollweberei', '101415': 'Filzfabrik', '101273': 'Hutmacherei', '1010340': 'Rumbrennerei', '1010341': 'Schokoladenfabrik', '101252': 'Kaffeerösterei', '101264': 'Küche', '101271': 'Tortilla-Bäckerei', '1010317': 'Zuckerraffinerie', '101266': 'Ponchoweberei', '1010342': 'Zigarren-Manufaktur', '112667': 'Rentier-Jagdhütte', '112676': 'Gänsefarm', '112673': 'Bären-Jagdhütte', '112682': 'Huskyfarm', '112666': 'Walfängerei', '112674': 'Robbenfängerei', '112675': 'Schlafsackfabrik', '112679': 'Öllampenfabrik', '112672': 'Parkaschneiderei', '112681': 'Schlittenmanufaktur', '112680': 'Hundeschlitten-Station', '112668': 'Pemmikan-Räucherei', '112690': 'Gasförderstätte', '118571': 'Tankhof', '122963': 'Wanza-Holzfällerhütte', '114448': 'Flachsfarm', '114447': 'Hibiskusfarm', '114450': 'Tef-Farm', '114451': 'Indigofarm', '114452': 'Gewürzfarm', '114453': 'Imkerei', '114456': 'Ziegenfarm', '114439': 'Sanga-Farm', '114440': 'Saline', '118729': 'Zuchtbecken', '117744': 'Papiermühle', '114441': 'Leinenweberei', '114459': 'Tef-Mühle', '114461': 'Kerzenzieherei', '114444': 'Trockenhaus', '114466': 'Stickerei', '114468': 'Teewürzerei', '118725': 'Keramikwerkstatt', '114469': 'Teppichknüpferei', '114467': 'Lehmziegelei', '114471': 'Wat-Küche', '114472': 'Pfeifenmacherei', '114470': 'Buchmalerei', '114464': 'Laternenmacher', '118733': 'Schuster', '118734': 'Schneidergeschäft', '118735': 'Telefonfabrik'}
            # bereits ermittelte Unterhaltskosten:
            self.Total_UKosten = {'120008': 2.5, '1010196': 5.0, '1010200': 20.0, '1010195': 10.0, '1010216': 30.0, '1010197': 10.0, '1010237': 35.0, '1010201': 5.0, '1010205': 25.0, '1010199': 40.0, '1010238': 120.0, '1010192': 20.0, '1010235': 45.0, '1010213': 105.0, '1010210': 47.5, '1010227': 12.5, '1010226': 10.0, '1010219': 72.5, '1010218': 222.5, '1010206': 325.0, '1010221': 297.5, '1010234': 80.0, '1010203': 105.0, '1010194': 30.0, '1010236': 95.0, '1010214': 325.0, '1010228': 60.0, '1010241': 110.0, '1010207': 312.5, '1010193': 100.0, '1010198': 200.0, '1010215': 500.0, '1010217': 662.5, '1010229': 125.0, '1010230': 125.0, '1010204': 500.0, '1010246': 3595.0, '1010251': 2.5, '1010257': 30.0, '1010254': 5.0, '1010239': 7.5, '1010258': 37.5, '1010255': 25.0, '1010245': 697.5, '1010231': 125.0, '1010202': 597.5, '1010243': 735.0, '1010208': 1845.0, '1010224': 3272.5, '120014': 400.0, '120016': 1010.0, '1010209': 50.0, '1010253': 5.0, '1010240': 10.0, '1010247': 310.0, '1010252': 50.0, '1010242': 752.5, '1010259': 927.5, '1010248': 4452.5, '1010232': 1000.0, '1010222': 2080.0, '1010223': 6552.5, '1010256': 37.5, '1010233': 625.0, '1010249': 1385.0, '1010250': 2672.5, '1010211': 2427.5, '1010225': 8700.0, '120030': 2110.0, '120031': 25.0, '120032': 100.0, '120033': 12.5, '120034': 25.0, '120035': 175.0, '120036': 2.5, '120037': 42.5, '120041': 2.5, '120042': 2.5, '120043': 10.0, '120044': 7.5, '112694': 40.0, '112695': 135.0, '112696': 25.0, '112697': 140.0, '112698': 300.0, '112699': 75.0, '112700': 685.0, '112701': 285.0, '112702': 775.0, '112703': 1427.5, '112704': 477.5, '112705': 175.0, '112706': 4500.0, '114356': 3.75, '114364': 15.0, '114365': 10.0, '114367': 20.0, '114368': 25.0, '114369': 25.0, '114370': 35.0, '114357': 10.0, '114371': 5.0, '114358': 7.5, '117702': 16.25, '114391': 20.0, '114408': 82.5, '117701': 100.0, '114359': 30.0, '114401': 40.0, '114390': 105.0, '114402': 65.0, '114404': 140.0, '114410': 272.5, '114414': 325.0, '117698': 291.25, '117699': 510.0, '118724': 80.0, '118728': 40.0, '114428': 360.0, '114430': 480.0, '114431': 3287.5}
            
               
            self.PROGRESSIONS = ["EarlyGame","EarlyMidGame","MidGame","LateMidGame","LateGame","EndGame"]
            
            self.trans_node = etree.parse(self.translation_path)
            self.assets_node = etree.parse(self.assets_path)
            
            self.neu_product_GUIDS = False
            self.product_GUIDS = {}
            if not self.neu_product_GUIDS:
                self.product_GUIDS = {'120008': {'trans': 'Holz', 'sessions': ['Moderate', 'Colony01'], 'progression': 'EarlyGame', 'Fabrik': '1010266'}, '1010196': {'trans': 'Bretter', 'sessions': ['Moderate', 'Colony01', 'Arctic'], 'progression': 'EarlyGame', 'Fabrik': '100451'}, '1010200': {'trans': 'Fische', 'sessions': ['Moderate'], 'progression': 'EarlyGame', 'Fabrik': '1010278'}, '1010195': {'trans': 'Kartoffeln', 'sessions': ['Moderate'], 'progression': 'EarlyGame', 'Fabrik': '1010265'}, '1010216': {'trans': 'Schnaps', 'sessions': ['Moderate'], 'progression': 'EarlyGame', 'Fabrik': '1010294'}, '1010197': {'trans': 'Wolle', 'sessions': ['Moderate'], 'progression': 'EarlyGame', 'Fabrik': '1010267'}, '1010237': {'trans': 'Arbeitskleidung', 'sessions': ['Moderate'], 'progression': 'EarlyGame', 'Fabrik': '1010315'}, '1010201': {'trans': 'Lehm', 'sessions': ['Moderate', 'Colony01', 'Africa'], 'progression': 'EarlyMidGame', 'Fabrik': '100416'}, '1010205': {'trans': 'Ziegelsteine', 'sessions': ['Moderate', 'Colony01'], 'progression': 'EarlyMidGame', 'Fabrik': '1010283'}, '1010199': {'trans': 'Schweine', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010269'}, '1010238': {'trans': 'Wurst', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010316'}, '1010192': {'trans': 'Getreide', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010262'}, '1010235': {'trans': 'Mehl', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010313'}, '1010213': {'trans': 'Brot', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010291'}, '1010210': {'trans': 'Segel', 'sessions': ['Moderate', 'Colony01'], 'progression': 'EarlyMidGame', 'Fabrik': '1010288'}, '1010227': {'trans': 'Eisen', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010305'}, '1010226': {'trans': 'Kohle', 'sessions': ['Moderate', 'Arctic'], 'progression': 'LateMidGame', 'Fabrik': '1010298'}, '1010219': {'trans': 'Stahl', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010297'}, '1010218': {'trans': 'Stahlträger', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010296'}, '1010206': {'trans': 'Nähmaschinen', 'sessions': ['Moderate'], 'progression': 'MidGame', 'Fabrik': '1010284'}, '1010221': {'trans': 'Kanonen', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010299'}, '1010234': {'trans': 'Talg', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010312'}, '1010203': {'trans': 'Seife', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010281'}, '1010194': {'trans': 'Hopfen', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010264'}, '1010236': {'trans': 'Malz', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010314'}, '1010214': {'trans': 'Bier', 'sessions': ['Moderate'], 'progression': 'EarlyMidGame', 'Fabrik': '1010292'}, '1010228': {'trans': 'Quarzsand', 'sessions': ['Moderate'], 'progression': 'MidGame', 'Fabrik': '1010560'}, '1010241': {'trans': 'Glas', 'sessions': ['Moderate'], 'progression': 'MidGame', 'Fabrik': '1010319'}, '1010207': {'trans': 'Fenster', 'sessions': ['Moderate'], 'progression': 'MidGame', 'Fabrik': '1010285'}, '1010193': {'trans': 'Rindfleisch', 'sessions': ['Moderate', 'Colony01'], 'progression': 'MidGame', 'Fabrik': '1010263'}, '1010198': {'trans': 'Paprika', 'sessions': ['Moderate'], 'progression': 'MidGame', 'Fabrik': '100654'}, '1010215': {'trans': 'Gulasch', 'sessions': ['Moderate'], 'progression': 'MidGame', 'Fabrik': '1010293'}, '1010217': {'trans': 'Fleischkonserven', 'sessions': ['Moderate'], 'progression': 'MidGame', 'Fabrik': '1010295'}, '1010229': {'trans': 'Zink', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010307'}, '1010230': {'trans': 'Kupfer', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010308'}, '1010204': {'trans': 'Messing', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010282'}, '1010246': {'trans': 'Taschenuhren', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010324'}, '1010251': {'trans': 'Zuckerrohr', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '1010329'}, '1010257': {'trans': 'Rum', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '1010340'}, '1010254': {'trans': 'Kakao', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '1010332'}, '1010239': {'trans': 'Zucker', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '1010317'}, '1010258': {'trans': 'Schokolade', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '1010341'}, '1010255': {'trans': 'Kautschuk', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '1010333'}, '1010245': {'trans': 'Hochräder', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010323'}, '1010231': {'trans': 'Zement', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010309'}, '1010202': {'trans': 'Stahlbeton', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010280'}, '1010243': {'trans': 'Glühfäden', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010321'}, '1010208': {'trans': 'Glühbirnen', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010286'}, '1010224': {'trans': 'Dampfmaschinen', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010302'}, '120014': {'trans': 'Trauben', 'sessions': ['Moderate'], 'progression': 'LateGame', 'Fabrik': '100655'}, '120016': {'trans': 'Sekt', 'sessions': ['Moderate'], 'progression': 'LateGame', 'Fabrik': '100659'}, '1010209': {'trans': 'Felle', 'sessions': ['Moderate'], 'progression': 'MidGame', 'Fabrik': '1010558'}, '1010253': {'trans': 'Baumwolle', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '1010331'}, '1010240': {'trans': 'Baumwollstoff', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '1010318'}, '1010247': {'trans': 'Pelzmäntel', 'sessions': ['Moderate'], 'progression': 'MidGame', 'Fabrik': '1010325'}, '1010252': {'trans': 'Tabak', 'sessions': ['Colony01'], 'progression': 'EarlyMidGame', 'Fabrik': '1010330'}, '1010242': {'trans': 'Holzfurnier', 'sessions': ['Moderate'], 'progression': 'LateGame', 'Fabrik': '1010320'}, '1010259': {'trans': 'Zigarren', 'sessions': ['Colony01'], 'progression': 'EarlyMidGame', 'Fabrik': '1010342'}, '1010248': {'trans': 'Phonographen', 'sessions': ['Moderate'], 'progression': 'LateGame', 'Fabrik': '1010326'}, '1010232': {'trans': 'Salpeter', 'sessions': ['Moderate'], 'progression': 'LateGame', 'Fabrik': '1010310'}, '1010222': {'trans': 'Dynamit', 'sessions': ['Moderate'], 'progression': 'LateGame', 'Fabrik': '1010300'}, '1010223': {'trans': 'Schwere Geschütze', 'sessions': ['Moderate'], 'progression': 'LateGame', 'Fabrik': '1010301'}, '1010256': {'trans': 'Perlen', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '1010339'}, '1010233': {'trans': 'Gold', 'sessions': ['Colony01', 'Arctic'], 'progression': 'LateMidGame', 'Fabrik': '1010311'}, '1010249': {'trans': 'Goldbarren', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '1010327'}, '1010250': {'trans': 'Schmuck', 'sessions': ['Moderate'], 'progression': 'LateGame', 'Fabrik': '1010328'}, '1010211': {'trans': 'Fahrgestelle', 'sessions': ['Moderate'], 'progression': 'LateGame', 'Fabrik': '1010289'}, '1010225': {'trans': 'Dampfwagen', 'sessions': ['Moderate'], 'progression': 'LateGame', 'Fabrik': '1010303'}, '120030': {'trans': 'Brillen', 'sessions': ['Moderate'], 'progression': 'LateMidGame', 'Fabrik': '101250'}, '120031': {'trans': 'Kaffeebohnen', 'sessions': ['Colony01'], 'progression': 'EarlyMidGame', 'Fabrik': '101251'}, '120032': {'trans': 'Kaffee', 'sessions': ['Colony01'], 'progression': 'EarlyMidGame', 'Fabrik': '101252'}, '120033': {'trans': 'Gebackene Bananen', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '101264'}, '120034': {'trans': 'Mais', 'sessions': ['Colony01'], 'progression': 'EarlyMidGame', 'Fabrik': '101270'}, '120035': {'trans': 'Tortillas', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '101271'}, '120036': {'trans': 'Alpakawolle', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '101272'}, '120037': {'trans': 'Melonen', 'sessions': ['Colony01'], 'progression': 'EarlyMidGame', 'Fabrik': '101273'}, '120041': {'trans': 'Bananen', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '101263'}, '120042': {'trans': 'Fischöl', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '101262'}, '120043': {'trans': 'Ponchos', 'sessions': ['Colony01'], 'progression': 'EarlyGame', 'Fabrik': '101266'}, '120044': {'trans': 'Filz', 'sessions': ['Colony01'], 'progression': 'EarlyMidGame', 'Fabrik': '101415'}, '112694': {'trans': 'Rentierfleisch', 'sessions': ['Arctic'], 'progression': 'EarlyGame', 'Fabrik': '112667'}, '112695': {'trans': 'Bärenfell', 'sessions': ['Arctic'], 'progression': 'EarlyMidGame', 'Fabrik': '112673'}, '112696': {'trans': 'Robbenfelle', 'sessions': ['Arctic'], 'progression': 'EarlyGame', 'Fabrik': '112674'}, '112697': {'trans': 'Gänsefedern', 'sessions': ['Arctic'], 'progression': 'EarlyGame', 'Fabrik': '112676'}, '112698': {'trans': 'Huskys', 'sessions': ['Arctic'], 'progression': 'EarlyMidGame', 'Fabrik': '112682'}, '112699': {'trans': 'Walöl', 'sessions': ['Arctic'], 'progression': 'EarlyGame', 'Fabrik': '112666'}, '112700': {'trans': 'Parkas', 'sessions': ['Arctic'], 'progression': 'EarlyMidGame', 'Fabrik': '112672'}, '112701': {'trans': 'Schlafsäcke', 'sessions': ['Arctic'], 'progression': 'EarlyGame', 'Fabrik': '112675'}, '112702': {'trans': 'Öllampen', 'sessions': ['Arctic'], 'progression': 'EarlyGame', 'Fabrik': '112679'}, '112703': {'trans': 'Hundeschlitten', 'sessions': ['Arctic'], 'progression': 'EarlyMidGame', 'Fabrik': '112680'}, '112704': {'trans': 'Schlitten', 'sessions': ['Arctic'], 'progression': 'EarlyMidGame', 'Fabrik': '112681'}, '112705': {'trans': 'Pemmikan', 'sessions': ['Arctic'], 'progression': 'EarlyGame', 'Fabrik': '112668'}, '112706': {'trans': 'Gas', 'sessions': ['Arctic'], 'progression': 'EarlyMidGame', 'Fabrik': '112690'}, '112518': {'trans': 'Schrott', 'sessions': ['Moderate', 'Colony01', 'Arctic'], 'progression': 'EarlyGame'}, '112520': {'trans': 'Schöner Schrott', 'sessions': ['Moderate', 'Colony01', 'Arctic'], 'progression': 'EarlyGame'}, '112523': {'trans': 'Besonderer Schrott', 'sessions': ['Moderate', 'Colony01', 'Arctic'], 'progression': 'EarlyGame'}, '115980': {'trans': 'Schrott verlorener Expeditionen', 'sessions': ['Arctic'], 'progression': 'EarlyGame'}, '114356': {'trans': 'Wanza-Bretter', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '122963'}, '114364': {'trans': 'Hibiskusblüten', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114447'}, '114365': {'trans': 'Leinsamen', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114448'}, '114367': {'trans': 'Tef', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114450'}, '114368': {'trans': 'Indigo', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114451'}, '114369': {'trans': 'Gewürze', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114452'}, '114370': {'trans': 'Bienenwachs', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114453'}, '114357': {'trans': 'Sanga-Kühe', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114439'}, '114371': {'trans': 'Ziegenmilch', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114456'}, '114358': {'trans': 'Salz', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114440'}, '117702': {'trans': 'Papier', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '117744'}, '114391': {'trans': 'Leinen', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114441'}, '114408': {'trans': 'Gewürzmehl', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114459'}, '117701': {'trans': 'Wachskerzen', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114461'}, '114359': {'trans': 'Trockenfleisch', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114444'}, '114401': {'trans': 'Gewänder', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114466'}, '114390': {'trans': 'Hibiskustee', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114468'}, '114402': {'trans': 'Lehmziegel', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114467'}, '114404': {'trans': 'Wandteppiche', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114469'}, '114410': {'trans': 'Meeresfrüchte-Eintopf', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114471'}, '114414': {'trans': 'Tonpfeifen', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114472'}, '117698': {'trans': 'Chroniken', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114470'}, '117699': {'trans': 'Laternen', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '114464'}, '118724': {'trans': 'Keramik', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '118725'}, '118728': {'trans': 'Hummer', 'sessions': ['Africa'], 'progression': 'EarlyGame', 'Fabrik': '118729'}, '114428': {'trans': 'Lederstiefel', 'sessions': ['Moderate'], 'progression': 'EarlyGame', 'Fabrik': '118733'}, '114430': {'trans': 'Maßanzüge', 'sessions': ['Moderate'], 'progression': 'EarlyGame', 'Fabrik': '118734'}, '114431': {'trans': 'Telefone', 'sessions': ['Moderate'], 'progression': 'EarlyGame', 'Fabrik': '118735'}}
                    
        def start(self):

            # get all products and collect some information about them
            product_GUIDS_list = self.assets_node.xpath("//Standard[GUID/text()='120055']/../ProductStorageList/ProductList/*/Product/text()") # all existing products
            for pr_GUID in product_GUIDS_list:
                trans = self.trans_node.xpath(f"//Text[GUID/text()='{pr_GUID}']/Text/text()")
                if trans: # only the ones with translation (afrika has no trans yet, as of 8.2)
                    node = self.assets_node.xpath(f"//Standard[GUID/text()='{pr_GUID}']")[0]
                    # print(node)
                    if not self.neu_product_GUIDS:
                        self.product_GUIDS[pr_GUID].update({"node":node}) # add the node
                    else:
                        self.product_GUIDS[pr_GUID] = {"trans":trans[0],"node":node}
                        sessions = node.xpath("../Product/AssociatedRegion/text()") # Moderate, Moderate;Colony01, Africa , Arctic, (kap is also moderate)
                        if sessions:
                            sessions = sessions[0].split(";")
                            self.product_GUIDS[pr_GUID]["sessions"] = sessions
                            progression = node.xpath("../Product/CivLevel/text()")
                            if progression:
                                progression = int(progression[0]) # 1 to 5, from EarlyGame to LateGame
                                self.product_GUIDS[pr_GUID]["progression"] = self.PROGRESSIONS[progression-1]
                        else:
                            print(f"product {pr_GUID} hat keine session/region?")

        
        def write_to_file(self,text,type="a"):
            # pass # testing
            with codecs.open("{}{}".format(self.out_dir, "mod_assets.xml"), type, encoding="utf-8") as out_file:
                out_file.write(text)
        
        def generate_vector(self,element,content=None,space=4,singleline=False):
            if content:
                enter = not singleline and "\n" or ""
                return f"""{space*' '}<{element}>{enter}{content}{enter}{not singleline and space*' ' or ''}</{element}>"""
            else:
                return f"""{space*' '}<{element} />"""
        def generate_mod_op(self,Type, Path=None, GUID=None, vector=""):
            Path = Path and f""" Path='{Path}'""" or ""
            GUID = GUID and f""" GUID='{GUID}'""" or ""
            return f"""\n  <ModOp Type='{Type}'{GUID}{Path}>\n{vector}\n  </ModOp>\n"""

        
        # baseprice anpassen:
        def write_mod_op_baseprice(self):
            for pr_GUID,info in self.product_GUIDS.items():
                pr_price = info["node"].xpath("../Product/BasePrice/text()")
                if pr_price and self.Total_UKosten.get(pr_GUID): # nur Produkte die unterhaltskosten haben, also auch eine Fabrik
                    pr_price = pr_price[0]
                    neu_baseprice = self.Total_UKosten[pr_GUID] / self.sell_dividend
                    # print(f"{info["trans"]} price alt: {pr_price}, neu: {neu_baseprice}") # im großen und ganzen ist self.Total_UKosten/0.8 okay.
                    vector = self.generate_vector("BasePrice",content=neu_baseprice,singleline=True)
                    modop = self.generate_mod_op("replace",Path=f"/Values/Product/BasePrice",GUID=pr_GUID,vector=vector)
                    self.write_to_file(modop)
        
        def write_mod_op_Traders(self): # call this after calc_UKosten, so we know if the product is sth we can produce ourself
            TraderNodes = self.assets_node.xpath("//Trader") # search for all 3rd party traders
            AI_Merchants_GUIDS = {}
            GoodsProduction_values = {}
            for TraderNode in TraderNodes: # find all traders and offeringgoods and GoodsProduction
                Template = TraderNode.xpath("../../Template/text()")
                CreateModeMeta = TraderNode.xpath("../Profile/CreateModeMeta/text()")
                if Template and (Template[0] == "Profile_3rdParty" or Template[0]=="Profile_3rdParty_Pirate" or Template[0]=="Profile_3rdParty_ItemCrafter") and (not CreateModeMeta or CreateModeMeta[0]!="AutoCreate_OnlyCampaign"):
                    AI_Merchants_GUID = TraderNode.xpath("../Standard/GUID/text()")[0]
                    is_goods_trader = TraderNode.xpath("GoodsTrader/text()")
                    if not is_goods_trader:# if it is not defined, the 3rdParty default value of 1 is used. Only if it is 0, it is no GoodsTrader
                        is_goods_trader = "1"
                    else:
                        is_goods_trader = is_goods_trader[0]
                    if is_goods_trader=="1":
                        # print(AI_Merchants_GUID)
                        AI_Merchants_GUIDS[AI_Merchants_GUID] = {}
                        sessions = TraderNode.xpath("../ThirdParty/AllowedRegions/text()")
                        if sessions:
                            sessions = sessions[0].split(";")
                            AI_Merchants_GUIDS[AI_Merchants_GUID]["sessions"] = sessions
                            if AI_Merchants_GUID=="77": # remove Arctiv from Nate, because there he does not sell any items and we dont want the Kap Nate to sell Arctic Goods.
                                try:
                                    AI_Merchants_GUIDS[AI_Merchants_GUID]["sessions"].remove("Arctic")
                                except Exception:
                                    pass
                        else:
                            print(f"merchant {AI_Merchants_GUID} hat keine session/region?")
                        GoodsProduction_values[AI_Merchants_GUID] = {}
                        for prog in self.PROGRESSIONS:
                            GoodsProduction_values[AI_Merchants_GUID][prog] = {}
                            Progression = TraderNode.xpath(f"Progression/{prog}")
                            if not Progression:
                                vector = self.generate_vector(f"{prog}")
                                modop = self.generate_mod_op("add",Path=f"/Values/Trader/Progression",GUID=AI_Merchants_GUID,vector=vector)
                                self.write_to_file(modop)
                            OfferingGoods = TraderNode.xpath(f"Progression/{prog}/OfferingGoods")
                            if not OfferingGoods:
                                vector = self.generate_vector("OfferingGoods")
                                modop = self.generate_mod_op("add",Path=f"/Values/Trader/Progression/{prog}",GUID=AI_Merchants_GUID,vector=vector)
                                self.write_to_file(modop)
                            GoodsProduction = TraderNode.xpath(f"Progression/{prog}/GoodsProduction")
                            if not GoodsProduction:
                                vector = self.generate_vector("GoodsProduction")
                                modop = self.generate_mod_op("add",Path=f"/Values/Trader/Progression/{prog}",GUID=AI_Merchants_GUID,vector=vector)
                                self.write_to_file(modop)
                            else: # already had GoodsProduction, then save the current productino values.
                                guids = GoodsProduction[0].xpath("Item/Good/text()")
                                ProductionPerMinutes = GoodsProduction[0].xpath("Item/ProductionPerMinute/text()")
                                GoodsProduction_values[AI_Merchants_GUID][prog] = dict(zip(guids, ProductionPerMinutes))
                            PreferedGoods = TraderNode.xpath(f"Progression/{prog}/PreferedGoods")
                            if not PreferedGoods:
                                vector = self.generate_vector("PreferedGoods")
                                modop = self.generate_mod_op("add",Path=f"/Values/Trader/Progression/{prog}",GUID=AI_Merchants_GUID,vector=vector)
                                self.write_to_file(modop)
            
            final = {}
            for AI_Merchants_GUID,merch_info in AI_Merchants_GUIDS.items():
                final[AI_Merchants_GUID] = {}
                item_vectors_dict = {}
                for pr_GUID,info in self.product_GUIDS.items():
                    if not self.Total_UKosten.get(pr_GUID): # nur produkte die wir herstellen können (zb kein Schrott usw)
                        continue
                    try:
                        progression_list = self.PROGRESSIONS[self.PROGRESSIONS.index(info["progression"]):] ## the first progression and all the following ones
                    except:
                        raise AssertionError(info)
                    for progression in progression_list:
                        
                        if progression not in item_vectors_dict:
                            item_vectors_dict[progression] = {"production":[],"offering":[]}
                        Good_vector = self.generate_vector("Good",pr_GUID,singleline=True,space=8)
                        
                        if len(set(merch_info["sessions"]).intersection(info["sessions"])) > 0 or pr_GUID in GoodsProduction_values[AI_Merchants_GUID][progression]: # if they have a region in common (nate at kap and arctic seems to be the same, so no possibility to differentiate? so kap will have artic stuff?)
                            if pr_GUID in GoodsProduction_values[AI_Merchants_GUID][progression]: # if the merchant already sells and produces this one, keep the old values for these
                                production = GoodsProduction_values[AI_Merchants_GUID][progression][pr_GUID]
                            else:
                                production = round(self.SLOW_PRODUCTION*(-6+len(progression_list)+self.PROGRESSIONS.index(progression)+1),3)  # increase the production rate every progression. So for every progression that contains that product, it will add additional production
                                if AI_Merchants_GUID in [45,46,78]: # since it are 3 merachnts in moderat, the production should be a little bit less than in other regions (pirates will have full production)
                                    production = round(production/2)
                            ProductionPerMinute_vector = self.generate_vector("ProductionPerMinute",production,singleline=True,space=8)
                            item_vector = self.generate_vector("Item",Good_vector+"\n"+ProductionPerMinute_vector,space=6)
                            item_vectors_dict[progression]["production"].append(item_vector)
                        
                        item_vector = self.generate_vector("Item",Good_vector,space=7)
                        item_vectors_dict[progression]["offering"].append(item_vector) # all goods, regardless of session, are added to offering (since it only helps displaying it)
                for progression, item_vectors_2 in item_vectors_dict.items():
                    item_vectors = "\n".join(item_vectors_2["production"])
                    GoodSets_item_vectors = "\n".join(item_vectors_2["offering"])
                    
                    if not progression in final[AI_Merchants_GUID]:
                        final[AI_Merchants_GUID][progression] = {"production":"","offering":""}
                    final[AI_Merchants_GUID][progression]["production"] += "\n"+item_vectors
                    final[AI_Merchants_GUID][progression]["offering"] += "\n"+GoodSets_item_vectors
                        
                        
            for AI_Merchants_GUID,info in final.items():            
                for progression, info2 in info.items():
                    
                    modop = self.generate_mod_op("replace",Path=f"/Values/Trader/Progression/{progression}/GoodsProduction",GUID=AI_Merchants_GUID,vector=self.generate_vector("GoodsProduction",info2["production"],space=4))
                    self.write_to_file(modop)
                    
                    GoodSets_vector = self.generate_vector("GoodSets",info2["offering"],space=6)
                    GoodSets_item_vector = self.generate_vector("Item",GoodSets_vector,space=5)
                    modop = self.generate_mod_op("replace",Path=f"/Values/Trader/Progression/{progression}/OfferingGoods",GUID=AI_Merchants_GUID,vector=self.generate_vector("OfferingGoods",GoodSets_item_vector,space=4))
                    self.write_to_file(modop)
        
        ##################
        ### change base prices
        ##################
        
        def calc_UKosten(self,neu_Fabrik_GUIDs=False):
            # ein paar zufügen, die hier wichtig sind, aber nicht in standardsotragelist sind:
            # self.product_GUIDS += ["1010566","270042"] # Öl,Treibstoff, öl ist baseprice 4, würde zu ~65 und Treibstoff ist BasePrice 1000 und würde zu ~160
            if neu_Fabrik_GUIDs:
                self.Fabrik_GUIDs = {} # wenn ichs neu ermitteln will
            
            ll = [ [] for pr_GUID in self.product_GUIDS ] # one list for every pr_GUID
            UKosten = dict(zip(self.product_GUIDS.keys(), ll))
            FactoryOutputsNodes = self.assets_node.xpath("//FactoryOutputs") # search for all FactoryOutputs
            for FONode in FactoryOutputsNodes:
                pr_GUIDs = FONode.xpath("Item/Product/text()") # usually only 1 product, but just to be sure
                Fabrik_GUID = FONode.xpath("../../Standard/GUID/text()")[0]
                if neu_Fabrik_GUIDs or (Fabrik_GUID in self.Fabrik_GUIDs): # nur vorausgewählte nehmen (oder neuberechnung)
                    Fabrik_trans = self.trans_node.xpath(f"//Text[GUID/text()='{Fabrik_GUID}']/Text/text()")
                    if Fabrik_trans and pr_GUIDs:
                        to_remove = []
                        for pr_GUID in pr_GUIDs:
                            if pr_GUID not in self.product_GUIDS:
                                print(f"{pr} ist nicht in product_GUIDS, wird produziert in {Fabrik_GUID} {Fabrik_trans}")
                                to_remove.append(pr_GUID)
                                continue
                            if self.neu_product_GUIDS:
                                self.product_GUIDS[pr_GUID]["Fabrik"] = Fabrik_GUID
                        pr_GUIDs = list(set(pr_GUIDs) - set(to_remove))
                        if not pr_GUIDs:# wenns danach leer ist
                            continue
                        Fabrik_trans = Fabrik_trans[0]
                        if neu_Fabrik_GUIDs:
                            self.Fabrik_GUIDs[Fabrik_GUID] = Fabrik_trans # to fill it if assets.xml changed
                        costs = None
                        costs_list = FONode.xpath("../../Maintenance/Maintenances/Item/text()")
                        for cost in costs_list:
                            m_pr = FONode.xpath("../../Maintenance/Maintenances/Item/Product/text()")
                            if m_pr:
                                try:
                                    index = m_pr.index("1010017")
                                except ValueError:
                                    print(f"Fabrik {Fabrik_GUID} {Fabrik_trans} hat keine Münzen maintenance?")
                                    continue
                                costs = FONode.xpath("../../Maintenance/Maintenances/Item/Amount/text()")
                                if costs:
                                    costs = float(costs[index])
                        if costs:
                            CycleTime = FONode.xpath("../CycleTime/text()")
                            if CycleTime:
                                CycleTime = float(CycleTime[0])
                            else: # seems to use a default value of 30 (kartoffel/fischerei usw)
                                CycleTime = 30
                            costs = costs * (CycleTime/60) # costs per output
                            amounts = FONode.xpath("Item/Amount/text()") # usually alawys amount 1, but just to be sure
                            amounts = [int(item) for item in amounts]
                            input_pr_GUIDs = FONode.xpath("../FactoryInputs/Item/Product/text()")
                            input_amounts = FONode.xpath("../FactoryInputs/Item/Amount/text()")
                            input_amounts = [int(item) for item in input_amounts]
                            if input_pr_GUIDs: # no input if it is a farm or sth like this
                                input_pr_am = dict(zip(input_pr_GUIDs, input_amounts))
                            pr_am = dict(zip(pr_GUIDs, amounts))
                            total_output_amount = sum(amounts) # most likely 1, but justo be sure
                            for pr,amount in pr_am.items():
                                multiplier = ((amount/total_output_amount)/amount) # to take care if there are multiple output products
                                if UKosten[pr]: 
                                    print(f"{pr} ist doppelt, jetzt wo mind. doppelt auch in {Fabrik_GUID} {Fabrik_trans}")
                                    continue
                                try:
                                    UKosten[pr].append( {"costs":costs, "multiplier": multiplier} )
                                except KeyError:
                                    print(f"product {pr} ist nicht in standardsotragelist?")
                                    continue
                                if input_pr_GUIDs:
                                    for input_pr,input_amount in input_pr_am.items():
                                        for i in range(input_amount):# for every amount, we add this input_pr once
                                            UKosten[pr].append( {"costs":UKosten[input_pr], "multiplier": multiplier} )
                        else: # zb 269951==silo_test
                            print(f"Fabrik {Fabrik_GUID} {Fabrik_trans} hat keine maintenance?")
                            continue
                    elif not pr_GUIDs:
                        print(f"Fabrik {Fabrik_GUID} hat keine factory output?")
                        continue
            
            if neu_Fabrik_GUIDs: # den neuen wert printen, damit ich ihn oben zb hardcoden kann
                print(self.Fabrik_GUIDs)
            
            def unpack_costs(c): # [{'costs': [{'costs': [{"costs":23,"multiplier":1}], 'multiplier': 1.0}, {'costs': 20.0, 'multiplier': 1.0}, {'costs': 20.0, 'multiplier': 1.0}], 'multiplier': 1.0}]
                kosten = 0
                if isinstance(c,list):
                    for cc in c:
                        if isinstance(cc["costs"],list):
                            cc["costs"] = unpack_costs(cc["costs"])
                        kosten += (cc["costs"]*cc["multiplier"])
                else:
                    kosten = c
                return kosten
            
            self.Total_UKosten = {}
            for pr_GUID, costs in UKosten.items():
                if costs: # kann [] sein, besonders fuer waren aus Afrika, wo noch keine produktionskosten in assets.xml stehen
                    self.Total_UKosten[pr_GUID] = unpack_costs(costs)
                    if self.Total_UKosten[pr_GUID]==0:
                        print(f"UKosten sind 0 fuer {pr_GUID}? {costs}") # erstmal printen, und sobald afrika dabei ist, gucken, ob noch immer was 0 ist
                
            return(self.Total_UKosten)
    
        def write_mod_op_ShipCosts(self):
            hardcode_money_prices = {} # am besten einmal alle ship_GUID printen und dann entscheiden, welches wieviel kosten sollte
            hardcode_money_prices["100437"] = 1000 # Kanonenboot
            hardcode_money_prices["100438"] = 1000 # schoner, can sell it for 2500, which is already near to material+1000. so no need to add sellable here
            hardcode_money_prices["100439"] = 2000 # Fregatte
            hardcode_money_prices["100441"] = 3000 # Klipper
            hardcode_money_prices["100440"] = 5000 # Linienschiff
            hardcode_money_prices["100442"] = 25000 # Schlachtkreuzer
            hardcode_money_prices["100443"] = 10000 # Monitor
            hardcode_money_prices["1010062"] = 10000 # Frachtschiff
            hardcode_money_prices["100853"] = 5000 # Öltanker
            hardcode_money_prices["114166"] = 17500 # Luftschiff
            hardcode_money_prices["102420"] = 2000 # Piraten Kanonenboot
            hardcode_money_prices["102421"] = 3500 # Piraten-​Fregatte
            hardcode_money_prices["102419"] = 8000 # Piraten Linienschiff
            hardcode_money_prices["102422"] = 15000 # Piraten Monitor
            hardcode_money_prices["102423"] = 15000 # Pyrphorischer Monitor
            hardcode_money_prices["102428"] = 20000 # Pyrphorisches Kriegsschiff
            hardcode_money_prices["102425"] = 40000 # Pyrphorischer Schlachtkreuzer
            hardcode_money_prices["102427"] = 6250 # Königliches Linienschiff, ~20% more than Linienschiff
            hardcode_money_prices["102455"] = 15000 # Extravaganter Dampfer
            hardcode_money_prices["118718"] = 15000 # Great Eastern
            
            ship_GUIDs = self.assets_node.xpath("//Values/Shipyard/AssemblyOptions/Item/Vehicle/text()")
            ship_GUIDs += self.assets_node.xpath("//Values/ShipyardUpgrade/AddAssemblyOptions/Item/NewOption/text()")
            for ship_GUID in ship_GUIDs:
                ship_node = self.assets_node.xpath(f"//Standard[GUID/text()='{ship_GUID}']")[0]
                Costs_node = ship_node.xpath("../Cost/Costs")
                if not Costs_node: # zb die schiffe die von einer BaseAssetGUID erben
                    base_GUID = ship_node.xpath("../../BaseAssetGUID/text()")[0]
                    if base_GUID:
                        base_ship_node = self.assets_node.xpath(f"//Standard[GUID/text()='{base_GUID}']")[0]
                        Costs_node_base = base_ship_node.xpath("../Cost/Costs")
                    if not Costs_node_base:
                        print(f"schiff {ship_GUID} hat auch in BaseAssetGUID {base_GUID} keine Costs?!")
                        continue
                    else:
                        Costs_node_base = Costs_node_base[0]
                        pr_GUIDs = Costs_node_base.xpath("Item/Ingredient/text()")
                        amounts = Costs_node_base.xpath("Item/Amount/text()")
                else:
                    Costs_node = Costs_node[0]
                    pr_GUIDs = Costs_node.xpath("Item/Ingredient/text()")
                    amounts = Costs_node.xpath("Item/Amount/text()")
                pr_am = dict(zip(pr_GUIDs, amounts))
                basecosts = 0
                other_costs_vector = ""
                for pr_GUID,amount in pr_am.items():
                    amount = int(amount)
                    if pr_GUID==1010017:
                        basecosts += amount
                    else:
                        basecosts += (self.Total_UKosten[pr_GUID] / self.sell_dividend) * amount # add the base price
                        ingr_vector = self.generate_vector("Ingredient",pr_GUID,space=6,singleline=True)
                        am_vector = self.generate_vector("Amount",amount,space=6,singleline=True)
                        item_vector = self.generate_vector("Item",ingr_vector+"\n"+am_vector,space=5)
                        other_costs_vector += "\n"+item_vector
                        
                if 1010017 not in pr_GUIDs: # if there is no money in yet
                    basecosts += hardcode_money_prices[ship_GUID]
                    ingr_vector = self.generate_vector("Ingredient",1010017,space=6,singleline=True)
                    am_vector = self.generate_vector("Amount",hardcode_money_prices[ship_GUID],space=6,singleline=True)
                    item_vector = self.generate_vector("Item",ingr_vector+"\n"+am_vector,space=5)
                    if len(Costs_node): # dann reicht ein add 
                        modop = self.generate_mod_op("add",Path="/Values/Cost/Costs",GUID=ship_GUID,vector=item_vector)
                    else: # dann Costs mit replace ersetzen
                        costs_vector = self.generate_vector("Costs",item_vector+"\n"+other_costs_vector,space=4)
                        cost_vector = self.generate_vector("Cost",costs_vector,space=3)
                        modop = self.generate_mod_op("replace",Path="/Values/Cost",GUID=ship_GUID,vector=cost_vector)
                    self.write_to_file(modop)
                Sellable_amount = ship_node.xpath("../Sellable/Baseprice/Item/Amount/text()")
                new_sell_price = round(basecosts * 3,-2) # round it to 100er # *3 because we will get only half of the price we enter here, because of SellPriceFactor 0.5. And I want to get *1.5 of the build costs.
                if Sellable_amount: # dann brauchen wir nur den Amount ändern, replace oder merge
                    Sellable_amount = Sellable_amount[0]
                    amount_vector = self.generate_vector("Amount",new_sell_price,space=4,singleline=True)
                    modop = self.generate_mod_op("replace",Path="/Values/Sellable/Baseprice/Item/Amount",GUID=ship_GUID,vector=amount_vector)
                    self.write_to_file(modop)
                else:# dann muessen wir ein komplettes Sellable zufügen... ist aber nur beim schoner der Fall, für den das Baseprice von 5000 ok ist.
                    print(f"ship {ship_GUID} has no sellable, which most likey means it sells for 5000 (2500). If this is not okay, add code to replace sellable")
                
                # print(f"Ship {ship_GUID} kostet an Material {basecosts}")
                
        
    
    b = builder()
    b.start()
    
    b.write_to_file("<ModOps>\n\n",type="w") # delete previous one
    
    Total_UKosten = b.calc_UKosten(neu_Fabrik_GUIDs=False)
    # print(Total_UKosten) # printen, wenn ich ihn oben neu hardcoden will
    b.write_mod_op_baseprice() # Total_UKosten müssen bekannt sein
    b.write_mod_op_Traders() # nach calc_UKosten aufrufen, damit wir wissen welche waren herstellbar sind (und so zb Schrott ausschließen)
    
    b.write_mod_op_ShipCosts() # rechnet die materialkosten der schiffe anhand des (neuen) basispreises zusammen, fügt einen hardgecodeden Geldwert zum bauen hinzu und setzen den sellprice = 2*baupreis
    
    # for pr_GUID,info in b.product_GUIDS.items():
        # del info["node"] # weil dies geprintet nichts bringt
    # print(b.product_GUIDS)
    
    
    b.write_to_file("\n\n</ModOps>")
        