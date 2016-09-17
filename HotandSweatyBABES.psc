scriptname HotandSweatyBABES extends Quest
;{Background Atmospherics Bright Evironment Sensor: This script modifies game settings to fit the time of day and weather.}

import Game
import Math
import FrostUtil
import PapyrusUtil
import StorageUtil

HotandSweatyConditions property HnS_BUTTS auto

GlobalVariable property HnS_AllowPhaseChangeSkillDecrease auto
GlobalVariable property HnS_TimeBetweenSneakGlobalSettingChecks auto
GlobalVariable property HnS_CurrentDetectionDistance_ReadOnly auto
;GlobalVariable property HnS_DawnStart auto
;GlobalVariable property HnS_DayStart auto
;GlobalVariable property HnS_DuskStart auto
;GlobalVariable property HnS_NightStart auto
GlobalVariable property HnS_WeatherSevereSnowThickness auto
GlobalVariable property HnS_WeatherSevereSnowHeaviness auto
GlobalVariable property HnS_WeatherMildSnowThickness auto
GlobalVariable property HnS_WeatherMildSnowHeaviness auto
GlobalVariable property HnS_WeatherSevereRainThickness auto
GlobalVariable property HnS_WeatherSevereRainHeaviness auto
GlobalVariable property HnS_WeatherMildRainThickness auto
GlobalVariable property HnS_WeatherMildRainHeaviness auto
GlobalVariable property HnS_WeatherFogThickness auto
;GlobalVariable property HnS_InteriorReverb auto
;GlobalVariable property HnS_ExteriorReverb auto
;GlobalVariable property HnS_InteriorLuminosity auto
;GlobalVariable property HnS_InteriorNoisiness auto
;GlobalVariable property HnS_InteriorDetectionDistance auto
;GlobalVariable property HnS_InteriorViewCone auto
;GlobalVariable property HnS_NightDarkness auto
;GlobalVariable property HnS_NightQuietness auto
;GlobalVariable property HnS_NightDetectionDistance auto
;GlobalVariable property HnS_NightViewCone auto
;GlobalVariable property HnS_DayBrightness auto
;GlobalVariable property HnS_DayLoudness auto
;GlobalVariable property HnS_DayDetectionDistance auto
;GlobalVariable property HnS_DayViewCone auto
GlobalVariable property HnS_PhaseChangeMaxSkillDecreasePercent auto

;Day-Night Cycle Type Keywords
Keyword property HnS_LocTypeDefault auto ;Ignore Time && Weather. Darkest locations are pitch black. Default Interior.
Keyword property HnS_LocTypeWilderness auto ;Normal Location with variable lighting and weather that follows the phases of the day. Mostly exteriors.
Keyword property HnS_LocTypeSoulCairn auto ;External area that Ignores Time && Weather. Used only in the Soul Cairn.
Keyword property HnS_LocTypeApocrypha auto ;External area that Ignores Time && Weather. Used only in the Apocrypha.

GlobalVariable property FrostfallCurrentTemperatureReadOnly auto

Actor property PlayerRef auto
GlobalVariable property GameHour auto
KeyWord property LocTypeCity auto

float VisualBrigthnessMod ;Game Setting Variable: fDetectionSneakLightMod
float VisualMovementMod ;Game Setting Variable: fSneakLightMoveMult
float VisualRunningMod ;Game Setting Variable: fSneakLightRunMult
float VisualGeneralMod ;Game Setting Variables: fSneakLightMult && fSneakLightExteriorMult
float SoundReverbMod ;Game Setting Variable: fSneakSoundLosMult
float SoundGeneralMod ;Game Setting Variable: fSneakSoundsMult
float SoundLoudnessMod ;Game Setting Variable: fSneakEquippedWeightBase
float SoundMovementMod ;Game Setting Variable: fSneakEquippedWeightMult
float SoundRunningMod ;Game Setting Variable: fSneakRunningMult

float DetectionDistanceMod ;Game Setting Variable: fSneakMaxDistance
float CurrentViewCone ;Game Setting Variable: fDetectionViewCone

float OriginalVisualBrigthnessMod ;Original Game Setting Variable: fDetectionSneakLightMod
float OriginalVisualMovementMod ;Original Game Setting Variable: fSneakLightMoveMult
float OriginalVisualRunningMod ;Original Game Setting Variable: fSneakLightRunMult
float OriginalSoundReverbMod ;Original Game Setting Variable: fSneakSoundLosMult
float OriginalSoundGeneralMod ;Original Game Setting Variable: fSneakSoundsMult
float OriginalSoundLoudnessMod ;Original Game Setting Variable: fSneakEquippedWeightBase
float OriginalSoundMovementMod ;Original Game Setting Variable: fSneakEquippedWeightMult
float OriginalSoundRunningMod ;Original Game Setting Variable: fSneakRunningMult
float OriginalDetectionDistanceMod ;Original Game Setting Variable: fSneakMaxDistance
float OriginalViewCone ;Original Game Setting Variable: fDetectionViewCone
float OriginalfSneakLightMult ;Original Game Setting Variable: fSneakLightMult
float OriginalfSneakLightExteriorMult ;Original Game Setting Variable: fSneakLightExteriorMult

