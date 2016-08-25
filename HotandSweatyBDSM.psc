scriptname HotandSweatyBDSM extends Quest
;{Background Dirtiness Smell Manager: Sets distance threshold to trigger Smell Detection on endowed NPCs.}

import PapyrusUtil
;for ClampInt and ClampFloat
import StorageUtil

;====================Start Property Definitions====================

;Hot and Sweaty Properties
HotandSweatyConditions property HnS_BUTTS auto
MagicEffect property HnS_AlchZeolite auto
Keyword property HnS_MagicSmellCloak auto
Keyword property HnS_MagicDeodorant auto

;Vanilla Properties
Actor property PlayerRef auto
MagicEffect property VoiceMakeEthereal auto
MagicEffect property FireCloakFFSelf auto
MagicEffect property ShockCloakFFSelf auto
Keyword property MagicCloak auto

;Background Setting
;GlobalVariable property HnS_CurrentDetectionDistance_ReadOnly auto
GlobalVariable property HnS_WeatherSevereRainHeaviness auto
GlobalVariable property HnS_PlayerNaturalBO auto
GlobalVariable property HnS_SmellDistanceModifier auto
GlobalVariable property HnS_DirtinessPercentageModifier auto
GlobalVariable property HnS_SmellDeodorantPower auto
GlobalVariable property HnS_SmellZeolitePower auto
GlobalVariable property HnS_SmellWindsPower auto
GlobalVariable property HnS_SmellOtherCloak auto
GlobalVariable property HnS_Tier4SmellSensitivityExponent auto
GlobalVariable property HnS_Tier3SmellSensitivityExponent auto
GlobalVariable property HnS_Tier2SmellSensitivityExponent auto
GlobalVariable property HnS_Tier1SmellSensitivityExponent auto
GlobalVariable property HnS_DefaultSmellSensitivityExponent auto
GlobalVariable property HnS_NPCSmellSensitivityExponent auto

;Threshold Settings
GlobalVariable property HnS_StinkyNPCDetectionDistance auto
GlobalVariable property HnS_StinkyDefaultDetectionDistance auto
GlobalVariable property HnS_StinkyTier1DetectionDistance auto
GlobalVariable property HnS_StinkyTier2DetectionDistance auto
GlobalVariable property HnS_StinkyTier3DetectionDistance auto
GlobalVariable property HnS_StinkyTier4DetectionDistance auto

;====================End Property Definitions====================

event OnInit()
	if self.IsRunning()
		RegisterForModEvent("HnS_UpdateSmelliness", "OnSmellUpdated")
		SendModEvent("HnS_UpdateSmelliness")
	endIf
endEvent

function OnLoadInitialize()
	RegisterForModEvent("HnS_UpdateSmelliness", "OnSmellUpdated")
endFunction

event OnSmellUpdated(string eventName, string strArg, float numArg, Form sender)
	;Make sure to Call this whenever a Bath takes place.
	float baseStinkyness = HnS_PlayerNaturalBO.GetValue()
	float StinkyPowerAttenuation = 0.0
	float StinkyBaseDetectionDistance = HnS_SmellDistanceModifier.GetValue() * GetFloatValue(none,"HnS_WeatherSoundMod", 1.0)
	
	if PlayerRef.HasMagicEffectWithKeyword(HnS_MagicDeodorant)
		StinkyPowerAttenuation += HnS_SmellDeodorantPower.GetValue()
	endIf
	
	if PlayerRef.HasMagicEffect(HnS_AlchZeolite)
		StinkyPowerAttenuation += HnS_SmellZeolitePower.GetValue()
	endIf
	
	if PlayerRef.HasMagicEffectWithKeyword(HnS_MagicSmellCloak)
		StinkyPowerAttenuation += HnS_SmellWindsPower.GetValue()			
	elseIf PlayerRef.HasMagicEffect(FireCloakFFSelf) || PlayerRef.HasMagicEffect(ShockCloakFFSelf)
		StinkyPowerAttenuation += HnS_SmellOtherCloak.GetValue()
	elseIf PlayerRef.HasMagicEffectWithKeyword(MagicCloak) && GetFloatValue(none,"HnS_WeatherSoundMod", 1.0) > HnS_WeatherSevereRainHeaviness.GetValue()
		StinkyPowerAttenuation -= 0.5
	endIf
	
	if PlayerRef.HasMagicEffect(VoiceMakeEthereal)
		StinkyPowerAttenuation += 0.5
	endIf
	
	float CoveredStinkiness = baseStinkyness * (1.0 - StinkyPowerAttenuation)
	
	float CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_NPCSmellSensitivityExponent.GetValue()), 0.0, 8192.0)
	HnS_StinkyNPCDetectionDistance.SetValue(CurrentStank)
	Debug.Trace("CurrentStank NPC: " + CurrentStank)
	
	CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_DefaultSmellSensitivityExponent.GetValue()), 0.0, 8192.0)
	HnS_StinkyDefaultDetectionDistance.SetValue(CurrentStank)
	Debug.Trace("CurrentStank Default: " + CurrentStank)
	
	CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_Tier1SmellSensitivityExponent.GetValue()), 0.0, 8192.0)
	HnS_StinkyTier1DetectionDistance.SetValue(CurrentStank)
	Debug.Trace("CurrentStank Tier 1: " + CurrentStank)
	
	CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_Tier2SmellSensitivityExponent.GetValue()), 0.0, 8192.0)
	HnS_StinkyTier2DetectionDistance.SetValue(CurrentStank)
	Debug.Trace("CurrentStank Tier 2: " + CurrentStank)
	
	CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_Tier3SmellSensitivityExponent.GetValue()), 0.0, 8192.0)
	HnS_StinkyTier3DetectionDistance.SetValue(CurrentStank)
	Debug.Trace("CurrentStank Tier 3: " + CurrentStank)
	
	CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_Tier4SmellSensitivityExponent.GetValue()), 0.0, 8192.0)
	HnS_StinkyTier4DetectionDistance.SetValue(CurrentStank)
	Debug.Trace("CurrentStank Tier 4: " + CurrentStank)
