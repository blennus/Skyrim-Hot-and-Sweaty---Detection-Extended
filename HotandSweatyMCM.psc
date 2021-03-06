scriptname HotandSweatyMCM extends SKI_ConfigBase

import Game
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
Keyword property HnS_LocTypeDefault auto ;Ignore Time && Weather. Darkest locations are pitch black. Default Interior.
Keyword property HnS_LocTypeWilderness auto ;Normal Location with variable lighting and weather that follows the phases of the day. Mostly exteriors.
string[] property CycleFloatVariableNames auto

;Vanilla Properties
Actor property PlayerRef auto
WorldSpace property Tamriel auto
;Race[] property RacesToNotAdd auto
Keyword property Vampire auto
Keyword property ActorTypeUndead auto
Keyword property ActorTypeDwarven auto
Keyword property ActorTypeNPC auto

;MCM Menu Local Variables
Race CurrentRace
Form CurrentCycleKey
Form CurrentArea
string[] RacialMenuList
string[] AreaTypeMenuList
string[] SmellTierArray
string[] CycleTypesArray
string[] AreaFormTypesArray
string[] CurrentAreaTypeArray
string[] CellsList
string[] LocationsList
string[] WorldsList
string VariableNamePostfix
string CustomKeyDisplayName
string HnSPresetFileName
bool BABESTrigger
bool BOOBSTrigger
bool BDSMTrigger
bool TITSTrigger
bool DAMESTrigger
int MCMRacesChanged
int CurrentlyModifiedAreaTypeIndex
int ValidKeyWordListLength
int CustomAreaListLength
int ProcessedCellsListLength
int ProcessedLocationsListLength
int ProcessedWorldsListLength
int ExteriorLocationsListLength
int AreaFormTypeIndex
int CurrentlyModifiedAreaIndex
int CurrentlyModifiedRaceIndex
int ProcessedRacesListLength
;bool CurrentlyProcessing

event OnConfigInit()
	; pages
	;Pages = new string[8]
	;Pages[0] = "$HnS_Basic_Settings_Page"
	;Pages[1] = "$HnS_Game_Settings_Page"
	;Pages[2] = "$HnS_Area_Settings_Page"
	;Pages[3] = "$HnS_Weather_n_Misc_Page"
	;Pages[4] = "$HnS_Smell_Sense_Page"
	;Pages[5] = "$HnS_Racial_Configuration"
	;Pages[6] = "$HnS_Manage_Presets"
	;Pages[7] = "$HnS_Current_Stealth_Stats_Page"
	
	SmellTierArray = new string[6]
	SmellTierArray[0] = "$NPC Tier"
	SmellTierArray[1] = "$Tier 0"
	SmellTierArray[2] = "$Tier 1"
	SmellTierArray[3] = "$Tier 2"
	SmellTierArray[4] = "$Tier 3"
	SmellTierArray[5] = "$Tier 4"
	
	CycleTypesArray = new string[4]
	CycleTypesArray[0] = "$Full_Static_Area"
	CycleTypesArray[1] = "$Part_Static_Area"
	CycleTypesArray[2] = "$Part_Dynamc_Area"
	CycleTypesArray[3] = "$Full_Dynamc_Area"
	
	AreaFormTypesArray = new string[3]
	AreaFormTypesArray[0] = "$Hns_Cells"
	AreaFormTypesArray[1] = "$Hns_Locations"
	AreaFormTypesArray[2] = "$Hns_Worldspaces"
	
	HnSPresetFileName = "Default"
	
	CurrentlyModifiedAreaTypeIndex = 0
	AreaFormTypeIndex = -1
	CurrentlyModifiedAreaIndex = -1
	CurrentArea = none
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
		int RaceArrayInitCounter = 0
		while RaceArrayInitCounter < ProcessedRacesListLength
			RacialMenuList[RaceArrayInitCounter] = "$" + GetRaceEditorID(FormListGet(none, "HnS_ProcessedRaces", RaceArrayInitCounter) as Race)
			RaceArrayInitCounter +=1
		endWhile
		RacialMenuList[RaceArrayInitCounter] = "$None"
	endIf
	
	ValidKeyWordListLength = FormListCount(none, "HnS_ValidKeyWordList")
	CustomAreaListLength = FormListCount(none, "HnS_CustomAreaList")
	AreaTypeMenuList = Utility.CreateStringArray(ValidKeyWordListLength + CustomAreaListLength)
	int AreaTypeArrayInitCounter = 0
	while AreaTypeArrayInitCounter < ValidKeyWordListLength
		AreaTypeMenuList[AreaTypeArrayInitCounter] = "$" + (FormListGet(none, "HnS_ValidKeyWordList", AreaTypeArrayInitCounter) as Keyword).GetString()
		AreaTypeArrayInitCounter +=1
	endWhile
	while AreaTypeArrayInitCounter < AreaTypeMenuList.Length
		Form InitCycleKey = FormListGet(none, "HnS_CustomAreaList", AreaTypeArrayInitCounter - ValidKeyWordListLength)
		AreaTypeMenuList[AreaTypeArrayInitCounter] = GetStringValue(InitCycleKey, "HnS_CustomAreaDisplayName")
		AreaTypeArrayInitCounter +=1
	endWhile
	
	ProcessedCellsListLength = FormListCount(none, "HnS_ProcessedCells")
	ProcessedLocationsListLength = FormListCount(none, "HnS_ProcessedLocations")
	ProcessedWorldsListLength = FormListCount(none, "HnS_ProcessedWorlds")
	ExteriorLocationsListLength = FormListCount(none, "HnS_ExteriorLocations")
	
	int AreaListArrayInitCounter
	
	if ProcessedCellsListLength > 0
		if AreaFormTypeIndex == -1
			AreaFormTypeIndex = 0
			CurrentlyModifiedAreaIndex = ProcessedCellsListLength - 1
			CurrentArea = FormListGet(none, "HnS_ProcessedCells", ProcessedCellsListLength - 1)
		endIf
		CellsList = Utility.CreateStringArray(ProcessedCellsListLength)
		AreaListArrayInitCounter = 0
		while AreaListArrayInitCounter < ProcessedCellsListLength
			CellsList[AreaListArrayInitCounter] = "$Cell{" + FormListGet(none, "HnS_ProcessedCells", AreaListArrayInitCounter).GetName() + "}"
			AreaListArrayInitCounter +=1
		endWhile
	endIf
	
	if ExteriorLocationsListLength > 0
		if AreaFormTypeIndex == -1
			AreaFormTypeIndex = 1
			CurrentlyModifiedAreaIndex = ExteriorLocationsListLength - 1
			CurrentArea = FormListGet(none, "HnS_ExteriorLocations", ExteriorLocationsListLength - 1)
		endIf
		LocationsList = Utility.CreateStringArray(ExteriorLocationsListLength)
		AreaListArrayInitCounter = 0
		while AreaListArrayInitCounter < ExteriorLocationsListLength
			string InitiatedLocationFormName = FormListGet(none, "HnS_ExteriorLocations", AreaListArrayInitCounter).GetName()
			if !InitiatedLocationFormName
				InitiatedLocationFormName = "Unnamed"
			endIf
			LocationsList[AreaListArrayInitCounter] = "$Location{" + InitiatedLocationFormName + "}"
			AreaListArrayInitCounter +=1
		endWhile
	endIf
	
	if ProcessedWorldsListLength > 0
		if AreaFormTypeIndex == -1
			AreaFormTypeIndex = 2
			CurrentlyModifiedAreaIndex = ProcessedWorldsListLength - 1
			CurrentArea = FormListGet(none, "HnS_ProcessedWorlds", ProcessedWorldsListLength - 1)
		endIf
		WorldsList = Utility.CreateStringArray(ProcessedWorldsListLength)
		AreaListArrayInitCounter = 0
		while AreaListArrayInitCounter < ProcessedWorldsListLength
			WorldsList[AreaListArrayInitCounter] = "$World{" + FormListGet(none, "HnS_ProcessedWorlds", AreaListArrayInitCounter).GetName() + "}"
			AreaListArrayInitCounter +=1
		endWhile
	endIf
	
	if CurrentlyModifiedAreaTypeIndex < ValidKeyWordListLength
		CurrentCycleKey = FormListGet(none, "HnS_ValidKeyWordList", CurrentlyModifiedAreaTypeIndex)
	else
		CurrentCycleKey = FormListGet(none, "HnS_CustomAreaList", CurrentlyModifiedAreaTypeIndex - ValidKeyWordListLength)
	endIf
	
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
	elseIf Page == "$HnS_Game_Settings_Page"
		displayGameStealthSettings()
	elseIf Page == "$HnS_Area_and_Race_Page"
		displayCustomizeAreaAndRace()
	elseIf Page == "$HnS_Weather_n_Misc_Page"
		displayEnvironmentSettings()
	elseIf Page == "$HnS_Smell_Sense_Page"
		displaySmellSenses()
	elseIf Page == "$HnS_Manage_Presets"
		displayPresetConfiguration()
	elseIf Page == "$HnS_Current_Stealth_Stats_Page"
		displayCurrentStats()
	endIf
endEvent

;=============OnPageReset functions: Displays Options and Values======================

int function GetVersion()
	return 1 ; Original version
endFunction

function displayBasicSettings()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Enable_Mod")
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
	AddEmptyOption()
	
	if HnS_BUTTS.IsRunning()
		AddTextOptionST("HnSUninstaller" ,"$HnS_Uninstaller", "")
	else
		AddTextOptionST("HnSUninstaller" ,"$HnS_Uninstaller", "", OPTION_FLAG_DISABLED)
	endIf
	
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
		
	AddHeaderOption("$HnS_HotKeys")
	AddKeyMapOptionST("HnSLightLevelKeyCode", "$HnS_LightLevelKeyCode", GlobalVarsArray[43].GetValue() as int)
	;AddEmptyOption()
endFunction

