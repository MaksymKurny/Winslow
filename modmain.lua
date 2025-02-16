PrefabFiles = {
    "winslow",
    "winslow_none",
    "baton",
    "musical_instruments",
    "winslow_orchestraproxy",
}

Assets = {
    Asset("IMAGE", "images/inventoryimages/winslow.tex"),
    Asset("ATLAS", "images/inventoryimages/winslow.xml"),
    Asset("ATLAS_BUILD", "images/inventoryimages/winslow.xml", 256),

    Asset("IMAGE", "images/saveslot_portraits/winslow.tex"),
    Asset("ATLAS", "images/saveslot_portraits/winslow.xml"),

    Asset("IMAGE", "images/selectscreen_portraits/winslow.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/winslow.xml"),

    Asset("IMAGE", "images/selectscreen_portraits/winslow_silho.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/winslow_silho.xml"),

    Asset("IMAGE", "bigportraits/winslow.tex"),
    Asset("ATLAS", "bigportraits/winslow.xml"),

    Asset("IMAGE", "images/map_icons/winslow.tex"),
    Asset("ATLAS", "images/map_icons/winslow.xml"),

    Asset("IMAGE", "images/avatars/avatar_winslow.tex"),
    Asset("ATLAS", "images/avatars/avatar_winslow.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_winslow.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_winslow.xml"),

    Asset("IMAGE", "images/avatars/self_inspect_winslow.tex"),
    Asset("ATLAS", "images/avatars/self_inspect_winslow.xml"),

    Asset("IMAGE", "images/names_winslow.tex"),
    Asset("ATLAS", "images/names_winslow.xml"),

    Asset("IMAGE", "images/names_gold_winslow.tex"),
    Asset("ATLAS", "images/names_gold_winslow.xml"),

    Asset("IMAGE", "images/winslow_skilltree.tex"),
    Asset("ATLAS", "images/winslow_skilltree.xml"),
}

AddMinimapAtlas("images/map_icons/winslow.xml")

local env = env
local modimport = modimport
local AddClassPostConstruct = AddClassPostConstruct
local AddComponentPostInit = AddComponentPostInit
local AddModCharacter = AddModCharacter
local GetModConfigData = GetModConfigData
local STRINGS = GLOBAL.STRINGS

modimport("scripts/strings")
modimport("scripts/tuning")
modimport("scripts/recipes")

local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = { 0, -25 }
    },
}

GLOBAL.setfenv(1, GLOBAL)

AddComponentPostInit("petleash", function(self)
    self.maxpetspertag = nil
    self.numpetspertag = nil
    local onremovepet = self._onremovepet
    self._onremovepet = function(pet)
        if self.pets[pet] ~= nil then
            local noTag = true
            for tag, _ in pairs(self.numpetspertag) do
                if pet:HasTag(tag) then
                    self.numpetspertag[tag] = self.numpetspertag[tag] - 1
                    noTag = false
                end
            end
            if noTag then
                onremovepet(pet)
            else
                self.pets[pet] = nil

                if self.onpetremoved ~= nil then
                    self.onpetremoved(self.inst, pet)
                end
            end
        end
    end


    function self:SetMaxPetsForTag(tag, maxpets)
        self.maxpetspertag = self.maxpetspertag or {}
        self.maxpetspertag[tag] = maxpets

        self.numpetspertag = self.numpetspertag or {}
        self.numpetspertag[tag] = self.numpetspertag[tag] or 0
    end

    function self:GetMaxPetsForTag(tag)
        if self.maxpetspertag == nil then
            return 0
        end

        return self.maxpetspertag[tag] or 0
    end

    function self:GetNumPetsForTag(tag)
        if self.numpetspertag == nil then
            return 0
        end

        return self.numpetspertag and self.numpetspertag[tag] or 0
    end

    function self:IsFullForTag(tag)
        return self:GetNumPetsForTag(tag) >= self:GetMaxPetsForTag(tag)
    end

    function self:GetPetsWithTag(tag)
        if self:GetNumPetsForTag(tag) == 0 then
            return nil
        end

        local pets = {}
        for k, v in pairs(self.pets) do
            if v:HasTag(tag) then
                table.insert(pets, v)
            end
        end

        return pets
    end

    local function LinkPet(self, pet)
        self.pets[pet] = pet
        if self:IsPetAPrefabLimitedOne(pet.prefab) then
            self.numpetsperprefab[pet.prefab] = self.numpetsperprefab[pet.prefab] + 1
        else
            local noTag = true
            for tag, _ in pairs(self.numpetspertag) do
                if pet:HasTag(tag) then
                    self.numpetspertag[tag] = self.numpetspertag[tag] + 1
                    noTag = false
                end
            end
            if noTag then
                self.numpets = self.numpets + 1
            end
        end
        self.inst:ListenForEvent("onremove", self._onremovepet, pet)
        pet.persists = false

        if self.inst.components.leader ~= nil then
            self.inst.components.leader:AddFollower(pet)
        end
    end

    function self:SpawnPetAt(x, y, z, prefaboverride, skin)
        local prefab = prefaboverride or self.petprefab
        if prefab == nil then
            return nil
        end
        if self:IsPetAPrefabLimitedOne(prefab) then
            if self:IsFullForPrefab(prefab) then
                return nil
            end
        else
            for tag, _ in pairs(self.numpetspertag) do
                if self:IsFullForTag(tag) then
                    return nil
                end
            end
            if self:IsFull() then
                return nil
            end
        end

        local pet = SpawnPrefab(prefab, skin, nil, self.inst.userid)
        if pet ~= nil then
            LinkPet(self, pet)

            if pet.Physics ~= nil then
                pet.Physics:Teleport(x, y, z)
            elseif pet.Transform ~= nil then
                pet.Transform:SetPosition(x, y, z)
            end

            if self.onspawnfn ~= nil then
                self.onspawnfn(self.inst, pet)
            end
        end

        return pet
    end

    function self:OnLoad(data)
        if data ~= nil and data.pets ~= nil then
            for i, v in ipairs(data.pets) do
                v.is_snapshot_save_record = self.inst.is_snapshot_user_session
                local pet = SpawnSaveRecord(v)
                v.is_snapshot_save_record = nil
                if pet ~= nil then
                    LinkPet(self, pet)

                    if self.onspawnfn ~= nil then
                        self.onspawnfn(self.inst, pet)
                    end
                end
            end
            if self.inst.migrationpets ~= nil then
                for k, v in pairs(self.pets) do
                    table.insert(self.inst.migrationpets, v)
                end
            end
        end
    end
end)

