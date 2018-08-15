local objectSets = {}
local spawns = {}
local currentParseName, currentParseResource

function DeleteObject(object)
	return Citizen.InvokeNative(0x539E0AE3E6634B9F, Citizen.PointerValueIntInitialized(object))
end

local function getSetLoader(sets)
	return function()
		-- request all the models
		for _,obj in ipairs(sets) do
			RequestModel(obj.hash)
		end

		-- make sure all the models are loaded
		while true do
			local loaded = true

			Citizen.Wait(0)

			for _,obj in ipairs(sets) do
				if not HasModelLoaded(obj.hash) then
					loaded = false
					break
				end
			end

			if loaded then
				break
			end
		end
	end
end

local function clearObjectSet(set)
	for _, obj in ipairs(set) do
		if obj.object then
			DeleteObject(obj.object)
		end

		SetModelAsNoLongerNeeded(obj.hash)
	end
end

-- object streamer
local function isNearObject(p1, obj, maxDist)
	local diff = obj.pos - p1
	local dist = (diff.x * diff.x) + (diff.y * diff.y)

	return (dist < (maxDist * maxDist))
end

--for now, this only includes toll/security booth gates
local function isObjectADoor(objHash)
    doorNames = {
                "prop_railway_barrier_01", "prop_railway_barrier_02",
                "prop_sec_barrier_ld_01a", "prop_sec_barrier_ld_02a",
                "prop_sec_barier_01a",
                "prop_sec_barier_02a", "prop_sec_barier_02b",
                "prop_sec_barier_03a", "prop_sec_barier_03b",
                "prop_sec_barier_04a", "prop_sec_barier_04b"
    }

    for k, v in pairs(doorNames) do
        if GetHashKey(v) == objHash then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)

		-- spawn objects
		local pos = GetEntityCoords(GetPlayerPed(-1))

		for k, sets in pairs(objectSets) do
			for i, obj in ipairs(sets) do
				local shouldHave = isNearObject(pos, obj, 3000)

				if shouldHave and not obj.object then
                    local o
                    local door = isObjectADoor(obj.hash)

                    o = CreateObjectNoOffset(obj.hash, obj.pos, false,
                        false, door)

					if o then
						SetEntityRotation(o, obj.rot, 2, true)
						--FreezeEntityPosition(o, not door)

						obj.object = o
					end
				elseif not shouldHave and obj.object then
					DeleteObject(obj.object)
					obj.object = nil
				end

				if (i % 75) == 0 then
					Citizen.Wait(15)
				end
			end
		end
	end
end)

local function registerObjectSpawn(name, pos, heading)
	local t = {
		name = name,
		filename = currentParseName,
		owner = currentParseResource,
		spawnPos = { pos.x, pos.y, pos.z },
		heading = heading
	}

	table.insert(spawns, t)

	TriggerEvent('objectLoader:onSpawnLoaded', t)
end

function getSpawns()
	return spawns
end

local function createObject(data)
	-- a no-op
	return data
end

local function parseIniObjectSet(data)
	local i = parseIni(data)
	local a = {}

	for k, v in pairs(i) do
		if v.Model then
			table.insert(a, createObject({
				pos = vector3(tonumber(v.x), tonumber(v.y), tonumber(v.z) + tonumber(v.h)),
				rot = quat(tonumber(v.qx), tonumber(v.qy), tonumber(v.qz), tonumber(v.qw)),
				hash = tonumber(v.Model)
			}))
		end
	end

	registerObjectSpawn(currentParseName, vector3(
		tonumber(i.Player.x),
		tonumber(i.Player.y),
		tonumber(i.Player.z)),
	0.0)

	return a
end

