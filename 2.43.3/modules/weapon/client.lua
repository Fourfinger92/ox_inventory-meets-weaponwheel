if not lib then return end

local Weapon = {}
local Items = require 'modules.items.client'
local Utils = require 'modules.utils.client'

-- generic group animation data
local anims = {}
anims[`GROUP_MELEE`] = { 'melee@holster', 'unholster', 200, 'melee@holster', 'holster', 600 }
anims[`GROUP_PISTOL`] = { 'reaction@intimidation@cop@unarmed', 'intro', 400, 'reaction@intimidation@cop@unarmed', 'outro', 450 }
anims[`GROUP_STUNGUN`] = anims[`GROUP_PISTOL`]

local function vehicleIsCycle(vehicle)
	local class = GetVehicleClass(vehicle)
	return class == 8 or class == 13
end

function Weapon.Equip(item, data, noWeaponAnim)
	local playerPed = cache.ped
	local coords = GetEntityCoords(playerPed, true)
    local sleep

	if client.weaponanims then
		if noWeaponAnim or (cache.vehicle and vehicleIsCycle(cache.vehicle)) then
			goto skipAnim
		end

		local anim = data.anim or anims[GetWeapontypeGroup(data.hash)]

		if anim == anims[`GROUP_PISTOL`] and not client.hasGroup(shared.police) then
			anim = nil
		end

		sleep = anim and anim[3] or 1200
		
		GiveWeaponToPed(playerPed, -1569615261, 0, false, true)--added by Holger

		Utils.PlayAnimAdvanced(sleep, anim and anim[1] or 'reaction@intimidation@1h', anim and anim[2] or 'intro', coords.x, coords.y, coords.z, 0, 0, GetEntityHeading(playerPed), 8.0, 3.0, sleep*2, 50, 0.1)
	end 

	::skipAnim::

	item.hash = data.hash
	item.ammo = data.ammoname
	item.melee = GetWeaponDamageType(data.hash) == 2 and 0
	item.timer = 0
	item.throwable = data.throwable
	item.group = GetWeapontypeGroup(item.hash)

	GiveWeaponToPed(playerPed, data.hash, 0, false, true)

	if item.metadata.tint then SetPedWeaponTintIndex(playerPed, data.hash, item.metadata.tint) end

	if item.metadata.components then
		for i = 1, #item.metadata.components do
			local components = Items[item.metadata.components[i]].client.component
			for v=1, #components do
				local component = components[v]
				if DoesWeaponTakeWeaponComponent(data.hash, component) then
					if not HasPedGotWeaponComponent(playerPed, data.hash, component) then
						GiveWeaponComponentToPed(playerPed, data.hash, component)
					end
				end
			end
		end
	end

	if item.metadata.specialAmmo then
		local clipComponentKey = ('%s_CLIP'):format(data.model:gsub('WEAPON_', 'COMPONENT_'))
		local specialClip = ('%s_%s'):format(clipComponentKey, item.metadata.specialAmmo:upper())

		if DoesWeaponTakeWeaponComponent(data.hash, specialClip) then
			GiveWeaponComponentToPed(playerPed, data.hash, specialClip)
		end
	end

	local ammo = item.metadata.ammo or item.throwable and 1 or 0

	SetCurrentPedWeapon(playerPed, data.hash, true)
	SetPedCurrentWeaponVisible(playerPed, true, false, false, false)
	SetWeaponsNoAutoswap(true)
	SetPedAmmo(playerPed, data.hash, ammo)
	SetTimeout(0, function() RefillAmmoInstantly(playerPed) end)

	if item.group == `GROUP_PETROLCAN` or item.group == `GROUP_FIREEXTINGUISHER` then
		item.metadata.ammo = item.metadata.durability
		SetPedInfiniteAmmo(playerPed, true, data.hash)
	end

	TriggerEvent('ox_inventory:currentWeapon', item)

	if client.weaponnotify then
		Utils.ItemNotify({ item, 'ui_equipped' })
	end

	return item, sleep
end

