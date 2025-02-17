---
-- @class ENT
-- @desc Dummy entity to convert ZM info_manipulate traps to TTT ones
-- @section InfoManipulate

ENT.Type = "point"
ENT.Base = "base_point"

---
-- @realm server
function ENT:Think()
	if not self.Replaced then
		self:CreateReplacement()

		self:Remove()
	end
end

---
-- Sets Hammer key values on an entity.
-- @param string key The internal key name
-- @param string value The value to set
-- @realm server
function ENT:KeyValue(key, value)
	if key == "OnPressed" then
		-- store raw, will be feeding this into the replacement's StoreOutput()
		self.RawOutputs = self.RawOutputs or {}

		self.RawOutputs[#self.RawOutputs + 1] = value
	elseif key == "Cost" then
		self[key] = tonumber(value)
	elseif key == "Active" or key == "RemoveOnTrigger" then
		self[key] = tobool(value)
	elseif key == "Description" then
		self[key] = tostring(value)
	end
end

---
-- @realm server
function ENT:CreateReplacement()
	local tgt = ents.Create("ttt_traitor_button")

	if not IsValid(tgt) then return end

	self.Replaced = true

	-- feed in our properties into replacement as keyvals
	tgt:SetPos(self:GetPos())
	tgt:SetKeyValue("targetname", self:GetName())

	if not self.Active then
		-- start locked
		tgt:SetKeyValue("spawnflags", tostring(2048))
	end

	if self.Description and self.Description ~= "" then
		tgt:SetKeyValue("description", self.Description)
	end

	if self.Cost then
		tgt:SetKeyValue("wait", tostring(self.Cost))
	end

	if self.RemoveOnTrigger then
		tgt:SetKeyValue("RemoveOnPress", tostring(true))
	end

	if self.RawOutputs then
		for k, v in pairs(self.RawOutputs) do
			tgt:SetKeyValue("OnPressed", tostring(v))
		end
	end

	tgt:Spawn()
end
