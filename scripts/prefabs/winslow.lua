local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WINSLOW = {
	"baton"
}

local prefabs =
{
	"winslow_orchestraproxy_violin",
}


local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WINSLOW
end
local prefabs = FlattenTree(start_inv, true)

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "winslow_speed_mod", 1)
end

local function onbecameghost(inst)
	inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "winslow_speed_mod")
end

local function onload(inst)
	inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
	inst:ListenForEvent("ms_becameghost", onbecameghost)

	if inst:HasTag("playerghost") then
		onbecameghost(inst)
	else
		onbecamehuman(inst)
	end
end

local function WLFSort(a, b) -- Better than roundcheck!
	return a.GUID < b.GUID
end

local function RecalculateOrchestraPattern(inst)
	local pets = inst.components.petleash and inst.components.petleash:GetPetsWithTag("orchestra") or nil
	if pets then
		inst.orchestra_pattern = pets
		table.sort(pets, WLFSort)
		for i, v in ipairs(pets) do
			pets[v] = i
		end
		pets.maxpets = #pets
	else
		inst.orchestra_pattern = nil
	end
end

local function OnSpawnPet(inst, pet)
	print("spawn")
	inst:RecalculateOrchestraPattern()

	if inst._OnSpawnPet ~= nil then
		inst:_OnSpawnPet(pet)
	end
end

local function OnDespawnPet(inst, pet)
	inst:RecalculateOrchestraPattern()

	if inst._OnDespawnPet ~= nil then
		inst:_OnDespawnPet(pet)
	end
end

local function OnEatFood(owner, health_delta, hunger_delta, sanity_delta, food, feeder)
	if food:HasTag("monstermeat") then
		return health_delta, hunger_delta, sanity_delta
	end
	return health_delta > 0 and health_delta or 0, hunger_delta > 0 and hunger_delta or 0,
			sanity_delta > 0 and sanity_delta or 0
end
local function OnRemovedPet(inst, pet)
	inst:RecalculateOrchestraPattern()
end

local function RemoveWinslowPets(inst)
	local todespawn = {}
	for k, v in pairs(inst.components.petleash:GetPets()) do
		if v:HasTag("winslow_pet") then
			table.insert(todespawn, v)
		end
	end
	for i, v in ipairs(todespawn) do
		v:RemoveWinslowPet()
	end
end

local common_postinit = function(inst)
	inst:AddTag("conductor")
	inst:AddTag("roteater")
	inst.MiniMapEntity:SetIcon("winslow.tex")
end

local master_postinit = function(inst)
	inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	inst.soundsname = "wilson"

	inst.components.health:SetMaxHealth(TUNING.WINSLOW_HEALTH)
	inst.components.hunger:SetMax(TUNING.WINSLOW_HUNGER)
	inst.components.sanity:SetMax(TUNING.WINSLOW_SANITY)

	-- inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.GENERIC, 1)
	-- inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.MEAT, 1)
	-- inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.VEGGIE, 1)
	-- inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.SEEDS, 1)
	-- inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.BERRY, 1)
	-- inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.RAW, 1)
	-- inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.GOODIES, 1)

	if inst.components.eater ~= nil then
		inst.components.eater.custom_stats_mod_fn = OnEatFood
	end

	if inst.components.petleash ~= nil then
		inst._OnSpawnPet = inst.components.petleash.onspawnfn
		inst._OnDespawnPet = inst.components.petleash.ondespawnfn
	else
		inst:AddComponent("petleash")
	end
	local petleash = inst.components.petleash
	petleash:SetOnSpawnFn(OnSpawnPet)
	petleash:SetOnDespawnFn(OnDespawnPet)
	petleash:SetOnRemovedFn(OnRemovedPet)
	petleash:SetMaxPetsForTag("orchestra", TUNING.ORCHESTRA_LIMIT)
	-- petleash:SetMaxPets(TUNING.ORCHESTRA_LIMIT)

	inst:ListenForEvent("ms_playerreroll", RemoveWinslowPets)
	inst:ListenForEvent("death", RemoveWinslowPets)

	inst.RecalculateOrchestraPattern = RecalculateOrchestraPattern

	inst.OnLoad = onload
	inst.OnNewSpawn = onload
end

return MakePlayerCharacter("winslow", prefabs, assets, common_postinit, master_postinit, prefabs)