function Weapon.Disarm(currentWeapon, noAnim, waffenlos) --waffenlos added by Holger
	if currentWeapon?.timer then
		currentWeapon.timer = nil

        TriggerServerEvent('ox_inventory:updateWeapon')
		--SetPedAmmo(cache.ped, currentWeapon.hash, 0)		--disabled by Holger

		if client.weaponanims and not noAnim then
			if cache.vehicle and vehicleIsCycle(cache.vehicle) then
				goto skipAnim
			end

			ClearPedSecondaryTask(cache.ped)

			local item = Items[currentWeapon.name]
			local coords = GetEntityCoords(cache.ped, true)
			local anim = item.anim or anims[GetWeapontypeGroup(currentWeapon.hash)]

			if anim == anims[`GROUP_PISTOL`] and not client.hasGroup(shared.police) then
				anim = nil
			end

			local sleep = anim and anim[6] or 1400

			
			if waffenlos then		--if added by Holger
				GiveWeaponToPed(cache.ped, currentWeapon.hash, 0, false, true)
			end

			Utils.PlayAnimAdvanced(sleep, anim and anim[4] or 'reaction@intimidation@1h', anim and anim[5] or 'outro', coords.x, coords.y, coords.z, 0, 0, GetEntityHeading(cache.ped), 8.0, 3.0, sleep, 50, 0)
		end

		::skipAnim::

		if client.weaponnotify then
			Utils.ItemNotify({ currentWeapon, 'ui_holstered' })
		end

		TriggerEvent('ox_inventory:currentWeapon')
	end

--[[ 	Utils.WeaponWheel() --disabled by Holger
	RemoveAllPedWeapons(cache.ped, true)

	if client.parachute then
		local chute = `GADGET_PARACHUTE`
		GiveWeaponToPed(cache.ped, chute, 0, true, false)
		SetPedGadget(cache.ped, chute, true)
		SetPlayerParachuteTintIndex(PlayerData.id, client.parachute?[2] or -1)
	end ]]
end


--Holgers part starts


Weapon.triggerAnimation = function(waffenhashalt,waffenhashneu,wert)
	if wert then
		local playerPed = cache.ped
		local coords = GetEntityCoords(playerPed, true)
		local sleep

		if  (cache.vehicle and vehicleIsCycle(cache.vehicle)) then
			return
		end

		local anim = anims[GetWeapontypeGroup(waffenhashneu)]

		if anim == anims[`GROUP_PISTOL`] and not client.hasGroup(shared.police) then
			anim = nil
		end


		GiveWeaponToPed(playerPed, -1569615261, 0, false, true)

		sleep = anim and anim[3] or 1100

		Utils.PlayAnimAdvanced(sleep, anim and anim[1] or 'reaction@intimidation@1h', anim and anim[2] or 'intro', coords.x, coords.y, coords.z, 0, 0, GetEntityHeading(playerPed), 8.0, 3.0, sleep*2, 50, 0.1)

		GiveWeaponToPed(playerPed, waffenhashneu, 250, false, true)
		sleep = 0

	else
		if cache.vehicle and vehicleIsCycle(cache.vehicle) then
			return
		end
		local sleep


		ClearPedSecondaryTask(cache.ped)

		local coords = GetEntityCoords(cache.ped, true)
		local anim = anims[GetWeapontypeGroup(waffenhashalt)]

		if anim == anims[`GROUP_PISTOL`] and not client.hasGroup(shared.police) then
			anim = nil
		end


		local sleep = anim and anim[6] or 1000

		GiveWeaponToPed(cache.ped, waffenhashalt, 0, false, true)
		
		Utils.PlayAnimAdvanced(sleep, anim and anim[4] or 'reaction@intimidation@1h', anim and anim[5] or 'outro', coords.x, coords.y, coords.z, 0, 0, GetEntityHeading(cache.ped), 8.0, 3.0, sleep, 50, 0)
	end

end

--Holgers part ends

function Weapon.ClearAll(currentWeapon)
	Weapon.Disarm(currentWeapon)

	if client.parachute then
		local chute = `GADGET_PARACHUTE`
		GiveWeaponToPed(cache.ped, chute, 0, true, false)
		SetPedGadget(cache.ped, chute, true)
	end
end

Utils.Disarm = Weapon.Disarm
Utils.ClearWeapons = Weapon.ClearAll

--added by Holger thanks to 5Labs for providing the list

