-- Register the behaviour
behaviour("ReloadControlMutator")

function ReloadControlMutator:Start()
	local mainObject = GameObject.Instantiate(self.targets.MainBehaviour)
	local mainBehaviour = mainObject.GetComponent(GlobalReloadSystem)

	mainBehaviour.globalReloadSpeed = self.script.mutator.GetConfigurationFloat("reloadSpeed")

	local weaponData = {}
	table.insert(weaponData, self.script.mutator.GetConfigurationString("line1"))
	table.insert(weaponData, self.script.mutator.GetConfigurationString("line2"))
	table.insert(weaponData, self.script.mutator.GetConfigurationString("line3"))
	table.insert(weaponData, self.script.mutator.GetConfigurationString("line4"))
	table.insert(weaponData, self.script.mutator.GetConfigurationString("line5"))
	mainBehaviour:SetWeaponConfigs(weaponData)
	
	mainBehaviour.specificAffectsGeneral = self.script.mutator.GetConfigurationBool("specificAffectsGeneral")

	mainBehaviour:Init()
end