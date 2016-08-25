scriptname HotandSweatyTITS extends Quest
;{Temperature Interface Tracking Script: Sets global temperature threshold to trigger Heat Vision Detection on endowed NPCs.}

import StorageUtil
import FrostUtil

;Hot and Sweaty Properties
HotandSweatyConditions property HnS_BUTTS auto
MagicEffect property HnS_ThermalsUnderwearEnchEf auto
Keyword property HnS_MagicDarkness auto

;Frostfall Properties
GlobalVariable property FrostfallWetLevelReadOnly auto

;Vanilla Properties
Actor property PlayerRef auto
MagicEffect property FrostCloakFFSelf auto
MagicEffect property AlchWeaknessFrost auto
Keyword property MagicDamageFrost auto

;Background Setting
GlobalVariable property HnS_PlayerNaturalHeatDampenedPercent auto
GlobalVariable property HnS_PlayerTemperatureDampenedAmount auto
GlobalVariable property HnS_HeatThermalUnderwearPower auto
GlobalVariable property HnS_HeatPotionPower auto
GlobalVariable property HnS_HeatCloakofDarkessPower auto

;Threshold Settings
GlobalVariable property HnS_HeatDetectionTemperature auto

event OnInit()
	if self.IsRunning()
		RegisterForModEvent("Frost_UpdateWarmth", "OnHeatUpdatedFF")
		RegisterForModEvent("HnS_UpdateRadiantHeat", "OnHeatUpdated")
		SendModEvent("HnS_UpdateRadiantHeat")
	endIf
endEvent

function OnLoadInitialize()
	RegisterForModEvent("Frost_UpdateWarmth", "OnHeatUpdatedFF")
	RegisterForModEvent("HnS_UpdateRadiantHeat", "OnHeatUpdated")
endFunction

event OnHeatUpdatedFF()
	OnHeatUpdated("", "", 0.0, self)
endEvent

event OnHeatUpdated(string eventName, string strArg, float numArg, Form sender)
	GotoState("HeatUpdating")
	Utility.WaitMenuMode(0.5) ;Usually updates from frostfall come in groups. Wait to process the latest one.
	if (HnS_BUTTS.HidespotsLoaded && PlayerRef.HasMagicEffect(HnS_BUTTS.JZBai_InvisibilityEffect))
		HnS_HeatDetectionTemperature.SetValue(-999.0)
		return
	endIf
	
	float HeatDampening = HnS_PlayerNaturalHeatDampenedPercent.GetValue()
	
	if PlayerRef.HasMagicEffect(HnS_ThermalsUnderwearEnchEf) || PlayerRef.HasMagicEffect(FrostCloakFFSelf)
		HeatDampening += HnS_HeatThermalUnderwearPower.GetValue()
	endIf
	
	if PlayerRef.HasMagicEffect(AlchWeaknessFrost)
		HeatDampening += HnS_HeatPotionPower.GetValue()
	endIf
	
	if PlayerRef.HasMagicEffectWithKeyword(HnS_MagicDarkness) || PlayerRef.HasMagicEffectWithKeyword(MagicDamageFrost)
		HeatDampening += HnS_HeatCloakofDarkessPower.GetValue()
	endIf
	
	Debug.Trace("HeatDampening: " + HeatDampening)
	
	float CurrentInsulation
	if HnS_BUTTS.FrostfallLoaded && HnS_BUTTS.FrostfallRunning.GetValue() > 1.0
		CurrentInsulation = 1.782*((2.0 * GetPlayerArmorWarmth()/HnS_BUTTS._Frost_Calc_MaxWarmth.GetValue()) + (GetPlayerArmorCoverage()/HnS_BUTTS._Frost_Calc_MaxCoverage.GetValue()))/(3.0 + FrostfallWetLevelReadOnly.GetValue())
		Debug.Trace("CurrentInsulation: " + CurrentInsulation)
	else
		CurrentInsulation = HotandSweatyGAMS.GetEquippedState(PlayerRef) / 50.0
		Debug.Trace("CurrentInsulation: " + CurrentInsulation)
	endIf
	
	HeatDampening *= CurrentInsulation
	
	;Modify by sneak skill?
	;Should I heat vision detect better in the dark, rather than light?
	;HeatDampening -= (75 - PlayerRef.GetLightLevel())/200
	
	;if FrostfallLoaded && IsPlayerNearFire()
		;HeatDampening = modify it by GetPlayerHeatSourceLevel() somehow.
	;endIf
	float DetectableTemperature = 35.0 - HnS_PlayerTemperatureDampenedAmount.GetValue() * HeatDampening * HeatDampening / GetFloatValue(none,"HnS_WeatherVisualMod", 1.0)
	Debug.Trace("DetectableTemperature: " + DetectableTemperature)
	HnS_HeatDetectionTemperature.SetValue(DetectableTemperature)
	GotoState("")
endEvent

state HeatUpdating
	event OnHeatUpdated(string eventName, string strArg, float numArg, Form sender)
		
	endEvent
endState
