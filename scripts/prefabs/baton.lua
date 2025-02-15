local assets =
{
    Asset("ANIM", "anim/baton.zip"),
    Asset("ANIM", "anim/swap_baton.zip"),
}

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

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("baton", fn, assets)