local SkillTreeDefs = require("prefabs/skilltree_defs")
local _MakeNoShadowLock = SkillTreeDefs.FN.MakeNoShadowLock
SkillTreeDefs.FN.MakeNoShadowLock = function(extra_data, not_root)
    local lock = _MakeNoShadowLock(extra_data, not_root)
    lock.lock_open = function(prefabname, activatedskills, readonly)
        if SkillTreeDefs.FN.CountTags(prefabname, "shadow_favor", activatedskills) == 0 and SkillTreeDefs.FN.CountTags(prefabname, "rejected_favor", activatedskills) == 0 then
            return true
        end

        return nil -- Important to return nil and not false.
    end
    return lock
end

local _MakeNoLunarLock = SkillTreeDefs.FN.MakeNoLunarLock
SkillTreeDefs.FN.MakeNoLunarLock = function(extra_data, not_root)
    local lock = _MakeNoLunarLock(extra_data, not_root)
    lock.lock_open = function(prefabname, activatedskills, readonly)
        if SkillTreeDefs.FN.CountTags(prefabname, "lunar_favor", activatedskills) == 0 and SkillTreeDefs.FN.CountTags(prefabname, "rejected_favor", activatedskills) == 0 then
            return true
        end

        return nil -- Important to return nil and not false.
    end
    return lock
end

SkillTreeDefs.FN.MakeAllLock = function(extra_data, not_root)
    local lock = {
        desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_6_DESC,
        root = not not_root,
        group = "allegiance",
        tags = { "allegiance", "lock" },
        lock_open = function(prefabname, activatedskills, readonly)
            if readonly then
                return "question"
            end

            return TheGenericKV:GetKV("fuelweaver_killed") == "1" and
                TheGenericKV:GetKV("celestialchampion_killed") == "1"
        end,
    }

    if extra_data then
        lock.pos = extra_data.pos
        lock.connects = extra_data.connects
        lock.group = extra_data.group or lock.group
    end

    return lock
end

SkillTreeDefs.FN.MakeRejectedAllLock = function(extra_data, not_root)
    local lock = {
        desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_7_DESC,
        root = not not_root,
        group = "allegiance",
        tags = { "allegiance", "lock" },
        lock_open = function(prefabname, activatedskills, readonly)
            if SkillTreeDefs.FN.CountTags(prefabname, "shadow_favor", activatedskills) == 0 and SkillTreeDefs.FN.CountTags(prefabname, "lunar_favor", activatedskills) == 0 then
                return true
            end

            return nil -- Important to return nil and not false.
        end,
    }

    if extra_data then
        lock.pos = extra_data.pos
        lock.connects = extra_data.connects
        lock.group = extra_data.group or lock.group
    end

    return lock
end

env.RegisterSkilltreeBGForCharacter("images/winslow_skilltree.xml", "winslow")
local CreateSkillTree = function()
    local BuildSkillsData = require("prefabs/skilltree_winslow")
    if BuildSkillsData then
        local data = BuildSkillsData(SkillTreeDefs.FN)

        if data then
            for name, data in pairs(data.SKILLS) do
                if not data.lock_open and data.icon then
                    RegisterSkilltreeIconsAtlas("images/winslow_skilltree.xml", data.icon .. ".tex")
                end
            end
            SkillTreeDefs.CreateSkillTreeFor("winslow", data.SKILLS)
            SkillTreeDefs.SKILLTREE_ORDERS["winslow"] = data.ORDERS
        end
    end
end
CreateSkillTree();

env.AddModCharacter("winslow", "MALE", skin_modes)
