scriptname HotandSweatyBUTTS extends Quest
;{Basic Universal Task Tender Script: This script installs the mod and manages the other quest scripts.}

import Utility
import Game
import StorageUtil

Form[] property IgnoredModdedRaces auto
Form[] property EnviroBlindnessImmuneRaces auto
Form[] property NightVisionRaces auto
Form[] property NoSmellRaces auto
Form[] property SmellyUnLivingRaces auto
Form[] property SmellTierNPCRaces auto
;Form[] property SmellNPCExceptionRaces auto
Form[] property SmellTier1Races auto
Form[] property SmellTier2Races auto
Form[] property SmellTier3Races auto
Form[] property SmellTier4Races auto
;Form[] property ThermalVisionRaces auto
Form[] property NoThermalVisionUndeadRaces auto
Form[] property MagickaDetectionRaces auto
;Form[] property NoMagickaDetectionDwarvenRaces auto
Form[] property FoggyWeather auto
Form[] property SevereWeather auto
Form[] property LargeCityWorldspaces auto
Form[] property StandardInteriorWorldspaces auto ;Array of Vanilla Worldspaces that count as interiors when it comes to lighting and sound.
Form[] property ValidKeyWordList auto ;Array of KeyWords that modify location values.
String[] property KeyWordCycleTypeStringList auto ;
int[] property KeyWordPriorityIntList auto ;

HotandSweatyBOOBS property HnS_BOOBS auto ;Blinded Object Outcome Brightness Selector
HotandSweatyBDSM property HnS_BDSM auto ;Background Dirtiness Smell Manager
HotandSweatyTITS property HnS_TITS auto ;Temperature Interface Tracking Script
HotandSweatyDAMES property HnS_DAMES auto ;Determining Allowed Magicka Event Script
HotandSweatySADIST  property HnS_SADIST auto ;Sneak Adjusting Detection Instigating Script Trigger
HotandSweatyBABES property HnS_BABES auto ;Background Atmospherics Bright Evironment Sensor

HotandSweatyLoad property HnS_Load Hidden
	HotandSweatyLoad function Get()
		return self.GetAliasByName("PlayerAlias") as HotandSweatyLoad
	endFunction
endProperty

LeveledItem property HnS_insertLIDeo auto
LeveledItem property HnS_insertLISpl auto
LeveledItem property HnS_insertLIScrl auto
LeveledItem property HnS_LitemDeodorant auto
LeveledItem property HnS_LitemSpellsSmell auto
LeveledItem property HnS_LitemSpellsHeat auto
LeveledItem property HnS_LitemScrollsSmell auto
LeveledItem property HnS_LitemScrollsHeat auto
LeveledItem property HnS_LitemScrollsMagicka auto

Spell[] property HnS_SpellsToRemove auto
Potion[] property HnS_PotionsToRemove auto
Book[] property HnS_BooksToRemove auto
Scroll[] property HnS_ScrollsToRemove auto
Armor property HnS_CloakofMeridia auto
;Race property HnS_GhostRace auto

GlobalVariable property HnS_AllowSmelling auto ;Permit olfactory perception
GlobalVariable property HnS_AllowHeatSeeking auto ;Authorize perspicuity of thermal radiation
GlobalVariable property HnS_AllowMagickaDetection auto ;License sensing of mystic energies
GlobalVariable property HnS_AllowEnvironmentalBlindness auto ;Instigate amaurosis proportional to both decreased photon count and atmospheric density of aerially suspended liquid and crystallized dihydrogen monoxide particulate matter.
GlobalVariable property HnS_AllowAddToLeveledLists auto

GlobalVariable property HnS_AlertWaitTime auto
GlobalVariable property HnS_AttackedWaitTime auto
GlobalVariable property HnS_AlertedBonus auto

;===Vanilla Properties===
LeveledItem property WIThiefLootSublist auto
LeveledItem property LootSilverHandRandom auto
LeveledItem property LootThalmorRandomWizard auto
LeveledItem property LootCitizenPocketsRich auto
LeveledItem property LItemMiscVendorMiscItems75 auto
LeveledItem property LItemSpellTomes25Illusion auto
LeveledItem property LItemSpellTomes25AllIllusion auto
LeveledItem property LItemScroll75Skill auto

