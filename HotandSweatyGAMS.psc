scriptname HotandSweatyGAMS Hidden
;{Global Algorithm Members Script}

float function GetEquippedState(Actor akTarget) Global
	float equippedValue = 0
	Armor BodyArmor = akTarget.GetWornForm(0x00000004) as Armor ;body equipped
	if BodyArmor
		equippedValue += (((BodyArmor.GetWeightClass() + 1) % 3) * 8) + 10
	endIf
	
	Armor FullHeadArmor = akTarget.GetWornForm(0x00000001) as Armor ;head fully equipped
	Armor HeadArmor = akTarget.GetWornForm(0x00000002) as Armor ;head equipped
	if FullHeadArmor
		equippedValue += 8.0
	elseIf HeadArmor
		equippedValue += (((HeadArmor.GetWeightClass() + 1) % 3) * 2.5) + 3.0
	endIf
	
	Armor HandArmor = akTarget.GetWornForm(0x00000008) as Armor ;gloves equipped
	Armor ArmArmor = akTarget.GetWornForm(0x00000010) as Armor ;arms equipped
	int HandAndArmCoverValue
	if HandArmor
		HandAndArmCoverValue += (((HandArmor.GetWeightClass() + 1) % 3)) + 1
	endIf
	if ArmArmor
		HandAndArmCoverValue += (((ArmArmor.GetWeightClass() + 1) % 3)) + 1
	endIf
	equippedValue += HandAndArmCoverValue / 2.0
	
	Armor FeetArmor = akTarget.GetWornForm(0x00000080) as Armor ;Feet equipped
	Armor CalvesArmor = akTarget.GetWornForm(0x00000100) as Armor ;Calves equipped
	int FeetAndCalvesCoverValue
	if FeetArmor
		FeetAndCalvesCoverValue += (((FeetArmor.GetWeightClass() + 1) % 3)) + 1
	endIf
	if CalvesArmor
		FeetAndCalvesCoverValue += (((CalvesArmor.GetWeightClass() + 1) % 3)) + 1
	endIf
	equippedValue += FeetAndCalvesCoverValue / 2.0
	
	if akTarget.GetWornForm(0x00010000) ;Assume cloaks are available. If you don't have one... well I'm sorry. At most you'll only be able to get 80% insulation, but that' should be enough for most circumstances
		equippedValue += 10
	endIf
	return equippedValue
endFunction

function SkyTweakUpdate(form akPushingForm) Global
	int handle = ModEvent.Create("PingSkyTweak")
	if handle
		ModEvent.PushForm(handle, akPushingForm)
		ModEvent.PushForm(handle, none)
		ModEvent.PushInt(handle, 0)
		ModEvent.PushString(handle, "")
		ModEvent.Send(handle)
	endIf
endFunction