function displayGameStealthSettings()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Stealth_Options")
	AddMenuOptionST("HnSSelectAreaTypeMenu", "$HnS_Area_Type_Choice", AreaTypeMenuList[CurrentlyModifiedAreaTypeIndex])
	
	string CurrentCycleTypeString = "$" + GetStringValue(CurrentCycleKey, "HnS_CycleType")
	AddMenuOptionST("HnSSelectCycleTypeMenu", "$HnS_Cycle_Type_Choice", CurrentCycleTypeString)
	
	int PhaseToggleOptionFlag = OPTION_FLAG_NONE
	int ActingPhaseOptionFlag = OPTION_FLAG_DISABLED
	string CurrentActingPhase = "$Not_Applicable"
	string PhaseToggleDisplayString
	int CurrentCycleTypeIndex = CycleTypesArray.Find(CurrentCycleTypeString)
	bool isDynamic = false
	if CurrentCycleTypeIndex >= 2
		if VariableNamePostfix
			PhaseToggleDisplayString = "$Day"
		else
			PhaseToggleDisplayString = "$Night"
		endIf
		isDynamic = true
	else
		PhaseToggleDisplayString = "$Not_Applicable"
		PhaseToggleOptionFlag = OPTION_FLAG_DISABLED
		if CurrentCycleTypeIndex == 1
			ActingPhaseOptionFlag = OPTION_FLAG_NONE
			int CurrentActingPhaseIndex = GetIntValue(CurrentCycleKey, "HnS_CurrentPhase")
			if CurrentActingPhaseIndex == 0
				CurrentActingPhase = "$Night"
			elseIf CurrentActingPhaseIndex == 1
				CurrentActingPhase = "$Day"
			else
				CurrentActingPhase = "$Twilight"
			endIf
		endIf
	endIf
	
	if isDynamic
		AddSliderOptionST("HnSNightPhaseStart", "$HnS_NightPhaseStart", GetFloatValue(CurrentCycleKey, "HnS_NightPhaseStart"), "{2}")
		AddSliderOptionST("HnSNightPhaseEnd", "$HnS_NightPhaseEnd", GetFloatValue(CurrentCycleKey, "HnS_NightPhaseEnd"), "{2}")
		AddSliderOptionST("HnSDayPhaseStart", "$HnS_DayPhaseStart", GetFloatValue(CurrentCycleKey, "HnS_DayPhaseStart"), "{2}")
		AddSliderOptionST("HnSDayPhaseEnd", "$HnS_DayPhaseEnd", GetFloatValue(CurrentCycleKey, "HnS_DayPhaseEnd"), "{2}")
	else
		AddSliderOptionST("HnSNightPhaseStart", "$HnS_NightPhaseStart", 21.0, "{2}", OPTION_FLAG_DISABLED)
		AddSliderOptionST("HnSNightPhaseEnd", "$HnS_NightPhaseEnd", 5.0, "{2}", OPTION_FLAG_DISABLED)
		AddSliderOptionST("HnSDayPhaseStart", "$HnS_DayPhaseStart", 9.0, "{2}", OPTION_FLAG_DISABLED)
		AddSliderOptionST("HnSDayPhaseEnd", "$HnS_DayPhaseEnd", 17.0, "{2}", OPTION_FLAG_DISABLED)
	endIf
	
	AddSliderOptionST("HnSBlindnessThreshold", "$HnS_BlindnessThreshold", GetFloatValue(CurrentCycleKey, "HnS_BlindnessThreshold" + VariableNamePostfix), "{0}")
	AddSliderOptionST("HnSBlindnessThresholdNE", "$HnS_BlindnessThresholdNE", GetFloatValue(CurrentCycleKey, "HnS_BlindnessThresholdNE" + VariableNamePostfix), "{0}")
	AddSliderOptionST("HnSLightBlindnessMod", "$HnS_LightBlindnessMod", GetFloatValue(CurrentCycleKey, "HnS_LightBlindnessMod" + VariableNamePostfix) * 100, "{0}%")
	AddSliderOptionST("HnSLightBlindnessModNE", "$HnS_LightBlindnessModNE", GetFloatValue(CurrentCycleKey, "HnS_LightBlindnessModNE" + VariableNamePostfix) * 100, "{0}%")
	AddSliderOptionST("HnSDetectionDistanceMod", "$HnS_DetectionDistanceMod", GetFloatValue(CurrentCycleKey, "HnS_DetectionDistance" + VariableNamePostfix), "{0}")
	
	SetCursorPosition(1)
	AddTextOptionST("HnSPhaseToggle" ,"$HnS_Phase_Toggle", PhaseToggleDisplayString, PhaseToggleOptionFlag)
	AddTextOptionST("HnSActingPhase" ,"$HnS_ActingPhase", CurrentActingPhase, ActingPhaseOptionFlag)

	AddSliderOptionST("HnSVisualGeneralMod", "$HnS_VisualGeneralMod", GetFloatValue(CurrentCycleKey, "HnS_Vision" + VariableNamePostfix) * 100.0, "{0}%")
	AddSliderOptionST("HnSVisualBrigthnessMod", "$HnS_VisualBrigthnessMod", GetFloatValue(CurrentCycleKey, "HnS_BrigthnessMod" + VariableNamePostfix), "{0}")
	AddSliderOptionST("HnSVisualMovementMod", "$HnS_VisualMovementMod", GetFloatValue(CurrentCycleKey, "HnS_VisualMovementMod" + VariableNamePostfix) * 100.0, "{0}%")
	AddSliderOptionST("HnSVisualRunningMod", "$HnS_VisualRunningMod", GetFloatValue(CurrentCycleKey, "HnS_VisualRunningMod" + VariableNamePostfix) * 100.0, "{0}%")
	AddSliderOptionST("HnSCurrentViewCone", "$HnS_CurrentViewCone", GetFloatValue(CurrentCycleKey, "HnS_ViewCone" + VariableNamePostfix), "{0}°")
	
	AddSliderOptionST("HnSSoundGeneralMod", "$HnS_SoundGeneralMod", GetFloatValue(CurrentCycleKey, "HnS_Hearing" + VariableNamePostfix) * 100.0, "{0}%")
	AddSliderOptionST("HnSSoundLoudnessMod", "$HnS_SoundLoudnessMod", GetFloatValue(CurrentCycleKey, "HnS_LoudnessMod" + VariableNamePostfix), "{0}")
	AddSliderOptionST("HnSSoundMovementMod", "$HnS_SoundMovementMod", GetFloatValue(CurrentCycleKey, "HnS_AuditoryMovementMod" + VariableNamePostfix), "{2}")
	AddSliderOptionST("HnSSoundRunningMod", "$HnS_SoundRunningMod", GetFloatValue(CurrentCycleKey, "HnS_AuditoryRunningMod" + VariableNamePostfix), "{2}")
	AddSliderOptionST("HnSSoundReverbMod", "$HnS_SoundReverbMod",  GetFloatValue(CurrentCycleKey, "HnS_Reverb") * 100.0, "{0}%")
	
endFunction