ObjectReference property HnS_SmellObjectsEnableParent auto ;Enable parent of Smell related object references.
ObjectReference property HnS_HeatVisionObjectsEnableParent auto ;Enable parent of Heat Vision related object references.
ObjectReference property HnS_MagickaDetectionObjectsEnableParent auto ;Enable parent of Magicka Detection related object references.
ObjectReference property HnS_PlayerCellPollerRef auto ;Cell Poller Reference, also acts as enable parent of any remaining object references.

Actor property PlayerRef auto

float[] property CycleVariableValues auto
string[] property CycleFloatVariableNames auto
;Following is the list of Variable Names:
;"HnS_Vision"
;"HnS_BrigthnessMod"
;"HnS_VisualMovementMod"
;"HnS_VisualRunningMod"
;"HnS_Hearing"
;"HnS_LoudnessMod"
;"HnS_AuditoryMovementMod"
;"HnS_AuditoryRunningMod"
;"HnS_ViewCone"
;"HnS_DetectionDistance"
;"HnS_BlindnessThreshold"
;"HnS_BlindnessThresholdNE"
;"HnS_LightBlindnessMod"
;"HnS_LightBlindnessModNE"
;"HnS_Reverb"
;"HnS_Vision_D"
;"HnS_BrigthnessMod_D"
;"HnS_VisualMovementMod_D"
;"HnS_VisualRunningMod_D"
;"HnS_Hearing_D"
;"HnS_LoudnessMod_D"
;"HnS_AuditoryMovementMod_D"
;"HnS_AuditoryRunningMod_D"
;"HnS_ViewCone_D"
;"HnS_DetectionDistance_D"
;"HnS_BlindnessThreshold_D"
;"HnS_BlindnessThresholdNE_D"
;"HnS_LightBlindnessMod_D"
;"HnS_LightBlindnessModNE_D"
;"HnS_DayPhaseStart"
;"HnS_DayPhaseEnd"
;"HnS_NightPhaseStart"
;"HnS_NightPhaseEnd"

float OriginalAlertTime
float OriginalAttackedTime
float OriginalEventTime
float OriginalLostTime

bool RunOnce

event OnInit()
	InitializeStorage()
	if !RunOnce
		InsertLeveledLists()
		SaveOriginalSettings()
		RunOnce = true
	endIf
	if isRunning()
		RegisterForModEvent("HnS_Ended", "onHnSEnded")
	endIf
endEvent

function OnLoadInitialize()
	RegisterForModEvent("HnS_Ended", "onHnSEnded")
endFunction

function InitializeStorage()
	Debug.Trace("Hot and Sweaty, Initializing Racial Ability Lists...")
	FormListCopy(none, "HnS_IgnoredModdedRaces", IgnoredModdedRaces)
	FormListCopy(none, "HnS_EnviroBlindnessImmuneRaces", EnviroBlindnessImmuneRaces)
	FormListCopy(none, "HnS_NightVisionRaces", NightVisionRaces)
	FormListCopy(none, "HnS_NoSmellRaces", NoSmellRaces)
	FormListCopy(none, "HnS_SmellyUnLivingRaces", SmellyUnLivingRaces)
	FormListCopy(none, "HnS_SmellTierNPCRaces", SmellTierNPCRaces)
	;FormListCopy(none, "HnS_SmellNPCExceptionRaces", SmellNPCExceptionRaces)
	FormListCopy(none, "HnS_SmellTier1Races", SmellTier1Races)
	FormListCopy(none, "HnS_SmellTier2Races", SmellTier2Races)
	FormListCopy(none, "HnS_SmellTier3Races", SmellTier3Races)
	FormListCopy(none, "HnS_SmellTier4Races", SmellTier4Races)
	;FormListCopy(none, "HnS_ThermalVisionRaces", ThermalVisionRaces)
	FormListCopy(none, "HnS_NoThermalVisionUndeadRaces", NoThermalVisionUndeadRaces)
	FormListCopy(none, "HnS_MagickaDetectionRaces", MagickaDetectionRaces)
	;FormListCopy(none, "HnS_NoMagickaDetectionDwarvenRaces", NoMagickaDetectionDwarvenRaces)
	FormListCopy(none, "HnS_FoggyWeather", FoggyWeather)
	FormListCopy(none, "HnS_SevereWeather", SevereWeather)
	FormListCopy(none, "HnS_StandardInteriorWorldspaces", StandardInteriorWorldspaces)
	FormListCopy(none, "HnS_LargeCityWorldspaces", LargeCityWorldspaces)
	
	FormListCopy(none, "HnS_ValidKeyWordList", ValidKeyWordList)
	
	SetFloatValue(none,"HnS_WeatherVisualMod", 1.0)
	SetFloatValue(none,"HnS_WeatherSoundMod", 1.0)
	
	int CycleKeyNumber = 0
	int CycleVariableNumber = 0
	while CycleKeyNumber < ValidKeyWordList.Length
		SetStringValue(ValidKeyWordList[CycleKeyNumber], "HnS_CycleType", KeyWordCycleTypeStringList[CycleKeyNumber])
		SetIntValue(ValidKeyWordList[CycleKeyNumber], "HnS_KeyWordPriority", KeyWordPriorityIntList[CycleKeyNumber])
		
		while CycleVariableNumber < CycleFloatVariableNames.length
			SetFloatValue(ValidKeyWordList[CycleKeyNumber], CycleFloatVariableNames[CycleVariableNumber], CycleVariableValues[CycleKeyNumber*CycleFloatVariableNames.length + CycleVariableNumber])
			CycleVariableNumber += 1
		endWhile
		
		CycleVariableNumber = 0
		CycleKeyNumber +=1
	endWhile
	Debug.Trace("Hot and Sweaty, Initialization Complete.")