endEvent

state BathingInSkyrimLoaded
	
	event OnSmellUpdated(string eventName, string strArg, float numArg, Form sender)
		;Make sure to Call this whenever a Bath takes place.
		float baseStinkyness
		float StinkyPowerAttenuation = 0.0
		float StinkyBaseDetectionDistance = HnS_SmellDistanceModifier.GetValue() * GetFloatValue(none,"HnS_WeatherSoundMod", 1.0)
		float mzinDirtinessPercentageValue = HnS_BUTTS.mzinDirtinessPercentage.GetValue()
		
		If PlayerRef.HasSpell(HnS_BUTTS.mzinSoapBonusDragonsTongueSpell) || PlayerRef.HasSpell(HnS_BUTTS.mzinSoapBonusFlowerRBPSpell) || PlayerRef.HasSpell(HnS_BUTTS.mzinSoapBonusFlowerBlueSpell) || PlayerRef.HasSpell(HnS_BUTTS.mzinSoapBonusFlowerRedSpell) || PlayerRef.HasSpell(HnS_BUTTS.mzinSoapBonusFlowerPurpleSpell) || PlayerRef.HasSpell(HnS_BUTTS.mzinSoapBonusFlowerLavenderSpell) ;|| PlayerRef.HasSpell(HnS_BUTTS.mzinSoapBonusDwemerSpell)
			baseStinkyness = 0.2 * HnS_DirtinessPercentageModifier.GetValue() + HnS_PlayerNaturalBO.GetValue()
		else
			baseStinkyness = mzinDirtinessPercentageValue*HnS_DirtinessPercentageModifier.GetValue() + HnS_PlayerNaturalBO.GetValue()
		endIf
		
		if PlayerRef.HasMagicEffectWithKeyword(HnS_MagicDeodorant)
			StinkyPowerAttenuation += HnS_SmellDeodorantPower.GetValue()
		endIf
		
		if PlayerRef.HasMagicEffect(HnS_AlchZeolite)
			StinkyPowerAttenuation += HnS_SmellZeolitePower.GetValue()
		endIf
		
		if PlayerRef.HasMagicEffectWithKeyword(HnS_MagicSmellCloak)
			StinkyPowerAttenuation += HnS_SmellWindsPower.GetValue()			
		elseIf PlayerRef.HasMagicEffect(FireCloakFFSelf) || PlayerRef.HasMagicEffect(ShockCloakFFSelf)
			StinkyPowerAttenuation += HnS_SmellOtherCloak.GetValue()
		elseIf PlayerRef.HasMagicEffectWithKeyword(MagicCloak) && GetFloatValue(none,"HnS_WeatherSoundMod", 1.0) > HnS_WeatherSevereRainHeaviness.GetValue()
			StinkyPowerAttenuation -= 0.5
		endIf
		
		if PlayerRef.HasMagicEffect(VoiceMakeEthereal)
			StinkyPowerAttenuation += 0.5
		endIf
		
		float CoveredStinkiness = baseStinkyness * (1 - StinkyPowerAttenuation)
		
		float CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_NPCSmellSensitivityExponent.GetValue()), 0.0, 8192.0)
		HnS_StinkyNPCDetectionDistance.SetValue(CurrentStank)
		Debug.Trace("CurrentStank NPC: " + CurrentStank)
		
		CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_DefaultSmellSensitivityExponent.GetValue()), 0.0, 8192.0)
		HnS_StinkyDefaultDetectionDistance.SetValue(CurrentStank)
		Debug.Trace("CurrentStank Default: " + CurrentStank)
		
		CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_Tier1SmellSensitivityExponent.GetValue()), 0.0, 8192.0)
		HnS_StinkyTier1DetectionDistance.SetValue(CurrentStank)
		Debug.Trace("CurrentStank Tier 1: " + CurrentStank)
		
		CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_Tier2SmellSensitivityExponent.GetValue()), 0.0, 8192.0)
		HnS_StinkyTier2DetectionDistance.SetValue(CurrentStank)
		Debug.Trace("CurrentStank Tier 2: " + CurrentStank)
		
		CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_Tier3SmellSensitivityExponent.GetValue()), 0.0, 8192.0)
		HnS_StinkyTier3DetectionDistance.SetValue(CurrentStank)
		Debug.Trace("CurrentStank Tier 3: " + CurrentStank)
		
		CurrentStank = ClampFloat(StinkyBaseDetectionDistance*(CoveredStinkiness - HnS_Tier4SmellSensitivityExponent.GetValue()), 0.0, 8192.0)
		HnS_StinkyTier4DetectionDistance.SetValue(CurrentStank)
		Debug.Trace("CurrentStank Tier 4: " + CurrentStank)
		
		HnS_BUTTS.CurrentDirtinessPercentage = mzinDirtinessPercentageValue
	endEvent
	
endState

