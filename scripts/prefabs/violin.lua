local assets =
{
    Asset("ANIM", "anim/lightflier.zip"),
}

local prefabs = {
    "lightbulb",
    "wormwood_lunar_transformation_finish",
}

local brain = require "brains/violin"

local function finish_transformed_life(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local bulb = SpawnPrefab("lightbulb")
    bulb.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(bulb)

    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetPosition(ix, iy, iz)

    inst:Remove()
end

local FORMATION_MAX_SPEED = 10.5
local FORMATION_RADIUS = 3.5
local FORMATION_ROTATION_SPEED = 0.5
local function OnUpdate(inst, dt)
    local leader = inst.components.follower and inst.components.follower:GetLeader() or nil
    if leader and leader.orchestra_pattern and inst.brain and not inst.brain.stopped then
        local index = (leader.orchestra_pattern[inst] or 1) - 1
        local maxpets = leader.orchestra_pattern.maxpets

        local theta = (index / maxpets) * TWOPI + GetTime() * FORMATION_ROTATION_SPEED
        local lx, ly, lz = leader.Transform:GetWorldPosition()

        lx, lz = lx + FORMATION_RADIUS * math.cos(theta), lz + FORMATION_RADIUS * math.sin(theta)

        local px, py, pz = inst.Transform:GetWorldPosition()
        local dx, dz = px - lx, pz - lz
        local dist = math.sqrt(dx * dx + dz * dz)

        inst.components.locomotor.walkspeed = math.min(dist * 8, FORMATION_MAX_SPEED)
        inst:FacePoint(lx, 0, lz)
        if inst.updatecomponents[inst.components.locomotor] == nil then
            inst.components.locomotor:WalkForward(true)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst, 1, 0.5)

    inst.DynamicShadow:SetSize(1, .5)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("lightflier")
    inst.AnimState:SetBuild("lightflier")

    inst.scrapbook_deps = { "violin" }

    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
    inst:AddTag("orchestra")

    inst:AddTag("NOBLOCK")
    inst:AddTag("notraptrigger")
    inst:AddTag("winslow_pet")
    inst:AddTag("noauradamage")
    inst:AddTag("soulless")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -- inst._formation_distribution_toggle = nil
    -- inst._find_target_task = nil
    inst._time_since_formation_attacked = -TUNING.LIGHTFLIER.ON_ATTACKED_ALERT_DURATION

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = TUNING.LIGHTFLIER.WALK_SPEED
    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:SetStateGraph("SGviolin")
    inst:SetBrain(brain)

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")
    inst:AddComponent("homeseeker")

    MakeSmallBurnableCharacter(inst, "lightbulb")
    MakeSmallFreezableCharacter(inst, "lightbulb")

    local follower = inst:AddComponent("follower")
    follower:KeepLeaderOnAttacked()
    follower.keepdeadleader = true
    follower.keepleaderduringminigame = true

    inst.SoundEmitter:PlaySound("grotto/creatures/light_bug/fly_LP", "loop")

    inst.no_spawn_fx = true
    inst.RemoveWinslowPet = finish_transformed_life

    local updatelooper = inst:AddComponent("updatelooper")
    updatelooper:AddOnUpdateFn(OnUpdate)

    return inst
end

return Prefab("violin", fn, assets, prefabs)