function displayCustomizeAreaAndRace()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Racial_Options")
	;int ProcessedRacesListLength = FormListCount(none, "HnS_ProcessedRaces")
	if ProcessedRacesListLength > 0
		;AddTextOptionST("HnSTextPlaceholder" ,"", "$HnS_Select_Race", OPTION_FLAG_DISABLED)
		AddMenuOptionST("HnSSelectRaceMenu", "$HnS_Actor_Race_Choice", RacialMenuList[CurrentlyModifiedRaceIndex])
		AddEmptyOption()
		if CurrentlyModifiedRaceIndex < ProcessedRacesListLength && CurrentlyModifiedRaceIndex >= 0
			
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
		AddTextOptionST("HnSRacialTextPlaceholder" ,"", "$HnS_No_Races_Encountered", OPTION_FLAG_DISABLED)
	endIf
	
	SetCursorPosition(1)
	
	AddHeaderOption("$HnS_Area_Options")
	if AreaFormTypeIndex != -1
		AddTextOptionST("HnSAreaDataType" ,"$HnS_Area_Data_Type", AreaFormTypesArray[AreaFormTypeIndex])
		if AreaFormTypeIndex == 0
			CurrentAreaTypeArray = CellsList
		elseIf AreaFormTypeIndex == 1
			CurrentAreaTypeArray = LocationsList
		else 
			CurrentAreaTypeArray = WorldsList
		endIf
		AddMenuOptionST("HnSSelectAreaMenu", "$HnS_Area_Choice", CurrentAreaTypeArray[CurrentlyModifiedAreaIndex])
		if CurrentArea == Tamriel
			AddMenuOptionST("HnSAreaCycleTypeMenu", "$HnS_Area_Cycle_Type", AreaTypeMenuList[GetCycleKeyIndex(GetConfirmedCycleKey(CurrentArea))], OPTION_FLAG_DISABLED)
		else
			AddMenuOptionST("HnSAreaCycleTypeMenu", "$HnS_Area_Cycle_Type", AreaTypeMenuList[GetCycleKeyIndex(GetConfirmedCycleKey(CurrentArea))])
		endIf
		AddEmptyOption()
		CustomKeyDisplayName = CurrentArea.GetName()
		if FormListHas(none, "HnS_CustomAreaList", CurrentArea)
			AddTextOptionST("HnsAddCustomArea" ,"$Hns_Add_Custom_Area_Type", "$HnS_AlreadyCustomized", OPTION_FLAG_DISABLED)
			AddInputOptionST("HnSKeyDisplayNameInput", "$HnS_KeyDisplayNameInput", GetStringValue(CurrentArea, "HnS_CustomAreaDisplayName"))
		elseIf CurrentArea == Tamriel
			AddTextOptionST("HnsAddCustomArea" ,"$Hns_Add_Custom_Area_Type", "$HnS_CannotBeCustomized", OPTION_FLAG_DISABLED)
			AddInputOptionST("HnSKeyDisplayNameInput", "$HnS_KeyDisplayNameInput", "$Not_Applicable", OPTION_FLAG_DISABLED)
		else
			AddTextOptionST("HnsAddCustomArea" ,"$Hns_Add_Custom_Area_Type", "$HnS_ReadyToAdd")
			AddInputOptionST("HnSKeyDisplayNameInput", "$HnS_KeyDisplayNameInput", CustomKeyDisplayName)
		endIf
	else
		AddTextOptionST("HnSAreaTextPlaceholder" ,"", "$HnS_No_Areas_Processed", OPTION_FLAG_DISABLED)
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
	
	AddSliderOptionST("HnSWeatherMildSnowHeaviness", "$HnS_WeatherMildSnowHeaviness", GlobalVarsArray[17].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSWeatherMildRainHeaviness", "$HnS_WeatherMildRainHeaviness", GlobalVarsArray[15].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSWeatherSevereSnowHeaviness", "$HnS_WeatherSevereSnowHeaviness", GlobalVarsArray[21].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSWeatherSevereRainHeaviness", "$HnS_WeatherSevereRainHeaviness", GlobalVarsArray[19].GetValue() * 100.0, "{0}%")
	AddEmptyOption()
	
	AddSliderOptionST("HnSPhaseChangeMaxSkillDecreasePercent", "$HnS_PhaseChangeMaxSkillDecreasePercent", GlobalVarsArray[22].GetValue() * 100.0, "{0}%")
	SetCursorPosition(1)
	
	AddHeaderOption("$HnS_Heat_Options")
	AddSliderOptionST("HnSplayerTemperatureDampenedAmount", "$HnS_PlayerTemperatureDampenedAmount", GlobalVarsArray[36].GetValue(), "{1}")
	AddSliderOptionST("HnSplayerNaturalHeatDampenedPercent", "$HnS_PlayerNaturalHeatDampenedPercent", GlobalVarsArray[37].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSheatThermalUnderwearPower", "$HnS_HeatThermalUnderwearPower", GlobalVarsArray[38].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSheatPotionPower", "$HnS_heatPotionPower", GlobalVarsArray[39].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSheatCloakofDarkessPower", "$HnS_heatCloakofDarkessPower", GlobalVarsArray[40].GetValue() * 100.0, "{0}%")
	AddEmptyOption()
	
	AddHeaderOption("$HnS_Magicka_Options")
	AddSliderOptionST("HnSmagickaIgnored", "$HnS_magickaIgnored", GlobalVarsArray[41].GetValue(), "{0}")
	AddSliderOptionST("HnSmagickaReductionPercent", "$HnS_magickaReductionPercent", 100.0 - GlobalVarsArray[42].GetValue() * 100.0, "{0}%")
	
endFunction

;function displayAuxiliarySenses()
;	SetCursorFillMode(TOP_TO_BOTTOM)
;	Merged this Page with Weather Page
;endFunction

function displaySmellSenses()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Smell_Options")
	AddSliderOptionST("HnSPlayerNaturalBO", "$HnS_PlayerNaturalBO", GlobalVarsArray[23].GetValue() * 100.0, "{0}%")
	if HnS_Conditions.MzinBathingInSkyrimLoaded
		AddSliderOptionST("HnSDirtinessPercentageModifier", "$HnS_DirtinessPercentageModifier", GlobalVarsArray[24].GetValue() * 100.0, "{0}%")
	else
		AddSliderOptionST("HnSDirtinessPercentageModifier", "$HnS_DirtinessPercentageModifier", 0, "{0}%", OPTION_FLAG_DISABLED)
	endIf
	AddSliderOptionST("HnSSmellDistanceModifier", "$HnS_SmellDistanceModifier", GlobalVarsArray[25].GetValue(), "{0}")
	AddEmptyOption()
	AddSliderOptionST("HnSSmellDeodorantPower", "$HnS_SmellDeodorantPower", GlobalVarsArray[26].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSSmellZeolitePower", "$HnS_SmellZeolitePower", GlobalVarsArray[27].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSSmellWindsPower", "$HnS_SmellWindsPower", GlobalVarsArray[28].GetValue() * 100.0, "{0}%")
	AddSliderOptionST("HnSSmellOtherCloak", "$HnS_SmellOtherCloak", GlobalVarsArray[29].GetValue() * 100.0, "{0}%")
	
	SetCursorPosition(1)
	AddHeaderOption("$HnS_Smell_Options_Continued")
	AddSliderOptionST("HnSNPCSmellSensitivityExponent", "$HnS_NPCSmellSensitivityExponent", (1.0 - GlobalVarsArray[30].GetValue()) * 100.0, "{0}%")
	AddSliderOptionST("HnSDefaultSmellSensitivityExponent", "$HnS_DefaultSmellSensitivityExponent", (1.0 - GlobalVarsArray[31].GetValue()) * 100.0, "{0}%")
	AddSliderOptionST("HnSTier1SmellSensitivityExponent", "$HnS_Tier1SmellSensitivityExponent", (1.0 - GlobalVarsArray[32].GetValue()) * 100.0, "{0}%")
	AddSliderOptionST("HnSTier2SmellSensitivityExponent", "$HnS_Tier2SmellSensitivityExponent", (1.0 - GlobalVarsArray[33].GetValue()) * 100.0, "{0}%")
	AddSliderOptionST("HnSTier3SmellSensitivityExponent", "$HnS_Tier3SmellSensitivityExponent", (1.0 - GlobalVarsArray[34].GetValue()) * 100.0, "{0}%")
	AddSliderOptionST("HnSTier4SmellSensitivityExponent", "$HnS_Tier4SmellSensitivityExponent", (1.0 - GlobalVarsArray[35].GetValue()) * 100.0, "{0}%")
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

function displayCurrentStats()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$HnS_Current_Status")
	Location CurrentLocation = PlayerRef.GetCurrentLocation()
	WorldSpace CurrentWorldSpace = PlayerRef.GetWorldspace()
	String CurrentCellName = PlayerRef.GetParentCell().GetName()
	if CurrentCellName
		AddTextOptionST("HnSTextPlaceholder" ,"$Hns_CurrentCell", CurrentCellName, OPTION_FLAG_DISABLED)
	else
		AddTextOptionST("HnSTextPlaceholder" ,"$Hns_CurrentCell", "$HnS_Unnamed_Cell", OPTION_FLAG_DISABLED)
	endIf
	if CurrentLocation
		AddTextOptionST("HnSTextPlaceholder0" ,"$Hns_CurrentLocation", CurrentLocation.GetName(), OPTION_FLAG_DISABLED)
	else
		AddTextOptionST("HnSTextPlaceholder0" ,"$Hns_CurrentLocation", "$HnS_Generic_Location", OPTION_FLAG_DISABLED)
	endIf
	if CurrentWorldSpace
		AddTextOptionST("HnSTextPlaceholder1" ,"$Hns_CurrentWorldspace", CurrentWorldSpace.GetName(), OPTION_FLAG_DISABLED)
	else
		AddTextOptionST("HnSTextPlaceholder1" ,"$Hns_CurrentWorldspace", "$HnS_Not_in_WorldSpace", OPTION_FLAG_DISABLED)
	endIf
	
	float PlayerCurrentLightLevel = PlayerRef.GetLightLevel()
	float WeatherBlindnessValue = (1.0 - GetFloatValue(none,"HnS_WeatherVisualMod", 1.0)) * 80.0
	AddSliderOptionST("HnSTextPlaceholder2", "$HnS_PlayerLightLevel", PlayerCurrentLightLevel, "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholder3", "$HnS_Heat_Vision_Blindness", WeatherBlindnessValue * 2.0, "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholder4", "$HnS_Dark_Blindness", ClampFloat((GetFloatValue(none, "HnS_CurrentBlindnessThreshold") - PlayerCurrentLightLevel)*GetFloatValue(none, "HnS_CurrentLightBlindnessMod"), 0.0, 96.0 - WeatherBlindnessValue * 0.75) + WeatherBlindnessValue  * 0.75, "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholder5", "$HnS_Dark_BlindnessNE", ClampFloat((GetFloatValue(none, "HnS_CurrentBlindnessThresholdNE") - PlayerCurrentLightLevel)*GetFloatValue(none, "HnS_CurrentLightBlindnessModNE"), 0.0, 100.0 - WeatherBlindnessValue * 1.5) + WeatherBlindnessValue * 1.5, "{2}", OPTION_FLAG_DISABLED)
	
	SetCursorPosition(1)
	
	AddSliderOptionST("HnSTextPlaceholderA", "fSneakLightMult", GetGameSettingFloat("fSneakLightMult"), "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholderB", "fDetectionSneakLightMod", GetGameSettingFloat("fDetectionSneakLightMod"), "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholderC", "fSneakLightMoveMult", GetGameSettingFloat("fSneakLightMoveMult"), "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholderD", "fSneakLightRunMult", GetGameSettingFloat("fSneakLightRunMult"), "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholderE", "fDetectionViewCone", GetGameSettingFloat("fDetectionViewCone"), "{0}°", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholderF", "fSneakSoundsMult", GetGameSettingFloat("fSneakSoundsMult"), "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholderG", "fSneakEquippedWeightBase", GetGameSettingFloat("fSneakEquippedWeightBase"), "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholderH", "fSneakEquippedWeightMult", GetGameSettingFloat("fSneakEquippedWeightMult"), "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholderI", "fSneakRunningMult", GetGameSettingFloat("fSneakRunningMult"), "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholderJ", "fSneakSoundLosMult", GetGameSettingFloat("fSneakSoundLosMult"), "{2}", OPTION_FLAG_DISABLED)
	AddSliderOptionST("HnSTextPlaceholderK", "fSneakMaxDistance", GetGameSettingFloat("fSneakMaxDistance"), "{2}", OPTION_FLAG_DISABLED)
	
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

state HnSLightLevelKeyCode
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		GlobalVarsArray[43].SetValue(newKeyCode)
		HnS_BOOBS.LightLevelKeyRegistration()
		SetKeyMapOptionValueST(newKeyCode)
	endEvent

	event OnDefaultST()
		GlobalVarsArray[43].SetValue(0x2F)
		HnS_BOOBS.LightLevelKeyRegistration()
		SetKeyMapOptionValueST(0x2F)
	endEvent

	event OnHighlightST()
		SetInfoText("$HnS_LightLevelKeyCode_Highlight")
	endEvent
endState

;=============$HnS_Game_Settings_Page functions: ======================

state HnSSelectAreaTypeMenu
	event OnMenuOpenST()
		SetMenuDialogStartIndex(CurrentlyModifiedAreaTypeIndex)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(AreaTypeMenuList)
	endEvent
	
	event OnMenuAcceptST(int index)
		if index != -1
			CurrentlyModifiedAreaTypeIndex = index
			if CurrentlyModifiedAreaTypeIndex < ValidKeyWordListLength
				CurrentCycleKey = FormListGet(none, "HnS_ValidKeyWordList", CurrentlyModifiedAreaTypeIndex)
			else
				CurrentCycleKey = FormListGet(none, "HnS_CustomAreaList", CurrentlyModifiedAreaTypeIndex - ValidKeyWordListLength)
			endIf
			
			string CurrentCycleTypeString = "$" + GetStringValue(CurrentCycleKey, "HnS_CycleType")
			SetMenuOptionValueST(CurrentCycleTypeString, true, "HnSSelectCycleTypeMenu")
			bool isDynamic = true
			int PhaseToggleOptionFlag
			int ActingPhaseOptionFlag = OPTION_FLAG_DISABLED
			string CurrentActingPhase = "$Not_Applicable"
			string PhaseToggleDisplayString
			int CurrentCycleTypeIndex = CycleTypesArray.Find(CurrentCycleTypeString)
			if CurrentCycleTypeIndex < 2
				isDynamic = false
				VariableNamePostfix = ""
				PhaseToggleDisplayString = "$Not_Applicable"
				PhaseToggleOptionFlag = OPTION_FLAG_DISABLED
				if CurrentCycleTypeIndex == 1
					ActingPhaseOptionFlag = OPTION_FLAG_NONE
					int CurrentActingPhaseIndex = GetIntValue(CurrentCycleKey, "HnS_CurrentPhase")
					if CurrentActingPhaseIndex == 0
						CurrentActingPhase = "$Night"
					elseIf CurrentActingPhaseIndex == 1
						CurrentActingPhase = "$Day"
					else
						CurrentActingPhase = "$Twilight"
					endIf
				endIf
			elseIf !VariableNamePostfix
				PhaseToggleOptionFlag = OPTION_FLAG_NONE
				PhaseToggleDisplayString = "$Night"
			endIf
			
			if PhaseToggleDisplayString
				SetOptionFlagsST(PhaseToggleOptionFlag, true, "HnSPhaseToggle")
				SetTextOptionValueST(PhaseToggleDisplayString, true, "HnSPhaseToggle")
			endIf
			SetOptionFlagsST(ActingPhaseOptionFlag, true, "HnSActingPhase")
			SetTextOptionValueST(CurrentActingPhase, true, "HnSActingPhase")
			UpdateLocationSliders()
			UpdatePhaseTimeSliders(isDynamic)
			SetMenuOptionValueST(AreaTypeMenuList[CurrentlyModifiedAreaTypeIndex])
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Area_Type_Choice_Highlight")
	endEvent
endState

state HnSSelectCycleTypeMenu
	event OnMenuOpenST()
		SetMenuDialogStartIndex(CycleTypesArray.Find("$" + GetStringValue(CurrentCycleKey, "HnS_CycleType")))
		;SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(CycleTypesArray)
	endEvent
	
	event OnMenuAcceptST(int index)
		if index != -1
			string CurrentCycleType = StringUtil.Substring(CycleTypesArray[index], 1)
			Debug.Trace("Set Cycle type to: " + CurrentCycleType)
			SetStringValue(CurrentCycleKey, "HnS_CycleType", CurrentCycleType)
			bool isDynamic = true
			int PhaseToggleOptionFlag = OPTION_FLAG_NONE
			int ActingPhaseOptionFlag = OPTION_FLAG_DISABLED
			string CurrentActingPhase = "$Not_Applicable"
			string PhaseToggleDisplayString
			if index < 2
				isDynamic = false
				if VariableNamePostfix
					VariableNamePostfix = ""
					UpdateLocationSliders()
				endIf
				PhaseToggleDisplayString = "$Not_Applicable"
				PhaseToggleOptionFlag = OPTION_FLAG_DISABLED
				if index == 1
					ActingPhaseOptionFlag = OPTION_FLAG_NONE
					int CurrentActingPhaseIndex = GetIntValue(CurrentCycleKey, "HnS_CurrentPhase")
					if CurrentActingPhaseIndex == 0
						CurrentActingPhase = "$Night"
					elseIf CurrentActingPhaseIndex == 1
						CurrentActingPhase = "$Day"
					else
						CurrentActingPhase = "$Twilight"
					endIf
				endIf
			elseIf !VariableNamePostfix
				PhaseToggleOptionFlag = OPTION_FLAG_NONE
				PhaseToggleDisplayString = "$Night"
			endIf
			
			UpdatePhaseTimeSliders(isDynamic)
			SetOptionFlagsST(PhaseToggleOptionFlag, true, "HnSPhaseToggle")
			SetTextOptionValueST(PhaseToggleDisplayString, true, "HnSPhaseToggle")
			SetOptionFlagsST(ActingPhaseOptionFlag, true, "HnSActingPhase")
			SetTextOptionValueST(CurrentActingPhase, true, "HnSActingPhase")
			SetMenuOptionValueST(CycleTypesArray[index])
			BABESTrigger = true
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SelectCycleTypeMenu_Highlight")
	endEvent
endState

state HnSPhaseToggle
	event OnSelectST()
		string PhaseToggleDisplayString
		if !VariableNamePostfix
			PhaseToggleDisplayString = "$Day"
			VariableNamePostfix = "_D"
		else
			PhaseToggleDisplayString = "$Night"
			VariableNamePostfix = ""
		endIf
		UpdateLocationSliders()
		SetTextOptionValueST(PhaseToggleDisplayString)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_PhaseToggle_Highlight")
	endEvent
endState

state HnSActingPhase
	event OnSelectST()
		string CurrentActingPhase
		int CurrentActingPhaseIndex = (GetIntValue(CurrentCycleKey, "HnS_CurrentPhase") + 2) % 3 - 1
		SetIntValue(CurrentCycleKey, "HnS_CurrentPhase", CurrentActingPhaseIndex)
		if CurrentActingPhaseIndex == 0
			CurrentActingPhase = "$Night"
		elseIf CurrentActingPhaseIndex == 1
			CurrentActingPhase = "$Day"
		else
			CurrentActingPhase = "$Twilight"
		endIf
		SetTextOptionValueST(CurrentActingPhase)
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_ActingPhase_Highlight")
	endEvent
endState

state HnSVisualGeneralMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 500.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_Vision" + VariableNamePostfix) * 100.0)
		SetSliderDialogInterval(1.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_Vision" + VariableNamePostfix, akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_VisualGeneralMod_Highlight")
	endEvent
endState

state HnSVisualBrigthnessMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 150.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_BrigthnessMod" + VariableNamePostfix))
		SetSliderDialogInterval(1.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_BrigthnessMod" + VariableNamePostfix, akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_VisualBrigthnessMod_Highlight")
	endEvent
endState

state HnSVisualMovementMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_VisualMovementMod" + VariableNamePostfix) * 100.0)
		SetSliderDialogInterval(1.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_VisualMovementMod" + VariableNamePostfix, akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_VisualMovementMod_Highlight")
	endEvent
endState

state HnSVisualRunningMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 200.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_VisualRunningMod" + VariableNamePostfix) * 100.0)
		SetSliderDialogInterval(1.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_VisualRunningMod" + VariableNamePostfix, akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_VisualRunningMod_Highlight")
	endEvent
endState

state HnSCurrentViewCone
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 270.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_ViewCone" + VariableNamePostfix))
		SetSliderDialogInterval(1.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_ViewCone" + VariableNamePostfix, akValue)
		SetSliderOptionValueST(akValue, "{0}°")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_CurrentViewCone_Highlight")
	endEvent
endState

state HnSSoundGeneralMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 500.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_Hearing" + VariableNamePostfix) * 100.0)
		SetSliderDialogInterval(1.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_Hearing" + VariableNamePostfix, akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SoundGeneralMod_Highlight")
	endEvent
endState

state HnSSoundLoudnessMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_LoudnessMod" + VariableNamePostfix))
		SetSliderDialogInterval(1.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_LoudnessMod" + VariableNamePostfix, akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SoundLoudnessMod_Highlight")
	endEvent
endState

state HnSSoundMovementMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_AuditoryMovementMod" + VariableNamePostfix))
		SetSliderDialogInterval(0.05)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_AuditoryMovementMod" + VariableNamePostfix, akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SoundMovementMod_Highlight")
	endEvent
endState

state HnSSoundRunningMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_AuditoryRunningMod" + VariableNamePostfix))
		SetSliderDialogInterval(0.05)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_AuditoryRunningMod" + VariableNamePostfix, akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SoundRunningMod_Highlight")
	endEvent
endState

state HnSSoundReverbMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 200.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_Reverb") * 100.0)
		SetSliderDialogInterval(1.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_Reverb", akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SoundReverbMod_Highlight")
	endEvent
endState

state HnSDetectionDistanceMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 5120.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_DetectionDistance" + VariableNamePostfix))
		SetSliderDialogInterval(10.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_DetectionDistance" + VariableNamePostfix, akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DetectionDistanceMod_Highlight")
	endEvent
endState

state HnSBlindnessThreshold
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 150.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_BlindnessThreshold" + VariableNamePostfix))
		SetSliderDialogInterval(1.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_BlindnessThreshold" + VariableNamePostfix, akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_BlindnessThreshold_Highlight")
	endEvent
endState

state HnSBlindnessThresholdNE
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 150.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_BlindnessThresholdNE" + VariableNamePostfix))
		SetSliderDialogInterval(1.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_BlindnessThresholdNE" + VariableNamePostfix, akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_BlindnessThresholdNE_Highlight")
	endEvent
endState

state HnSLightBlindnessMod
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 1000.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_LightBlindnessMod" + VariableNamePostfix) * 100.0)
		SetSliderDialogInterval(5.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_LightBlindnessMod" + VariableNamePostfix, akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_LightBlindnessMod_Highlight")
	endEvent
endState

state HnSLightBlindnessModNE
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 1000.0)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_LightBlindnessModNE" + VariableNamePostfix) * 100.0)
		SetSliderDialogInterval(5.0)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_LightBlindnessModNE" + VariableNamePostfix, akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_LightBlindnessModNE_Highlight")
	endEvent
