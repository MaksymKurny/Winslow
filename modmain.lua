PrefabFiles = {
    "winslow",
    "winslow_none",
    "baton",
    "violin",
    "winslow_orchestraproxy",
}

Assets = {
    Asset("IMAGE", "images/inventoryimages/winslow.tex"),
    Asset("ATLAS", "images/inventoryimages/winslow.xml"),

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
}

AddMinimapAtlas("images/map_icons/winslow.xml")

local env = env
local modimport = modimport
local AddClassPostConstruct = AddClassPostConstruct
local AddComponentPostInit = AddComponentPostInit
local AddModCharacter = AddModCharacter
local AddRecipe2 = AddRecipe2
local GetModConfigData = GetModConfigData

GLOBAL.setfenv(1, GLOBAL)

modimport("scripts/strings")
modimport("scripts/tuning")

local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = { 0, -25 }
    },
}

AddComponentPostInit("petleash", function(self)
    self.maxpetspertag = nil
    self.numpetspertag = nil


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

AddModCharacter("winslow", "MALE", skin_modes)


local atlas = "images/inventoryimages/winslow.xml"
AddRecipe2("violin", { Ingredient("nightmarefuel", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "violin.tex",
        product = "winslow_orchestraproxy_violin",
        sg_state =
        "spawn_mutated_creature",
        actionstr = "TRANSFORM",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")), "HASPET"
        end
    },
    { "CHARACTER" })
AddRecipe2("drum", { Ingredient("nightmarefuel", 1), Ingredient("pigskin", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "drum.tex",
        product = "winslow_orchestraproxy_drum",
        sg_state =
        "spawn_mutated_creature",
        actionstr = "TRANSFORM",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")), "HASPET"
        end
    },
    { "CHARACTER" })
AddRecipe2("clarinet", { Ingredient("nightmarefuel", 2), Ingredient("transistor", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "clarinet.tex",
        product = "winslow_orchestraproxy_clarinet",
        sg_state =
        "spawn_mutated_creature",
        actionstr = "TRANSFORM",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")), "HASPET"
        end
    },
    { "CHARACTER" })
AddRecipe2("bass", { Ingredient("nightmarefuel", 2), Ingredient("livinglog", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "clarinet.tex",
        product = "winslow_orchestraproxy_bass",
        sg_state =
        "spawn_mutated_creature",
        actionstr = "TRANSFORM",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")), "HASPET"
        end
    },
    { "CHARACTER" })
AddRecipe2("trombone", { Ingredient("nightmarefuel", 2), Ingredient("goldnugget", 1) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "trombone.tex",
        product = "winslow_orchestraproxy_trombone",
        sg_state =
        "spawn_mutated_creature",
        actionstr = "TRANSFORM",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")), "HASPET"
        end
    },
    { "CHARACTER" })
AddRecipe2("guitar", { Ingredient("nightmarefuel", 2), Ingredient("log", 4) }, TECH.NONE,
    {
        builder_tag = "conductor",
        atlas = atlas,
        image = "guitar.tex",
        product = "winslow_orchestraproxy_guitar",
        sg_state =
        "spawn_mutated_creature",
        actionstr = "TRANSFORM",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")), "HASPET"
        end
    },
    { "CHARACTER" })

AddRecipe2("piano", { Ingredient("nightmarefuel", 3), Ingredient("marble", 2) }, TECH.NONE,
    {
        builder_tag = "conductor_allegiance_shadow",
        atlas = atlas,
        image = "piano.tex",
        product =
        "winslow_orchestraproxy_piano",
        sg_state = "spawn_mutated_creature",
        actionstr = "TRANSFORM",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")), "HASPET"
        end
    },
    { "CHARACTER" })
AddRecipe2("saxophone", { Ingredient("nightmarefuel", 3), Ingredient("goldnugget", 5) }, TECH.NONE,
    {
        builder_tag = "conductor_allegiance_shadow",
        atlas = atlas,
        image = "saxophone.tex",
        product =
        "winslow_orchestraproxy_saxophone",
        sg_state = "spawn_mutated_creature",
        actionstr = "TRANSFORM",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")), "HASPET"
        end
    },
    { "CHARACTER" })

AddRecipe2("shamisen", { Ingredient("moonglass", 2), Ingredient("goldnugget", 2) }, TECH.NONE,
    {
        builder_tag = "conductor_allegiance_lunar",
        atlas = atlas,
        image = "shamisen.tex",
        product =
        "winslow_orchestraproxy_shamisen",
        sg_state = "spawn_mutated_creature",
        actionstr = "TRANSFORM",
        no_deconstruction = true,
        dropitem = true,
        canbuild = function(
            inst, builder)
            return (builder.components.petleash and not builder.components.petleash:IsFullForTag("orchestra")), "HASPET"
        end
    },
    { "CHARACTER" })