bool RunOnce

event OnInit()
	if self.IsRunning()
		SaveOriginalSettings()
		RegisterForModEvent("HnS_UpdateSneakGlobals", "OnUpdateSneakGlobals")
	endIf
	UpdateLock = false
	;SneakGlobalsUpdate()
endEvent

event OnUpdateGameTime()
	SneakGlobalsUpdate()
endEvent

event OnUpdateSneakGlobals(string eventName, string strArg, float numArg, Form sender)
	SneakGlobalsUpdate()
endEvent

function OnLoadInitialize()
	Utility.WaitMenuMode(0.5)
	SneakGlobalsUpdate()
endFunction

bool UpdateLock
function SneakGlobalsUpdate()
	if UpdateLock
		return
	endIf
	UpdateLock = true
	Form CurrentArea
	Cell CurrentCell = PlayerRef.GetParentCell()
	Location CurrentLocation = PlayerRef.GetCurrentLocation()
	WorldSpace CurrentWorldSpace = PlayerRef.GetWorldspace()
	Form AreaCycleKeyWord
	
	if CurrentLocation && !FormListHas(none, "HnS_ProcessedLocations", CurrentLocation)
		ProcessLocation(CurrentLocation)
	endIf
	
	if CurrentWorldSpace
		CurrentArea = CurrentWorldSpace
		if !FormListHas(none, "HnS_ProcessedWorlds", CurrentArea)
			if FormListHas(none, "HnS_StandardInteriorWorldspaces", CurrentArea)
				AreaCycleKeyWord = HnS_LocTypeDefault
				SetFormValue(CurrentArea, "HnS_CycleKey", AreaCycleKeyWord)
			elseIf FormListHas(none, "HnS_LargeCityWorldspaces", CurrentArea)
				AreaCycleKeyWord = LocTypeCity
				SetFormValue(CurrentArea, "HnS_CycleKey", AreaCycleKeyWord)
			elseIf HnS_BUTTS.DawnguardLoaded && (CurrentWorldSpace == HnS_BUTTS.DLC01SoulCairn || CurrentWorldSpace == HnS_BUTTS.DLC01Boneyard)
				AreaCycleKeyWord = HnS_LocTypeSoulCairn
				SetFormValue(CurrentArea, "HnS_CycleKey", AreaCycleKeyWord)
			elseIf HnS_BUTTS.DragonBornLoaded && CurrentWorldSpace == HnS_BUTTS.DLC2ApocryphaWorld
				AreaCycleKeyWord = HnS_LocTypeApocrypha
				SetFormValue(CurrentArea, "HnS_CycleKey", AreaCycleKeyWord)
			else
				AreaCycleKeyWord = GetFormValue(CurrentLocation, "HnS_CycleKey", HnS_LocTypeWilderness)
				SetFormValue(CurrentArea, "HnS_CycleKey", HnS_LocTypeWilderness)
				if CurrentLocation
					FormListAdd(none, "HnS_ExteriorLocations", CurrentLocation, false)
				endIf
			endIf
			
			FormListAdd(none, "HnS_ProcessedWorlds", CurrentArea, false)
		else
			AreaCycleKeyWord = GetFormValue(CurrentArea, "HnS_CycleKey")
			if AreaCycleKeyWord == HnS_LocTypeWilderness
				AreaCycleKeyWord = GetFormValue(CurrentLocation, "HnS_CycleKey", HnS_LocTypeWilderness)
				if CurrentLocation
					FormListAdd(none, "HnS_ExteriorLocations", CurrentLocation, false)
				endIf
			endIf
		endIf
	else
		CurrentArea = CurrentCell
		if !FormListHas(none, "HnS_ProcessedCells", CurrentArea)
			AreaCycleKeyWord = GetFormValue(CurrentLocation, "HnS_InCycleKey", HnS_LocTypeDefault)
			SetFormValue(CurrentArea, "HnS_CycleKey", AreaCycleKeyWord)
			FormListAdd(none, "HnS_ProcessedCells", CurrentArea, false)
		else
			AreaCycleKeyWord = GetFormValue(CurrentArea, "HnS_CycleKey")
		endIf
	endIf
	
	; AreaCycleKeyWord
	; The Current location's CycleKey has the following possible values:
	
	;Hot and Sweaty Keywords Used:
	;HnS_LocTypeDefault: Ignore Time && Weather. Darkest locations are pitch black. Default Interior.
	;HnS_LocTypeWilderness: Normal Location with variable lighting and weather that follows the phases of the day. Mostly exteriors.
	;HnS_LocTypeSoulCairn: External area that Ignores Time && Weather. Used only in the Soul Cairn.
	;HnS_LocTypeApocrypha: External area that Ignores Time && Weather. Used only in the Apocrypha.
	
	;Vanilla Keywords Used:
	;LocTypeDwelling: Ignore Time && Weather. Darkest locations are only slightly visible. Inhabited Interiors.
	;LocSetDwarvenRuin: Ignore Time && Weather. Darkest locations are pitch black. Harder to hear than Caves. Default for Dwemer Ruins.
	;LocTypeCity: Same as Normal exteriors, but with much lower hearing. Only in Major Hold Capitals IE Markarth, Riften, Solitude, Whiterun, Windhelm
	;CWCapital: Same as Normal exteriors, but with lower hearing. Only in Minor Hold Capitals IE Dawnstar, Falkreath, Morthal, and Winterhold
	;LocTypeTown: Same as Normal exteriors, but with slightly lower hearing. Only in Towns IE Dragon Bridge, Ivarstead, Karthwasten, Rorikstead, Shor's Stone, and Riverwood
	;LocTypeStore: Only Auditory Loud/Quiet cycle with no weather. Primarily used in interior Cells that are stores.
	;LocTypeInn: Only Auditory Loud/Quiet cycle with no weather. Primarily used in interior Cells that are Taverns and Inns.
	
	;Go to Cycle STATE
	;Full_Static_Area - Locations where stealth variables don't change over time and doesn't have weather
	;Part_Static_Area - Locations where stealth variables don't change over time but has weather
	;Part_Dynamc_Area - Locations where stealth variables change over time but doesn't have weather
	;Full_Dynamc_Area - Locations where stealth variables change over time and has weather
	
	if !AreaCycleKeyWord
		AreaCycleKeyWord = HnS_LocTypeDefault
	endIf
	
	string CycleState = GetStringValue(AreaCycleKeyWord, "HnS_CycleType")
	GoToState(CycleState)
	
	Debug.Trace("Current Cycle Key: " + (AreaCycleKeyWord as Keyword).GetString())
	Debug.Trace("Current Cycle Type: " + CycleState)
	
	ProcessSneakVariables(AreaCycleKeyWord)
	UpdateLock = false