endState

state HnSNightPhaseStart
	event OnSliderOpenST()
		SetSliderDialogRange(GetFloatValue(CurrentCycleKey, "HnS_DayPhaseEnd") + 0.05, 23.95)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_NightPhaseStart"))
		SetSliderDialogInterval(0.05)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_NightPhaseStart", akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_NightPhaseStart_Highlight")
	endEvent
endState

state HnSNightPhaseEnd
	event OnSliderOpenST()
		SetSliderDialogRange(0.05, GetFloatValue(CurrentCycleKey, "HnS_DayPhaseStart") - 0.05)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_NightPhaseEnd"))
		SetSliderDialogInterval(0.05)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_NightPhaseEnd", akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_NightPhaseEnd_Highlight")
	endEvent
endState

state HnSDayPhaseStart
	event OnSliderOpenST()
		SetSliderDialogRange(GetFloatValue(CurrentCycleKey, "HnS_NightPhaseEnd") + 0.05, 11.95)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_DayPhaseStart"))
		SetSliderDialogInterval(0.05)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_DayPhaseStart", akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DayPhaseStart_Highlight")
	endEvent
endState

state HnSDayPhaseEnd
	event OnSliderOpenST()
		SetSliderDialogRange(12.05, GetFloatValue(CurrentCycleKey, "HnS_NightPhaseStart") - 0.05)
		SetSliderDialogStartValue(GetFloatValue(CurrentCycleKey, "HnS_DayPhaseEnd"))
		SetSliderDialogInterval(0.05)
		;SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		SetFloatValue(CurrentCycleKey, "HnS_DayPhaseEnd", akValue)
		SetSliderOptionValueST(akValue, "{2}")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DayPhaseEnd_Highlight")
	endEvent
endState

