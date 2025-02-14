local ViolinBrain = Class(Brain, function(self, inst)
  Brain._ctor(self, inst)
end)

function ViolinBrain:OnStart()
  local root = PriorityNode({
    ParallelNode {
      ActionNode(function()
        self.inst.components.locomotor.walkspeed = TUNING.LIGHTFLIER.WALK_SPEED
        self.inst.components.locomotor.directdrive = false
      end),
    }
  }, .25)

  self.bt = BT(self.inst, root)
end

return ViolinBrain