endFunction

event OnUpdateGameTime() ;Uninstall Event
	Wait(0.1)
	self.Stop()
	Debug.MessageBox("Hot and Sweaty has completely been removed.")
endEvent

event onHnSStarted()
	;Placeholder
endEvent

event onHnSEnded(bool abRemoveItemsandSpells)
	if abRemoveItemsandSpells
		int ItemAndSpellCounter
		int numberInInventory
		while ItemAndSpellCounter < HnS_SpellsToRemove.Length
			if PlayerRef.HasSpell(HnS_SpellsToRemove[ItemAndSpellCounter])
				PlayerRef.RemoveSpell(HnS_SpellsToRemove[ItemAndSpellCounter])
			endIf
			ItemAndSpellCounter +=1
		endWhile
		numberInInventory = PlayerRef.GetItemCount(HnS_CloakofMeridia)
		if numberInInventory > 0
			PlayerRef.RemoveItem(HnS_CloakofMeridia, numberInInventory, true)
		endIf
		ItemAndSpellCounter = 0
		while ItemAndSpellCounter < HnS_BooksToRemove.Length
			numberInInventory = PlayerRef.GetItemCount(HnS_BooksToRemove[ItemAndSpellCounter])
			if numberInInventory > 0
				PlayerRef.RemoveItem(HnS_BooksToRemove[ItemAndSpellCounter], numberInInventory, true)
			endIf
			ItemAndSpellCounter +=1
		endWhile
		ItemAndSpellCounter = 0
		while ItemAndSpellCounter < HnS_PotionsToRemove.Length
			numberInInventory = PlayerRef.GetItemCount(HnS_PotionsToRemove[ItemAndSpellCounter])
			if numberInInventory > 0
				PlayerRef.RemoveItem(HnS_PotionsToRemove[ItemAndSpellCounter], numberInInventory, true)
			endIf
			ItemAndSpellCounter +=1
		endWhile
		ItemAndSpellCounter = 0
		while ItemAndSpellCounter < HnS_ScrollsToRemove.Length
			numberInInventory = PlayerRef.GetItemCount(HnS_ScrollsToRemove[ItemAndSpellCounter])
			if numberInInventory > 0
				PlayerRef.RemoveItem(HnS_ScrollsToRemove[ItemAndSpellCounter], numberInInventory, true)
			endIf
			ItemAndSpellCounter +=1
		endWhile
	endIf
	ClearAllPrefix("HnS_")
	Wait(0.01)
	Debug.MessageBox("Please Move to an unpopulated indoor location alone and wait one in-game day to make sure no scripts are running.")
	RegisterForSingleUpdateGameTime(24.0)
endEvent

function SaveOriginalSettings()
	OriginalAlertTime = GetGameSettingFloat("fCombatStealthPointRegenAlertWaitTime")
	OriginalAttackedTime = GetGameSettingFloat("fCombatStealthPointRegenAttackedWaitTime")
	OriginalEventTime = GetGameSettingFloat("fCombatStealthPointRegenDetectedEventWaitTime")
	OriginalLostTime = GetGameSettingFloat("fCombatStealthPointRegenLostWaitTime")
endFunction