local stuntProps = {
	121220643,
	1152255454,
	3453068267,
	702363064,
	1433896578,
	2407289523,
	552628848,
	867375093,
	2209848793,
	1917226454,
	3060364316,
	275222712,
	572929077,
	1874201716,
	2674715617,
	2353120651,
	3729249628,
	2955498176,
	3254777453,
	2360708057,
	3131434941,
	2749086249,
	3292101667,
	2682888379,
	3660001399,
	4025342980,
	514111857,
	3670547238,
	1034909591,
	4036118202,
	3375458752,
	1807115326,
	1231757224,
	2421304693,
	1577011408,
	775743912,
	8851005,
	1681773169,
	1872357673,
	3633003274,
	3865335484,
	456802407,
	3396574939,
	2414979540,
	2688633459,
	4082430109,
	2173570317,
	57414813,
	905017767,
	1000408330,
	1852009102,
	1616301685,
	2467181539,
	834628502,
	3213554001,
	3848856321,
	3549473092,
	3554787315,
	1487912627,
	2371528712,
	1961391908,
	460484791,
	1058039257,
	676870249,
	2408856974,
	2102302979,
	1594832215,
	2408701808,
	2018816246,
	3003688541,
	2641001249,
	2356009260,
	574046431,
	3797008144,
	467114592,
	3807123503,
	4111842434,
	2937166252,
	17078901,
	420668111,
	8119097,
	2772630293,
	310508364,
	4056830028,
	4001732176,
	2388984703,
	1217634719,
	2589596876,
	3301124110,
	3860064701,
	3734792899,
	1840346984,
	1509937157,
	1356119471,
	1051072850,
	1692096969,
	3153727096,
	1981283394,
	1385612163,
	729675090,
	267992649,
	432230877,
	4166516932,
	1077125729,
	194750283,
	502647807,
	796159740,
	961545722,
	1725554957,
	421053840,
	1202496179,
	92741229,
	876477402,
	3585162095,
	994275129,
	3930104175,
	275835867,
	3760529737,
	2877436326,
	3766066068,
	305168129,
	1424175123,
	3950374244,
	2152088064,
	437430754,
	3360612091,
	3053468254,
	2310136254,
	2749394351,
	550397829,
	4002644752,
	1534483676,
	1764816977,
	1317576424,
	4029799261,
	55410908,
	3714430221,
	74396054,
	2088651031,
	2010842635,
	1413933094,
	2795242278,
	340516484,
	574716527,
	4060518906,
	1872926000,
	3684751657,
	596212035,
	569327829,
	3787764121,
	2728080929,
	3958327496,
	795338997,
	1612877521,
	936459356,
	2281486687,
	895663090,
	3865058786,
	2115358035,
	2501623494,
	1757476573,
	3742454444,
	1990229224,
	2102470706,
	1558653929,
	1966970935,
	3824957154,
	45036260,
	4259081603,
	2854484063,
	2542156769,
	2302058306,
	4181284058,
	4107119683,
	3749937583,
	290088252,
	2064415974,
	1439605076,
	953784960,
	3421199051,
	3719888486,
	1013503655,
	634984916,
	2722701694,
	874264154,
	3962015530,
	1260020750,
	2917601738,
	1021429661,
	173040327,
	2748033227,
	427196615,
	2949562265,
	4026183196,
	2692796649,
	2056002078,
	456296435,
	3763623269,
}
local DIV, SUBT = (2^31) + 1, (2^32)
-- n MUST be an integer!
local function convert(n)
    -- the math.floor() evaluates to 0 for integers 0 through 2^31;
    -- else it is 1 and SUBT is subtracted.
    return n - (math.floor(n / DIV) * SUBT)
end

local function isModelAStuntProp(hash)
	for _, sph in next, stuntProps do
		if sph == hash or GetHashKey(hash) == GetHashKey(sph) or convert(sph) == hash then
			print("Model " .. hash .. " is a stunt prop!")
			return true
		end
	end
	return false
end

local function parseMapEditorXml(xml)
	local a = {}

	for _,obj in ipairs(xml.Objects[1].MapObject) do
		if obj.Type[1] == 'Prop' then
			if isModelAStuntProp(tonumber(obj.Hash[1])) then
				table.insert(a, createObject({
					pos = vector3(tonumber(obj.Position[1].X[1]), tonumber(obj.Position[1].Y[1]), tonumber(obj.Position[1].Z[1])),
					rot = vector3(tonumber(obj.Rotation[1].X[1]), tonumber(obj.Rotation[1].Y[1]), tonumber(obj.Rotation[1].Z[1])),
					hash = tonumber(obj.Hash[1])
				}))
			end
		end
	end

	if xml.Metadata then
		registerObjectSpawn(xml.Metadata[1].Name[1], vector3(
			tonumber(xml.Metadata[1].TeleportPoint[1].X[1]),
			tonumber(xml.Metadata[1].TeleportPoint[1].Y[1]),
			tonumber(xml.Metadata[1].TeleportPoint[1].Z[1])),
		tonumber(xml.Metadata[1].TeleportPoint[1].Heading[1]))
	end

	return a
end