function UpdateLocationSliders()
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_Vision" + VariableNamePostfix) * 100.0, "{0}%", true, "HnSVisualGeneralMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_BrigthnessMod" + VariableNamePostfix), "{0}", true, "HnSVisualBrigthnessMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_VisualMovementMod" + VariableNamePostfix) * 100.0, "{0}%", true, "HnSVisualMovementMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_VisualRunningMod" + VariableNamePostfix) * 100.0, "{0}%", true, "HnSVisualRunningMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_ViewCone" + VariableNamePostfix), "{0}°", true, "HnSCurrentViewCone")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_Hearing" + VariableNamePostfix) * 100.0, "{0}%", true, "HnSSoundGeneralMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_LoudnessMod" + VariableNamePostfix), "{0}", true, "HnSSoundLoudnessMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_AuditoryMovementMod" + VariableNamePostfix), "{2}", true, "HnSSoundMovementMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_AuditoryRunningMod" + VariableNamePostfix), "{2}", true, "HnSSoundRunningMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_Reverb") * 100.0, "{0}%", true, "HnSSoundReverbMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_DetectionDistance" + VariableNamePostfix), "{0}", true, "HnSDetectionDistanceMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_BlindnessThreshold" + VariableNamePostfix), "{0}", true, "HnSBlindnessThreshold")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_BlindnessThresholdNE" + VariableNamePostfix), "{0}", true, "HnSBlindnessThresholdNE")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_LightBlindnessMod" + VariableNamePostfix) * 100.0, "{0}%", true, "HnSLightBlindnessMod")
	SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_LightBlindnessModNE" + VariableNamePostfix) * 100.0, "{0}%", true, "HnSLightBlindnessModNE")
endFunction

function UpdatePhaseTimeSliders(bool abIsDynamic)
	if abIsDynamic
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSNightPhaseStart")
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSNightPhaseEnd")
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSDayPhaseStart")
		SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSDayPhaseEnd")
		SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_NightPhaseStart"), "{2}", true, "HnSNightPhaseStart")
		SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_NightPhaseEnd"), "{2}", true, "HnSNightPhaseEnd")
		SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_DayPhaseStart"), "{2}", true, "HnSDayPhaseStart")
		SetSliderOptionValueST(GetFloatValue(CurrentCycleKey, "HnS_DayPhaseEnd"), "{2}", true, "HnSDayPhaseEnd")
	else
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSNightPhaseStart")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSNightPhaseEnd")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSDayPhaseStart")
		SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSDayPhaseEnd")
		SetSliderOptionValueST(21.0, "{2}", true, "HnSNightPhaseStart")
		SetSliderOptionValueST(5.0, "{2}", true, "HnS_NightPhaseEnd")
		SetSliderOptionValueST(9.0, "{2}", true, "HnS_DayPhaseStart")
		SetSliderOptionValueST(17.0, "{2}", true, "HnS_DayPhaseEnd")
	endIf
endFunction

;=============$HnS_Area_Settings_Page functions: ======================

state HnSAreaDataType
	event OnSelectST()
		string[] EmptyStringArray
		CurrentAreaTypeArray = EmptyStringArray
		while CurrentAreaTypeArray.length == 0
			AreaFormTypeIndex += 1
			AreaFormTypeIndex %= 3
			if AreaFormTypeIndex == 0
				CurrentAreaTypeArray = CellsList
				CurrentlyModifiedAreaIndex = CellsList.length - 1
				CurrentArea = FormListGet(none, "HnS_ProcessedCells", CurrentlyModifiedAreaIndex)
			elseIf AreaFormTypeIndex == 1
				CurrentAreaTypeArray = LocationsList
				CurrentlyModifiedAreaIndex = LocationsList.length - 1
				CurrentArea = FormListGet(none, "HnS_ExteriorLocations", CurrentlyModifiedAreaIndex)
			else 
				CurrentAreaTypeArray = WorldsList
				CurrentlyModifiedAreaIndex = WorldsList.length - 1
				CurrentArea = FormListGet(none, "HnS_ProcessedWorlds", CurrentlyModifiedAreaIndex)
			endIf
		endWhile
		CustomKeyDisplayName = CurrentArea.GetName()
		SetMenuOptionValueST(CurrentAreaTypeArray[CurrentlyModifiedAreaIndex], true, "HnSSelectAreaMenu")
		SetMenuOptionValueST(AreaTypeMenuList[GetCycleKeyIndex(GetConfirmedCycleKey(CurrentArea))], true, "HnSAreaCycleTypeMenu")
		
		if CurrentArea == Tamriel
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSAreaCycleTypeMenu")
			SetTextOptionValueST("$Hns_CannotBeCustomized", true, "HnsAddCustomArea")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnsAddCustomArea")
			SetInputOptionValueST("$Not_Applicable", true, "HnSKeyDisplayNameInput")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSKeyDisplayNameInput")
		elseIf FormListHas(none, "HnS_CustomAreaList", CurrentArea)
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSAreaCycleTypeMenu")
			SetTextOptionValueST("$Hns_AlreadyCustomized", true, "HnsAddCustomArea")
			SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnsAddCustomArea")
			SetInputOptionValueST(GetStringValue(CurrentArea, "HnS_CustomAreaDisplayName"), true, "HnSKeyDisplayNameInput")
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSKeyDisplayNameInput")
		else
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSAreaCycleTypeMenu")
			SetTextOptionValueST("$HnS_ReadyToAdd", true, "HnsAddCustomArea")
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnsAddCustomArea")
			SetInputOptionValueST(CustomKeyDisplayName, true, "HnSKeyDisplayNameInput")
			SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSKeyDisplayNameInput")
		endIf
		SetTextOptionValueST(AreaFormTypesArray[AreaFormTypeIndex])
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Area_Data_Type_Highlight")
	endEvent
endState

state HnSSelectAreaMenu
	event OnMenuOpenST()
		SetMenuDialogStartIndex(CurrentlyModifiedAreaIndex)
		SetMenuDialogDefaultIndex(CurrentAreaTypeArray.length - 1)
		SetMenuDialogOptions(CurrentAreaTypeArray)
	endEvent
	
	event OnMenuAcceptST(int index)
		if index != -1
			CurrentlyModifiedAreaIndex = index
			if AreaFormTypeIndex == 0
				CurrentArea = FormListGet(none, "HnS_ProcessedCells", CurrentlyModifiedAreaIndex)
			elseIf AreaFormTypeIndex == 1
				CurrentArea = FormListGet(none, "HnS_ExteriorLocations", CurrentlyModifiedAreaIndex)
			else 
				CurrentArea = FormListGet(none, "HnS_ProcessedWorlds", CurrentlyModifiedAreaIndex)
			endIf
			CustomKeyDisplayName = CurrentArea.GetName()
			SetMenuOptionValueST(AreaTypeMenuList[GetCycleKeyIndex(GetConfirmedCycleKey(CurrentArea))], true, "HnSAreaCycleTypeMenu")
			if CurrentArea == Tamriel
				SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSAreaCycleTypeMenu")
				SetTextOptionValueST("$Hns_CannotBeCustomized", true, "HnsAddCustomArea")
				SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnsAddCustomArea")
				SetInputOptionValueST("$Not_Applicable", true, "HnSKeyDisplayNameInput")
				SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnSKeyDisplayNameInput")
			elseIf FormListHas(none, "HnS_CustomAreaList", CurrentArea)
				SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSAreaCycleTypeMenu")
				SetTextOptionValueST("$Hns_AlreadyCustomized", true, "HnsAddCustomArea")
				SetOptionFlagsST(OPTION_FLAG_DISABLED, true, "HnsAddCustomArea")
				SetInputOptionValueST(GetStringValue(CurrentArea, "HnS_CustomAreaDisplayName"), true, "HnSKeyDisplayNameInput")
				SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSKeyDisplayNameInput")
			else
				SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSAreaCycleTypeMenu")
				SetTextOptionValueST("$HnS_ReadyToAdd", true, "HnsAddCustomArea")
				SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnsAddCustomArea")
				SetInputOptionValueST(CustomKeyDisplayName, true, "HnSKeyDisplayNameInput")
				SetOptionFlagsST(OPTION_FLAG_NONE, true, "HnSKeyDisplayNameInput")
			endIf
			SetMenuOptionValueST(CurrentAreaTypeArray[CurrentlyModifiedAreaIndex])
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Area_Choice_Highlight")
	endEvent
endState

state HnSAreaCycleTypeMenu
	event OnMenuOpenST()
		SetMenuDialogStartIndex(GetCycleKeyIndex(GetFormValue(CurrentArea, "HnS_CycleKey")))
		;SetMenuDialogDefaultIndex()
		SetMenuDialogOptions(AreaTypeMenuList)
	endEvent
	
	event OnMenuAcceptST(int index)
		if index != -1
			Form SelectedCycleKey
			if index < ValidKeyWordListLength
				SelectedCycleKey = FormListGet(none, "HnS_ValidKeyWordList", index)
			else
				SelectedCycleKey = FormListGet(none, "HnS_CustomAreaList", index - ValidKeyWordListLength)
			endIf
			SetFormValue(CurrentArea, "HnS_CycleKey", SelectedCycleKey)
			SetMenuOptionValueST(AreaTypeMenuList[index])
			BABESTrigger = true
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Area_Cycle_Type_Highlight")
	endEvent
endState

