scriptname HotandSweatyLEGS extends ActiveMagicEffect  
;{Limited Exposure Gain Script: This script applies exposure to those that use the Anti-Heat Vision spell}

import HotandSweatyGAMS

GlobalVariable property FrostfallAttributeWarmthReadOnly auto
GlobalVariable property FrostfallWetLevelReadOnly auto
HotandSweatyConditions property HnS_BUTTS auto

Actor SpellTarget

event OnEffectStart(Actor akTarget, Actor akCaster)
	SendModEvent("HnS_UpdateRadiantHeat")
	SpellTarget = akTarget
	ApplyExposure()
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.SendModEvent("HnS_UpdateRadiantHeat")
endEvent

event OnUpdate()
	ApplyExposure()
endEvent

event ApplyExposure()
	int handle = ModEvent.Create("Frost_ForceExposureMeterDisplay")
	if handle
		ModEvent.PushBool(handle, true)
		ModEvent.Send(handle)
	endif
	FrostUtil.ModPlayerExposure(1.0, 30.0 + (GetMagnitude() * 2.0))
	float CurrentInsulationLevel
	if HnS_BUTTS.FrostfallLoaded && HnS_BUTTS.FrostfallRunning.GetValue() == 2.0
		CurrentInsulationLevel = 3.0 * FrostfallAttributeWarmthReadOnly.GetValue() / HnS_BUTTS._Frost_Calc_MaxWarmth.GetValue() / (3.0 + FrostfallWetLevelReadOnly.GetValue())
	else
		CurrentInsulationLevel = GetEquippedState(SpellTarget) / 50.0
	endIf
	RegisterForSingleUpdate(3.5 + 4.0 * CurrentInsulationLevel - GetMagnitude() / 10.0)
endEvent
