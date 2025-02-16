local assets =
{
    Asset("ANIM", "anim/baton.zip"),
    Asset("ANIM", "anim/swap_baton.zip"),

    Asset("ANIM", "anim/spell_icons_winona.zip"),
}

local prefabs =
{
    "reticuleaoecatapultvolley",
    "reticuleaoecatapultvolleyping",
    "reticuleaoecatapultelementalvolley",
    "reticuleaoecatapultwakeup",
    "reticuleaoecatapultwakeupping",
    "reticuleaoewinonaengineeringping",
    "reticuleaoehostiletarget_1d25",
    "winona_battery_sparks",
}

local function ShouldRepeatCast(inst, doer)
	return not inst:HasTag("usesdepleted")
end


local function ForEachInstruments(inst, doer, pos, fn)
	local success = false
    if doer and doer.components.orchestra then
        local instruments = doer.components.orchestra:GetInstruments() or {}
        for i, v in ipairs(instruments) do
            if fn(inst, doer, pos, v) then
				success = true
			end
        end
    end
	return success
end

local function VolleyUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
	reticule.Transform:SetPosition(pos:Get())
	if reticule.prefab == "reticuleaoecatapultvolleyping" then
		ForEachCatapult(inst, nil, pos, TryPingVolley)
	else
		TriggerDeployHelpers(pos.x, 0, pos.z, 64, nil, reticule)
	end
end

local function ReticuleTargetAllowWaterFn()
	local player = ThePlayer
	local ground = TheWorld.Map
	local pos = Vector3()
	--Cast range is 30, leave room for error
	--15 is the aoe range
	for r = 10, 0, -.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
			return pos
		end
	end
	return pos
end

local function TryTarget(inst, doer, pos, instrument)
	local min_range = TUNING.WINONA_CATAPULT_MIN_RANGE
	if instrument:GetDistanceSqToPoint(pos) >= min_range * min_range then
		return true
	end
	return false
end


local function SetTargetSpellFn(inst, doer, pos)
	if ForEachInstruments(inst, doer, pos, TryTarget) then
		return true
	end
	return false, "NO_CATAPULTS"
end


local function StartAOETargeting(inst)
	local playercontroller = ThePlayer.components.playercontroller
	if playercontroller ~= nil then
		playercontroller:StartAOETargetingUsing(inst)
	end
end

local ICON_SCALE = .6
local SPELLBOOK_RADIUS = 100
local SPELLBOOK_FOCUS_RADIUS = SPELLBOOK_RADIUS + 2

local SPELLS =
{
    {
        label = STRINGS.ENGINEER_REMOTE.VOLLEY,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.ENGINEER_REMOTE.VOLLEY)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(ShouldRepeatCast)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoecatapultvolley"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoecatapultvolleyping"
            -- inst.components.aoetargeting.reticule.updatepositionfn = VolleyUpdatePositionFn
            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX("reticuleaoehostiletarget_1d25")
                inst.components.aoespell:SetSpellFn(SetTargetSpellFn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
        bank = "spell_icons_winona",
        build = "spell_icons_winona",
        anims =
        {
            idle = { anim = "icon_target" },
            focus = { anim = "icon_target_focus", loop = true },
            down = { anim = "icon_target_pressed" },
            disabled = { anim = "icon_target_disabled" },
        },
        clicksound = "meta4/winona_UI/select",
        widget_scale = ICON_SCALE
    },
}


local function RefreshAttunedSkills(inst, owner)
    -- local skilltreeupdater = owner and owner.components.skilltreeupdater or nil
    local skilltreeupdater = owner or nil
    if skilltreeupdater then
        -- if inst.components.channelcastable == nil then
        --     inst:AddComponent("channelcastable")
        --     inst.components.channelcastable:SetStrafing(false)
        -- end
        if inst.components.aoespell == nil then
            inst:AddComponent("aoespell")
        end
        if TheWorld.ismastersim then
            if inst.components.spellbook == nil then
                inst:AddComponent("spellbook")
                inst.components.spellbook:SetRequiredTag("conductor")
                inst.components.spellbook:SetRadius(SPELLBOOK_RADIUS)
                inst.components.spellbook:SetFocusRadius(SPELLBOOK_FOCUS_RADIUS) --UIAnimButton don't use focus radius SPELLBOOK_FOCUS_RADIUS)
                inst.components.spellbook:SetItems(SPELLS)
                inst.components.spellbook.opensound = "meta4/winona_UI/open"
                inst.components.spellbook.closesound = "meta4/winona_UI/close"
                inst.components.spellbook.focussound = "meta4/winona_UI/hover"
            end
            if inst.components.aoetargeting == nil then
                inst:AddComponent("aoetargeting")
                inst.components.aoetargeting:SetAllowWater(true)
                inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
                inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
                inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
                inst.components.aoetargeting.reticule.ease = true
                inst.components.aoetargeting.reticule.mouseenabled = true
                inst.components.aoetargeting.reticule.twinstickmode = 1
                inst.components.aoetargeting.reticule.twinstickrange = 8
            end
        end
    else
        if owner then
            -- inst:RemoveComponent("channelcastable")
            inst:RemoveComponent("aoespell")
            if TheWorld.ismastersim then
                inst:RemoveComponent("spellbook")
                inst:RemoveComponent("aoetargeting")
            end
        end
    end
end

-- local function WatchSkillRefresh(inst, owner)
--     if inst._owner then
--         inst:RemoveEventCallback("onactivateskill_server", inst._onskillrefresh, inst._owner)
--         inst:RemoveEventCallback("ondeactivateskill_server", inst._onskillrefresh, inst._owner)
--     end
--     inst._owner = owner
--     if owner then
--         inst:ListenForEvent("onactivateskill_server", inst._onskillrefresh, owner)
--         inst:ListenForEvent("ondeactivateskill_server", inst._onskillrefresh, owner)
--     end
-- end

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_baton", inst.GUID, "swap_baton")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_baton", "swap_baton")
    end
    if owner.components.orchestra then
        owner.components.orchestra:ShowInstruments()
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner:AddTag("readytoperform")

    -- WatchSkillRefresh(inst, owner)
    RefreshAttunedSkills(inst, owner)
end

local function onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
    if owner.components.orchestra then
        owner.components.orchestra:HideInstruments()
    end
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner:RemoveTag("readytoperform")

    -- WatchSkillRefresh(inst, nil)
    RefreshAttunedSkills(inst, nil)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("baton")
    inst.AnimState:SetBuild("baton")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")

    local floater_swap_data = { sym_build = "swap_baton" }
    MakeInventoryFloatable(inst, "med", 0.05, { 0.8, 0.4, 0.8 }, true, -12, floater_swap_data)

    inst.scrapbook_subcat = "tool"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.FISHINGROD_DAMAGE)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.restrictedtag = "conductor"
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst._onskillrefresh = function(owner) RefreshAttunedSkills(inst, owner) end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("baton", fn, assets)