endFunction

function ProcessSneakVariables(Form akCycleKeyWord)
	Debug.Trace("Set Sneak Variable Function Called in Empty state! Bug occurred. Please contact Mod author.")
endFunction

function SetSneakVariables(Form akCycleKeyWord)
	float CurrentWeatherVisualMod = GetFloatValue(none,"HnS_WeatherVisualMod", 1.0)
	float CurrentWeatherSoundMod = GetFloatValue(none,"HnS_WeatherSoundMod", 1.0)
	
	VisualGeneralMod = GetFloatValue(akCycleKeyWord, "HnS_Vision") * CurrentWeatherVisualMod
	VisualBrigthnessMod = GetFloatValue(akCycleKeyWord, "HnS_BrigthnessMod")
	VisualMovementMod = GetFloatValue(akCycleKeyWord, "HnS_VisualMovementMod")
	VisualRunningMod = GetFloatValue(akCycleKeyWord, "HnS_VisualRunningMod")
	SoundReverbMod = GetFloatValue(akCycleKeyWord, "HnS_Reverb")
	SoundGeneralMod = GetFloatValue(akCycleKeyWord, "HnS_Hearing") * CurrentWeatherSoundMod
	SoundLoudnessMod = GetFloatValue(akCycleKeyWord, "HnS_LoudnessMod")
	SoundMovementMod = GetFloatValue(akCycleKeyWord, "HnS_AuditoryMovementMod")
	SoundRunningMod = GetFloatValue(akCycleKeyWord, "HnS_AuditoryRunningMod")
	CurrentViewCone = GetFloatValue(akCycleKeyWord, "HnS_ViewCone")
	DetectionDistanceMod = GetFloatValue(akCycleKeyWord, "HnS_DetectionDistance") * (CurrentWeatherVisualMod + CurrentWeatherSoundMod) / 2.0
	
	SetFloatValue(none, "HnS_CurrentBlindnessThreshold", GetFloatValue(akCycleKeyWord, "HnS_BlindnessThreshold"))
	SetFloatValue(none, "HnS_CurrentBlindnessThresholdNE", GetFloatValue(akCycleKeyWord, "HnS_BlindnessThresholdNE"))
	SetFloatValue(none, "HnS_CurrentLightBlindnessMod", GetFloatValue(akCycleKeyWord, "HnS_LightBlindnessMod"))
	SetFloatValue(none, "HnS_CurrentLightBlindnessModNE", GetFloatValue(akCycleKeyWord, "HnS_LightBlindnessModNE"))
endFunction

