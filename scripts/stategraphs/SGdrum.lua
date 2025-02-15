require("stategraphs/commonstates")

local events=
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),

    EventHandler("startled", function(inst)
        inst.sg:GoToState("startled")
    end),
}

local states =
{
    State{

        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("walk_loop", true)
            else
                inst.AnimState:PlayAnimation("walk_loop", true)
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{

        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst:PerformBufferedAction()
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{

        name = "startled",
        tags = { "busy" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },
}

local walkanims =
{
    startwalk = "walk_pre",
    walk = "walk_loop",
    stopwalk = "walk_pst",
}

CommonStates.AddWalkStates(states, nil, walkanims, true)

CommonStates.AddCombatStates(states,
{
    hittimeline =
    {
        TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("grotto/creatures/light_bug/hit") end),
    },

    deathtimeline =
    {
        TimeEvent(1*FRAMES, function(inst)
            inst.SoundEmitter:KillSound("loop")
            inst.SoundEmitter:PlaySound("grotto/creatures/light_bug/death")
        end),
    },
},
{
    hit = "hit_2",
})

return StateGraph("lightflier", states, events, "idle")