state HnsAddCustomArea
	event OnSelectST()
		if ShowMessage("$Hns_CustomizeAreaQuery{" + CustomKeyDisplayName + "}")
			Form DefaultTemplate = GetFormValue(CurrentArea, "HnS_CycleKey")
			if !DefaultTemplate
				DefaultTemplate = HnS_LocTypeDefault
			endIf
			SetFormValue(CurrentArea, "HnS_CycleKey", CurrentArea)
			FormListAdd(none, "HnS_CustomAreaList", CurrentArea, false)

			SetStringValue(CurrentArea, "HnS_CustomAreaDisplayName", CustomKeyDisplayName)
			SetStringValue(CurrentArea, "HnS_CycleType", GetStringValue(DefaultTemplate, "HnS_CycleType"))
			SetIntValue(CurrentArea, "HnS_CurrentPhase", GetIntValue(DefaultTemplate, "HnS_CurrentPhase"))
			
			SetFloatValue(CurrentArea, "HnS_NightPhaseStart", GetFloatValue(DefaultTemplate, "HnS_NightPhaseStart"))
			SetFloatValue(CurrentArea, "HnS_NightPhaseEnd", GetFloatValue(DefaultTemplate, "HnS_NightPhaseEnd"))
			SetFloatValue(CurrentArea, "HnS_DayPhaseStart", GetFloatValue(DefaultTemplate, "HnS_DayPhaseStart"))
			SetFloatValue(CurrentArea, "HnS_DayPhaseEnd", GetFloatValue(DefaultTemplate, "HnS_DayPhaseEnd"))
			
			SetFloatValue(CurrentArea, "HnS_Vision", GetFloatValue(DefaultTemplate, "HnS_Vision"))
			SetFloatValue(CurrentArea, "HnS_BrigthnessMod", GetFloatValue(DefaultTemplate, "HnS_BrigthnessMod"))
			SetFloatValue(CurrentArea, "HnS_VisualMovementMod", GetFloatValue(DefaultTemplate, "HnS_VisualMovementMod"))
			SetFloatValue(CurrentArea, "HnS_VisualRunningMod", GetFloatValue(DefaultTemplate, "HnS_VisualRunningMod"))
			SetFloatValue(CurrentArea, "HnS_ViewCone", GetFloatValue(DefaultTemplate, "HnS_ViewCone"))
			SetFloatValue(CurrentArea, "HnS_Hearing", GetFloatValue(DefaultTemplate, "HnS_Hearing"))
			SetFloatValue(CurrentArea, "HnS_LoudnessMod", GetFloatValue(DefaultTemplate, "HnS_LoudnessMod"))
			SetFloatValue(CurrentArea, "HnS_AuditoryMovementMod", GetFloatValue(DefaultTemplate, "HnS_AuditoryMovementMod"))
			SetFloatValue(CurrentArea, "HnS_AuditoryRunningMod", GetFloatValue(DefaultTemplate, "HnS_AuditoryRunningMod"))
			SetFloatValue(CurrentArea, "HnS_Reverb", GetFloatValue(DefaultTemplate, "HnS_Reverb"))
			SetFloatValue(CurrentArea, "HnS_DetectionDistance", GetFloatValue(DefaultTemplate, "HnS_DetectionDistance"))
			SetFloatValue(CurrentArea, "HnS_BlindnessThreshold", GetFloatValue(DefaultTemplate, "HnS_BlindnessThreshold"))
			SetFloatValue(CurrentArea, "HnS_BlindnessThresholdNE", GetFloatValue(DefaultTemplate, "HnS_BlindnessThresholdNE"))
			SetFloatValue(CurrentArea, "HnS_LightBlindnessMod", GetFloatValue(DefaultTemplate, "HnS_LightBlindnessMod"))
			SetFloatValue(CurrentArea, "HnS_LightBlindnessModNE", GetFloatValue(DefaultTemplate, "HnS_LightBlindnessModNE"))
			
			SetFloatValue(CurrentArea, "HnS_Vision_D", GetFloatValue(DefaultTemplate, "HnS_Vision_D"))
			SetFloatValue(CurrentArea, "HnS_BrigthnessMod_D", GetFloatValue(DefaultTemplate, "HnS_BrigthnessMod_D"))
			SetFloatValue(CurrentArea, "HnS_VisualMovementMod_D", GetFloatValue(DefaultTemplate, "HnS_VisualMovementMod_D"))
			SetFloatValue(CurrentArea, "HnS_VisualRunningMod_D", GetFloatValue(DefaultTemplate, "HnS_VisualRunningMod_D"))
			SetFloatValue(CurrentArea, "HnS_ViewCone_D", GetFloatValue(DefaultTemplate, "HnS_ViewCone_D"))
			SetFloatValue(CurrentArea, "HnS_Hearing_D", GetFloatValue(DefaultTemplate, "HnS_Hearing_D"))
			SetFloatValue(CurrentArea, "HnS_LoudnessMod_D", GetFloatValue(DefaultTemplate, "HnS_LoudnessMod_D"))
			SetFloatValue(CurrentArea, "HnS_AuditoryMovementMod_D", GetFloatValue(DefaultTemplate, "HnS_AuditoryMovementMod_D"))
			SetFloatValue(CurrentArea, "HnS_AuditoryRunningMod_D", GetFloatValue(DefaultTemplate, "HnS_AuditoryRunningMod_D"))
			SetFloatValue(CurrentArea, "HnS_DetectionDistance_D", GetFloatValue(DefaultTemplate, "HnS_DetectionDistance_D"))
			SetFloatValue(CurrentArea, "HnS_BlindnessThreshold_D", GetFloatValue(DefaultTemplate, "HnS_BlindnessThreshold_D"))
			SetFloatValue(CurrentArea, "HnS_BlindnessThresholdNE_D", GetFloatValue(DefaultTemplate, "HnS_BlindnessThresholdNE_D"))
			SetFloatValue(CurrentArea, "HnS_LightBlindnessMod_D", GetFloatValue(DefaultTemplate, "HnS_LightBlindnessMod_D"))
			SetFloatValue(CurrentArea, "HnS_LightBlindnessModNE_D", GetFloatValue(DefaultTemplate, "HnS_LightBlindnessModNE_D"))
			
			AreaTypeMenuList = PushString(AreaTypeMenuList, CustomKeyDisplayName)
			CustomAreaListLength += 1
			SetMenuOptionValueST(AreaTypeMenuList[AreaTypeMenuList.length - 1], true, "HnSAreaCycleTypeMenu")
			SetTextOptionValueST("$Hns_AlreadyCustomized")
			SetOptionFlagsST(OPTION_FLAG_DISABLED)
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$Hns_Add_Custom_Area_Type_Highlight")
	endEvent
endState

state HnSKeyDisplayNameInput
	event OnInputOpenST()
		SetInputDialogStartText(CustomKeyDisplayName)
	endEvent
	
	event OnInputAcceptST(string inputedString)
		if inputedString
			if FormListHas(none, "HnS_CustomAreaList", CurrentArea)
				if ShowMessage("$Hns_RenameAreaTypeQuery{" + GetStringValue(CurrentArea, "HnS_CustomAreaDisplayName") + "}{" + inputedString + "}")
					AreaTypeMenuList[FormListFind(none, "HnS_CustomAreaList", CurrentArea)] = inputedString
					SetStringValue(CurrentArea, "HnS_CustomAreaDisplayName", inputedString)
					SetInputOptionValueST(inputedString)
				endIf
			else
				CustomKeyDisplayName = inputedString
				SetInputOptionValueST(inputedString)
			endIf
		endIf
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_KeyDisplayNameInput_Highlight")
	endEvent
endState

Form function GetConfirmedCycleKey(Form akSelectedArea)
	Form SelectedCycleKey = GetFormValue(akSelectedArea, "HnS_CycleKey")
	if SelectedCycleKey
		return SelectedCycleKey
	else
		SetFormValue(akSelectedArea, "HnS_CycleKey", HnS_LocTypeDefault)
		return HnS_LocTypeDefault
	endIf
endFunction

int function GetCycleKeyIndex(Form akCycleKey)
	if akCycleKey as Keyword
		return FormListFind(none, "HnS_ValidKeyWordList", akCycleKey)
	else
		return FormListFind(none, "HnS_CustomAreaList", akCycleKey) + ValidKeyWordListLength
	endIf
endFunction

;=============$HnS_Racial_Configuration functions: ======================

state HnSSelectRaceMenu

	event OnMenuOpenST()
		;int ProcessedRacesListLength = FormListCount(none, "HnS_ProcessedRaces")
		SetMenuDialogStartIndex(CurrentlyModifiedRaceIndex)
		SetMenuDialogDefaultIndex(ProcessedRacesListLength)
		SetMenuDialogOptions(RacialMenuList)
	endEvent
	
	event OnMenuAcceptST(int index)
		if index >= 0
			CurrentlyModifiedRaceIndex = index
			if CurrentlyModifiedRaceIndex < ProcessedRacesListLength 
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
				;SetTextOptionValueST("$HnS_Select_Race", true, "HnSTextPlaceholder")
				DisableRacialToggleOptions()
				SetToggleOptionValueST(false, true, "HnSIgnoreRace")
				SetOptionFlagsST(OPTION_FLAG_DISABLED, "HnSIgnoreRace")
			endIf
			;SetOptionFlagsST(OPTION_FLAG_DISABLED, true) No longer necessary.
			SetOptionFlagsST(OPTION_FLAG_NONE, true)
			SetMenuOptionValueST(RacialMenuList[CurrentlyModifiedRaceIndex])
		else
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

;------------Racial Ability Functions ------------

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

;=============$HnS_Weather_n_Misc_Page functions: ======================
;------------Weather Functions------------

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