function SetDaySneakVariables(Form akCycleKeyWord)
	float CurrentWeatherVisualMod = GetFloatValue(none,"HnS_WeatherVisualMod", 1.0)
	float CurrentWeatherSoundMod = GetFloatValue(none,"HnS_WeatherSoundMod", 1.0)
	
	VisualGeneralMod = GetFloatValue(akCycleKeyWord, "HnS_Vision_D") * CurrentWeatherVisualMod
	VisualBrigthnessMod = GetFloatValue(akCycleKeyWord, "HnS_BrigthnessMod_D")
	VisualMovementMod = GetFloatValue(akCycleKeyWord, "HnS_VisualMovementMod_D")
	VisualRunningMod = GetFloatValue(akCycleKeyWord, "HnS_VisualRunningMod_D")
	SoundReverbMod = GetFloatValue(akCycleKeyWord, "HnS_Reverb")
	SoundGeneralMod = GetFloatValue(akCycleKeyWord, "HnS_Hearing_D") * CurrentWeatherSoundMod
	SoundLoudnessMod = GetFloatValue(akCycleKeyWord, "HnS_LoudnessMod_D")
	SoundMovementMod = GetFloatValue(akCycleKeyWord, "HnS_AuditoryMovementMod_D")
	SoundRunningMod = GetFloatValue(akCycleKeyWord, "HnS_AuditoryRunningMod_D")
	CurrentViewCone = GetFloatValue(akCycleKeyWord, "HnS_ViewCone_D")
	DetectionDistanceMod = GetFloatValue(akCycleKeyWord, "HnS_DetectionDistance_D") * (CurrentWeatherVisualMod + CurrentWeatherSoundMod) / 2.02
	
	SetFloatValue(none, "HnS_CurrentBlindnessThreshold", GetFloatValue(akCycleKeyWord, "HnS_BlindnessThreshold_D"))
	SetFloatValue(none, "HnS_CurrentBlindnessThresholdNE", GetFloatValue(akCycleKeyWord, "HnS_BlindnessThresholdNE_D"))
	SetFloatValue(none, "HnS_CurrentLightBlindnessMod", GetFloatValue(akCycleKeyWord, "HnS_LightBlindnessMod_D"))
	SetFloatValue(none, "HnS_CurrentLightBlindnessModNE", GetFloatValue(akCycleKeyWord, "HnS_LightBlindnessModNE_D"))
endFunction

