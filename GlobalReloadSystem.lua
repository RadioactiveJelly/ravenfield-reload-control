-- Register the behaviour
behaviour("GlobalReloadSystem")

function GlobalReloadSystem:Start()
	-- Run when behaviour is created
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")

	local function onWeaponReturn(weapon)
		self:EvaluateWeapon(weapon)
	end

	local quickThrowObj = self.gameObject.Find("QuickThrow")
	if quickThrowObj then
		self.quickThrow = quickThrowObj.GetComponent(ScriptedBehaviour)
		self.quickThrow.self:SubscribeToWeaponReturnEvent("GlobalReloadSystem", onWeaponReturn)
	end

	local armorObj = self.gameObject.Find("PlayerArmor")
	if armorObj then
		self.playerArmor = armorObj.GetComponent(ScriptedBehaviour)
		self.playerArmor.self:SubscribeToWeaponReturnEvent("GlobalReloadSystem", onWeaponReturn)
	end

	local weaponPickup = self.gameObject.Find("[LQS]WeaponPickup(Clone)")
	if weaponPickup then
		self.weaponPickup = weaponPickup.GetComponent(ScriptedBehaviour)
		if self.weaponPickup.self.onWeaponPickUpListeners then
			self.weaponPickup.self:AddOnWeaponPickupListener("GlobalReloadSystem", onWeaponReturn)
		end
	end

	self.globalReloadSpeed = self.script.mutator.GetConfigurationFloat("reloadSpeed")

	self.weaponData = {}
	self:ParseString(self.script.mutator.GetConfigurationString("line1"))
	self:ParseString(self.script.mutator.GetConfigurationString("line2"))
	self:ParseString(self.script.mutator.GetConfigurationString("line3"))
	self:ParseString(self.script.mutator.GetConfigurationString("line4"))
	self:ParseString(self.script.mutator.GetConfigurationString("line5"))

	self.specificAffectsGeneral = self.script.mutator.GetConfigurationBool("specificAffectsGeneral")

	self.script.AddValueMonitor("monitorReloading", "onReloadingStateChanged")
end

--Parse string lines for weapon data
function GlobalReloadSystem:ParseString(str)
	for word in string.gmatch(str, '([^,]+)') do
		local iterations = 0
		local name = ""
		local reloadSpeedMultiplier = 1
		for wrd in string.gmatch(word,'([^|]+)') do
			if wrd ~= "-" then
				if iterations == 0 then name = wrd end
				if iterations == 1 then reloadSpeedMultiplier = tonumber(wrd) end
			end
			iterations = iterations + 1
			if(iterations >= 2) then break end
		end
		local data = {}
		self.weaponData[name] = reloadSpeedMultiplier
	end
end

function GlobalReloadSystem:onActorSpawn(actor)
	if actor.isPlayer then
		for i = 1, #actor.weaponSlots, 1 do
			self:EvaluateWeapon(actor.weaponSlots[i]);
		end
	end
end

function GlobalReloadSystem:EvaluateWeapon(weapon)
	local cleanName = string.gsub(weapon.weaponEntry.name,"<.->","")
	weapon.reloadTime = weapon.reloadTime/self:GetWeaponReloadMultiplier(cleanName)
end

function GlobalReloadSystem:monitorReloading()
	if Player.actor.activeWeapon == nil then return false end
	return Player.actor.activeWeapon.isReloading
end

function GlobalReloadSystem:onReloadingStateChanged()
	if Player.actor.activeWeapon == nil then return end
	if self.quickThrow and self.quickThrow.self.isThrowing then return end
	if self.playerArmor and self.playerArmor.self.isInArmorPlateMode then return end

	if Player.actor.activeWeapon.isReloading then
		Player.actor.activeWeapon.animator.speed = self:GetWeaponReloadMultiplier(Player.actor.activeWeapon.weaponEntry.name)
	else
		Player.actor.activeWeapon.animator.speed = 1
	end
end

function GlobalReloadSystem:GetWeaponReloadMultiplier(name)
	if self.weaponData == nil then self.weaponData = {} end

	local multiplier = self.weaponData[name]
	if multiplier then
		if self.specificAffectsGeneral then
			multiplier = multiplier * self.globalReloadSpeed
		end
	else
		multiplier = self.globalReloadSpeed
	end

	return multiplier
end