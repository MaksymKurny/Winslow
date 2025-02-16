local POS_Y_1               = 172
local POS_Y_2               = POS_Y_1 - 38
local POS_Y_3               = POS_Y_1 - (38 * 2)
local POS_Y_4               = POS_Y_1 - (38 * 3)
local POS_Y_5               = POS_Y_1 - (38 * 4)

local HUMAN_POS_Y_1         = POS_Y_1
local HUMAN_POS_Y_2         = HUMAN_POS_Y_1 - 36
local HUMAN_POS_Y_3         = HUMAN_POS_Y_2 - 36
local HUMAN_POS_Y_4         = HUMAN_POS_Y_3 - 48
local HUMAN_POS_Y_5         = HUMAN_POS_Y_4 - 38

local ALLEGIANCE_POS_Y_1    = POS_Y_1
local ALLEGIANCE_POS_Y_2    = 128
local ALLEGIANCE_POS_Y_3    = 84
local ALLEGIANCE_POS_Y_4    = 38

local WEREMETER_POS_X       = -205

local BEAVER_POS_X          = WEREMETER_POS_X + 65
local MOOSE_POS_X           = BEAVER_POS_X + 44.5
local GOOSE_POS_X           = MOOSE_POS_X + 43.5

local QUICKPICKER_POS_X     = 37
local TREE_GUARD_POS_X      = QUICKPICKER_POS_X + 40 + 32

local LUCY_POS_X_1          = (QUICKPICKER_POS_X + TREE_GUARD_POS_X) * .5
local LUCY_POS_X_2          = LUCY_POS_X_1 - 28
local LUCY_POS_X_3          = LUCY_POS_X_1 + 31

local ALLEGIANCE_LOCK_X     = 202
local ALLEGIANCE_SHADOW_X   = ALLEGIANCE_LOCK_X - 36
local ALLEGIANCE_REJECTED_X = ALLEGIANCE_LOCK_X
local ALLEGIANCE_LUNAR_X    = ALLEGIANCE_LOCK_X + 36

local CURSE_TITLE_X         = (GOOSE_POS_X + WEREMETER_POS_X) * .5
local HUMAN_TITLE_X         = LUCY_POS_X_1
local ALLEGIANCE_TILE_X     = ALLEGIANCE_LOCK_X

local TITLE_Y               = POS_Y_1 + 30

local WINSLOW_SKILL_STRINGS = STRINGS.SKILLTREE.WINSLOW

--------------------------------------------------------------------------------------------------