function SetPhaseChangeSneakVariables(Form akCycleKeyWord, float afRelativePhaseChangeModifier)
	float CenterDipFactor
	float PhaseChangeMaxSkillDecreasePercent = HnS_PhaseChangeMaxSkillDecreasePercent.GetValue()
	if PhaseChangeMaxSkillDecreasePercent > 0.0
		float CentralDipModifier = 2.0/PhaseChangeMaxSkillDecreasePercent
		CenterDipFactor = (CentralDipModifier - 1.0 - Cos((afRelativePhaseChangeModifier - 0.5) * 360.0))/CentralDipModifier
	else
		CenterDipFactor = 1.0
	endIf
	float VisualPhaseTransitionModifier = afRelativePhaseChangeModifier * CenterDipFactor
	float AuditoryPhaseTransitionModifier = 1 + VisualPhaseTransitionModifier - CenterDipFactor
	
	float CurrentWeatherVisualMod = GetFloatValue(none,"HnS_WeatherVisualMod", 1.0)
	float CurrentWeatherSoundMod = GetFloatValue(none,"HnS_WeatherSoundMod", 1.0)
	
	float NightVisualGeneralMod = GetFloatValue(akCycleKeyWord, "HnS_Vision")
	float NightVisualBrigthnessMod = GetFloatValue(akCycleKeyWord, "HnS_BrigthnessMod")
	float NightVisualMovementMod = GetFloatValue(akCycleKeyWord, "HnS_MovementMod")
	float NightVisualRunningMod = GetFloatValue(akCycleKeyWord, "HnS_RunningMod")
	float NightSoundGeneralMod = GetFloatValue(akCycleKeyWord, "HnS_Hearing")
	float NightSoundLoudnessMod = GetFloatValue(akCycleKeyWord, "HnS_LoudnessMod")
	float NightSoundMovementMod = GetFloatValue(akCycleKeyWord, "HnS_AuditoryMovementMod")
	float NightSoundRunningMod = GetFloatValue(akCycleKeyWord, "HnS_AuditoryRunningMod")
	float NightCurrentViewCone = GetFloatValue(akCycleKeyWord, "HnS_ViewCone")
	float NightDetectionDistanceMod = GetFloatValue(akCycleKeyWord, "HnS_DetectionDistance")
	float NightBlindnessThreshold = GetFloatValue(akCycleKeyWord, "HnS_BlindnessThreshold")
	float NightBlindnessThresholdNE = GetFloatValue(akCycleKeyWord, "HnS_BlindnessThresholdNE")
	float NightLightBlindnessMod = GetFloatValue(akCycleKeyWord, "HnS_LightBlindnessMod")
	float NightLightBlindnessModNE = GetFloatValue(akCycleKeyWord, "HnS_LightBlindnessModNE")
	
	float DayVisualGeneralMod = GetFloatValue(akCycleKeyWord, "HnS_Vision_D")
	float DayVisualBrigthnessMod = GetFloatValue(akCycleKeyWord, "HnS_BrigthnessMod_D")
	float DayVisualMovementMod = GetFloatValue(akCycleKeyWord, "HnS_MovementMod_D")
	float DayVisualRunningMod = GetFloatValue(akCycleKeyWord, "HnS_RunningMod_D")
	float DaySoundGeneralMod = GetFloatValue(akCycleKeyWord, "HnS_Hearing_D")
	float DaySoundLoudnessMod = GetFloatValue(akCycleKeyWord, "HnS_LoudnessMod_D")
	float DaySoundMovementMod = GetFloatValue(akCycleKeyWord, "HnS_AuditoryMovementMod_D")
	float DaySoundRunningMod = GetFloatValue(akCycleKeyWord, "HnS_AuditoryRunningMod_D")
	float DayCurrentViewCone = GetFloatValue(akCycleKeyWord, "HnS_ViewCone_D")
	float DayDetectionDistanceMod = GetFloatValue(akCycleKeyWord, "HnS_DetectionDistance_D")
	float DayBlindnessThreshold = GetFloatValue(akCycleKeyWord, "HnS_BlindnessThreshold_D")
	float DayBlindnessThresholdNE = GetFloatValue(akCycleKeyWord, "HnS_BlindnessThresholdNE_D")
	float DayLightBlindnessMod = GetFloatValue(akCycleKeyWord, "HnS_LightBlindnessMod_D")
	float DayLightBlindnessModNE = GetFloatValue(akCycleKeyWord, "HnS_LightBlindnessModNE_D")
	
	VisualGeneralMod = (NightVisualGeneralMod + (VisualPhaseTransitionModifier * (DayVisualGeneralMod - NightVisualGeneralMod))) * CurrentWeatherVisualMod
	VisualBrigthnessMod = NightVisualBrigthnessMod + (VisualPhaseTransitionModifier * (DayVisualBrigthnessMod - NightVisualBrigthnessMod))
	VisualMovementMod = NightVisualMovementMod + (VisualPhaseTransitionModifier * (DayVisualMovementMod - NightVisualMovementMod))
	VisualRunningMod = NightVisualRunningMod + (VisualPhaseTransitionModifier * (DayVisualRunningMod - NightVisualRunningMod))
	SoundReverbMod = GetFloatValue(akCycleKeyWord, "HnS_Reverb")
	SoundGeneralMod = (NightSoundGeneralMod + (AuditoryPhaseTransitionModifier * (DaySoundGeneralMod - NightSoundGeneralMod))) * CurrentWeatherSoundMod
	SoundLoudnessMod = NightSoundLoudnessMod + (AuditoryPhaseTransitionModifier * (DaySoundLoudnessMod - NightSoundLoudnessMod))
	SoundMovementMod = NightSoundMovementMod + (AuditoryPhaseTransitionModifier * (DaySoundMovementMod - NightSoundMovementMod))
	SoundRunningMod = NightSoundRunningMod + (AuditoryPhaseTransitionModifier * (DaySoundRunningMod - NightSoundRunningMod))
	
	CurrentViewCone = NightCurrentViewCone + (VisualPhaseTransitionModifier * (DayCurrentViewCone - NightCurrentViewCone))
	DetectionDistanceMod = (NightDetectionDistanceMod + (afRelativePhaseChangeModifier * (DayDetectionDistanceMod - NightDetectionDistanceMod))) * (CurrentWeatherVisualMod + CurrentWeatherSoundMod) / 2.0
	
	SetFloatValue(none, "HnS_CurrentBlindnessThreshold", NightBlindnessThreshold + (VisualPhaseTransitionModifier * (DayBlindnessThreshold - NightBlindnessThreshold)))
	SetFloatValue(none, "HnS_CurrentBlindnessThresholdNE", NightBlindnessThresholdNE + (VisualPhaseTransitionModifier * (DayBlindnessThresholdNE - NightBlindnessThresholdNE)))
	SetFloatValue(none, "HnS_CurrentLightBlindnessMod", NightLightBlindnessMod + (VisualPhaseTransitionModifier * (DayLightBlindnessMod - NightLightBlindnessMod)))
	SetFloatValue(none, "HnS_CurrentLightBlindnessModNE", NightLightBlindnessModNE + (VisualPhaseTransitionModifier * (DayLightBlindnessModNE - NightLightBlindnessModNE)))
endFunction

;WeatherVisualMod definitions Defaults
;Clear, Cloudy = 100%
;Fog = 90%
;Mild rain = 80%
;Mild snow = 75%
;Severe rain = 60%
;Severe snow = 50%

;WeatherSoundMod definitions Defaults
;Clear, Cloudy, fog = 100%
;Mild snow = 85%
;Mild rain = 75%
;Severe snow = 60%
;Severe rain = 50%

