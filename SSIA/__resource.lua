-- Sandy Shores International Airport (SSIA)
-- Map by KINGBOUGHEY: https://www.gta5-mods.com/maps/sandy-shores-international-airport-map-editor-menyoo-low-fps-kingboughey

-- Standalone Resource for FiveM
-- Converted and finalized by GlitchDetector for Transport Tycoon

-- Contains a generated YMAP from the Spooner XML
-- Contains a modified Map Editor XML
-- Contains a customized XML object loader (that only loads certain props)
-- Contains 18 add-on props from "addonprops" by Meth0d & Quechus13: https://www.gta5-mods.com/tools/addonprops
-- Certain props, such as the gates and tanker trailers have been removed due to weird behavior.
-- Stunt Props and other props in the object loader have been removed from the YMAP to prevent duplicate loading.
-- Big thanks to the people at the FiveM forums and FiveM discord for help on getting this thing working

description 'Sandy Shores International Airport (SSIA) by Kingboughey, Meth0d, Quechus13 & GlitchDetector'

resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"
this_is_a_map 'yes'

local function object_entry_stunt(data)

	file(data)
	object_loader_stunt(data)
end

client_script {
	'object_loader.lua',
	'xml.lua',
}

object_entry_stunt 'SSIA No Vehicles.xml'

data_file 'DLC_ITYP_REQUEST' 'stream/props.ytyp'