local function parseSpoonerXml(xml)
	local a = {}

	for _,obj in ipairs(xml.Placement) do
		if obj.Type[1] == '3' then
			table.insert(a, createObject({
				pos = vector3(tonumber(obj.PositionRotation[1].X[1]), tonumber(obj.PositionRotation[1].Y[1]), tonumber(obj.PositionRotation[1].Z[1])),
				rot = vector3(tonumber(obj.PositionRotation[1].Pitch[1]), tonumber(obj.PositionRotation[1].Roll[1]), tonumber(obj.PositionRotation[1].Yaw[1])),
				hash = tonumber(obj.ModelHash[1])
			}))
		end
	end

	if xml.ReferenceCoords then
		registerObjectSpawn(currentParseName, vector3(
			tonumber(xml.ReferenceCoords[1].X[1]),
			tonumber(xml.ReferenceCoords[1].Y[1]),
			tonumber(xml.ReferenceCoords[1].Z[1])),
		0.0)
	end

	return a
end

local function processXml(el)
	local v = {}
	local text

	for _,kid in ipairs(el.kids) do
		if kid.type == 'text' then
			text = kid.value
		elseif kid.type == 'element' then
			if not v[kid.name] then
				v[kid.name] = {}
			end

			table.insert(v[kid.name], processXml(kid))
		end
	end

	v._ = el.attr

	if #el.attr == 0 and #el.el == 0 then
		v = text
	end

	return v
end

local function parseObjectSet(data)
	print("Data processing")
	local xml = SLAXML:dom(data)

	print("Checks")
	if xml and xml.root then
		if xml.root.name == 'Map' then
			print("Parsing XML as Map Editor")
			return parseMapEditorXml(processXml(xml.root))
		elseif xml.root.name == 'SpoonerPlacements' then
			print("Parsing XML as Spooner")
			return parseSpoonerXml(processXml(xml.root))
		else
			print("Failed to parse XML")
			return {}
		end
	else
		-- ini maps don't work due to quaternions being weird
		--return parseIniObjectSet(data)
		print("Failed to parse file")
		return {}
	end
end

AddEventHandler('onClientResourceStart', function(name)
	local metaEntries = GetNumResourceMetadata(name, 'object_loader_stunt')

	if not metaEntries then
		return
	end

	currentParseResource = name

	local sets = {}

	for i = 0, metaEntries - 1 do
		local fileName = GetResourceMetadata(name, 'object_loader_stunt', i)
		local data = LoadResourceFile(name, fileName)
		print("Loading map: " .. fileName)

		currentParseName = fileName

		if data then
			print("Setting up map")
			local newset = parseObjectSet(data)
			print("Generated " .. #newset .. " entries")
			table.merge(sets, newset)
		else
			print("Map contained no data")
		end
	end

	objectSets[name] = sets

	Citizen.CreateThread(getSetLoader(sets))
end)

AddEventHandler('onClientResourceStop', function(name)
	if objectSets[name] then
		clearObjectSet(objectSets[name])
	end
end)

-- mapmanager support
local mapObjectSets = {}
local mapObjectSet = 1

AddEventHandler('getMapDirectives', function(add, resource)
	local function addMap(state, data)
        local set = parseObjectSet(data)

        Citizen.CreateThread(getSetLoader(set))

        mapObjectSets[mapObjectSet] = set
        state.set = mapObjectSet

        mapObjectSet = mapObjectSet + 1
	end

	local function undoMap(state, arg)
        clearObjectSet(mapObjectSets[state.set])
        mapObjectSets[state.set] = nil
    end

    add('object_data', addMap, undoMap)

	if not resource then
		return
	end

	-- if no owning resource was specified, don't add the object_file directive
    add('object_loader_2', function(state, name)
        local data = LoadResourceFile(resource, name)
        addMap(state, data)
    end, undoMap)
end)

function table.merge(t1, t2)
	for k,v in ipairs(t2) do
		table.insert(t1, v)
	end
end

-- ini parser
--[[
	Copyright (c) 2012 Carreras Nicolas

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]
--- Lua INI Parser.
-- It has never been that simple to use INI files with Lua.
--@author Dynodzzo

--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function parseIni(fileData)
	local function lines(str)
		local t = {}
		local function helper(line) table.insert(t, line) return "" end
		helper((str:gsub("(.-)\r?\n", helper)))
		return t
	end

	local data = {};
	local section;
	for _, line in ipairs(lines(fileData)) do
		local tempSection = line:match('^%[([^%[%]]+)%]$');
		if(tempSection)then
			section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
			data[section] = data[section] or {};
		end
		local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
		if(param and value ~= nil)then
			if(tonumber(value))then
				value = tonumber(value);
			elseif(value == 'true')then
				value = true;
			elseif(value == 'false')then
				value = false;
			end
			if(tonumber(param))then
				param = tonumber(param);
			end
			data[section][param] = value;
		end
	end
	return data;
end
