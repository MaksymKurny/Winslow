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

local function OnEatFood(owner, health_delta, hunger_delta, sanity_delta, food, feeder)
	if food:HasTag("monstermeat") then
		return health_delta, hunger_delta, sanity_delta
	end
	return health_delta > 0 and health_delta or 0, hunger_delta > 0 and hunger_delta or 0,
			sanity_delta > 0 and sanity_delta or 0
end

local function OnAttacked(inst)
	if math.random() < TUNING.INST_SHATTER_CHANCE then
		local pet_list = inst.components.orchestra:GetInstruments() or {}

		if #pet_list > 0 then
			local random_pet = pet_list[math.random(#pet_list)]
			if random_pet and random_pet.RemoveWinslowPet then
				random_pet:RemoveWinslowPet()
			end
		end

		if inst.components.sanity then
			inst.components.sanity:DoDelta(-TUNING.SANITY_TINY)
		end
	end
end

local function RemoveWinslowPets(inst)
	local todespawn = inst.components.orchestra:GetInstruments(true) or {}
	for i, v in ipairs(todespawn) do
		v:RemoveWinslowPet()
	end
end

local function OnAllyAttacked(inst)
	if inst and inst.components.health and not inst.components.health:IsDead() and inst._sanity_watcher and inst._sanity_watcher.components.sanity then
		inst._sanity_watcher.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
	end
end

local POWERPOINT_MUST_TAGS = { "player" }
local POWERPOINT_CAN_TAGS = { "INLIMBO", "FX", "playerghost" }

local function UpdateWatchList(inst)
	if not TheWorld.ismastersim then return end

	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, TUNING.ALLY_INFLUENCE_RADIUS, POWERPOINT_MUST_TAGS, POWERPOINT_CAN_TAGS)

	for entity, _ in pairs(inst._watching) do
		if not table.contains(ents, entity) then
			entity:RemoveEventCallback("attacked", OnAllyAttacked)
			inst._watching[entity] = nil
		end
	end

	for _, entity in ipairs(ents) do
		if not inst._watching[entity] then
			inst._watching[entity] = true
			entity._sanity_watcher = inst
			entity:ListenForEvent("attacked", OnAllyAttacked)
		end
	end
end

local common_postinit = function(inst)
	inst:AddTag("conductor")
	inst.MiniMapEntity:SetIcon("winslow.tex")
end

local master_postinit = function(inst)
	inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	inst.soundsname = "wilson"

	inst.components.health:SetMaxHealth(TUNING.WINSLOW_HEALTH)
	inst.components.hunger:SetMax(TUNING.WINSLOW_HUNGER)
	inst.components.sanity:SetMax(TUNING.WINSLOW_SANITY)

	inst.components.foodaffinity:AddPrefabAffinity("spoiled_food", -TUNING.AFFINITY_15_CALORIES_VERYHUGE)

	if inst.components.eater ~= nil then
		inst.components.eater.custom_stats_mod_fn = OnEatFood
	end

	inst:AddComponent("orchestra")

	inst:ListenForEvent("ms_playerreroll", RemoveWinslowPets)
	inst:ListenForEvent("death", RemoveWinslowPets)

	inst._watching = {}
	inst:DoPeriodicTask(1, UpdateWatchList)
	inst:ListenForEvent("attacked", OnAttacked)

	inst.OnLoad = onload
	inst.OnNewSpawn = onload
end

return MakePlayerCharacter("winslow", prefabs, assets, common_postinit, master_postinit, prefabs)