function ResetSneakWaitSettings()
	SetGameSettingFloat("fCombatStealthPointRegenAlertWaitTime", OriginalAlertTime)
	SetGameSettingFloat("fCombatStealthPointRegenAttackedWaitTime", OriginalAttackedTime)
	SetGameSettingFloat("fCombatStealthPointRegenDetectedEventWaitTime", OriginalEventTime)
	SetGameSettingFloat("fCombatStealthPointRegenLostWaitTime", OriginalLostTime)
	HotandSweatyGAMS.SkyTweakUpdate(self)
endFunction

function InsertLeveledLists()
	WIThiefLootSublist.AddForm(HnS_insertLIDeo, 1, 1)
	LootSilverHandRandom.AddForm(HnS_insertLIDeo, 1, 1)
	LootThalmorRandomWizard.AddForm(HnS_insertLIDeo, 1, 1)
	LootCitizenPocketsRich.AddForm(HnS_insertLIDeo, 1, 1)
	LItemMiscVendorMiscItems75.AddForm(HnS_insertLIDeo, 1, 1)
	LItemSpellTomes25Illusion.AddForm(HnS_insertLISpl, 1, 1) ;Should I make the tomes less common?
	LItemSpellTomes25AllIllusion.AddForm(HnS_insertLISpl, 1, 1) ;or not?
	LItemScroll75Skill.AddForm(HnS_insertLIScrl, 1, 1) ;*Make scrolls for the greater powers
endFunction

function RevertLeveledLists()
	HnS_insertLIDeo.Revert()
	HnS_insertLISpl.Revert()
	HnS_insertLIScrl.Revert()
	HnS_SmellObjectsEnableParent.DisableNoWait()
	HnS_HeatVisionObjectsEnableParent.DisableNoWait()
	HnS_MagickaDetectionObjectsEnableParent.DisableNoWait()
	Debug.Trace("Leveled Lists Emptied")
endFunction

function SADISTCheck()
	;Placeholder function
endFunction

function BOOBSCHeck()
	;Placeholder function
endFunction

function BDSMCheck()
	;Placeholder function
endFunction

function TITSCheck()
	;Placeholder function
endFunction

function DAMESCheck()
	;Placeholder function
endFunction

function LeveledListsCheck()
	;Placeholder function
endFunction

function AddToLeveledLists()
	;Placeholder function
endFunction

function LongerSneakWait()
	;Placeholder function
endFunction