local ORDERS                =
{
    { "curse",      { CURSE_TITLE_X, TITLE_Y } },
    -- { "human",      { HUMAN_TITLE_X, TITLE_Y } },
    { "allegiance", { ALLEGIANCE_TILE_X, TITLE_Y } },
}

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills =
    {
        winslow_battle_part_1 = {
            pos = { WEREMETER_POS_X, POS_Y_1 },
            group = "curse",
            tags = { "curse", "weremeter" },
            root = true,
            connects = {
                "winslow_battle_part_2",
            },
        },

        winslow_battle_part_2 = {
            pos = { WEREMETER_POS_X, POS_Y_2 },
            group = "curse",
            tags = { "curse", "weremeter" },
            -- connects = {
            --     "winslow_curse_weremeter_3",
            -- },
        },


        winslow_allegiance_lock_1 = {
            pos = { ALLEGIANCE_LOCK_X, ALLEGIANCE_POS_Y_1 },
            group = "allegiance",
            tags = { "allegiance", "lock" },
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 2
            end,
        },

        winslow_allegiance_lock_2 = SkillTreeFns.MakeFuelWeaverLock(
            { pos = { ALLEGIANCE_SHADOW_X, ALLEGIANCE_POS_Y_2 } }
        ),


        winslow_allegiance_lock_5 = SkillTreeFns.MakeNoLunarLock(
            { pos = { ALLEGIANCE_SHADOW_X, ALLEGIANCE_POS_Y_3 } }
        ),

        -- Woodie no longer draws the aggression of shadow creatures when transformed into one of the wereforms.
        winslow_allegiance_shadow = {
            icon = "wilson_favor_shadow",
            pos = { ALLEGIANCE_SHADOW_X, ALLEGIANCE_POS_Y_4 },
            group = "allegiance",
            tags = { "allegiance", "shadow", "shadow_favor" },
            locks = { "winslow_allegiance_lock_1", "winslow_allegiance_lock_2", "winslow_allegiance_lock_5" },

            onactivate = function(inst, fromload)
                inst:AddTag("player_shadow_aligned")

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WOODIE.ALLEGIANCE_SHADOW_RESIST,
                        "allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WOODIE.ALLEGIANCE_VS_LUNAR_BONUS,
                        "allegiance_shadow")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_shadow_aligned")

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("shadow_aligned", inst, "allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "allegiance_shadow")
                end
            end,
        },

        winslow_allegiance_lock_3 = SkillTreeFns.MakeAllLock(
            { pos = { ALLEGIANCE_REJECTED_X, ALLEGIANCE_POS_Y_2 } }
        ),

        winslow_allegiance_lock_6 = SkillTreeFns.MakeRejectedAllLock(
            { pos = { ALLEGIANCE_REJECTED_X, ALLEGIANCE_POS_Y_3 } }
        ),

        winslow_allegiance_rejected = {
            icon = "winslow_favor_rejected",
            pos = { ALLEGIANCE_REJECTED_X, ALLEGIANCE_POS_Y_4 },
            group = "allegiance",
            tags = { "allegiance", "rejected", "rejected_favor" },
            locks = { "winslow_allegiance_lock_1", "winslow_allegiance_lock_3", "winslow_allegiance_lock_6" },

            onactivate = function(inst, fromload)
                inst:AddTag("player_rejected_aligned")

                -- local damagetyperesist = inst.components.damagetyperesist
                -- if damagetyperesist then
                --     damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WOODIE.ALLEGIANCE_LUNAR_RESIST, "allegiance_lunar")
                -- end
                -- local damagetypebonus = inst.components.damagetypebonus
                -- if damagetypebonus then
                --     damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WOODIE.ALLEGIANCE_VS_SHADOW_BONUS, "allegiance_lunar")
                -- end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_rejected_aligned")

                -- local damagetyperesist = inst.components.damagetyperesist
                -- if damagetyperesist then
                --     damagetyperesist:RemoveResist("lunar_aligned", inst, "allegiance_lunar")
                -- end
                -- local damagetypebonus = inst.components.damagetypebonus
                -- if damagetypebonus then
                --     damagetypebonus:RemoveBonus("shadow_aligned", inst, "allegiance_lunar")
                -- end
            end,
        },

        winslow_allegiance_lock_4 = SkillTreeFns.MakeCelestialChampionLock(
            { pos = { ALLEGIANCE_LUNAR_X, ALLEGIANCE_POS_Y_2 } }
        ),

        winslow_allegiance_lock_7 = SkillTreeFns.MakeNoShadowLock(
            { pos = { ALLEGIANCE_LUNAR_X, ALLEGIANCE_POS_Y_3 } }
        ),

        -- Woodie's curse is no longer triggered by full moons.
        winslow_allegiance_lunar = {
            icon = "wilson_favor_lunar",
            pos = { ALLEGIANCE_LUNAR_X, ALLEGIANCE_POS_Y_4 },
            group = "allegiance",
            tags = { "allegiance", "lunar", "lunar_favor" },
            locks = { "winslow_allegiance_lock_1", "winslow_allegiance_lock_4", "winslow_allegiance_lock_7" },

            onactivate = function(inst, fromload)
                inst:AddTag("player_lunar_aligned")

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WOODIE.ALLEGIANCE_LUNAR_RESIST,
                        "allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WOODIE.ALLEGIANCE_VS_SHADOW_BONUS,
                        "allegiance_lunar")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_lunar_aligned")

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("lunar_aligned", inst, "allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "allegiance_lunar")
                end
            end,
        },
    }


    for name, data in pairs(skills) do
        local uppercase_name = string.upper(name)
        if not data.desc then
            data.desc = WINSLOW_SKILL_STRINGS[uppercase_name .. "_DESC"]
        end

        -- If it's not a lock.
        if not data.lock_open then
            if not data.title then
                data.title = WINSLOW_SKILL_STRINGS[uppercase_name .. "_TITLE"]
            end

            if not data.icon then
                data.icon = name
            end
        end
    end

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

--------------------------------------------------------------------------------------------------

return BuildSkillsData