float function SetWeatherMods(int aiDayPhase)
	float NewWeatherVisualMod = 1.0
	float NewWeatherSoundMod = 1.0
	float NewTemperature = 10.0
	Weather WeatherToClassfy = GetCurrentWeatherActual()
	float TemperatureRandomizer = Utility.RandomFloat(0.0, 10.0)
	int BethesdaWeatherClassification = WeatherToClassfy.GetClassification()
	if BethesdaWeatherClassification == 3
		if FormListHas(none, "HnS_SevereWeather", WeatherToClassfy)
			Debug.Trace("Weather is Blizzardy / Dust Stormy.")
			NewWeatherVisualMod = HnS_WeatherSevereSnowThickness.GetValue()
			NewWeatherSoundMod = HnS_WeatherSevereSnowHeaviness.GetValue()
			if (HnS_BUTTS.DragonBornLoaded && (WeatherToClassfy == HnS_BUTTS.DLC02VolcanicAshStorm01))
				NewTemperature = 12.5 + TemperatureRandomizer * 0.75
			else
				NewTemperature = -25.0 + TemperatureRandomizer
			endIf
		else
			Debug.Trace("Weather is Snowy.")
			NewWeatherVisualMod = HnS_WeatherMildSnowThickness.GetValue()
			NewWeatherSoundMod = HnS_WeatherMildSnowHeaviness.GetValue()
			NewTemperature = -15.0 + TemperatureRandomizer
		endIf
	elseIf BethesdaWeatherClassification == 2
		if FormListHas(none, "HnS_SevereWeather", WeatherToClassfy)
			Debug.Trace("Weather is Stormy.")
			NewWeatherVisualMod = HnS_WeatherSevereRainThickness.GetValue()
			NewWeatherSoundMod = HnS_WeatherSevereRainHeaviness.GetValue()
			NewTemperature = 5.0 + TemperatureRandomizer * 0.5
		else
			Debug.Trace("Weather is rainy.")
			NewWeatherVisualMod = HnS_WeatherMildRainThickness.GetValue()
			NewWeatherSoundMod = HnS_WeatherMildRainHeaviness.GetValue()
			NewTemperature = 5.0 + TemperatureRandomizer
			endIf
	elseIf BethesdaWeatherClassification == 1
		if FormListHas(none, "HnS_FoggyWeather", WeatherToClassfy)
			Debug.Trace("Weather is foggy.")
			NewWeatherVisualMod = HnS_WeatherFogThickness.GetValue()
			NewTemperature = 5.0 + TemperatureRandomizer
		elseif aiDayPhase == 0
			NewTemperature = -5.0 + TemperatureRandomizer * 0.5
		elseIf aiDayPhase > 0
			NewTemperature = 10.0 + TemperatureRandomizer * 0.5
		else
			NewTemperature = 2.5 + TemperatureRandomizer * 0.75
		endIf
	elseIf aiDayPhase == 0
		NewTemperature = -10.0 + TemperatureRandomizer * 1.5
	elseIf aiDayPhase > 0
		NewTemperature = 15.0 + TemperatureRandomizer * 0.5
	else
		NewTemperature = TemperatureRandomizer
	endIf
	SetFloatValue(none, "HnS_WeatherVisualMod", NewWeatherVisualMod)
	SetFloatValue(none, "HnS_WeatherSoundMod", NewWeatherSoundMod)
	return NewTemperature
endFunction

function UpdateTemperature(float akNewTemperature)
	if (!HnS_BUTTS.FrostfallLoaded || HnS_BUTTS.FrostfallRunning.GetValue() != 2.0) && (akNewTemperature != FrostfallCurrentTemperatureReadOnly.GetValue())
		FrostfallCurrentTemperatureReadOnly.SetValue(akNewTemperature)
		SendModEvent("HnS_UpdateRadiantHeat")
	endIf
endFunction

state Full_Static_Area ;This location/cell/Worldspace is Static. Do not update stealth variables over time.
	function ProcessSneakVariables(Form akCycleKeyWord)
		SetFloatValue(none, "HnS_WeatherVisualMod", 1.0)
		SetFloatValue(none, "HnS_WeatherSoundMod", 1.0)
		SetSneakVariables(akCycleKeyWord)
		instituteSneakVariables()
		UpdateTemperature(10.0)
	endFunction
endState

state Part_Static_Area ;This location/cell/Worldspace is Static, but has weather. Update twice as slow as usual.
	function ProcessSneakVariables(Form akCycleKeyWord)
		float WeatherTemperature = SetWeatherMods(GetIntValue(akCycleKeyWord, "HnS_CurrentPhase"))
		SetSneakVariables(akCycleKeyWord)
		instituteSneakVariables()
		UpdateTemperature(WeatherTemperature)
		RegisterForSingleUpdateGameTime(HnS_TimeBetweenSneakGlobalSettingChecks.GetValue() * 2.0)
	endFunction
endState