state Active
	event OnBeginState()
		((self as Quest) as HotandSweatyConditions).HotAndSweatyActive = 2
		HnS_PlayerCellPollerRef.EnableNoWait()
		if HnS_AllowAddToLeveledLists.GetValue()
			AddToLeveledLists()
		endIf
		LongerSneakWait()
		;Debug.Notification("$HnS_StartingUpText")
		RegisterForSingleUpdate(0.1)
	endEvent
	
	event OnEndState()
		((self as Quest) as HotandSweatyConditions).HotAndSweatyActive = 1
		SendModEvent("HnS_MCMBoolUpdate", "", 1.0)
		HnS_Load.ToggleState()
		Debug.Trace("Hot and Sweaty Un-Loaded.")
		if HnS_AllowMagickaDetection.GetValue()
			HnS_DAMES.Stop()
			Debug.Trace("DAMES Stopped.")
		endIf
		if HnS_AllowHeatSeeking.GetValue()
			HnS_TITS.Stop()
			Debug.Trace("TITS Stopped.")
		endIf
		if HnS_AllowSmelling.GetValue()
			HnS_BDSM.Stop()
			Debug.Trace("BDSM Stopped.")
		endIf
		if HnS_AllowEnvironmentalBlindness.GetValue()
			HnS_BOOBS.Stop()
			Debug.Trace("BOOBS Stopped.")
		endIf
		if HnS_AllowAddToLeveledLists.GetValue()
			RevertLeveledLists()
		endIf
		HnS_SADIST.Stop()
		Debug.Trace("SADIST Stopped.")
		HnS_BABES.RevertStop()
		Debug.Trace("BABES Stopped.")
		ResetSneakWaitSettings()
		HnS_PlayerCellPollerRef.DisableNoWait()
		((self as Quest) as HotandSweatyConditions).HotAndSweatyActive = 0
	endEvent
	
	event onUpdate()
		HnS_BABES.Start()
		Debug.Trace("BABES Started.")
		HnS_SADIST.Start()
		Debug.Trace("SADIST Started.")
		SADISTCheck()
		if HnS_AllowEnvironmentalBlindness.GetValue()
			HnS_BOOBS.Start()
			Debug.Trace("BOOBS Started.")
		endIf
		if HnS_AllowSmelling.GetValue()
			HnS_BDSM.Start()
			Debug.Trace("BDSM Started.")
		endIf
		if HnS_AllowHeatSeeking.GetValue()
			HnS_TITS.Start()
			Debug.Trace("TITS Started.")
		endIf
		if HnS_AllowMagickaDetection.GetValue()
			HnS_DAMES.Start()
			Debug.Trace("DAMES Started.")
		endIf
		HnS_Load.ToggleState()
		Debug.Trace("Hot and Sweaty Loaded.")
		((self as Quest) as HotandSweatyConditions).HotAndSweatyActive = 3
		Debug.Notification("$HnS_IsNowActive")
	endEvent
	
	function SADISTCheck()
		bool DoSADIST = HnS_AlertedBonus.GetValue()
		if HnS_SADIST.hasDetectionBonus() != DoSADIST
			if DoSADIST
				HnS_SADIST.GotoState("")
			else
				HnS_SADIST.GotoState("NoAlertBonus")
			endIf
		endIf
	endFunction
	
	function BOOBSCHeck()
		bool DoBOOBS = HnS_AllowEnvironmentalBlindness.GetValue()
		if HnS_BOOBS.isRunning() != DoBOOBS
			if DoBOOBS
				HnS_BOOBS.Start()
			else
				HnS_BOOBS.Stop()
			endIf
		endIf
	endFunction
	
	function BDSMCheck()
		bool DoBDSM = HnS_AllowSmelling.GetValue()
		if HnS_BDSM.isRunning() != DoBDSM
			if DoBDSM
				HnS_BDSM.Start()
			else
				HnS_BDSM.Stop()
			endIf
		endIf
	endFunction
	
	function TITSCheck()
		bool DoTITS = HnS_AllowHeatSeeking.GetValue()
		if HnS_TITS.isRunning() != DoTITS
			if DoTITS
				HnS_TITS.Start()
			else
				HnS_TITS.Stop()
			endIf
		endIf
	endFunction
	
	function DAMESCheck()
		bool DoDAMES = HnS_AllowMagickaDetection.GetValue()
		if HnS_DAMES.isRunning() != DoDAMES
			if DoDAMES
				HnS_DAMES.Start()
			else
				HnS_DAMES.Stop()
			endIf
		endIf
	endFunction
	
	function LeveledListsCheck()
		if HnS_AllowAddToLeveledLists.GetValue()
			RevertLeveledLists()
			AddToLeveledLists()
		else
			RevertLeveledLists()
		endIf
	endFunction
	
	function AddToLeveledLists()
		if HnS_AllowSmelling.GetValue()
			HnS_insertLIDeo.AddForm(HnS_LitemDeodorant, 1, 1)
			HnS_insertLISpl.AddForm(HnS_LitemSpellsSmell, 1, 1)
			HnS_insertLIScrl.AddForm(HnS_LitemScrollsSmell, 1, 1)
			HnS_SmellObjectsEnableParent.EnableNoWait()
		endIf
		if HnS_AllowHeatSeeking.GetValue()
			HnS_insertLISpl.AddForm(HnS_LitemSpellsHeat, 1, 1)
			HnS_insertLIScrl.AddForm(HnS_LitemScrollsHeat, 1, 1)
			HnS_HeatVisionObjectsEnableParent.EnableNoWait()
		endIf
		if HnS_AllowMagickaDetection.GetValue()
			HnS_insertLIScrl.AddForm(HnS_LitemScrollsMagicka, 1, 1)
			HnS_MagickaDetectionObjectsEnableParent.EnableNoWait()
		endIf
		Debug.Trace("Items added to Leveled Lists")
	endFunction
	
	function LongerSneakWait()
		Debug.Trace("Game Sneak Wait Time Set.")
		SetGameSettingFloat("fCombatStealthPointRegenAlertWaitTime", HnS_AlertWaitTime.GetValue())
		SetGameSettingFloat("fCombatStealthPointRegenAttackedWaitTime", HnS_AttackedWaitTime.GetValue())
		SetGameSettingFloat("fCombatStealthPointRegenDetectedEventWaitTime", HnS_AlertWaitTime.GetValue())
		SetGameSettingFloat("fCombatStealthPointRegenLostWaitTime", HnS_AlertWaitTime.GetValue())
		HotandSweatyGAMS.SkyTweakUpdate(self)
	endFunction
	
endState

