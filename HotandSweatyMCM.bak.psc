scriptname HotandSweatyMCM extends SKI_ConfigBase

import Math
import MiscUtil
import StorageUtil
import PapyrusUtil

;Main Script and Globals to import
HotandSweatyConditions property HnS_Conditions auto
HotandSweatyBUTTS property HnS_BUTTS auto
HotandSweatyBOOBS property HnS_BOOBS auto
GlobalVariable[] property GlobalVarsArray auto ;List of Global Variables to modify in the MCM.
Spell[] property ListOfSpellsToApply auto

;Vanilla Properties
Actor property PlayerRef Auto
Race[] property RacesToNotAdd Auto
Keyword property Vampire auto
Keyword property ActorTypeUndead auto
Keyword property ActorTypeDwarven auto
Keyword property ActorTypeNPC auto

;MCM Menu Local Variables
string[] RacialMenuList
string[] SmellTierArray
string[] PresetArray
bool BABESTrigger
bool BOOBSTrigger
bool BDSMTrigger
bool TITSTrigger
bool DAMESTrigger
int MCMRacesChanged
Race CurrentRace
int CurrentlyModifiedRaceIndex
int ProcessedRacesListLength
string HnSPresetFileName

event OnConfigInit()
	; pages
	Pages = new string[7]
	Pages[0] = "$HnS_Basic_Settings_Page"
	Pages[1] = "$HnS_Environment_Page"
	Pages[2] = "$HnS_Game_Settings_Page"
	Pages[3] = "$HnS_Location_Settings_Page"
	Pages[4] = "$HnS_Auxiliary_Senses_Page"
	Pages[5] = "$HnS_Smell_Sense_Page"
	Pages[6] = "$HnS_Racial_Configuration"
	Pages[7] = "$HnS_Manage_Presets"
	
	SmellTierArray = new string[6]
	SmellTierArray[0] = "$NPC Tier"
	SmellTierArray[1] = "$Tier 0"
	SmellTierArray[2] = "$Tier 1"
	SmellTierArray[3] = "$Tier 2"
	SmellTierArray[4] = "$Tier 3"
	SmellTierArray[5] = "$Tier 4"
	
	HnSPresetFileName = "Default"
endEvent

event OnVersionUpdate(int Version)
	;Nothing to do here yet as it is still version 1
	;if CurrentVersion < Version
	;	OnConfigInit()
	;endIf
endEvent

event OnConfigOpen()
	ProcessedRacesListLength = FormListCount(none, "HnS_ProcessedRaces")
	CurrentlyModifiedRaceIndex = ProcessedRacesListLength
	if ProcessedRacesListLength
		RacialMenuList = Utility.CreateStringArray(ProcessedRacesListLength + 1)
		int ArrayInitCounter = 0
		While ArrayInitCounter < ProcessedRacesListLength
			RacialMenuList[ArrayInitCounter] = "$" + GetRaceEditorID(FormListGet(none, "HnS_ProcessedRaces", ArrayInitCounter) as Race)
			ArrayInitCounter +=1
		endWhile
		RacialMenuList[ArrayInitCounter] = "$None"
	endIf
	;
	;ValidKeywordsLength
	;ProcessedWorldsLength
	;ProcessedLocationsLength
	;ProcessedCellsLength
endEvent

event OnConfigClose()
	if BABESTrigger
		SendModEvent("HnS_UpdateSneakGlobals")
		BABESTrigger = false
		Debug.Trace("MCM BABES Event Sent")
	endIf
	if BOOBSTrigger
		HnS_BOOBS.UpdateNow()
		BOOBSTrigger = false
		Debug.Trace("MCM BOOBS Triggered")
	endIf
	if DAMESTrigger
		SendModEvent("HnS_UpdateMagicAura")
		DAMESTrigger = false
		Debug.Trace("MCM DAMES Event Sent")
	endIf
	if TITSTrigger
		SendModEvent("HnS_UpdateRadiantHeat")
		Debug.Trace("MCM TITS Event Sent")
		TITSTrigger = false
	endIf
	if BDSMTrigger
		SendModEvent("HnS_UpdateSmelliness")
		Debug.Trace("MCM BDSM Event Sent")
		BDSMTrigger = false
	endIf
	if MCMRacesChanged > 1
		FormListClear(none, "HnS_ProcessingRaces")
		FormListClear(none, "HnS_ProcessedRaces")
		SendModEvent("HnS_MCMLoadUpdate")
		MCMRacesChanged = 0
		Debug.Trace("MCM PARTIES Global Event Sent")
	elseIf MCMRacesChanged == 1
		;Send Events to all Races modified in Menu.
		int RacesToResetCounter = FormListCount(none, "HnS_MCMEditedRaces")
		Debug.Trace("Races Reset Counter: " + RacesToResetCounter)
		while RacesToResetCounter > 0
			RacesToResetCounter -= 1
			Race CurrentlyCheckingRace = FormListGet(none, "HnS_MCMEditedRaces", RacesToResetCounter) as Race
			Debug.Trace("Sending Event for: " + GetRaceEditorID(CurrentlyCheckingRace))
			SendModEvent("HnS_MCMRaceUpdate" + GetRaceEditorID(CurrentlyCheckingRace), "", FormListHas(none, "HnS_IgnoredModdedRaces", CurrentlyCheckingRace) as float)
		endWhile
		FormListClear(none, "HnS_MCMEditedRaces")
		MCMRacesChanged = 0
		Debug.Trace("MCM PARTIES Race Specific Events Sent")
	endIf
	CurrentRace = none
endEvent

;=============event functions======================

event OnPageReset(String Page)
	if Page == ""
		UnloadCustomContent()
		LoadCustomContent("Hot-n-Sweaty Logo.dds", 85, 13)
	else
		UnloadCustomContent()
	endIf
	if Page == "$HnS_Basic_Settings_Page"
		displayBasicSettings()
	elseIf Page == "$HnS_Environment_Page"
		displayEnvironmentSettings()
	elseIf Page == "$HnS_Game_Settings_Page"
		displayGameStealthSettings()
	elseIf Page == "$HnS_Location_Settings_Page"
		displayLocationConfiguration()
	elseIf Page == "$HnS_Auxiliary_Senses_Page"
		displayAuxiliarySenses()
	elseIf Page == "$HnS_Smell_Sense_Page"
		displaySmellSenses()
	elseIf Page == "$HnS_Racial_Configuration"
		displayRacialConfiguration()
	elseIf Page == "$HnS_Manage_Presets"
		displayPresetConfiguration()
	endIf
endEvent


;=============OnPageReset functions: Displays Options and Values======================

int function GetVersion()
	return 1 ; Original version
endFunction

function displayBasicSettings()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Current_Status")
	String HnSActivatorText
	int WhichOptionFlag = OPTION_FLAG_NONE
	if !HnS_BUTTS.IsRunning()
		HnSActivatorText = "$HnS_Uninstalled"
	elseIf HnS_Conditions.HotAndSweatyActive == 3
		HnSActivatorText = "$HnS_Active"
	elseIf HnS_Conditions.HotAndSweatyActive == 2
		HnSActivatorText = "$HnS_Initializing"
		WhichOptionFlag = OPTION_FLAG_DISABLED
	elseIf HnS_Conditions.HotAndSweatyActive == 1
		HnSActivatorText = "$HnS_Uninstalling"
		WhichOptionFlag = OPTION_FLAG_DISABLED
	else
		HnSActivatorText = "$HnS_inActive"
	endIf
	AddTextOptionST("HnSActivator" ,"$HnS_Activator", HnSActivatorText, WhichOptionFlag)
	AddEmptyOption()
	
	AddHeaderOption("$HnS_Enable_Detection")
	bool isEnvironmentalBlindnessEnabled = GlobalVarsArray[0].GetValue()
	AddToggleOptionST("HnSAllowEnvironmentalBlindness", "$HnS_AllowEnvironmentalBlindness", isEnvironmentalBlindnessEnabled)
	if isEnvironmentalBlindnessEnabled
		AddToggleOptionST("HnSAllowNightVision", "$HnS_AllowNightVision", GlobalVarsArray[1].GetValue())
	else
		AddToggleOptionST("HnSAllowNightVision", "$HnS_AllowNightVision", false, OPTION_FLAG_DISABLED)
	endIf
	AddToggleOptionST("HnSAllowSmelling", "$HnS_AllowSmelling", GlobalVarsArray[2].GetValue())
	AddToggleOptionST("HnSAllowHeatSeeking", "$HnS_AllowHeatSeeking", GlobalVarsArray[3].GetValue())
	AddToggleOptionST("HnSAllowMagickaDetection", "$HnS_AllowMagickaDetection", GlobalVarsArray[4].GetValue())
	AddToggleOptionST("HnSAllowAddToLeveledLists", "$HnS_AllowAddToLeveledLists", GlobalVarsArray[5].GetValue())
	
	SetCursorPosition(1)
	AddHeaderOption("$HnS_Timers_and_Frequency")
	AddSliderOptionST("HnSTimeBetweenSneakGlobalSettingChecks", "$HnS_TimeBetweenSneakGlobalSettingChecks", GlobalVarsArray[6].GetValue() * 60, "${0} minutes")
	AddSliderOptionST("HnSTimeBetweenDetectionChecks", "$HnS_TimeBetweenDetectionChecks", GlobalVarsArray[7].GetValue(), "${2} seconds")
	AddSliderOptionST("HnSAlertedBonus", "$HnS_AlertedBonus", GlobalVarsArray[8].GetValue(), "{2}")
	AddSliderOptionST("HnSSneakBaseValueCeiling", "$HnS_SneakBaseValueCeiling", GlobalVarsArray[9].GetValue() + 5.0, "{0}")
	AddEmptyOption()
	
	AddSliderOptionST("HnSTimeTillDetectionResets", "$HnS_TimeTillDetectionResets", GlobalVarsArray[10].GetValue(), "${0} seconds")
	AddSliderOptionST("HnSAlertWaitTime", "$HnS_AlertWaitTime", GlobalVarsArray[11].GetValue(), "${0} seconds")
	AddSliderOptionST("HnSAttackedWaitTime", "$HnS_AttackedWaitTime", GlobalVarsArray[12].GetValue(), "${0} seconds")
	AddEmptyOption()
	if HnS_BUTTS.IsRunning()
		AddTextOptionST("HnSUninstaller" ,"$HnS_Uninstaller", "")
	else
		AddTextOptionST("HnSUninstaller" ,"$HnS_Uninstaller", "", OPTION_FLAG_DISABLED)
	endIf
	
endFunction

