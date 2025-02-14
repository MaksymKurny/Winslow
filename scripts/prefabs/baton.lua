local assets =
{
    Asset("ANIM", "anim/fishingrod.zip"),
    Asset("ANIM", "anim/swap_fishingrod.zip"),
}

local function onequip (inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_fishingrod", inst.GUID, "swap_fishingrod")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_fishingrod", "swap_fishingrod")
    end

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("fishingrod")
    inst.AnimState:SetBuild("fishingrod")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")

    local floater_swap_data = {sym_build = "swap_fishingrod"}
    MakeInventoryFloatable(inst, "med", 0.05, {0.8, 0.4, 0.8}, true, -12, floater_swap_data)

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
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("baton", fn, assets)