state Part_Dynamc_Area ;This location/cell/Worldspace is Dynamic but without any Weather. Update all stealth variables over time.
	function ProcessSneakVariables(Form akCycleKeyWord)
		float CurrentHour = GameHour.GetValue()
		float DayPhaseStart = GetFloatValue(akCycleKeyWord, "HnS_DayPhaseStart")
		float DayPhaseEnd = GetFloatValue(akCycleKeyWord, "HnS_DayPhaseEnd")
		float NightPhaseStart = GetFloatValue(akCycleKeyWord, "HnS_NightPhaseStart")
		float NightPhaseEnd = GetFloatValue(akCycleKeyWord, "HnS_NightPhaseEnd")
		SetFloatValue(none, "HnS_WeatherVisualMod", 1.0)
		SetFloatValue(none, "HnS_WeatherSoundMod", 1.0)
		if CurrentHour >= NightPhaseStart || CurrentHour <= NightPhaseEnd ;is Night
			SetSneakVariables(akCycleKeyWord)
			Debug.Trace("Night Phase")
		elseIf CurrentHour > DayPhaseEnd ;Is Dusk
			Debug.Trace("Dusk Phase")
			SetPhaseChangeSneakVariables(akCycleKeyWord, (NightPhaseStart - CurrentHour)/(NightPhaseStart - DayPhaseEnd))
		elseIf CurrentHour < DayPhaseStart ;Is Dawn
			Debug.Trace("Dawn Phase")
			SetPhaseChangeSneakVariables(akCycleKeyWord, (CurrentHour - NightPhaseEnd)/(DayPhaseStart - NightPhaseEnd))
		else ;is Day
			SetDaySneakVariables(akCycleKeyWord)
			Debug.Trace("Day Phase")
		endIf
		instituteSneakVariables()
		UpdateTemperature(10.0)
		RegisterForSingleUpdateGameTime(HnS_TimeBetweenSneakGlobalSettingChecks.GetValue())
	endFunction
endState

state Full_Dynamc_Area ;This location/cell/Worldspace is Dynamic. Update all stealth variables over time.
	function ProcessSneakVariables(Form akCycleKeyWord)
		float WeatherTemperature
		float CurrentHour = GameHour.GetValue()
		float DayPhaseStart = GetFloatValue(akCycleKeyWord, "HnS_DayPhaseStart")
		float DayPhaseEnd = GetFloatValue(akCycleKeyWord, "HnS_DayPhaseEnd")
		float NightPhaseStart = GetFloatValue(akCycleKeyWord, "HnS_NightPhaseStart")
		float NightPhaseEnd = GetFloatValue(akCycleKeyWord, "HnS_NightPhaseEnd")
		bool ProcessWeather = GetIntValue(akCycleKeyWord, "HnS_HasWeather")
		if CurrentHour >= NightPhaseStart || CurrentHour <= NightPhaseEnd || (ProcessWeather && Weather.GetCurrentWeather() == HnS_BUTTS.DLC1Eclipse) ;is Night
			WeatherTemperature = SetWeatherMods(0)
			SetSneakVariables(akCycleKeyWord)
			Debug.Trace("Night Phase")
		elseIf CurrentHour > DayPhaseEnd ;Is Dusk
			WeatherTemperature = SetWeatherMods(-1)
			Debug.Trace("Dusk Phase")
			SetPhaseChangeSneakVariables(akCycleKeyWord, (NightPhaseStart - CurrentHour)/(NightPhaseStart - DayPhaseEnd))
		elseIf CurrentHour < DayPhaseStart ;Is Dawn
			WeatherTemperature = SetWeatherMods(-1)
			Debug.Trace("Dawn Phase")
			SetPhaseChangeSneakVariables(akCycleKeyWord, (CurrentHour - NightPhaseEnd)/(DayPhaseStart - NightPhaseEnd))
		else ;is Day
			WeatherTemperature = SetWeatherMods(1)
			SetDaySneakVariables(akCycleKeyWord)
			Debug.Trace("Day Phase")
		endIf
		Debug.Trace("WeatherVisualMod: " + GetFloatValue(none,"HnS_WeatherVisualMod", 1.0))
		Debug.Trace("WeatherSoundMod: " + GetFloatValue(none,"HnS_WeatherSoundMod", 1.0))
		instituteSneakVariables()
		UpdateTemperature(WeatherTemperature)
		RegisterForSingleUpdateGameTime(HnS_TimeBetweenSneakGlobalSettingChecks.GetValue())
	endFunction
endState

function ProcessLocation(Location akCurrentLocation)
	Keyword CurrentKeyWord
	Keyword KeyWordWithHighestPriority = none
	Keyword KeyWordWithLowestPriority = none
	int KeyWordCount = akCurrentLocation.GetNumKeywords()
	int KeyWordIndex
	int MaxPriority = 0
	int MinPriority = 0
	int CurrentPriority = 0
	
	while KeyWordIndex < KeyWordCount
		CurrentKeyWord = akCurrentLocation.GetNthKeyword(KeyWordIndex)
		if FormListHas(none, "HnS_ValidKeyWordList", CurrentKeyWord)
			CurrentPriority = GetIntValue(CurrentKeyWord, "HnS_KeyWordPriority")
			if CurrentPriority > MaxPriority
				MaxPriority = CurrentPriority
				KeyWordWithHighestPriority = CurrentKeyWord
			elseIf CurrentPriority < MinPriority
				MinPriority = CurrentPriority
				KeyWordWithLowestPriority = CurrentKeyWord
			endIf
		endIf
		KeyWordIndex += 1
	endwhile
	
	if KeyWordWithHighestPriority
		SetFormValue(akCurrentLocation, "HnS_InCycleKey", KeyWordWithHighestPriority)
	else
		SetFormValue(akCurrentLocation, "HnS_InCycleKey", HnS_LocTypeDefault)
	endIf
	if KeyWordWithLowestPriority
		SetFormValue(akCurrentLocation, "HnS_CycleKey", KeyWordWithLowestPriority)
	else
		SetFormValue(akCurrentLocation, "HnS_CycleKey", HnS_LocTypeWilderness)
	endIf
	
	FormListAdd(none, "HnS_ProcessedLocations", akCurrentLocation, false)