Weapon.WeaponByHash = {
	[-1768145561] = {
	["name"] = 'WEAPON_SPECIALCARBINE_MK2',
	["label"] = 'Special Carbine MK2',
	},
	[487013001] = {
	["name"] = 'WEAPON_PUMPSHOTGUN',
	["label"] = 'Pump Shotgun',
	},
	[-1075685676] = {
	["name"] = 'WEAPON_PISTOL_MK2',
	["label"] = 'Pistol MK2',
	},
	[-1238556825] = {
	["name"] = 'WEAPON_RAYMINIGUN',
	["label"] = 'Widowmaker',
	},
	[-1834847097] = {
	["name"] = 'WEAPON_DAGGER',
	["label"] = 'Dagger',
	},
	[-2067956739] = {
	["name"] = 'WEAPON_CROWBAR',
	["label"] = 'Crowbar',
	},
	[650961374] = {
	["name"] = 'WEAPON_TEARGAS',
	["label"] = 'Tear Gas',
	},
	[-618237638] = {
	["name"] = 'WEAPON_EMPLAUNCHER',
	["label"] = 'Compact EMP Launcher',
	},
	[-2084633992] = {
	["name"] = 'WEAPON_CARBINERIFLE',
	["label"] = 'Carbine Rifle',
	},
	[940833800] = {
	["name"] = 'WEAPON_STONE_HATCHET',
	["label"] = 'Stone Hatchet',
	},
	[-1716589765] = {
	["name"] = 'WEAPON_PISTOL50',
	["label"] = 'Pistol .50',
	},
	[-1716189206] = {
	["name"] = 'WEAPON_KNIFE',
	["label"] = 'Knife',
	},
	[1853742572] = {
	["name"] = 'WEAPON_PRECISIONRIFLE',
	["label"] = 'Precision Rifle',
	},
	[-1076751822] = {
	["name"] = 'WEAPON_SNSPISTOL',
	["label"] = 'SNS Pistol',
	},
	[1198879012] = {
	["name"] = 'WEAPON_FLAREGUN',
	["label"] = 'Flare Gun',
	},
	[-1355376991] = {
	["name"] = 'WEAPON_RAYPISTOL',
	["label"] = 'Up-n-Atomizer',
	},
	[-1813897027] = {
	["name"] = 'WEAPON_GRENADE',
	["label"] = 'Grenade',
	},
	[1737195953] = {
	["name"] = 'WEAPON_NIGHTSTICK',
	["label"] = 'Nightstick',
	},
	[1198256469] = {
	["name"] = 'WEAPON_RAYCARBINE',
	["label"] = 'Unholy Hellbringer',
	},
	[465894841] = {
	["name"] = 'WEAPON_PISTOLXM3',
	["label"] = 'WM 29 Pistol',
	},
	[1432025498] = {
	["name"] = 'WEAPON_PUMPSHOTGUN_MK2',
	["label"] = 'Pump Shotgun MK2',
	},
	[100416529] = {
	["name"] = 'WEAPON_SNIPERRIFLE',
	["label"] = 'Sniper Rifle',
	},
	[1593441988] = {
	["name"] = 'WEAPON_COMBATPISTOL',
	["label"] = 'Glock',
	},
	[-581044007] = {
	["name"] = 'WEAPON_MACHETE',
	["label"] = 'Machete',
	},
	[-275439685] = {
	["name"] = 'WEAPON_DBSHOTGUN',
	["label"] = 'Double Barrel Shotgun',
	},
	[-1063057011] = {
	["name"] = 'WEAPON_SPECIALCARBINE',
	["label"] = 'Special Carbine',
	},
	[-1951375401] = {
	["name"] = 'WEAPON_FLASHLIGHT',
	["label"] = 'Flashlight',
	},
	[727643628] = {
	["name"] = 'WEAPON_CERAMICPISTOL',
	["label"] = 'Ceramic Pistol',
	},
	[584646201] = {
	["name"] = 'WEAPON_APPISTOL',
	["label"] = 'AP Pistol',
	},
	[-1045183535] = {
	["name"] = 'WEAPON_REVOLVER',
	["label"] = 'Revolver',
	},
	[-22923932] = {
	["name"] = 'WEAPON_RAILGUNXM3',
	["label"] = 'Railgun XM3',
	},
	[324215364] = {
	["name"] = 'WEAPON_MICROSMG',
	["label"] = 'Micro SMG',
	},
	[-1600701090] = {
	["name"] = 'WEAPON_BZGAS',
	["label"] = 'BZ Gas',
	},
	[-1168940174] = {
	["name"] = 'WEAPON_HAZARDCAN',
	["label"] = 'Hazard Can',
	},
	[-608341376] = {
	["name"] = 'WEAPON_COMBATMG_MK2',
	["label"] = 'Combat MG MK2',
	},
	[-538741184] = {
	["name"] = 'WEAPON_SWITCHBLADE',
	["label"] = 'Switchblade',
	},
	[984333226] = {
	["name"] = 'WEAPON_HEAVYSHOTGUN',
	["label"] = 'Heavy Shotgun',
	},
	[1785463520] = {
	["name"] = 'WEAPON_MARKSMANRIFLE_MK2',
	["label"] = 'Marksman Rifle MK2',
	},
	[2024373456] = {
	["name"] = 'WEAPON_SMG_MK2',
	["label"] = 'SMG Mk2',
	},
	[1649403952] = {
	["name"] = 'WEAPON_COMPACTRIFLE',
	["label"] = 'Compact Rifle',
	},
	[615608432] = {
	["name"] = 'WEAPON_MOLOTOV',
	["label"] = 'Molotov',
	},
	[600439132] = {
	["name"] = 'WEAPON_BALL',
	["label"] = 'Ball',
	},
	[-952879014] = {
	["name"] = 'WEAPON_MARKSMANRIFLE',
	["label"] = 'Marksman Rifle',
	},
	[-610080759] = {
	["name"] = 'WEAPON_METALDETECTOR',
	["label"] = 'Metal Detector',
	},
	[2017895192] = {
	["name"] = 'WEAPON_SAWNOFFSHOTGUN',
	["label"] = 'Sawn Off Shotgun',
	},
	[-1568386805] = {
	["name"] = 'WEAPON_GRENADELAUNCHER',
	["label"] = 'Grenade Launcher',
	},
	[-270015777] = {
	["name"] = 'WEAPON_ASSAULTSMG',
	["label"] = 'Assault SMG',
	},
	[-1466123874] = {
	["name"] = 'WEAPON_MUSKET',
	["label"] = 'Musket',
	},
	[-37975472] = {
	["name"] = 'WEAPON_SMOKEGRENADE',
	["label"] = 'Smoke Grenade',
	},
	[-1654528753] = {
	["name"] = 'WEAPON_BULLPUPSHOTGUN',
	["label"] = 'Bullpup Shotgun',
	},
	[1317494643] = {
	["name"] = 'WEAPON_HAMMER',
	["label"] = 'Hammer',
	},
	[137902532] = {
	["name"] = 'WEAPON_VINTAGEPISTOL',
	["label"] = 'Vintage Pistol',
	},
	[-853065399] = {
	["name"] = 'WEAPON_BATTLEAXE',
	["label"] = 'Battle Axe',
	},
	[-1660422300] = {
	["name"] = 'WEAPON_MG',
	["label"] = 'Machine Gun',
	},
	[1470379660] = {
	["name"] = 'WEAPON_GADGETPISTOL',
	["label"] = 'Perico Pistol',
	},
	[-1853920116] = {
	["name"] = 'WEAPON_NAVYREVOLVER',
	["label"] = 'Navy Revolver',
	},
	[94989220] = {
	["name"] = 'WEAPON_COMBATSHOTGUN',
	["label"] = 'Combat Shotgun',
	},
	[2144741730] = {
	["name"] = 'WEAPON_COMBATMG',
	["label"] = 'Combat MG',
	},
	[317205821] = {
	["name"] = 'WEAPON_AUTOSHOTGUN',
	["label"] = 'Sweeper Shotgun',
	},
	[883325847] = {
	["name"] = 'WEAPON_PETROLCAN',
	["label"] = 'Gas Can',
	},
	[-1357824103] = {
	["name"] = 'WEAPON_ADVANCEDRIFLE',
	["label"] = 'Advanced Rifle',
	},
	[736523883] = {
	["name"] = 'WEAPON_SMG',
	["label"] = 'SMG',
	},
	[205991906] = {
	["name"] = 'WEAPON_HEAVYSNIPER',
	["label"] = 'Heavy Sniper',
	},
	[-1312131151] = {
	["name"] = 'WEAPON_RPG',
	["label"] = 'RPG',
	},
	[-771403250] = {
	["name"] = 'WEAPON_HEAVYPISTOL',
	["label"] = 'Heavy Pistol',
	},
	[-879347409] = {
	["name"] = 'WEAPON_REVOLVER_MK2',
	["label"] = 'Revolver MK2',
	},
	[-494615257] = {
	["name"] = 'WEAPON_ASSAULTSHOTGUN',
	["label"] = 'Assault Shotgun',
	},
	[-947031628] = {
	["name"] = 'WEAPON_HEAVYRIFLE',
	["label"] = 'Heavy Rifle',
	},
	[-1420407917] = {
	["name"] = 'WEAPON_PROXMINE',
	["label"] = 'Proximity Mine',
	},
	[-619010992] = {
	["name"] = 'WEAPON_MACHINEPISTOL',
	["label"] = 'Machine Pistol',
	},
	[-1746263880] = {
	["name"] = 'WEAPON_DOUBLEACTION',
	["label"] = 'Double Action Revolver',
	},
	[125959754] = {
	["name"] = 'WEAPON_COMPACTLAUNCHER',
	["label"] = 'Compact Grenade Launcher',
	},
	[2132975508] = {
	["name"] = 'WEAPON_BULLPUPRIFLE',
	["label"] = 'Bullpup Rifle',
	},
	[-86904375] = {
	["name"] = 'WEAPON_CARBINERIFLE_MK2',
	["label"] = 'Carbine Rifle MK2',
	},
	[453432689] = {
	["name"] = 'WEAPON_PISTOL',
	["label"] = 'Pistol',
	},
	[-1074790547] = {
	["name"] = 'WEAPON_ASSAULTRIFLE',
	["label"] = 'Assault Rifle',
	},
	[1627465347] = {
	["name"] = 'WEAPON_GUSENBERG',
	["label"] = 'Gusenberg',
	},
	[911657153] = {
	["name"] = 'WEAPON_STUNGUN',
	["label"] = 'Tazer',
	},
	[-1121678507] = {
	["name"] = 'WEAPON_MINISMG',
	["label"] = 'Mini SMG',
	},
	[171789620] = {
	["name"] = 'WEAPON_COMBATPDW',
	["label"] = 'Combat PDW',
	},
	[1141786504] = {
	["name"] = 'WEAPON_GOLFCLUB',
	["label"] = 'Golf Club',
	},
	[1834241177] = {
	["name"] = 'WEAPON_RAILGUN',
	["label"] = 'Railgun',
	},
	[1119849093] = {
	["name"] = 'WEAPON_MINIGUN',
	["label"] = 'Minigun',
	},
	[961495388] = {
	["name"] = 'WEAPON_ASSAULTRIFLE_MK2',
	["label"] = 'Assault Rifle MK2',
	},
	[406929569] = {
	["name"] = 'WEAPON_FERTILIZERCAN',
	["label"] = 'Fertilizer Can',
	},
	[1233104067] = {
	["name"] = 'WEAPON_FLARE',
	["label"] = 'Flare',
	},
	[419712736] = {
	["name"] = 'WEAPON_WRENCH',
	["label"] = 'Wrench',
	},
	[-2009644972] = {
	["name"] = 'WEAPON_SNSPISTOL_MK2',
	["label"] = 'SNS Pistol MK2',
	},
	[-102973651] = {
	["name"] = 'WEAPON_HATCHET',
	["label"] = 'Hatchet',
	},
	[-2066285827] = {
	["name"] = 'WEAPON_BULLPUPRIFLE_MK2',
	["label"] = 'Bullpup Rifle MK2',
	},
	[-1169823560] = {
	["name"] = 'WEAPON_PIPEBOMB',
	["label"] = 'Pipe Bomb',
	},
	[1703483498] = {
	["name"] = 'WEAPON_CANDYCANE',
	["label"] = 'Candy Cane',
	},
	[-598887786] = {
	["name"] = 'WEAPON_MARKSMANPISTOL',
	["label"] = 'Marksman Pistol',
	},
	[350597077] = {
	["name"] = 'WEAPON_TECPISTOL',
	["label"] = 'Tactical SMG',
	},
	[-1786099057] = {
	["name"] = 'WEAPON_BAT',
	["label"] = 'Bat',
	},
	[2138347493] = {
	["name"] = 'WEAPON_FIREWORK',
	["label"] = 'Firework Launcher',
	},
	[-1658906650] = {
	["name"] = 'WEAPON_MILITARYRIFLE',
	["label"] = 'Military Rifle',
	},
	[-656458692] = {
	["name"] = 'WEAPON_KNUCKLE',
	["label"] = 'Knuckle Dusters',
	},
	[126349499] = {
	["name"] = 'WEAPON_SNOWBALL',
	["label"] = 'Snow Ball',
	},
	[177293209] = {
	["name"] = 'WEAPON_HEAVYSNIPER_MK2',
	["label"] = 'Heavy Sniper MK2',
	},
	[-774507221] = {
	["name"] = 'WEAPON_TACTICALRIFLE',
	["label"] = 'Tactical Rifle',
	},
	[101631238] = {
	["name"] = 'WEAPON_FIREEXTINGUISHER',
	["label"] = 'Fire Extinguisher',
	},
	[-102323637] = {
	["name"] = 'WEAPON_BOTTLE',
	["label"] = 'Bottle',
	},
	[741814745] = {
	["name"] = 'WEAPON_STICKYBOMB',
	["label"] = 'Sticky Bomb',
	},
	[1672152130] = {
	["name"] = 'WEAPON_HOMINGLAUNCHER',
	["label"] = 'Homing Launcher',
	},
	[-1810795771] = {
	["name"] = 'WEAPON_POOLCUE',
	["label"] = 'Pool Cue',
	},
}


return Weapon