state HnSPhaseChangeMaxSkillDecreasePercent
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[22].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(50.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[22].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[22].SetValue(0.5)
		SetSliderOptionValueST(50.0, "{0}%")
		BABESTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_PhaseChangeMaxSkillDecreasePercent_Highlight")
	endEvent
endState

;------------Auxiliary Senses Functions------------

state HnSplayerNaturalHeatDampenedPercent
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 200.0)
		SetSliderDialogStartValue(GlobalVarsArray[37].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(167.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[37].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[37].SetValue(1.67)
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
		SetSliderDialogStartValue(GlobalVarsArray[36].GetValue())
		SetSliderDialogInterval(0.1)
		SetSliderDialogDefaultValue(8.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[36].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{1}")
		TITSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[36].SetValue(8.0)
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
		SetSliderDialogStartValue(GlobalVarsArray[38].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(22.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[38].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[38].SetValue(0.22)
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
		SetSliderDialogStartValue(GlobalVarsArray[39].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(33.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[39].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[39].SetValue(0.33)
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
		SetSliderDialogStartValue(GlobalVarsArray[40].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(45.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[40].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		TITSTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[40].SetValue(0.45)
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
		SetSliderDialogStartValue(GlobalVarsArray[41].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[41].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		DAMESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[41].SetValue(100.0)
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
		SetSliderDialogStartValue(100 - GlobalVarsArray[42].GetValue() * 100.0)
		SetSliderDialogInterval(0.5)
		SetSliderDialogDefaultValue(80.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[42].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		DAMESTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[42].SetValue(0.2)
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
		SetSliderDialogStartValue(GlobalVarsArray[23].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[23].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[23].SetValue(1.0)
		SetSliderOptionValueST(100.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_PlayerNaturalBO_Highlight")
	endEvent
endState

state HnSSmellDistanceModifier
	event OnSliderOpenST()
		SetSliderDialogRange(1024.0,8192.0)
		SetSliderDialogStartValue(GlobalVarsArray[25].GetValue())
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(4096.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[25].SetValue(akValue)
		SetSliderOptionValueST(akValue, "{0}")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[25].SetValue(4096.0)
		SetSliderOptionValueST(4096.0, "{0}")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SmellDistanceModifier_Highlight")
	endEvent
endState

state HnSDirtinessPercentageModifier
	event OnSliderOpenST()
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogStartValue(GlobalVarsArray[24].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[24].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[24].SetValue(1.0)
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
		SetSliderDialogStartValue(GlobalVarsArray[26].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(20.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[26].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[26].SetValue(0.2)
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
		SetSliderDialogStartValue(GlobalVarsArray[27].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(30.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[27].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[27].SetValue(0.3)
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
		SetSliderDialogStartValue(GlobalVarsArray[28].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(50.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[28].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[28].SetValue(0.5)
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
		SetSliderDialogStartValue(GlobalVarsArray[29].GetValue() * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(25.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[29].SetValue(akValue / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[29].SetValue(0.25)
		SetSliderOptionValueST(25.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_SmellOtherCloak_Highlight")
	endEvent
endState

state HnSTier4SmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange((1 - GlobalVarsArray[34].GetValue()) * 100.0, 200.0)
		SetSliderDialogStartValue((1 - GlobalVarsArray[35].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(100.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[35].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[35].SetValue(0.0)
		SetSliderOptionValueST(100.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Tier4SmellSensitivityExponent_Highlight")
	endEvent
endState

state HnSTier3SmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange((1.0 - GlobalVarsArray[33].GetValue()) * 100.0,(1 - GlobalVarsArray[35].GetValue()) * 100.0)
		SetSliderDialogStartValue((1.0 - GlobalVarsArray[34].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(90.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[34].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[34].SetValue(0.1)
		SetSliderOptionValueST(90.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Tier3SmellSensitivityExponent_Highlight")
	endEvent
endState

state HnSTier2SmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange((1.0 - GlobalVarsArray[32].GetValue()) * 100.0,(1.0 - GlobalVarsArray[34].GetValue()) * 100.0)
		SetSliderDialogStartValue((1.0 - GlobalVarsArray[33].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(80.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[33].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[33].SetValue(0.2)
		SetSliderOptionValueST(80.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Tier2SmellSensitivityExponent_Highlight")
	endEvent
endState

state HnSTier1SmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange((1.0 - GlobalVarsArray[31].GetValue()) * 100.0,(1.0 - GlobalVarsArray[33].GetValue()) * 100.0)
		SetSliderDialogStartValue((1.0 - GlobalVarsArray[32].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(70.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[32].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[32].SetValue(0.3)
		SetSliderOptionValueST(70.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_Tier1SmellSensitivityExponent_Highlight")
	endEvent
endState

state HnSDefaultSmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange((1.0 - GlobalVarsArray[30].GetValue()) * 100.0,(1.0 - GlobalVarsArray[32].GetValue()) * 100.0)
		SetSliderDialogStartValue((1.0 - GlobalVarsArray[31].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(60.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[31].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[31].SetValue(0.4)
		SetSliderOptionValueST(60.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_DefaultSmellSensitivityExponent_Highlight")
	endEvent
endState

state HnSNPCSmellSensitivityExponent
	event OnSliderOpenST()
		SetSliderDialogRange(-100.0, (1.0 - GlobalVarsArray[31].GetValue()) * 100.0)
		SetSliderDialogStartValue((1.0 - GlobalVarsArray[30].GetValue()) * 100.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(-90.0)
	endEvent
	
	event OnSliderAcceptST(float akValue)
		GlobalVarsArray[30].SetValue((100.0 - akValue) / 100.0)
		SetSliderOptionValueST(akValue, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnDefaultST()
		GlobalVarsArray[30].SetValue(1.9)
		SetSliderOptionValueST(-90.0, "{0}%")
		BDSMTrigger = true
	endEvent
	
	event OnHighlightST()
		SetInfoText("$HnS_NPCSmellSensitivityExponent_Highlight")
	endEvent
endState

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
				Utility.WaitMenuMode(0.25)
				Game.DisablePlayerControls(false, false, false, false, false, true, false, false)
				Utility.WaitMenuMode(0.25)
				Game.EnablePlayerControls(false, false, false, false, false, true, false, false)
			elseIf LoadWarningCount > 0
				ShowMessage("$HnS_LoadPartiallySuccessful", false)
				SetTextOptionValueST(LoadWarningCount + " Warnings")
				Utility.WaitMenuMode(0.25)
				Game.DisablePlayerControls(false, false, false, false, false, true, false, false)
				Utility.WaitMenuMode(0.25)
				Game.EnablePlayerControls(false, false, false, false, false, true, false, false)
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

int function SaveCurrentPreset()
	string SaveFileName = "../HnS/" + HnSPresetFileName
	
	;============================================================================
	;Saving GlobalVariable Array by converting it to an array of floats.
	;============================================================================
	
	int ListCounter = 0
	float[] GlobalSaveFloatArray = Utility.CreateFloatArray(GlobalVarsArray.length)
	while ListCounter < GlobalVarsArray.length
		GlobalSaveFloatArray[ListCounter] = GlobalVarsArray[ListCounter].GetValue()
		ListCounter +=1
	endWhile
	int warningCounter = 0
	if !JsonUtil.FloatListCopy(SaveFileName, "GlobalVariablesList", GlobalSaveFloatArray)
		Debug.Trace("Unable to Save Global Variables List.")
		warningCounter += 1
	endIf
	
	;============================================================================
	;Saving Cycle Key Data by consolidating each Key's collection of float data into an array.
	;============================================================================
	
	if !JsonUtil.FormListCopy(SaveFileName, "HnS_ValidKeyWordList", FormListToArray(none, "HnS_ValidKeyWordList"))
		Debug.Trace("Unable to Save KeyWord List.")
		warningCounter += 1
	endIf
	
	int KeyWordListSaveWarningCounter
	int KeyWordInit
	while KeyWordInit < ValidKeyWordListLength
		Form SavedKeyword = FormListGet(none, "HnS_ValidKeyWordList", KeyWordInit)
		string SavedCycleTypeString = GetStringValue(SavedKeyword, "HnS_CycleType")
		KeyWordListSaveWarningCounter += 1 - (JsonUtil.SetStringValue(SaveFileName, "HnS_Keyword" + KeyWordInit + "_CycleType", SavedCycleTypeString) == SavedCycleTypeString && SavedCycleTypeString) as int
		int SavedPriority = GetIntValue(SavedKeyword, "HnS_KeyWordPriority")
		KeyWordListSaveWarningCounter += 1 - (JsonUtil.SetIntValue(SaveFileName, "HnS_Keyword" + KeyWordInit + "_Priority", SavedPriority) == SavedPriority) as int
		int SavedCurrentPhase = GetIntValue(SavedKeyword, "HnS_CurrentPhase")
		KeyWordListSaveWarningCounter += 1 - (JsonUtil.SetIntValue(SaveFileName, "HnS_Keyword" + KeyWordInit + "_CurrentPhase", SavedCurrentPhase) == SavedCurrentPhase) as int
		float[] SavedKeywordFloatArray = Utility.CreateFloatArray(CycleFloatVariableNames.length)
		int KeywordFloatCounter = 0
		while KeywordFloatCounter < SavedKeywordFloatArray.length
			SavedKeywordFloatArray[KeywordFloatCounter] = GetFloatValue(SavedKeyword, CycleFloatVariableNames[KeywordFloatCounter])
			KeywordFloatCounter +=1
		endWhile
		KeyWordListSaveWarningCounter += 1 - JsonUtil.FloatListCopy(SaveFileName, "HnS_Keyword" + KeyWordInit + "FloatArray", SavedKeywordFloatArray) as int
		KeyWordInit += 1
	endWhile
	if KeyWordListSaveWarningCounter > 0
		Debug.Trace("Unable to Save KeyWord Data.")
		warningCounter += KeyWordListSaveWarningCounter
	endIf
	
	;============================================================================
	;Saving Custom Area Data in the same way as above.
	;============================================================================
	
	if !JsonUtil.FormListCopy(SaveFileName, "HnS_CustomAreaList", FormListToArray(none, "HnS_CustomAreaList"))
		Debug.Trace("Unable to Save Custom Area List.")
		warningCounter += 1
	endIf
	
	int CustomAreaListSaveWarningCounter
	int CustomAreaInit
	while CustomAreaInit < CustomAreaListLength
		Form SavedCustomArea = FormListGet(none, "HnS_CustomAreaList", CustomAreaInit)
		string SavedCycleDisplayName = GetStringValue(SavedCustomArea, "HnS_CustomAreaDisplayName")
		CustomAreaListSaveWarningCounter += 1 - (JsonUtil.SetStringValue(SaveFileName, "HnS_Area" + CustomAreaInit + "_DisplayName", SavedCycleDisplayName) == SavedCycleDisplayName && SavedCycleDisplayName) as int
		string SavedCycleTypeString = GetStringValue(SavedCustomArea, "HnS_CycleType")
		CustomAreaListSaveWarningCounter += 1 - (JsonUtil.SetStringValue(SaveFileName, "HnS_Area" + CustomAreaInit + "_CycleType", SavedCycleTypeString) == SavedCycleTypeString && SavedCycleTypeString) as int
		int SavedCurrentPhase = GetIntValue(SavedCustomArea, "HnS_CurrentPhase")
		CustomAreaListSaveWarningCounter += 1 - (JsonUtil.SetIntValue(SaveFileName, "HnS_Area" + CustomAreaInit + "_CurrentPhase", SavedCurrentPhase) == SavedCurrentPhase) as int
		float[] SavedCustomAreaFloatArray = Utility.CreateFloatArray(CycleFloatVariableNames.length)
		int CustomAreaFloatCounter = 0
		while CustomAreaFloatCounter < SavedCustomAreaFloatArray.length
			SavedCustomAreaFloatArray[CustomAreaFloatCounter] = GetFloatValue(SavedCustomArea, CycleFloatVariableNames[CustomAreaFloatCounter])
			CustomAreaFloatCounter +=1
		endWhile
		CustomAreaListSaveWarningCounter += 1 - JsonUtil.FloatListCopy(SaveFileName, "HnS_Area" + CustomAreaInit + "FloatArray", SavedCustomAreaFloatArray) as int
		CustomAreaInit += 1
	endWhile
	if CustomAreaListSaveWarningCounter > 0
		Debug.Trace("Unable to Fully Save Custom Area Data.")
		warningCounter += CustomAreaListSaveWarningCounter
	endIf
	
	;============================================================================
	;Saving World List and Appropriate Keys.
	;============================================================================
	
	if !JsonUtil.FormListCopy(SaveFileName, "HnS_ProcessedWorlds", FormListToArray(none, "HnS_ProcessedWorlds"))
		Debug.Trace("Unable to Save World List.")
		warningCounter += 1
	endIf
	int WorldSaveWarningCounter
	int WorldInit
	while WorldInit < ProcessedWorldsListLength
		WorldSaveWarningCounter += 1 - (JsonUtil.SetFormValue(SaveFileName, "HnS_World" + WorldInit + "_CycleKey", GetFormValue(FormListGet(none, "HnS_ProcessedWorlds", WorldInit), "HnS_CycleKey")) as bool) as int
		WorldInit += 1
	endWhile
	if WorldSaveWarningCounter > 0
		Debug.Trace("Unable to Fully Save World Data.")
		warningCounter += WorldSaveWarningCounter
	endIf
	
	;============================================================================
	;Saving Location Lists and Appropriate Keys.
	;============================================================================
	
	if !JsonUtil.FormListCopy(SaveFileName, "HnS_ProcessedLocations", FormListToArray(none, "HnS_ProcessedLocations"))
		Debug.Trace("Unable to Save Location List.")
		warningCounter += 1
	endIf
	if !JsonUtil.FormListCopy(SaveFileName, "HnS_ExteriorLocations", FormListToArray(none, "HnS_ExteriorLocations"))
		Debug.Trace("Unable to Save Exterior Location List.")
		warningCounter += 1
	endIf
	int LocationSaveWarningCounter
	int LocationInit
	while LocationInit < ProcessedLocationsListLength
		LocationSaveWarningCounter += 1 - (JsonUtil.SetFormValue(SaveFileName, "HnS_Location" + LocationInit + "_CycleKey", GetFormValue(FormListGet(none, "HnS_ProcessedLocations", LocationInit), "HnS_CycleKey")) as bool) as int
		LocationInit += 1
	endWhile
	if LocationSaveWarningCounter > 0
		Debug.Trace("Unable to Fully Save Location Data.")
		warningCounter += LocationSaveWarningCounter
	endIf
	
	;============================================================================
	;Saving Cell List and Appropriate Keys.
	;============================================================================
	
	if !JsonUtil.FormListCopy(SaveFileName, "HnS_ProcessedCells", FormListToArray(none, "HnS_ProcessedCells"))
		Debug.Trace("Unable to Save Cell List.")
		warningCounter += 1
	endIf
	int CellSaveWarningCounter
	int CellInit
	while CellInit < ProcessedCellsListLength
		CellSaveWarningCounter += 1 - (JsonUtil.SetFormValue(SaveFileName, "HnS_Cell" + CellInit + "_CycleKey", GetFormValue(FormListGet(none, "HnS_ProcessedCells", CellInit), "HnS_CycleKey")) as bool) as int
		CellInit += 1
	endWhile
	if CellSaveWarningCounter > 0
		Debug.Trace("Unable to Fully Save Cell Data.")
		warningCounter += CellSaveWarningCounter
	endIf
	
	;============================================================================
	;Saving Racial Preset Lists
	;============================================================================
	
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
	
	;============================================================================
	;Loading GlobalVariable Array by converting it from an array of floats.
	;============================================================================
	
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
	
	;============================================================================
	;Loading Cycle Key Data by distributing each Key's collection of float from an array to the appropriate Variables.
	;============================================================================
	
	if !FormListCopy(none, "HnS_ValidKeyWordList", JsonUtil.FormListToArray(LoadFileName, "HnS_ValidKeyWordList"))
		Debug.Trace("Unable to Load KeyWord List.")
		warningCounter += 1
	endIf
	ValidKeyWordListLength = FormListCount(none, "HnS_ValidKeyWordList")
	
	int KeyWordListLoadWarningCounter
	int KeyWordInit
	while KeyWordInit < ValidKeyWordListLength
		Form LoadedKeyword = FormListGet(none, "HnS_ValidKeyWordList", KeyWordInit)
		KeyWordListLoadWarningCounter += 1 - (SetStringValue(LoadedKeyword, "HnS_CycleType", JsonUtil.GetStringValue(LoadFileName, "HnS_Keyword" + KeyWordInit + "_CycleType")) as bool) as int
		KeyWordListLoadWarningCounter += (SetIntValue(LoadedKeyword, "HnS_KeyWordPriority", JsonUtil.GetIntValue(LoadFileName, "HnS_Keyword" + KeyWordInit + "_Priority", -999)) == -999) as int
		KeyWordListLoadWarningCounter += (SetIntValue(LoadedKeyword, "HnS_CurrentPhase", JsonUtil.GetIntValue(LoadFileName, "HnS_Keyword" + KeyWordInit + "_CurrentPhase", -999)) == -999) as int
		float[] LoadedKeywordFloatArray = JsonUtil.FloatListToArray(LoadFileName,  "HnS_Keyword" + KeyWordInit + "FloatArray")
		if LoadedKeywordFloatArray.length == CycleFloatVariableNames.length
			int KeywordFloatCounter = 0
			while KeywordFloatCounter < LoadedKeywordFloatArray.length
				SetFloatValue(LoadedKeyword, CycleFloatVariableNames[KeywordFloatCounter], LoadedKeywordFloatArray[KeywordFloatCounter])
				KeywordFloatCounter +=1
			endWhile
		else
			KeyWordListLoadWarningCounter += 1
		endIf
		KeyWordInit += 1
	endWhile
	if KeyWordListLoadWarningCounter > 0
		Debug.Trace("Unable to Fully Load KeyWord Data.")
		warningCounter += KeyWordListLoadWarningCounter
	endIf
	
	;============================================================================
	;Loading Custom Area Data in the same way as above.
	;============================================================================
	
	if !FormListCopy(none, "HnS_CustomAreaList", JsonUtil.FormListToArray(LoadFileName, "HnS_CustomAreaList"))
		Debug.Trace("Unable to Load Custom Area List.")
		warningCounter += 1
	endIf
	CustomAreaListLength = FormListCount(none, "HnS_CustomAreaList")
	
	int AreaListLoadWarningCounter
	int AreaInit
	while AreaInit < CustomAreaListLength
		Form LoadedCustomArea = FormListGet(none, "HnS_CustomAreaList", AreaInit)
		AreaListLoadWarningCounter += 1 - (SetStringValue(LoadedCustomArea, "HnS_CustomAreaDisplayName", JsonUtil.GetStringValue(LoadFileName, "HnS_Area" + AreaInit + "_DisplayName")) as bool) as int
		;Debug.Trace("Display Name Error: " + AreaListLoadWarningCounter)
		AreaListLoadWarningCounter += 1 - (SetStringValue(LoadedCustomArea, "HnS_CycleType", JsonUtil.GetStringValue(LoadFileName, "HnS_Area" + AreaInit + "_CycleType")) as bool) as int
		;Debug.Trace("Cycle Type Error: " + AreaListLoadWarningCounter)
		AreaListLoadWarningCounter += (SetIntValue(LoadedCustomArea, "HnS_CurrentPhase", JsonUtil.GetIntValue(LoadFileName, "HnS_Area" + AreaInit + "_CurrentPhase", -999)) == -999) as int
		;Debug.Trace("Current Phase Error: " + AreaListLoadWarningCounter)
		float[] LoadedAreaFloatArray = JsonUtil.FloatListToArray(LoadFileName,  "HnS_Area" + AreaInit + "FloatArray")
		if LoadedAreaFloatArray.length == CycleFloatVariableNames.length
			int AreaFloatCounter = 0
			while AreaFloatCounter < LoadedAreaFloatArray.length
				SetFloatValue(LoadedCustomArea, CycleFloatVariableNames[AreaFloatCounter], LoadedAreaFloatArray[AreaFloatCounter])
				AreaFloatCounter +=1
			endWhile
		else
			;Debug.Trace("LoadedAreaFloatArray Length Incorrect: " + AreaListLoadWarningCounter)
			AreaListLoadWarningCounter += 1
		endIf
		AreaInit += 1
	endWhile
	if AreaListLoadWarningCounter > 0
		Debug.Trace("Unable to Fully Load Custom Area Data.")
		warningCounter += AreaListLoadWarningCounter
	endIf
		
	;============================================================================
	;Loading World List and Appropriate Keys.
	;============================================================================
	if !FormListCopy(none, "HnS_ProcessedWorlds", JsonUtil.FormListToArray(LoadFileName, "HnS_ProcessedWorlds"))
		Debug.Trace("Unable to Load World List.")
		warningCounter += 1
	endIf
	ProcessedWorldsListLength = FormListCount(none, "HnS_ProcessedWorlds")
	
	int WorldLoadWarningCounter
	int WorldInit
	while WorldInit < ProcessedWorldsListLength
		WorldLoadWarningCounter += 1 - (SetFormValue(FormListGet(none, "HnS_ProcessedWorlds", WorldInit), "HnS_CycleKey", JsonUtil.GetFormValue(LoadFileName, "HnS_World" + WorldInit + "_CycleKey")) as bool) as int
		WorldInit += 1
	endWhile
	if WorldLoadWarningCounter > 0
		Debug.Trace("Unable to Fully Load World Data.")
		warningCounter += WorldLoadWarningCounter
	endIf
	
	;============================================================================
	;Loading Location Lists and Appropriate Keys.
	;============================================================================
	if !FormListCopy(none, "HnS_ProcessedLocations", JsonUtil.FormListToArray(LoadFileName, "HnS_ProcessedLocations"))
		Debug.Trace("Unable to Load World List.")
		warningCounter += 1
	endIf
	if !FormListCopy(none, "HnS_ExteriorLocations", JsonUtil.FormListToArray(LoadFileName, "HnS_ExteriorLocations"))
		Debug.Trace("Unable to Load World List.")
		warningCounter += 1
	endIf
	ProcessedLocationsListLength = FormListCount(none, "HnS_ProcessedLocations")
	ExteriorLocationsListLength = FormListCount(none, "HnS_ExteriorLocations")
	
	int LocationLoadWarningCounter
	int LocationInit
	while LocationInit < ProcessedWorldsListLength
		LocationLoadWarningCounter += 1 - (SetFormValue(FormListGet(none, "HnS_ProcessedLocations", LocationInit), "HnS_CycleKey", JsonUtil.GetFormValue(LoadFileName, "HnS_Location" + LocationInit + "_CycleKey")) as bool) as int
		LocationInit += 1
	endWhile
	if LocationLoadWarningCounter > 0
		Debug.Trace("Unable to Fully Load Location Data.")
		warningCounter += LocationLoadWarningCounter
	endIf
	
	;============================================================================
	;Loading Cell List and Appropriate Keys.
	;============================================================================
	if !FormListCopy(none, "HnS_ProcessedCells", JsonUtil.FormListToArray(LoadFileName, "HnS_ProcessedCells"))
		Debug.Trace("Unable to Load World List.")
		warningCounter += 1
	endIf
	ProcessedCellsListLength = FormListCount(none, "HnS_ProcessedCells")
	 
	int CellLoadWarningCounter
	int CellInit
	while CellInit < ProcessedWorldsListLength
		CellLoadWarningCounter += 1 - (SetFormValue(FormListGet(none, "HnS_ProcessedCells", CellInit), "HnS_CycleKey", JsonUtil.GetFormValue(LoadFileName, "HnS_Cell" + CellInit + "_CycleKey")) as bool) as int
		CellInit += 1
	endWhile
	if CellLoadWarningCounter > 0
		Debug.Trace("Unable to Fully Load Cell Data.")
		warningCounter += CellLoadWarningCounter
	endIf
	
	;============================================================================
	;Loading Racial Preset Lists
	;============================================================================
	
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