function displayEnvironmentSettings()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Default_Weather_Options")
	AddSliderOptionST("HnSWeatherFogThickness", "$HnS_WeatherFogThickness", GlobalVarsArray[13].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSWeatherMildRainThickness", "$HnS_WeatherMildRainThickness", GlobalVarsArray[14].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSWeatherMildSnowThickness", "$HnS_WeatherMildSnowThickness", GlobalVarsArray[16].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSWeatherSevereRainThickness", "$HnS_WeatherSevereRainThickness", GlobalVarsArray[18].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSWeatherSevereSnowThickness", "$HnS_WeatherSevereSnowThickness", GlobalVarsArray[20].GetValue() * 100.0, "{0}%")
	AddEmptyOption()
	
	AddSliderOptionST("HnSWeatherMildSnowHeaviness", "$HnS_WeatherMildSnowHeaviness", GlobalVarsArray[17].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSWeatherMildRainHeaviness", "$HnS_WeatherMildRainHeaviness", GlobalVarsArray[15].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSWeatherSevereSnowHeaviness", "$HnS_WeatherSevereSnowHeaviness", GlobalVarsArray[21].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSWeatherSevereRainHeaviness", "$HnS_WeatherSevereRainHeaviness", GlobalVarsArray[19].GetValue() * 100.0, "{0}%")
	AddEmptyOption()
	
	SetCursorPosition(1)
	AddHeaderOption("$HnS_Day_Phases_Starting_Hours")
	AddSliderOptionST("HnSDawnStart", "$HnS_DawnStart", GlobalVarsArray[24].GetValue(), "{2}")
	AddSliderOptionST("HnSDayStart", "$HnS_DayStart", GlobalVarsArray[25].GetValue(), "{2}")
	AddSliderOptionST("HnSDuskStart", "$HnS_DuskStart", GlobalVarsArray[22].GetValue(), "{2}")
	AddSliderOptionST("HnSNightStart", "$HnS_NightStart", GlobalVarsArray[23].GetValue(), "{2}")
	AddEmptyOption()
	AddSliderOptionST("HnSPhaseChangeMaxSkillDecreasePercent", "$HnS_PhaseChangeMaxSkillDecreasePercent", GlobalVarsArray[26].GetValue() * 100.0, "{0}%")
endFunction

function displayGameStealthSettings()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Stealth_Options")
	AddSliderOptionST("HnSDayBrightness", "$HnS_DayBrightness", GlobalVarsArray[27].GetValue(), "{0}")
	AddSliderOptionST("HnSNightDarkness", "$HnS_NightDarkness", GlobalVarsArray[28].GetValue(), "{0}")
	AddSliderOptionST("HnSInteriorLuminosity", "$HnS_InteriorLuminosity", GlobalVarsArray[29].GetValue(), "{0}")
	AddEmptyOption()
	
	AddSliderOptionST("HnSDayLoudness", "$HnS_DayLoudness", GlobalVarsArray[30].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSNightQuietness", "$HnS_NightQuietness", GlobalVarsArray[31].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSInteriorNoisiness", "$HnS_InteriorNoisiness", GlobalVarsArray[32].GetValue() * 100.0, "{0}%")
	AddEmptyOption()
	
	AddSliderOptionST("HnSExteriorReverb", "$HnS_ExteriorReverb", GlobalVarsArray[33].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSInteriorReverb", "$HnS_InteriorReverb", GlobalVarsArray[34].GetValue() * 100.0, "{0}%")
	
	SetCursorPosition(1)
	AddHeaderOption("$HnS_Stealth_Options_Continued")
	AddSliderOptionST("HnSDayDetectionDistance", "$HnS_DayDetectionDistance", GlobalVarsArray[35].GetValue(), "{0}")
	AddSliderOptionST("HnSNightDetectionDistance", "$HnS_NightDetectionDistance", GlobalVarsArray[36].GetValue(), "{0}")
	AddSliderOptionST("HnSInteriorDetectionDistance", "$HnS_InteriorDetectionDistance", GlobalVarsArray[37].GetValue(), "{0}")
	AddEmptyOption()
	
	AddSliderOptionST("HnSDayViewCone", "$HnS_DayViewCone", GlobalVarsArray[38].GetValue(), "{0} °")
	AddSliderOptionST("HnSNightViewCone", "$HnS_NightViewCone", GlobalVarsArray[39].GetValue(), "{0} °")
	AddSliderOptionST("HnSInteriorViewCone", "$HnS_InteriorViewCone", GlobalVarsArray[40].GetValue(), "{0} °")
	AddEmptyOption()
	
	AddHeaderOption("$HnS_HotKeys")
	AddKeyMapOptionST("HnSLightLevelKeyCode", "$HnS_LightLevelKeyCode", GlobalVarsArray[65].GetValue() as int)
	
endFunction

function displayLocationConfiguration()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddTextOptionST("HnSTextPlaceholder" ,"", "$HnS_Coming_Soon", OPTION_FLAG_DISABLED)
endFunction

function displayAuxiliarySenses()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Blindness_Options")
	AddSliderOptionST("HnSBlindnessThreshold", "$HnS_BlindnessThreshold", GlobalVarsArray[41].GetValue(), "{0}")
	AddSliderOptionST("HnSBlindnessThresholdNE", "$HnS_BlindnessThresholdNE", GlobalVarsArray[42].GetValue(), "{0}")
	
	AddSliderOptionST("HnSLightBlindnessMod", "$HnS_LightBlindnessMod", GlobalVarsArray[43].GetValue(), "{2}")
	AddSliderOptionST("HnSLightBlindnessModNE", "$HnS_LightBlindnessModNE", GlobalVarsArray[44].GetValue(), "{2}")
	
	AddEmptyOption()
	
	AddHeaderOption("$HnS_Magicka_Options")
	AddSliderOptionST("HnSmagickaIgnored", "$HnS_magickaIgnored", GlobalVarsArray[63].GetValue(), "{0}")
	AddSliderOptionST("HnSmagickaReductionPercent", "$HnS_magickaReductionPercent", 100.0 - GlobalVarsArray[64].GetValue() * 100.0, "{0}%")
	
	SetCursorPosition(1)
	AddHeaderOption("$HnS_Heat_Options")
	AddSliderOptionST("HnSplayerTemperatureDampenedAmount", "$HnS_PlayerTemperatureDampenedAmount", GlobalVarsArray[58].GetValue(), "{1}")
	AddSliderOptionST("HnSplayerNaturalHeatDampenedPercent", "$HnS_PlayerNaturalHeatDampenedPercent", GlobalVarsArray[59].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSheatThermalUnderwearPower", "$HnS_HeatThermalUnderwearPower", GlobalVarsArray[60].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSheatPotionPower", "$HnS_heatPotionPower", GlobalVarsArray[61].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSheatCloakofDarkessPower", "$HnS_heatCloakofDarkessPower", GlobalVarsArray[62].GetValue() * 100.0, "{0}%")
endFunction

function displaySmellSenses()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Smell_Options")
	AddSliderOptionST("HnSPlayerNaturalBO", "$HnS_PlayerNaturalBO", GlobalVarsArray[45].GetValue() * 100.0, "{0}%")
	if HnS_Conditions.MzinBathingInSkyrimLoaded
		AddSliderOptionST("HnSDirtinessPercentageModifier", "$HnS_DirtinessPercentageModifier", GlobalVarsArray[46].GetValue() * 100.0, "{0}%")
	else
		AddSliderOptionST("HnSDirtinessPercentageModifier", "$HnS_DirtinessPercentageModifier", 0, "{0}%", OPTION_FLAG_DISABLED)
	endIf
	AddSliderOptionST("HnSSmellDistanceModifier", "$HnS_SmellDistanceModifier", (GlobalVarsArray[47].GetValue() - 1.0) * 100.0, "{0}%")
	AddEmptyOption()
	AddSliderOptionST("HnSSmellDeodorantPower", "$HnS_SmellDeodorantPower", GlobalVarsArray[48].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSSmellZeolitePower", "$HnS_SmellZeolitePower", GlobalVarsArray[49].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSSmellWindsPower", "$HnS_SmellWindsPower", GlobalVarsArray[50].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSSmellOtherCloak", "$HnS_SmellOtherCloak", GlobalVarsArray[51].GetValue() * 100.0, "{0}%")
	
	SetCursorPosition(1)
	AddHeaderOption("$HnS_Smell_Options_Continued")
	AddSliderOptionST("HnSNPCSmellSensitivityExponent", "$HnS_NPCSmellSensitivityExponent", (1.0 - GlobalVarsArray[52].GetValue()) * 100.0, "{0}%")
	AddSliderOptionST("HnSDefaultSmellSensitivityExponent", "$HnS_DefaultSmellSensitivityExponent", (1.0 - GlobalVarsArray[53].GetValue()) * 100.0, "{0}%")
	AddSliderOptionST("HnSTier1SmellSensitivityExponent", "$HnS_Tier1SmellSensitivityExponent", (1.0 - GlobalVarsArray[54].GetValue()) * 100.0, "{0}%")
	AddSliderOptionST("HnSTier2SmellSensitivityExponent", "$HnS_Tier2SmellSensitivityExponent", (1.0 - GlobalVarsArray[55].GetValue()) * 100.0, "{0}%")
	AddSliderOptionST("HnSTier3SmellSensitivityExponent", "$HnS_Tier3SmellSensitivityExponent", (1.0 - GlobalVarsArray[56].GetValue()) * 100.0, "{0}%")
	AddSliderOptionST("HnSTier4SmellSensitivityExponent", "$HnS_Tier4SmellSensitivityExponent", (1.0 - GlobalVarsArray[57].GetValue()) * 100.0, "{0}%")
endFunction

function displayRacialConfiguration()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Racial_Options")
	;int ProcessedRacesListLength = FormListCount(none, "HnS_ProcessedRaces")
	if ProcessedRacesListLength > 0
		;AddTextOptionST("HnSTextPlaceholder" ,"", "$HnS_Select_Race", OPTION_FLAG_DISABLED)
		AddMenuOptionST("HnSSelectRaceMenu", "$HnS_Actor_Race_Choice", RacialMenuList[CurrentlyModifiedRaceIndex])
		AddEmptyOption()
		if CurrentlyModifiedRaceIndex < ProcessedRacesListLength
			
			bool Blindability = false
			if GlobalVarsArray[0].GetValue()
				Blindability = Blindable(CurrentRace)
				AddToggleOptionST("HnSRacialBlindness", "$HnS_RacialBlindness", Blindability)
			else
				AddToggleOptionST("HnSRacialBlindness", "$HnS_RacialBlindness", false, OPTION_FLAG_DISABLED)
			endIf
			
			;Smell Option Block
			bool Smellability = false
			if GlobalVarsArray[2].GetValue()
				Smellability = HasNostrils(CurrentRace)
				AddToggleOptionST("HnSRacialSmelling", "$HnS_RacialSmelling", Smellability)
			else
				AddToggleOptionST("HnSRacialSmelling", "$HnS_RacialSmelling", false, OPTION_FLAG_DISABLED)
			endIf
			
			;Heat Seeker Option Block
			bool HeatSeeker = false
			if GlobalVarsArray[3].GetValue()
				HeatSeeker = HasPitOrgans(CurrentRace)
				AddToggleOptionST("HnSRacialHeatVision", "$HnS_RacialHeatVision", HeatSeeker)
			else
				AddToggleOptionST("HnSRacialHeatVision", "$HnS_RacialHeatVision", false, OPTION_FLAG_DISABLED)
			endIf
			
			;Magicka Detection Option Block
			if GlobalVarsArray[4].GetValue()
				AddToggleOptionST("HnSRacialMagickaDetection", "$HnS_RacialMagickaDetection", HasAmpullaeOfLorenzini(CurrentRace))
			else
				AddToggleOptionST("HnSRacialMagickaDetection", "$HnS_RacialMagickaDetection", false, OPTION_FLAG_DISABLED)
			endIf
			
			;Night Vision Option Block
			if GlobalVarsArray[1].GetValue() && Blindability
				AddToggleOptionST("HnSRacialNightVision", "$HnS_RacialNightVision", HasExtraRods(CurrentRace))
			else
				AddToggleOptionST("HnSRacialNightVision", "$HnS_RacialNightVision", false, OPTION_FLAG_DISABLED)
			endIf
			
			if Smellability
				AddMenuOptionST("HnSRacialSmellTier", "$HnS_RacialSmellTier", SmellTierArray[OlfactoryReceptorNeuronDensity(CurrentRace)])
			else
				AddMenuOptionST("HnSRacialSmellTier", "$HnS_RacialSmellTier", "$None", OPTION_FLAG_DISABLED)
			endIf
			
		else
			AddToggleOptionST("HnSRacialBlindness", "$HnS_RacialBlindness", false, OPTION_FLAG_DISABLED)
			AddToggleOptionST("HnSRacialSmelling", "$HnS_RacialSmelling", false, OPTION_FLAG_DISABLED)
			AddToggleOptionST("HnSRacialHeatVision", "$HnS_RacialHeatVision", false, OPTION_FLAG_DISABLED)
			AddToggleOptionST("HnSRacialMagickaDetection", "$HnS_RacialMagickaDetection", false, OPTION_FLAG_DISABLED)
			AddToggleOptionST("HnSRacialNightVision", "$HnS_RacialNightVision", false, OPTION_FLAG_DISABLED)
			AddMenuOptionST("HnSRacialSmellTier", "$HnS_RacialSmellTier", "$None", OPTION_FLAG_DISABLED)
			AddEmptyOption()
			AddToggleOptionST("HnSIgnoreRace", "$HnS_IgnoreRace", false, OPTION_FLAG_DISABLED)
		endIf
	else
		AddTextOptionST("HnSTextPlaceholder" ,"", "$HnS_No_Races_Encountered", OPTION_FLAG_DISABLED)
	endIf
endFunction

function displayPresetConfiguration()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Preset")
	AddInputOptionST("HnSSelectPresetInput", "$HnS_SelectPresetInput", HnSPresetFileName)
	;AddMenuOptionST("HnSSelectPresetMenu", "$HnS_SelectPresetMenu", HnSPresetFileName)
	AddEmptyOption()
	AddHeaderOption("$HnS_Preset_Actions")
	if HnS_Conditions.HotAndSweatyActive == 3
		AddTextOptionST("HnSSaveCurrentPreset" ,"$HnS_Save_Current_Preset", "")
	else
		AddTextOptionST("HnSTextPlaceholder" ,"", "$HnS_ActivateToSaveWarning", OPTION_FLAG_DISABLED)
	endIf
	AddTextOptionST("HnSLoadCurrentPreset" ,"$HnS_Load_Current_Preset", "")
endFunction

;=============$HnS_Basic_Settings_Page functions: ======================

state HnSActivator
	event OnSelectST()
		String HnSMessageText
		String HnSBetweenText
		String HnSGotoState
		String HnSMenuExitString
		if !HnS_BUTTS.IsRunning() || !HnS_Conditions.HotAndSweatyActive
			HnSMessageText = "$HnS_InitializePrompt"
			HnSBetweenText = "$HnS_Initializing"
			HnSGotoState = "Active"
			HnSMenuExitString = "$HnS_ExitMenuToActivate"
		else
			HnSMessageText = "$HnS_ShutDownPrompt"
			HnSBetweenText = "$HnS_Uninstalling"
			HnSGotoState = ""
			HnSMenuExitString = "$HnS_ExitMenuToUninstall"
		endIf
		if ShowMessage(HnSMessageText)
			SetTextOptionValueST(HnSBetweenText)
			SetOptionFlagsST(OPTION_FLAG_DISABLED)
			ShowMessage(HnSMenuExitString, false)
			if !HnS_BUTTS.IsRunning()
				HnS_BUTTS.Start()
			endIf
			HnS_BUTTS.GotoState(HnSGotoState)
			Debug.Trace("BUTT Going to State: " + HnSGotoState)
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Activator_Highlight")
	endEvent
endState

state HnSUninstaller
	event OnSelectST()
		if ShowMessage("$HnS_UninstallConfirmationMessage")
			HnS_BUTTS.GotoState("")
			int handle = ModEvent.Create("HnS_Ended")
			if handle
				Utility.WaitMenuMode(0.25)
				ModEvent.PushBool(handle, ShowMessage("$HnS_RemoveItemsConfirmationMessage", true, "$Remove", "$Keep"))
				ModEvent.Send(handle)
			endIf
			Utility.WaitMenuMode(0.25)
			SetTextOptionValueST("$HnS_UninstallFinished")
			SetOptionFlagsST(OPTION_FLAG_DISABLED)
			ShowMessage("$HnS_ExitMenuToUninstall", false)
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Uninstaller_Highlight")
	endEvent
endState

state HnSAllowEnvironmentalBlindness
	event OnSelectST()
		float toggleFloat = (GlobalVarsArray[0].GetValue() - 1.0) * - 1.0
		if toggleFloat
			SetToggleOptionValueST(GlobalVarsArray[1].GetValue(), true, "HnSAllowNightVision")
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSAllowNightVision")
		else
			SetToggleOptionValueST(false, true, "HnSAllowNightVision")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSAllowNightVision")
		endIf
		GlobalVarsArray[0].SetValue(toggleFloat)
		SetToggleOptionValueST(toggleFloat)
		HnS_BUTTS.BOOBSCHeck()
	endEvent
	
	event OnDefaultST()
		bool GlobalChanged = (GlobalVarsArray[0].GetValue() != 1.0)
		if GlobalChanged
			GlobalVarsArray[0].SetValue(1.0)
			SetToggleOptionValueST(GlobalVarsArray[1].GetValue(), true, "HnSAllowNightVision")
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSAllowNightVision")
			SetToggleOptionValueST(true)
			HnS_BUTTS.BOOBSCHeck()
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_AllowEnvironmentalBlindness_Highlight")
	endEvent
endState

state HnSAllowNightVision
	event OnSelectST()
		float toggleFloat = (GlobalVarsArray[1].GetValue() - 1.0) * - 1.0
		GlobalVarsArray[1].SetValue(toggleFloat)
		SetToggleOptionValueST(toggleFloat)
	endEvent
	
	event OnDefaultST()
		bool GlobalChanged = (GlobalVarsArray[1].GetValue() != 1.0)
		if GlobalChanged
			GlobalVarsArray[1].SetValue(1.0)
			SetToggleOptionValueST(true)
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_AllowNightVision_Highlight")
	endEvent
endState

state HnSAllowSmelling
	event OnSelectST()
		float toggleFloat = (GlobalVarsArray[2].GetValue() - 1.0) * - 1.0
		GlobalVarsArray[2].SetValue(toggleFloat)
		SetToggleOptionValueST(toggleFloat)
		HnS_BUTTS.BDSMCheck()
	endEvent
	
	event OnDefaultST()
		bool GlobalChanged = (GlobalVarsArray[2].GetValue() != 1.0)
		if GlobalChanged
			GlobalVarsArray[2].SetValue(1.0)
			SetToggleOptionValueST(true)
			HnS_BUTTS.BDSMCheck()
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_AllowSmelling_Highlight")
	endEvent
endState

state HnSAllowHeatSeeking
	event OnSelectST()
		float toggleFloat = (GlobalVarsArray[3].GetValue() - 1.0) * - 1.0
		GlobalVarsArray[3].SetValue(toggleFloat)
		SetToggleOptionValueST(toggleFloat)
		HnS_BUTTS.TITSCheck()
		(HnS_BUTTS.GetAliasByName("PlayerAlias") as HotandSweatyLoad).StateValidation()
	endEvent
	
	event OnDefaultST()
		bool GlobalChanged = (GlobalVarsArray[3].GetValue() != 1.0)
		if GlobalChanged
			GlobalVarsArray[3].SetValue(1.0)
			SetToggleOptionValueST(true)
			HnS_BUTTS.TITSCheck()
			(HnS_BUTTS.GetAliasByName("PlayerAlias") as HotandSweatyLoad).StateValidation()
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_AllowHeatSeeking_Highlight")
	endEvent
endState

state HnSAllowMagickaDetection
	event OnSelectST()
		float toggleFloat = (GlobalVarsArray[4].GetValue() - 1.0) * - 1.0
		GlobalVarsArray[4].SetValue(toggleFloat)
		SetToggleOptionValueST(toggleFloat)
		HnS_BUTTS.DAMESCheck()
	endEvent
	
	event OnDefaultST()
		bool GlobalChanged = (GlobalVarsArray[4].GetValue() != 1.0)
		if GlobalChanged
			GlobalVarsArray[4].SetValue(1.0)
			SetToggleOptionValueST(true)
			HnS_BUTTS.DAMESCheck()
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_AllowMagickaDetection_Highlight")
	endEvent
endState

state HnSAllowAddToLeveledLists
	event OnSelectST()
		float toggleFloat = (GlobalVarsArray[5].GetValue() - 1.0) * (-1.0)
		GlobalVarsArray[5].SetValue(toggleFloat)
		HnS_BUTTS.LeveledListsCheck()
		SetToggleOptionValueST(toggleFloat)
	endEvent
	
	event OnDefaultST()
		;No default for this one.
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_AllowAddToLeveledLists_Highlight")
	endEvent
endState

state HnSTimeTillDetectionResets
	event OnSliderOpenST()
		SetSliderDialogRange(5.0 , 120.0)
		SetSliderDialogStartValue(GlobalVarsArray[10].GetValue() as int)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(45.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[10].SetValue(akValue)
		SetSliderOptionValueST(akValue, "${0} seconds")
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[10].SetValue(5.0)
		SetSliderOptionValueST(45.0, "${0} seconds")
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_TimeTillDetectionResets_Highlight")
	endEvent
endState

state HnSTimeBetweenSneakGlobalSettingChecks
	event OnSliderOpenST()
		SetSliderDialogRange( 6.0, 120.0)
		SetSliderDialogStartValue(GlobalVarsArray[6].GetValue() * 60.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(15.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[6].SetValue(akValue / 60.0)
		SetSliderOptionValueST(akValue, "${0} minutes")
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[6].SetValue(0.25)
		SetSliderOptionValueST(15, "${0} minutes")
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_TimeBetweenSneakGlobalSettingChecks_Highlight")
	endEvent
endState

state HnSTimeBetweenDetectionChecks
	event OnSliderOpenST()
		SetSliderDialogRange(1.0 , 5.0)
		SetSliderDialogStartValue(GlobalVarsArray[7].GetValue())
		SetSliderDialogInterval(0.05)
		SetSliderDialogDefaultValue(2.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[7].SetValue(akValue)
		SetSliderOptionValueST(akValue, "${2} seconds")
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[7].SetValue(2.0)
		SetSliderOptionValueST(2, "${2} seconds")
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_TotalTimeBetweenDetectionChecks_Highlight")
	endEvent
endState

state HnSAlertedBonus
	event OnSliderOpenST()
		SetSliderDialogRange( 0.0, 10.0)
		SetSliderDialogStartValue(GlobalVarsArray[8].GetValue())
		SetSliderDialogInterval(0.01)
		SetSliderDialogDefaultValue(0.25)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[8].SetValue(akValue)
		HnS_BUTTS.SADISTCheck()
		SetSliderOptionValueST(akValue, "{2}")
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[8].SetValue(0.25)
		HnS_BUTTS.SADISTCheck()
		SetSliderOptionValueST(0.25, "{2}")
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_AlertedBonus_Highlight")
	endEvent
endState

state HnSSneakBaseValueCeiling
	event OnSliderOpenST()
		SetSliderDialogRange( 20.0, 105.0)
		SetSliderDialogStartValue(GlobalVarsArray[9].GetValue() + 5.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(105.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[9].SetValue(akValue - 5.0)
		SetSliderOptionValueST(akValue, "{0}")
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[9].SetValue(100.0)
		SetSliderOptionValueST(105.0, "{0}")
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SneakBaseValueCeiling_Highlight")
	endEvent
endState

state HnSAlertWaitTime
	event OnSliderOpenST()
		SetSliderDialogRange( 5.0, 900.0)
		SetSliderDialogStartValue(GlobalVarsArray[11].GetValue())
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(60.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[11].SetValue(akValue)
		SetSliderOptionValueST(akValue, "${0} seconds")
		HnS_BUTTS.LongerSneakWait()
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[11].SetValue(60.0)
		SetSliderOptionValueST(60.0, "${0} seconds")
		HnS_BUTTS.LongerSneakWait()
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_AlertWaitTime_Highlight")
	endEvent
endState

state HnSAttackedWaitTime
	event OnSliderOpenST()
		SetSliderDialogRange( 5.0, 900.0)
		SetSliderDialogStartValue(GlobalVarsArray[12].GetValue())
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(120.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[12].SetValue(akValue)
		SetSliderOptionValueST(akValue, "${0} seconds")
		HnS_BUTTS.LongerSneakWait()
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[12].SetValue(120.0)
		SetSliderOptionValueST(120.0, "${0} seconds")
		HnS_BUTTS.LongerSneakWait()
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_AttackedWaitTime_Highlight")
	endEvent
endState

;=============$HnS_Environment_Page functions: ======================

state HnSWeatherFogThickness
	event OnSliderOpenST()
		SetSliderDialogRange(10.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[13].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(90.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[13].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[13].SetValue(0.9)
		SetSliderOptionValueST(90.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_WeatherFogThickness_Highlight")
	endEvent
endState

state HnSWeatherMildRainThickness
	event OnSliderOpenST()
		SetSliderDialogRange(10.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[14].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(80.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[14].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[14].SetValue(0.8)
		SetSliderOptionValueST(80.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_WeatherMildRainThickness_Highlight")
	endEvent
endState

state HnSWeatherMildRainHeaviness
	event OnSliderOpenST()
		SetSliderDialogRange(10.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[15].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(75.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[15].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[15].SetValue(0.75)
		SetSliderOptionValueST(75.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_WeatherMildRainHeaviness_Highlight")
	endEvent
endState

state HnSWeatherMildSnowThickness
	event OnSliderOpenST()
		SetSliderDialogRange(10.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[16].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(75.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[16].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[16].SetValue(0.75)
		SetSliderOptionValueST(75.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_WeatherMildSnowThickness_Highlight")
	endEvent
endState

state HnSWeatherMildSnowHeaviness
	event OnSliderOpenST()
		SetSliderDialogRange(10.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[17].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(90.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[17].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[17].SetValue(0.9)
		SetSliderOptionValueST(90.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_WeatherMildSnowHeaviness_Highlight")
	endEvent
endState

state HnSWeatherSevereRainThickness
	event OnSliderOpenST()
		SetSliderDialogRange(10.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[18].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(60.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[18].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[18].SetValue(0.6)
		SetSliderOptionValueST(60.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_WeatherSevereRainThickness_Highlight")
	endEvent
endState

state HnSWeatherSevereRainHeaviness
	event OnSliderOpenST()
		SetSliderDialogRange(10.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[19].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(50.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[19].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[19].SetValue(0.5)
		SetSliderOptionValueST(50.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_WeatherSevereRainHeaviness_Highlight")
	endEvent
endState

state HnSWeatherSevereSnowThickness
	event OnSliderOpenST()
		SetSliderDialogRange(10.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[20].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(50.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[20].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[20].SetValue(0.5)
		SetSliderOptionValueST(50.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_WeatherSevereSnowThickness_Highlight")
	endEvent
endState

state HnSWeatherSevereSnowHeaviness
	event OnSliderOpenST()
		SetSliderDialogRange(10.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[21].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(60.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[21].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[21].SetValue(0.6)
		SetSliderOptionValueST(60.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_WeatherSevereSnowHeaviness_Highlight")
	endEvent
endState

state HnSDuskStart
	event OnSliderOpenST()
		SetSliderDialogRange(12.05, GlobalVarsArray[23].GetValue() - 0.05) ;After noon, but before the start of night.
		SetSliderDialogStartValue(GlobalVarsArray[22].GetValue())
		SetSliderDialogInterval(0.05)
		SetSliderDialogDefaultValue(17)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[22].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[22].SetValue(17)
		SetSliderOptionValueST(17, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DuskStart_Highlight")
	endEvent
endState

state HnSNightStart
	event OnSliderOpenST()
		SetSliderDialogRange(GlobalVarsArray[22].GetValue() + 0.05, 23.95) ;After the start of dusk, but before midnight.
		SetSliderDialogStartValue(GlobalVarsArray[23].GetValue())
		SetSliderDialogInterval(0.05)
		SetSliderDialogDefaultValue(21)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[23].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[23].SetValue(21)
		SetSliderOptionValueST(21, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_NightStart_Highlight")
	endEvent
endState

state HnSDawnStart
	event OnSliderOpenST()
		SetSliderDialogRange(0.05, GlobalVarsArray[25].GetValue() - 0.05) ;After midnight, but before the start of day.
		SetSliderDialogStartValue(GlobalVarsArray[24].GetValue())
		SetSliderDialogInterval(0.05)
		SetSliderDialogDefaultValue(5)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[24].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[24].SetValue(5)
		SetSliderOptionValueST(5, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DawnStart_Highlight")
	endEvent
endState

state HnSDayStart
	event OnSliderOpenST()
		SetSliderDialogRange(GlobalVarsArray[24].GetValue() + 0.05, 11.95) ;After the start of dawn, but before noon.
		SetSliderDialogStartValue(GlobalVarsArray[25].GetValue())
		SetSliderDialogInterval(0.05)
		SetSliderDialogDefaultValue(8)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[25].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[25].SetValue(8)
		SetSliderOptionValueST(8, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DayStart_Highlight")
	endEvent
endState

state HnSPhaseChangeMaxSkillDecreasePercent
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[26].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(50.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[26].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[26].SetValue(0.5)
		SetSliderOptionValueST(50.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_PhaseChangeMaxSkillDecreasePercent_Highlight")
	endEvent
endState

;=============$HnS_Game_Settings_Page functions: ======================

state HnSDayBrightness
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[27].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(50.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[27].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[27].SetValue(50.0)
		SetSliderOptionValueST(50.0, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DayBrightness_Highlight")
	endEvent
endState

state HnSNightDarkness
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[28].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(20.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[28].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[28].SetValue(20.0)
		SetSliderOptionValueST(20.0, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_NightDarkness_Highlight")
	endEvent
endState

state HnSInteriorLuminosity
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[29].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(25.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[29].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[29].SetValue(25.0)
		SetSliderOptionValueST(25.0, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_InteriorLuminosity_Highlight")
	endEvent
endState

state HnSDayLoudness
	event OnSliderOpenST()
		SetSliderDialogRange(5.0, 1000.0)
		SetSliderDialogStartValue(GlobalVarsArray[30].GetValue() * 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(75.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[30].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[30].SetValue(0.75)
		SetSliderOptionValueST(75.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DayLoudness_Highlight")
	endEvent
endState

state HnSNightQuietness
	event OnSliderOpenST()
		SetSliderDialogRange(5.0, 1000.0)
		SetSliderDialogStartValue(GlobalVarsArray[31].GetValue() * 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(200.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[31].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[31].SetValue(3)
		SetSliderOptionValueST(200.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_NightQuietness_Highlight")
	endEvent
endState

state HnSInteriorNoisiness
	event OnSliderOpenST()
		SetSliderDialogRange(5.0, 1000.0)
		SetSliderDialogStartValue(GlobalVarsArray[32].GetValue() * 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(150.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[32].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[32].SetValue(1.5)
		SetSliderOptionValueST(150.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_InteriorNoisiness_Highlight")
	endEvent
endState

state HnSExteriorReverb
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[33].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(30.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[33].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[33].SetValue(0.3)
		SetSliderOptionValueST(30.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_ExteriorReverb_Highlight")
	endEvent
endState

state HnSInteriorReverb
	event OnSliderOpenST()
		SetSliderDialogRange(0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[34].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(60.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[34].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[34].SetValue(0.6)
		SetSliderOptionValueST(60.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_InteriorReverb_Highlight")
	endEvent
endState

state HnSDayDetectionDistance
	event OnSliderOpenST()
		SetSliderDialogRange(1000.0, 4096.0)
		SetSliderDialogStartValue(GlobalVarsArray[35].GetValue())
		SetSliderDialogInterval(100.0)
		SetSliderDialogDefaultValue(3000.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[35].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[35].SetValue(3000.0)
		SetSliderOptionValueST(3000.0, "{0}")
		BABESTrigger = true
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DayDetectionDistance_Highlight")
	endEvent
endState

state HnSNightDetectionDistance
	event OnSliderOpenST()
		SetSliderDialogRange(1000.0, 9000.0)
		SetSliderDialogStartValue(GlobalVarsArray[36].GetValue())
		SetSliderDialogInterval(100.0)
		SetSliderDialogDefaultValue(2500.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[36].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[36].SetValue(2500.0)
		SetSliderOptionValueST(2500.0, "{0}")
		BABESTrigger = true
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_NightDetectionDistance_Highlight")
	endEvent
endState

state HnSInteriorDetectionDistance
	event OnSliderOpenST()
		SetSliderDialogRange(1000.0, 9000.0)
		SetSliderDialogStartValue(GlobalVarsArray[37].GetValue())
		SetSliderDialogInterval(100.0)
		SetSliderDialogDefaultValue(2000.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[37].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[37].SetValue(2000.0)
		SetSliderOptionValueST(2000.0, "{0}")
		BABESTrigger = true
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_InteriorDetectionDistance_Highlight")
	endEvent
endState

state HnSDayViewCone
	event OnSliderOpenST()
		SetSliderDialogRange(90.0, 270.0)
		SetSliderDialogStartValue(GlobalVarsArray[38].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(170.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[38].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0} °")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[38].SetValue(170.0)
		SetSliderOptionValueST(170.0, "{0} °")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DayViewCone_Highlight")
	endEvent
endState

state HnSNightViewCone
	event OnSliderOpenST()
		SetSliderDialogRange(90.0, 270.0)
		SetSliderDialogStartValue(GlobalVarsArray[39].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(150.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[39].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0} °")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[39].SetValue(150.0)
		SetSliderOptionValueST(150.0, "{0} °")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_NightViewCone_Highlight")
	endEvent
endState

state HnSInteriorViewCone
	event OnSliderOpenST()
		SetSliderDialogRange(90.0, 270.0)
		SetSliderDialogStartValue(GlobalVarsArray[40].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(140.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[40].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0} °")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[40].SetValue(140.0)
		SetSliderOptionValueST(140.0, "{0} °")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_InteriorViewCone_Highlight")
	endEvent
endState

state HnSLightLevelKeyCode
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		GlobalVarsArray[65].SetValue(newKeyCode)
		HnS_BOOBS.LightLevelKeyRegistration()
		SetKeyMapOptionValueST(newKeyCode)
	endEvent

	event OnDefaultST()
		GlobalVarsArray[65].SetValue(0x2F)
		HnS_BOOBS.LightLevelKeyRegistration()
		SetKeyMapOptionValueST(0x2F)
	endEvent

	event OnHighlightST()
		SetInfoText("$HnS_LightLevelKeyCode_Highlight")
	endEvent
endState

;=============$HnS_Auxiliary_Senses_Page functions: ======================

state HnSBlindnessThreshold
	event OnSliderOpenST()
		SetSliderDialogRange(GlobalVarsArray[42].GetValue(), 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[41].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(60.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[41].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BOOBSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[41].SetValue(60.0)
		SetSliderOptionValueST(60.0, "{0}")
		BOOBSTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_BlindnessThreshold_Highlight")
	endEvent
endState

state HnSBlindnessThresholdNE
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, GlobalVarsArray[41].GetValue())
		SetSliderDialogStartValue(GlobalVarsArray[42].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(25.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[42].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BOOBSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[42].SetValue(25.0)
		SetSliderOptionValueST(25.0, "{0}")
		BOOBSTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_BlindnessThresholdNE_Highlight")
	endEvent
endState

state HnSLightBlindnessMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(GlobalVarsArray[43].GetValue())
		SetSliderDialogInterval(0.01)
		SetSliderDialogDefaultValue(1.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[43].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BOOBSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[43].SetValue(1.0)
		SetSliderOptionValueST(1.0, "{2}")
		BOOBSTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_LightBlindnessMod_Highlight")
	endEvent
endState

state HnSLightBlindnessModNE
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 2.0)
		SetSliderDialogStartValue(GlobalVarsArray[44].GetValue())
		SetSliderDialogInterval(0.01)
		SetSliderDialogDefaultValue(1.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[44].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BOOBSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[44].SetValue(1.0)
		SetSliderOptionValueST(1.0, "{2}")
		BOOBSTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_LightBlindnessModNE_Highlight")
	endEvent
endState

state HnSplayerNaturalHeatDampenedPercent
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[59].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(1.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[59].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[59].SetValue(1.67)
		SetSliderOptionValueST(167.0, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_PlayerNaturalHeatDampenedPercent_Highlight")
	endEvent
endState

state HnSplayerTemperatureDampenedAmount
	event OnSliderOpenST()
		SetSliderDialogRange(1.0, 30.0)
		SetSliderDialogStartValue(GlobalVarsArray[58].GetValue())
		SetSliderDialogInterval(0.1)
		SetSliderDialogDefaultValue(8.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[58].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{1}")
		TITSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[58].SetValue(8.0)
		SetSliderOptionValueST(8.0, "{1}")
		TITSTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_playerTemperatureDampenedAmount_Highlight")
	endEvent
endState

state HnSheatThermalUnderwearPower
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[60].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(22.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[60].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[60].SetValue(0.22)
		SetSliderOptionValueST(22.0, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_HeatThermalUnderwearPower_Highlight")
	endEvent
endState

state HnSheatPotionPower
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[61].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(33.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[61].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[61].SetValue(0.33)
		SetSliderOptionValueST(33.0, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_heatPotionPower_Highlight")
	endEvent
endState

state HnSheatCloakofDarkessPower
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[62].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(45.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[62].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[62].SetValue(0.45)
		SetSliderOptionValueST(45.0, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_heatCloakofDarkessPower_Highlight")
	endEvent
endState

state HnSmagickaIgnored
	event OnSliderOpenST()
		SetSliderDialogRange(10.0, 1000.0)
		SetSliderDialogStartValue(GlobalVarsArray[63].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[63].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		DAMESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[63].SetValue(100.0)
		SetSliderOptionValueST(100.0, "{0}")
		DAMESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_magickaIgnored_Highlight")
	endEvent
endState

state HnSmagickaReductionPercent
	event OnSliderOpenST()
		SetSliderDialogRange(25.0, 99.5)
		SetSliderDialogStartValue(100 - GlobalVarsArray[64].GetValue() * 100.0)
		SetSliderDialogInterval(0.5)
		SetSliderDialogDefaultValue(80.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[64].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		DAMESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[64].SetValue(0.2)
		SetSliderOptionValueST(80.0, "{0}%")
		DAMESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_magickaReductionPercent_Highlight")
	endEvent
endState

;=============$HnS_Smell_Sense_Page functions: ======================

state HnSPlayerNaturalBO
	event OnSliderOpenST()
		SetSliderDialogRange(1.0, 200.0)
		SetSliderDialogStartValue(GlobalVarsArray[45].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[45].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[45].SetValue(1.0)
		SetSliderOptionValueST(100.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_PlayerNaturalBO_Highlight")
	endEvent
endState

state HnSSmellDistanceModifier
	event OnSliderOpenST()
		SetSliderDialogRange(-50.0, 100.0)
		SetSliderDialogStartValue((GlobalVarsArray[47].GetValue() - 1.0) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(0.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[47].SetValue((akValue / 100.0) + 1.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[47].SetValue(1.5)
		SetSliderOptionValueST(50.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SmellDistanceModifier_Highlight")
	endEvent
endState

state HnSDirtinessPercentageModifier
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[46].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[46].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[46].SetValue(1.0)
		SetSliderOptionValueST(100.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DirtinessPercentageModifier_Highlight")
	endEvent
endState

state HnSSmellDeodorantPower
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[48].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(20.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[48].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[48].SetValue(0.2)
		SetSliderOptionValueST(20.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SmellDeodorantPower_Highlight")
	endEvent
endState

state HnSSmellZeolitePower
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[49].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(30.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[49].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[49].SetValue(0.3)
		SetSliderOptionValueST(30.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SmellZeolitePower_Highlight")
	endEvent
endState

state HnSSmellWindsPower
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[50].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(50.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[50].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[50].SetValue(0.5)
		SetSliderOptionValueST(50.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SmellWindsPower_Highlight")
	endEvent
endState

state HnSSmellOtherCloak
	event OnSliderOpenST()
		SetSliderDialogRange(0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[51].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(25.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[51].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[51].SetValue(0.25)
		SetSliderOptionValueST(25.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SmellOtherCloak_Highlight")
	endEvent
endState

state HnSTier4SmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange((1 - GlobalVarsArray[56].GetValue()) * 100.0, 200.0)
		SetSliderDialogStartValue((1 - GlobalVarsArray[57].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[57].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[57].SetValue(0.0)
		SetSliderOptionValueST(100.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Tier4SmellSensitivityExponent_Highlight")
	endEvent
endState

state HnSTier3SmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange((1.0 - GlobalVarsArray[55].GetValue()) * 100.0,(1 - GlobalVarsArray[57].GetValue()) * 100.0)
		SetSliderDialogStartValue((1.0 - GlobalVarsArray[56].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(90.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[56].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[56].SetValue(0.1)
		SetSliderOptionValueST(90.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Tier3SmellSensitivityExponent_Highlight")
	endEvent
endState

state HnSTier2SmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange((1.0 - GlobalVarsArray[54].GetValue()) * 100.0,(1.0 - GlobalVarsArray[56].GetValue()) * 100.0)
		SetSliderDialogStartValue((1.0 - GlobalVarsArray[55].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(80.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[55].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[55].SetValue(0.2)
		SetSliderOptionValueST(80.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Tier2SmellSensitivityExponent_Highlight")
	endEvent
endState

state HnSTier1SmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange((1.0 - GlobalVarsArray[53].GetValue()) * 100.0,(1.0 - GlobalVarsArray[55].GetValue()) * 100.0)
		SetSliderDialogStartValue((1.0 - GlobalVarsArray[54].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(70.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[54].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[54].SetValue(0.3)
		SetSliderOptionValueST(70.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Tier1SmellSensitivityExponent_Highlight")
	endEvent
endState

state HnSDefaultSmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange((1.0 - GlobalVarsArray[52].GetValue()) * 100.0,(1.0 - GlobalVarsArray[54].GetValue()) * 100.0)
		SetSliderDialogStartValue((1.0 - GlobalVarsArray[53].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(60.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[53].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[53].SetValue(0.4)
		SetSliderOptionValueST(60.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DefaultSmellSensitivityExponent_Highlight")
	endEvent
endState

state HnSNPCSmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange(-100.0, (1.0 - GlobalVarsArray[53].GetValue()) * 100.0)
		SetSliderDialogStartValue((1.0 - GlobalVarsArray[52].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(-90.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[52].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[52].SetValue(1.9)
		SetSliderOptionValueST(-90.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_NPCSmellSensitivityExponent_Highlight")
	endEvent
endState

;=============$HnS_Racial_Configuration functions: ======================

state HnSTextPlaceholder
	;Empty This is just used as a place-holder for text.
endState

state HnSSelectRaceMenu

	event OnMenuOpenST()
		;int ProcessedRacesListLength = FormListCount(none, "HnS_ProcessedRaces")
		SetMenuDialogStartIndex(CurrentlyModifiedRaceIndex)
		SetMenuDialogDefaultIndex(ProcessedRacesListLength)
		SetMenuDialogOptions(RacialMenuList)
	endEvent
	
	event OnMenuAcceptST(int index)
		if index != -1
			CurrentlyModifiedRaceIndex = index
			if CurrentlyModifiedRaceIndex < FormListCount(none, "HnS_ProcessedRaces")
				CurrentRace = FormListGet(none, "HnS_ProcessedRaces", CurrentlyModifiedRaceIndex) as Race
				;SetTextOptionValueST("$HnS_Exit_Menu_After_Changes", true, "HnSTextPlaceholder")
				;Blindness Option Block
				bool IgnoredRace = FormListHas(none, "HnS_IgnoredModdedRaces", CurrentRace)
				if !IgnoredRace
					EnableRacialToggleOptions()
				else
					DisableRacialToggleOptions()
				endIf
				SetToggleOptionValueST(IgnoredRace, true, "HnSIgnoreRace")
				SetOptionFlagsST(OPTION_FLAG_NONE, false, "HnSIgnoreRace")
			else
				;CurrentRace = none
				DisableRacialToggleOptions()
				SetTextOptionValueST("$HnS_Select_Race", true, "HnSTextPlaceholder")
				SetToggleOptionValueST(false, true, "HnSIgnoreRace")
				SetOptionFlagsST(OPTION_FLAG_DISABLED, "HnSIgnoreRace")
			endIf
			;SetOptionFlagsST(OPTION_FLAG_DISABLED, true) No longer necessary.
			SetMenuOptionValueST(RacialMenuList[CurrentlyModifiedRaceIndex])
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Select_Race_Highlight")
	endEvent
endState

state HnSRacialBlindness
	event OnSelectST()
		bool NewEnabledState = !Blindable(CurrentRace)
		bool VariableSetSuccessfully = SetBlindnessEnable(CurrentRace, NewEnabledState)
		Debug.trace("Blindness was set correctly: " + VariableSetSuccessfully)
		if VariableSetSuccessfully
			int NVWhichOptionFlag = OPTION_FLAG_DISABLED
			bool Rodability = HasExtraRods(CurrentRace)
			bool PitOrgany = HasPitOrgans(CurrentRace)
			int BlindnessIndex = 2 * (PitOrgany as int) + (Rodability as int)
			if NewEnabledState
				FormListAdd(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[BlindnessIndex], false)
				if GlobalVarsArray[1].GetValue()
					NVWhichOptionFlag = OPTION_FLAG_NONE
				else
					Rodability = false
				endIf
			else
				FormListRemove(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[BlindnessIndex], true)
				Rodability = false
			endIf
			SetToggleOptionValueST(Rodability, true, "HnSRacialNightVision")
			SetOptionFlagsST(NVWhichOptionFlag, true, "HnSRacialNightVision")
			FormListAdd(none, "HnS_MCMEditedRaces", CurrentRace, false)
			MCMRacesChanged = LogicalOr(1, MCMRacesChanged)
			SetToggleOptionValueST(NewEnabledState)
		endIf
	endEvent
	
	event OnDefaultST()
		
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_RacialBlindness_Highlight")
	endEvent
endState

state HnSRacialSmelling
	event OnSelectST()
		bool NewEnabledState = !HasNostrils(CurrentRace)
		bool VariableSetSuccessfully = SetSmellEnable(CurrentRace, NewEnabledState)
		Debug.trace("Smelling was set correctly: " + VariableSetSuccessfully)
		if VariableSetSuccessfully
			int CurrentSmellLevel = OlfactoryReceptorNeuronDensity(CurrentRace)
			if NewEnabledState
				FormListAdd(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[CurrentSmellLevel + 4], false)
				SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSRacialSmellTier")
				SetMenuOptionValueST(SmellTierArray[CurrentSmellLevel], true, "HnSRacialSmellTier")
			else
				FormListRemove(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[CurrentSmellLevel + 4], true)
				SetMenuOptionValueST("$None", true, "HnSRacialSmellTier")
				SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialSmellTier")
			endIf
			FormListAdd(none, "HnS_MCMEditedRaces", CurrentRace, false)
			SetToggleOptionValueST(NewEnabledState)
			MCMRacesChanged = LogicalOr(1, MCMRacesChanged)
		endIf
	endEvent
	
	event OnDefaultST()
		
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_RacialSmelling_Highlight")
	endEvent
endState

state HnSRacialHeatVision
	event OnSelectST()
		bool NewEnabledState = !HasPitOrgans(CurrentRace)
		bool VariableSetSuccessfully = SetHeatVisionEnable(CurrentRace, NewEnabledState)
		Debug.trace("Heat Vision was set correctly: " + VariableSetSuccessfully)
		if VariableSetSuccessfully
			bool RacialBlindability = Blindable(CurrentRace)
			bool Rodability = HasExtraRods(CurrentRace)
			int RodabilityInt = Rodability as int
			int  HeatSeekingBlindnessIndex = 2 + RodabilityInt
			if NewEnabledState
				FormListAdd(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[10], false)
				if RacialBlindability
					FormListRemove(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[RodabilityInt], true)
					FormListAdd(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[HeatSeekingBlindnessIndex], false)
				endIf
			else
				FormListRemove(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[10], true)
				if RacialBlindability
					FormListRemove(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[HeatSeekingBlindnessIndex], true)
					FormListAdd(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[RodabilityInt], false)
				endIf
			endIf
			FormListAdd(none, "HnS_MCMEditedRaces", CurrentRace, false)
			SetToggleOptionValueST(NewEnabledState)
			MCMRacesChanged = LogicalOr(1, MCMRacesChanged)
		endIf
	endEvent
	
	event OnDefaultST()
		
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_RacialHeatVision_Highlight")
	endEvent
endState

state HnSRacialMagickaDetection
	event OnSelectST()
		bool NewEnabledState = !HasAmpullaeOfLorenzini(CurrentRace)
		bool VariableSetSuccessfully = SetMagickaDetectionEnable(CurrentRace, NewEnabledState)
		Debug.trace("Magicka Detection was set correctly: " + VariableSetSuccessfully)
		if VariableSetSuccessfully
			if NewEnabledState
				FormListAdd(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[11], false)
			else
				FormListRemove(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[11], true)
			endIf
			FormListAdd(none, "HnS_MCMEditedRaces", CurrentRace, false)
			SetToggleOptionValueST(NewEnabledState)
			MCMRacesChanged = LogicalOr(1, MCMRacesChanged)
		endIf
	endEvent
	
	event OnDefaultST()
		
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_RacialMagickaDetection_Highlight")
	endEvent
endState

state HnSRacialNightVision
	event OnSelectST()
		bool NewEnabledState = !HasExtraRods(CurrentRace)
		bool VariableSetSuccessfully = SetNightVisionEnable(CurrentRace, NewEnabledState)
		Debug.trace("Night Vision was set correctly: " + VariableSetSuccessfully)
		if VariableSetSuccessfully
			int PitOrganyInt = 2 * (HasPitOrgans(CurrentRace) as int)
			int OldBlindnessIndex = PitOrganyInt + ((!NewEnabledState) as int)
			int NewBlindnessIndex = PitOrganyInt + (NewEnabledState as int)
			FormListRemove(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[OldBlindnessIndex], true)
			FormListAdd(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[NewBlindnessIndex], false)
			FormListAdd(none, "HnS_MCMEditedRaces", CurrentRace, false)
			SetToggleOptionValueST(NewEnabledState)
			MCMRacesChanged = LogicalOr(1, MCMRacesChanged)
		endIf
	endEvent
	
	event OnDefaultST()
		
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_RacialNightVision_Highlight")
	endEvent
endState

state HnSRacialSmellTier
	event OnMenuOpenST()
		SetMenuDialogStartIndex(OlfactoryReceptorNeuronDensity(CurrentRace))
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(SmellTierArray)
	endEvent
	
	event OnMenuAcceptST(int index)
		if index > -1
			int OldSmellLevel = OlfactoryReceptorNeuronDensity(CurrentRace)
			bool VariableSetSuccessfully = SetSmellTier(CurrentRace, index)
			Debug.trace("Smell Tier was changed from " + OldSmellLevel + " to " + index + " successfully: " + VariableSetSuccessfully)
			if VariableSetSuccessfully
				FormListRemove(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[OldSmellLevel + 4], true)
				FormListAdd(CurrentRace, "HnS_RacialAbilities", ListOfSpellsToApply[index + 4], false)
				FormListAdd(none, "HnS_MCMEditedRaces", CurrentRace, false)
				SetMenuOptionValueST(SmellTierArray[index])
				MCMRacesChanged = LogicalOr(1, MCMRacesChanged)
			endIf
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_RacialSmellTier_Highlight")
	endEvent
endState

state HnSIgnoreRace
	event OnSelectST()
		if ShowMessage("$HnS_IgnoreQuery")
			bool NewEnabledState = !FormListHas(none, "HnS_IgnoredModdedRaces", CurrentRace)
			if NewEnabledState
				FormListAdd(none, "HnS_IgnoredModdedRaces", CurrentRace, false)
				DisableRacialToggleOptions()
			else
				FormListRemove(none, "HnS_IgnoredModdedRaces", CurrentRace, true)
				EnableRacialToggleOptions()
			endIf
			FormListAdd(none, "HnS_MCMEditedRaces", CurrentRace, false)
			SetToggleOptionValueST(NewEnabledState)
			MCMRacesChanged = LogicalOr(1, MCMRacesChanged)
		endIf
	endEvent
	
	event OnDefaultST()
		
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_IgnoreRace_Highlight")
	endEvent
endState

function EnableRacialToggleOptions()
	bool Blindability = false
	if GlobalVarsArray[0].GetValue()
		Blindability = Blindable(CurrentRace)
		SetToggleOptionValueST(Blindability, true, "HnSRacialBlindness")
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSRacialBlindness")
	else
		SetToggleOptionValueST(false, true, "HnSRacialBlindness")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialBlindness")
	endIf
	
	;Smell Option Block
	bool Smellability = false
	if GlobalVarsArray[2].GetValue()
		Smellability = HasNostrils(CurrentRace)
		SetToggleOptionValueST(Smellability, true, "HnSRacialSmelling")
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSRacialSmelling")
	else
		Smellability = false
		SetToggleOptionValueST(false, true, "HnSRacialSmelling")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialSmelling")
	endIf
	
	;Heat Seeker Option Block
	bool HeatSeeker
	if GlobalVarsArray[3].GetValue()
		HeatSeeker = HasPitOrgans(CurrentRace)
		SetToggleOptionValueST(HeatSeeker, true, "HnSRacialHeatVision")
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSRacialHeatVision")
	else
		HeatSeeker = false
		SetToggleOptionValueST(false, true, "HnSRacialHeatVision")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialHeatVision")
	endIf
	
	;Magicka Detection Option Block
	if GlobalVarsArray[4].GetValue()
		SetToggleOptionValueST(HasAmpullaeOfLorenzini(CurrentRace), true, "HnSRacialMagickaDetection")
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSRacialMagickaDetection")
	else
		SetToggleOptionValueST(false, true, "HnSRacialMagickaDetection")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialMagickaDetection")
	endIf
	
	;Heat Seeker Option Block
	if GlobalVarsArray[1].GetValue() && Blindability
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSRacialNightVision")
		SetToggleOptionValueST(HasExtraRods(CurrentRace), true, "HnSRacialNightVision")
	else
		SetToggleOptionValueST(false, true, "HnSRacialNightVision")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialNightVision")
	endIf
	
	if Smellability
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSRacialSmellTier")
		SetMenuOptionValueST(SmellTierArray[OlfactoryReceptorNeuronDensity(CurrentRace)], true, "HnSRacialSmellTier")
	else
		SetMenuOptionValueST("$None", true, "HnSRacialSmellTier")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialSmellTier")
	endIf
endFunction

function DisableRacialToggleOptions()
	SetToggleOptionValueST(false, true, "HnSRacialBlindness")
	SetToggleOptionValueST(false, true, "HnSRacialSmelling")
	SetToggleOptionValueST(false, true, "HnSRacialHeatVision")
	SetToggleOptionValueST(false, true, "HnSRacialMagickaDetection")
	SetToggleOptionValueST(false, true, "HnSRacialNightVision")
	SetMenuOptionValueST("$None", true, "HnSRacialSmellTier")
	SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialBlindness")
	SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialSmelling")
	SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialHeatVision")
	SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialMagickaDetection")
	SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialNightVision")
	SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSRacialSmellTier")
endFunction

;=============$HnS_Preset functions: ======================

state HnSSelectPresetInput
	event OnInputOpenST()
		SetInputDialogStartText(HnSPresetFileName)
	endEvent
	
	event OnInputAcceptST(string inputedString)
		HnSPresetFileName = inputedString
		SetInputOptionValueST(inputedString)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SelectPresetInput_Highlight")
	endEvent
endState

state HnSSaveCurrentPreset
	event OnSelectST()
		if ShowMessage("$HnS_SaveQuery")
			SetTextOptionValueST("$HnS_TryingToSave")
			int SaveWarningCount = SaveCurrentPreset()
			if SaveWarningCount == 0
				ShowMessage("$HnS_SaveSuccessful", false)
				SetTextOptionValueST("$Success")
			elseIf SaveWarningCount > 0
				ShowMessage("$HnS_SavePartiallySuccessful", false)
				SetTextOptionValueST(SaveWarningCount + " Warnings")
			else
				ShowMessage("$HnS_SaveFailed", false)
				SetTextOptionValueST("$Failure")
			endIf
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Save_Current_Preset_Highlight")
	endEvent
endState

state HnSLoadCurrentPreset
	event OnSelectST()
		if ShowMessage("$HnS_LoadQuery")
			SetTextOptionValueST("$HnS_TryingToLoad")
			int LoadWarningCount = LoadCurrentPreset()
			if LoadWarningCount == 0
				ShowMessage("$HnS_LoadSuccessful", false)
				SetTextOptionValueST("$Success")
			elseIf LoadWarningCount > 0
				ShowMessage("$HnS_LoadPartiallySuccessful", false)
				SetTextOptionValueST(LoadWarningCount + " Warnings")
			else
				ShowMessage("$HnS_LoadFailed", false)
				SetTextOptionValueST("$Failure")
			endIf
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Load_Current_Preset_Highlight")
	endEvent
endState

;=============$Racial Configuration Functions: =========================

bool function SetBlindnessEnable(Race akTargetRace, bool abTurnOn)
	if abTurnOn == Blindable(akTargetRace)
		return false
	elseIf abTurnOn
		FormListRemove(none, "HnS_EnviroBlindnessImmuneRaces", akTargetRace, true)
	else
		FormListAdd(none, "HnS_EnviroBlindnessImmuneRaces", akTargetRace, false)
	endIf
	return abTurnOn == Blindable(akTargetRace)
endFunction


bool function SetNightVisionEnable(Race akTargetRace, bool abTurnOn)
	if abTurnOn == HasExtraRods(akTargetRace)
		return false
	elseIf abTurnOn
		FormListAdd(none, "HnS_NightVisionRaces", akTargetRace, false)
	else
		FormListRemove(none, "HnS_NightVisionRaces", akTargetRace, true)
	endIf
	return abTurnOn == HasExtraRods(akTargetRace)
endFunction

bool function SetSmellEnable(Race akTargetRace, bool abTurnOn)
	if abTurnOn == HasNostrils(akTargetRace)
		return false
	elseIf abTurnOn
		if FormListHas(none, "HnS_NoSmellRaces", akTargetRace)
			FormListRemove(none, "HnS_NoSmellRaces", akTargetRace, true)
		else
			FormListAdd(none, "HnS_SmellyUnLivingRaces", akTargetRace, false)
		endIf
	else
		if FormListHas(none, "HnS_SmellyUnLivingRaces", akTargetRace)
			FormListRemove(none, "HnS_SmellyUnLivingRaces", akTargetRace, true)
		else
			FormListAdd(none, "HnS_NoSmellRaces", akTargetRace, false)
		endIf
	endIf
	return abTurnOn == HasNostrils(akTargetRace)
endFunction

bool function SetHeatVisionEnable(Race akTargetRace, bool abTurnOn)
	if abTurnOn == HasPitOrgans(akTargetRace)
		return false
	elseIf abTurnOn
		if FormListHas(none, "HnS_NoThermalVisionUndeadRaces", akTargetRace)
			FormListRemove(none, "HnS_NoThermalVisionUndeadRaces", akTargetRace, true)
		else
			FormListAdd(none, "HnS_ThermalVisionRaces", akTargetRace, false)
		endIf
	else
		if FormListHas(none, "HnS_ThermalVisionRaces", akTargetRace)
			FormListRemove(none, "HnS_ThermalVisionRaces", akTargetRace, true)
		else
			FormListAdd(none, "HnS_NoThermalVisionUndeadRaces", akTargetRace, false)
		endIf
	endIf
	return abTurnOn == HasPitOrgans(akTargetRace)
endFunction

bool function SetMagickaDetectionEnable(Race akTargetRace, bool abTurnOn)
	if abTurnOn == HasAmpullaeOfLorenzini(akTargetRace)
		return false
	elseIf abTurnOn
		if FormListHas(none, "HnS_NoMagickaDetectionDwarvenRaces", akTargetRace)
			FormListRemove(none, "HnS_NoMagickaDetectionDwarvenRaces", akTargetRace, true)
		else
			FormListAdd(none, "HnS_MagickaDetectionRaces", akTargetRace, false)
		endIf
	else
		if FormListHas(none, "HnS_MagickaDetectionRaces", akTargetRace)
			FormListRemove(none, "HnS_MagickaDetectionRaces", akTargetRace, true)
		else
			FormListAdd(none, "HnS_NoMagickaDetectionDwarvenRaces", akTargetRace, false)
		endIf
	endIf
	return abTurnOn == HasAmpullaeOfLorenzini(akTargetRace)
endFunction

bool function SetSmellTier(Race akTargetRace, int aiNewTier)
	int CurrentTier = OlfactoryReceptorNeuronDensity(akTargetRace)
	if CurrentTier == aiNewTier ;if tier doesn't change return false
		return false
	elseIf CurrentTier == 5 ;Otherwise remove from old Formlist
		FormListRemove(none, "HnS_SmellTier4Races", akTargetRace, true)
	elseIf CurrentTier == 4
		FormListRemove(none, "HnS_SmellTier3Races", akTargetRace, true)
	elseIf CurrentTier == 3
		FormListRemove(none, "HnS_SmellTier2Races", akTargetRace, true)
	elseIf CurrentTier == 2
		FormListRemove(none, "HnS_SmellTier1Races", akTargetRace, true)
	elseIf CurrentTier == 1
		if FormListHas(none, "HnS_SmellNPCExceptionRaces", akTargetRace)
			FormListRemove(none, "HnS_SmellNPCExceptionRaces", akTargetRace, true)
		endIf
	elseIf CurrentTier == 0
		if FormListHas(none, "HnS_SmellTierNPCRaces", akTargetRace)
			FormListRemove(none, "HnS_SmellTierNPCRaces", akTargetRace, true)
		endIf
	else
		Debug.Trace("Hot and Sweaty MCM ERROR: SetSmellTier CurrentTier Out of Bounds!")
	endIf
		
	if OlfactoryReceptorNeuronDensity(akTargetRace) == aiNewTier ;If removing from old formlist was enough, return true
		return true
	elseIf aiNewTier == 5 ;Else try adding to new Formlist
		FormListAdd(none, "HnS_SmellTier4Races", akTargetRace, false)
	elseIf aiNewTier == 4
		FormListAdd(none, "HnS_SmellTier3Races", akTargetRace, false)
	elseIf aiNewTier == 3
		FormListAdd(none, "HnS_SmellTier2Races", akTargetRace, false)
	elseIf aiNewTier == 2
		FormListAdd(none, "HnS_SmellTier1Races", akTargetRace, false)
	elseIf aiNewTier == 1
		FormListAdd(none, "HnS_SmellNPCExceptionRaces", akTargetRace, false)
	elseIf aiNewTier == 0
		FormListAdd(none, "HnS_SmellTierNPCRaces", akTargetRace, false)
	else
		Debug.Trace("Hot and Sweaty MCM ERROR: SetSmellTier aiNewTier Out of Bounds!")
	endIf
	return OlfactoryReceptorNeuronDensity(akTargetRace) == aiNewTier ;Make sure we got it right.
endFunction

;=============$Save and Load Functions: =========================

int function SaveCurrentPreset()
	string SaveFileName = "../HnS/" + HnSPresetFileName
	int ListCounter = 0
	float[] trytoSaveFloatArray = Utility.CreateFloatArray(GlobalVarsArray.Length)
	while ListCounter < GlobalVarsArray.Length
		trytoSaveFloatArray[ListCounter] = GlobalVarsArray[ListCounter].GetValue()
		ListCounter +=1
	endWhile
	int warningCounter = 0
	if !JsonUtil.FloatListCopy(SaveFileName, "GlobalVariablesList", trytoSaveFloatArray)
		Debug.Trace("Unable to Save Global Variables List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "EnviroBlindnessImmuneRaces", FormListToArray(none, "HnS_EnviroBlindnessImmuneRaces"))
		Debug.Trace("Unable to Save EnviroBlindnessImmuneRaces List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "NightVisionRaces", FormListToArray(none, "HnS_NightVisionRaces"))
		Debug.Trace("Unable to Save NightVisionRaces List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "NoSmellRaces", FormListToArray(none, "HnS_NoSmellRaces"))
		Debug.Trace("Unable to Save NoSmellRaces List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "SmellyUnLivingRaces", FormListToArray(none, "HnS_SmellyUnLivingRaces"))
		Debug.Trace("Unable to Save SmellyUnLivingRaces List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "SmellTierNPCRaces", FormListToArray(none, "HnS_SmellTierNPCRaces"))
		Debug.Trace("Unable to Save SmellTierNPCRaces List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "SmellNPCExceptionRaces", FormListToArray(none, "HnS_SmellNPCExceptionRaces"))
		Debug.Trace("Unable to Save SmellNPCExceptionRaces List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "SmellTier1Races", FormListToArray(none, "HnS_SmellTier1Races"))
		Debug.Trace("Unable to Save SmellTier1Races List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "SmellTier2Races", FormListToArray(none, "HnS_SmellTier2Races"))
		Debug.Trace("Unable to Save SmellTier2Races List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "SmellTier3Races", FormListToArray(none, "HnS_SmellTier3Races"))
		Debug.Trace("Unable to Save SmellTier3Races List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "SmellTier4Races", FormListToArray(none, "HnS_SmellTier4Races"))
		Debug.Trace("Unable to Save SmellTier4Races List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "ThermalVisionRaces", FormListToArray(none, "HnS_ThermalVisionRaces"))
		Debug.Trace("Unable to Save ThermalVisionRaces List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "NoThermalVisionUndeadRaces", FormListToArray(none, "HnS_NoThermalVisionUndeadRaces"))
		Debug.Trace("Unable to Save NoThermalVisionUndeadRaces List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "MagickaDetectionRaces", FormListToArray(none, "HnS_MagickaDetectionRaces"))
		Debug.Trace("Unable to Save MagickaDetectionRaces List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "NoMagickaDetectionDwarvenRaces", FormListToArray(none, "HnS_NoMagickaDetectionDwarvenRaces"))
		Debug.Trace("Unable to Save NoMagickaDetectionDwarvenRaces List.")
		warningCounter += 1
	endIf
	JsonUtil.Unload(SaveFileName)
	return warningCounter
endFunction

int function LoadCurrentPreset()
	int ListCounter = 0
	string LoadFileName = "../HnS/" + HnSPresetFileName
	if !JsonUtil.Load(LoadFileName) || !JsonUtil.IsGood(LoadFileName)
		Debug.Trace("Unable to Read data from file.")
		return -1
	endIf
	
	float[] trytoLoadFloatArray = JsonUtil.FloatListToArray(LoadFileName, "GlobalVariablesList")
	if trytoLoadFloatArray.length == GlobalVarsArray.length
		while ListCounter < GlobalVarsArray.length
			GlobalVarsArray[ListCounter].SetValue(trytoLoadFloatArray[ListCounter])
			ListCounter +=1
		endWhile
	else
		Debug.Trace("Unable to Load Global Variables List.")
		return -1
	endIf
	
	int warningCounter = 0
	if !FormListCopy(none, "HnS_EnviroBlindnessImmuneRaces", JsonUtil.FormListToArray(LoadFileName, "EnviroBlindnessImmuneRaces"))
		Debug.Trace("Unable to Load HnS_EnviroBlindnessImmuneRaces List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_NightVisionRaces", JsonUtil.FormListToArray(LoadFileName, "NightVisionRaces"))
		Debug.Trace("Unable to Load HnS_NightVisionRaces List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_NoSmellRaces", JsonUtil.FormListToArray(LoadFileName, "NoSmellRaces"))
		Debug.Trace("Unable to Load HnS_NoSmellRaces List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_SmellyUnLivingRaces", JsonUtil.FormListToArray(LoadFileName, "SmellyUnLivingRaces"))
		Debug.Trace("Unable to Load HnS_SmellyUnLivingRaces List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_SmellTierNPCRaces", JsonUtil.FormListToArray(LoadFileName, "SmellTierNPCRaces"))
		Debug.Trace("Unable to Load HnS_SmellTierNPCRaces List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_SmellNPCExceptionRaces", JsonUtil.FormListToArray(LoadFileName, "SmellNPCExceptionRaces"))
		Debug.Trace("Unable to Load HnS_SmellNPCExceptionRaces List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_SmellTier1Races", JsonUtil.FormListToArray(LoadFileName, "SmellTier1Races"))
		Debug.Trace("Unable to Load HnS_SmellTier1Races List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_SmellTier2Races", JsonUtil.FormListToArray(LoadFileName, "SmellTier2Races"))
		Debug.Trace("Unable to Load HnS_SmellTier2Races List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_SmellTier3Races", JsonUtil.FormListToArray(LoadFileName, "SmellTier3Races"))
		Debug.Trace("Unable to Load HnS_SmellTier3Races List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_SmellTier4Races", JsonUtil.FormListToArray(LoadFileName, "SmellTier4Races"))
		Debug.Trace("Unable to Load HnS_SmellTier4Races List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_ThermalVisionRaces", JsonUtil.FormListToArray(LoadFileName, "ThermalVisionRaces"))
		Debug.Trace("Unable to Load HnS_ThermalVisionRaces List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_NoThermalVisionUndeadRaces", JsonUtil.FormListToArray(LoadFileName, "NoThermalVisionUndeadRaces"))
		Debug.Trace("Unable to Load HnS_NoThermalVisionUndeadRaces List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_MagickaDetectionRaces", JsonUtil.FormListToArray(LoadFileName, "MagickaDetectionRaces"))
		Debug.Trace("Unable to Load HnS_MagickaDetectionRaces List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_NoMagickaDetectionDwarvenRaces", JsonUtil.FormListToArray(LoadFileName, "NoMagickaDetectionDwarvenRaces"))
		Debug.Trace("Unable to Load HnS_NoMagickaDetectionDwarvenRaces List.")
		warningCounter += 1
	endIf
	JsonUtil.Unload(LoadFileName, false)
	HnS_BUTTS.SADISTCheck()
	HnS_BUTTS.BOOBSCHeck()
	HnS_BUTTS.BDSMCheck()
	HnS_BUTTS.TITSCheck()
	HnS_BUTTS.DAMESCheck()
	HnS_BUTTS.LeveledListsCheck()
	BABESTrigger = true
	BOOBSTrigger = true
	BDSMTrigger = true
	TITSTrigger = true
	DAMESTrigger = true
	MCMRacesChanged = 2
	return warningCounter
endFunction

bool function Blindable(Form akTargetRace)
	return !FormListHas(none, "HnS_EnviroBlindnessImmuneRaces", akTargetRace)
endFunction

bool function HasExtraRods(Form akTargetRace)
	return FormListHas(none, "HnS_NightVisionRaces", akTargetRace)
endFunction

bool function HasNostrils(Form akTargetRace)
	return !FormListHas(none, "HnS_NoSmellRaces", akTargetRace) && (!(akTargetRace.HasKeyWord(ActorTypeUndead) || akTargetRace.HasKeyWord(ActorTypeDwarven)) || FormListHas(none, "HnS_SmellyUnLivingRaces", akTargetRace))
endFunction

bool function HasPitOrgans(Form akTargetRace)
	return FormListHas(none, "HnS_ThermalVisionRaces", akTargetRace) || ((akTargetRace.HasKeyWord(ActorTypeUndead) || akTargetRace.HasKeyWord(Vampire)) && !FormListHas(none, "HnS_NoThermalVisionUndeadRaces", akTargetRace))
endFunction

bool function HasAmpullaeOfLorenzini(Form akTargetRace)
	return FormListHas(none, "HnS_MagickaDetectionRaces", akTargetRace) || (akTargetRace.HasKeyWord(ActorTypeDwarven) && !FormListHas(none, "HnS_NoMagickaDetectionDwarvenRaces", akTargetRace))
endFunction

int function OlfactoryReceptorNeuronDensity(Form akTargetRace)
	if FormListHas(none, "HnS_SmellTier4Races", akTargetRace)
		return 5
	elseIf FormListHas(none, "HnS_SmellTier3Races", akTargetRace)
		return 4
	elseIf FormListHas(none, "HnS_SmellTier2Races", akTargetRace)
		return 3
	elseIf FormListHas(none, "HnS_SmellTier1Races", akTargetRace)
		return 2
	elseIf FormListHas(none, "HnS_SmellNPCExceptionRaces", akTargetRace) || !(akTargetRace.HasKeyWord(ActorTypeNPC) || FormListHas(none, "HnS_SmellTierNPCRaces", akTargetRace))
		return 1
	else
		return 0
	endIf
endFunction

