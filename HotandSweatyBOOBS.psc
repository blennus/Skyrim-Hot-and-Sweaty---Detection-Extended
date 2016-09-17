scriptname HotandSweatyBOOBS extends Quest
;{Blinded Object Outcome Brightness Selector: Sets global Light level threshold to trigger blindness on Environmental Blindness on afflicted NPCs.}

import PapyrusUtil
import StorageUtil

;Background Setting
Spell property HnS_DINGIS auto ;Dynamic Image Nullifying Global Intermittent Spell
GlobalVariable property HnS_TimeBetweenDetectionChecks auto
;GlobalVariable property HnS_BlindnessThreshold auto
;GlobalVariable property HnS_BlindnessThresholdNE auto
;GlobalVariable property HnS_LightBlindnessMod auto
;GlobalVariable property HnS_LightBlindnessModNE auto
;GlobalVariable property HnS_ContrastBlindnessMod auto
;GlobalVariable property HnS_ContrastBlindnessModNE auto
GlobalVariable property HnS_LightLevelKeyCode auto

;GlobalVariable property HnS_TargetLightLevelThreshold auto
;GlobalVariable property HnS_TargetLightLevelThresholdNE auto

Actor property PlayerRef auto

event OnInit()
	if self.IsRunning()
		RegisterForSingleUpdate(0.01)
		LightLevelKeyRegistration()
	endIf
endEvent

function OnLoadInitialize()
	;LightLevelKeyRegistration()
endFunction

function UpdateNow()
	RegisterForSingleUpdate(0.01)
endFunction

function LightLevelKeyRegistration()
	UnregisterForAllKeys()
	int LightLevelKeyCode = HnS_LightLevelKeyCode.GetValue() as int
	if LightLevelKeyCode > 0x01 && LightLevelKeyCode <= 0x119
		RegisterForKey(LightLevelKeyCode)
	endIf
endFunction

event OnUpdate()
	float PlayerCurrentLightLevel = PlayerRef.GetLightLevel()
	;float ContrastBlindnessMod= HnS_ContrastBlindnessMod.GetValue()
	;float ContrastBlindnessModNE= HnS_ContrastBlindnessModNE.GetValue()
	float WeatherBlindnessValue = (1.0 - GetFloatValue(none,"HnS_WeatherVisualMod", 1.0)) * 80.0
	float CurrentBlindnessLevel = ClampFloat((GetFloatValue(none, "HnS_CurrentBlindnessThreshold") - PlayerCurrentLightLevel)*GetFloatValue(none, "HnS_CurrentLightBlindnessMod"), 0.0, 96.0 - WeatherBlindnessValue * 0.75) + WeatherBlindnessValue  * 0.75
	float CurrentBlindnessLevelNE = ClampFloat((GetFloatValue(none, "HnS_CurrentBlindnessThresholdNE") - PlayerCurrentLightLevel)*GetFloatValue(none, "HnS_CurrentLightBlindnessModNE"), 0.0, 100.0) + (WeatherBlindnessValue * 1.5)
	
	;Debug.Trace("Surrounding NPCs Blinded by: " + CurrentBlindnessLevel)
	;Debug.Trace("Surrounding NPCs with Night Eye Blinded by: " + CurrentBlindnessLevelNE)
	;Debug.Trace("Surrounding NPCs with Heat Vision Blinded by: " + ClampFloat(WeatherBlindnessValue * 2.0, 0.0, 100.0))
	
	HnS_DINGIS.SetNthEffectMagnitude(0, CurrentBlindnessLevel)
	HnS_DINGIS.SetNthEffectMagnitude(1, ClampFloat(CurrentBlindnessLevelNE, 0.0, 100.0 - WeatherBlindnessValue * 1.5) + WeatherBlindnessValue * 1.5)
	HnS_DINGIS.SetNthEffectMagnitude(2, ClampFloat(WeatherBlindnessValue * 2.0, 0.0, 100.0))
	
	HnS_DINGIS.Cast(PlayerRef)
	
	;TargetLightLevelThreshold = (100.0 + (PlayerCurrentLightLevel - HnS_BlindnessThreshold.GetValue())*HnS_LightBlindnessMod.GetValue() - (100.0 /GetFloatValue(none,"HnS_WeatherVisualMod", 1.0))) / ContrastBlindnessMod + PlayerCurrentLightLevel
	;TargetLightLevelThresholdNE = (100.0 + (PlayerCurrentLightLevel - HnS_BlindnessThresholdNE.GetValue())*HnS_LightBlindnessModNE.GetValue() - (100.0 /GetFloatValue(none,"HnS_WeatherVisualMod", 1.0))) / ContrastBlindnessModNE + PlayerCurrentLightLevel
	
	RegisterForSingleUpdate(HnS_TimeBetweenDetectionChecks.GetValue())
endEvent

event OnKeyDown(int KeyCode)
	if Utility.IsInMenuMode()
		Return
	endIf
	
	GotoState("KeyDown")
	;Utility.Wait(0.01)
	float PlayerCurrentLightLevel = PlayerRef.GetLightLevel()
	float BlindnessThresholdNE = GetFloatValue(none, "HnS_CurrentBlindnessThresholdNE")
	float BlindnessThreshold = GetFloatValue(none, "HnS_CurrentBlindnessThreshold")
	string LightLevelString
	if PlayerCurrentLightLevel < BlindnessThresholdNE * 0.2
		LightLevelString = "$HnS_CurrentLightLevelPitchBlack"
	elseIf PlayerCurrentLightLevel < BlindnessThresholdNE * 0.4
		LightLevelString = "$HnS_CurrentLightLevelNEVeryDark"
	elseIf PlayerCurrentLightLevel < BlindnessThresholdNE
		LightLevelString = "$HnS_CurrentLightLevelNEDark"
	elseIf PlayerCurrentLightLevel < (BlindnessThreshold + BlindnessThresholdNE) * 0.5
		LightLevelString = "$HnS_CurrentLightLevelDark"
	elseIf PlayerCurrentLightLevel < BlindnessThreshold
		LightLevelString = "$HnS_CurrentLightLevelSlightlyDark"
	elseIf PlayerCurrentLightLevel < (BlindnessThreshold + 120) * 0.5
		LightLevelString = "$HnS_CurrentLightLevelNormal"
	elseIf PlayerCurrentLightLevel < 120.0
		LightLevelString = "$HnS_CurrentLightLevelBright"
	else
		LightLevelString = "$HnS_CurrentLightLevelVeryBright"
	endIf
	Debug.Notification(LightLevelString)
	Utility.Wait(1.0)
	GotoState("")
endEvent

state KeyDown
	
	event OnKeyDown(int KeyCode)
		
	endEvent
	
endState
