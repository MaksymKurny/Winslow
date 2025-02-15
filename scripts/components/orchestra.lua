
local function WLFSort(a, b)
	return a.GUID < b.GUID
end

local function RecalculateOrchestraPattern(inst)
	local pets = inst.components.orchestra and inst.components.orchestra:GetInstruments(true) or nil
	if pets then
		inst.orchestra_pattern = pets
		table.sort(pets, WLFSort)
		for i, v in ipairs(pets) do
			pets[v] = i
		end
		pets.maxpets = #pets
	else
		inst.orchestra_pattern = nil
	end
end

local function OnSpawnPet(inst, pet)
	RecalculateOrchestraPattern(inst)

	if inst._OnSpawnPet ~= nil then
		inst:_OnSpawnPet(pet)
	end
end

local function OnDespawnPet(inst, pet)
	RecalculateOrchestraPattern(inst)

	if inst._OnDespawnPet ~= nil then
		inst:_OnDespawnPet(pet)
	end
end

local function OnRemovedPet(inst, pet)
	RecalculateOrchestraPattern(inst)
end

local Orchestra = Class(function(self, inst)
  self.inst = inst

	if inst.components.petleash ~= nil then
		inst._OnSpawnPet = inst.components.petleash.onspawnfn
		inst._OnDespawnPet = inst.components.petleash.ondespawnfn
	else
		inst:AddComponent("petleash")
	end
	local petleash = inst.components.petleash
	petleash:SetOnSpawnFn(OnSpawnPet)
	petleash:SetOnDespawnFn(OnDespawnPet)
	petleash:SetOnRemovedFn(OnRemovedPet)
	petleash:SetMaxPetsForTag("orchestra", TUNING.ORCHESTRA_LIMIT)
end)

function Orchestra:GetInstruments(get_in_limbo)
  local instruments = {}
  if self.inst.components.petleash == nil then
    return instruments
  end
  for k, v in pairs(self.inst.components.petleash:GetPetsWithTag("orchestra") or {}) do
    if not v:IsInLimbo() or get_in_limbo then
      table.insert(instruments, v)
    end
  end
  return instruments
end

function Orchestra:OnStartPlay()
  for i, v in ipairs(self:GetInstruments()) do

  end
end

function Orchestra:HideInstruments()
  for i, v in ipairs(self:GetInstruments()) do
    if v.components.timer then
      v.components.timer:StartTimer("HideOrchestra", 10.5 * FRAMES)
    end
    v.formation_radius = 0
  end
end

function Orchestra:ShowInstruments()
  local pos = self.inst:GetPosition()
  for i, v in ipairs(self:GetInstruments(true)) do
    v.components.timer:StopTimer("HideOrchestra")
    v.Transform:SetPosition(pos:Get())
    v:ReturnToScene()
    v.formation_radius = TUNING.DEFAULT_FORMATION_RADIUS
  end
end

return Orchestra