endFunction

function instituteSneakVariables()
	SetGameSettingFloat("fSneakLightMult", VisualGeneralMod)
	SetGameSettingFloat("fDetectionSneakLightMod", VisualBrigthnessMod)
	SetGameSettingFloat("fSneakLightMoveMult", VisualMovementMod)
	SetGameSettingFloat("fSneakLightRunMult", VisualRunningMod)
	SetGameSettingFloat("fSneakSoundsMult", SoundGeneralMod)
	SetGameSettingFloat("fSneakEquippedWeightBase", SoundLoudnessMod)
	SetGameSettingFloat("fSneakEquippedWeightMult", SoundMovementMod)
	SetGameSettingFloat("fSneakRunningMult", SoundRunningMod)
	SetGameSettingFloat("fSneakSoundLosMult", SoundReverbMod)
	SetGameSettingFloat("fSneakMaxDistance", DetectionDistanceMod)
	SetGameSettingFloat("fDetectionViewCone", CurrentViewCone)
	HotandSweatyGAMS.SkyTweakUpdate(self)
	Debug.Trace("fSneakLightMult = " + VisualGeneralMod)
	Debug.Trace("fSneakLightExteriorMult = " + VisualGeneralMod)
	Debug.Trace("fDetectionSneakLightMod = " + VisualBrigthnessMod)
	Debug.Trace("fSneakLightMoveMult = " + VisualMovementMod)
	Debug.Trace("fSneakLightRunMult = " + VisualRunningMod)
	Debug.Trace("fSneakSoundsMult = " + SoundGeneralMod)
	Debug.Trace("fSneakEquippedWeightBase = " + SoundLoudnessMod)
	Debug.Trace("fSneakEquippedWeightMult = " + SoundMovementMod)
	Debug.Trace("fSneakRunningMult = " + SoundRunningMod)
	Debug.Trace("fSneakSoundLosMult = " + SoundReverbMod)
	Debug.Trace("fSneakMaxDistance = " + DetectionDistanceMod)
	Debug.Trace("fDetectionViewCone = " + CurrentViewCone)
	HnS_CurrentDetectionDistance_ReadOnly.SetValue(DetectionDistanceMod)
endFunction

function SaveOriginalSettings()
	OriginalVisualBrigthnessMod = GetGameSettingFloat("fDetectionSneakLightMod")
	OriginalVisualMovementMod = GetGameSettingFloat("fSneakLightMoveMult")
	OriginalVisualRunningMod = GetGameSettingFloat("fSneakLightRunMult")
	OriginalSoundReverbMod = GetGameSettingFloat("fSneakSoundLosMult")
	OriginalSoundGeneralMod = GetGameSettingFloat("fSneakSoundsMult")
	OriginalSoundLoudnessMod = GetGameSettingFloat("fSneakEquippedWeightBase")
	OriginalSoundMovementMod = GetGameSettingFloat("fSneakEquippedWeightMult")
	OriginalSoundRunningMod = GetGameSettingFloat("fSneakRunningMult")
	OriginalDetectionDistanceMod = GetGameSettingFloat("fSneakMaxDistance")
	OriginalViewCone = GetGameSettingFloat("fDetectionViewCone")
	OriginalfSneakLightMult = GetGameSettingFloat("fSneakLightMult")
	;OriginalfSneakLightExteriorMult = GetGameSettingFloat("fSneakLightExteriorMult")
endFunction

function RevertStop()
	int OverFlowCounter
	while UpdateLock && OverFlowCounter < 50
		Utility.WaitMenuMode(0.1)
		OverFlowCounter +=1
	endWhile
	if OverFlowCounter >= 50 ;Give it a few seconds
		Debug.Trace("SneakGlobalsUpdate not registering as complete. Proceeding with variable reset. Unwanted behaviour possible.")
	endIf
	UpdateLock = true
	VisualGeneralMod = OriginalfSneakLightMult
	VisualBrigthnessMod = OriginalVisualBrigthnessMod
	VisualMovementMod = OriginalVisualMovementMod
	VisualRunningMod = OriginalVisualRunningMod
	SoundReverbMod = OriginalSoundReverbMod
	SoundGeneralMod = OriginalSoundGeneralMod
	SoundLoudnessMod = OriginalSoundLoudnessMod
	SoundMovementMod = OriginalSoundMovementMod
	SoundRunningMod = OriginalSoundRunningMod
	DetectionDistanceMod = OriginalDetectionDistanceMod
	CurrentViewCone = OriginalViewCone
	instituteSneakVariables()
	;SetGameSettingFloat("fSneakLightExteriorMult", OriginalfSneakLightExteriorMult)
	Self.Stop()
	Utility.wait(0.1)
	UpdateLock = false
	Debug.Trace("Finished reverting game sneak settings back to vanilla values.")
endFunction


