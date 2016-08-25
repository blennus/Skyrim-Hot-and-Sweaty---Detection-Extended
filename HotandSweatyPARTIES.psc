scriptname HotandSweatyPARTIES extends ActiveMagicEffect
;{Perception Ability Regulating Trigger Integrator Event Script: This script Adds and Removes proper detection ability effects on event.}

import Utility
import MiscUtil
import StorageUtil
import PapyrusUtil

;=======================Hot and Sweaty Properties============================
;HotandSweatyGSTRInG property HnS_GSTRInG auto
;GlobalVariable property HnS_AllowSmelling auto ;Permit olfactory perception
;GlobalVariable property HnS_AllowHeatSeeking auto ;Authorize perspicuity of thermal radiation
;GlobalVariable property HnS_AllowMagickaDetection auto ;License sensing of mystic energies
;GlobalVariable property HnS_AllowEnvironmentalBlindness auto ;Instigate amaurosis proportional to both decreased photon count and atmospheric density of aerially suspended liquid and crystallized dihydrogen monoxide particulate matter.
;GlobalVariable property HnS_AllowNightVision auto ;Grant nocturnal optic enhancement
Race property HnS_GhostRace auto
;Race property HnS_FreshZombieRace auto
MagicEffect property HnS_ReAR_Ef auto
Spell property HnS_PARTIES auto
Faction property HnS_BlindnessFaction auto
Spell[] property ListOfSpellsToApply auto

;===========================PARTIES Variables================================
Form[] CurrentRacialAbilities
Actor DetectingActor
Race DetectingActorRace
string MyMCMUpdateEventName
string CurrentNameStringforDebugging
string TargetRaceName

;===========================Vanilla Properties===============================
Spell property GhostResistsAbility auto
Faction property TG09NightingaleEnemyFaction auto
Keyword property Vampire auto
Keyword property ActorTypeUndead auto
Keyword property ActorTypeDwarven auto
Keyword property ActorTypeNPC auto
;Keyword property MagicSummonUndead auto
Actor property PlayerRef auto

event OnEffectStart(Actor akTarget, Actor akCaster)
	DetectingActor = akTarget
	FormListAdd(none, "HnS_DetectingNPCs", DetectingActor, false)
	WaitMenuMode(0.1)
	if DetectingActor.HasSpell(GhostResistsAbility) || DetectingActor.IsInFaction(TG09NightingaleEnemyFaction)
		GotoState("IseeDeadPeople")
		DetectingActorRace = HnS_GhostRace
	;elseIf DetectingActor.HasMagicEffectWithKeyword(MagicSummonUndead)
	;	GotoState("IseeDeadPeople")
	;	DetectingActorRace = HnS_FreshZombieRace
	else
		DetectingActorRace = DetectingActor.GetRace()
	endIf
	DetectingActor.SetFactionRank(HnS_BlindnessFaction, -1)
	TargetRaceName = DetectingActorRace.GetName()
	CurrentNameStringforDebugging = DetectingActor.GetBaseObject().GetName() + " of Race " + TargetRaceName
	MyMCMUpdateEventName = "HnS_MCMRaceUpdate" + GetRaceEditorID(DetectingActorRace)
	RegisterForModEvent(MyMCMUpdateEventName, "onMCMRaceUpdate")
	RegisterForModEvent("HnS_MCMLoadUpdate", "onMCMRaceUpdate")
	RegisterForModEvent("HnS_Ended", "onHnSEnded")
	Debug.Trace(CurrentNameStringforDebugging + " now has PARTIES.")
	ApplyForAbilityUpdate()
	RegisterForSingleUpdateGameTime(24.0) ;this spell will auto expire in approx 1 hour 12 minutes irl, if at vanilla timescale. Just in case.
endEvent

function ApplyForAbilityUpdate()
	if !(FormListHas(none, "HnS_ProcessedRaces", DetectingActorRace) || FormListHas(none, "HnS_ProcessingRaces", DetectingActorRace))
		FormListAdd(none, "HnS_ProcessingRaces", DetectingActorRace, false)
		Debug.Trace("First time to meet race " + TargetRaceName + ". Creating Spell List.")
		determineRacialAbilities()
		FormListAdd(none, "HnS_ProcessedRaces", DetectingActorRace, false)
		FormListRemove(none, "HnS_ProcessingRaces", DetectingActorRace, true)
	else
		int overflow
		while !FormListHas(none, "HnS_ProcessedRaces", DetectingActorRace) && overflow < 32
			WaitMenuMode(0.25)
			overflow +=1
		endWhile
		if overflow >= 32
			FormListRemove(none, "HnS_ProcessingRaces", DetectingActorRace, true)
			Debug.Trace("Race never finished processing. Aborting and removing spell.")
			DetectingActor.RemoveSpell(HnS_PARTIES)
			return
		endIf
	endIf
	 AddRacialAbilities()
endFunction

function determineRacialAbilities()
	FormListClear(DetectingActorRace, "HnS_RacialAbilities") ;Clear abilities, in case it's a recalculation
	bool isUndead = DetectingActorRace.HasKeyWord(ActorTypeUndead)
	bool isVampire = DetectingActorRace.HasKeyWord(Vampire)
	bool isDwarvenConstruct = DetectingActorRace.HasKeyWord(ActorTypeDwarven)
	
	if !FormListHas(none, "HnS_NoSmellRaces", DetectingActorRace) && (!(isUndead || isDwarvenConstruct) || FormListHas(none, "HnS_SmellyUnLivingRaces", DetectingActorRace))
		;If Smelling ability is ON, and NOT a Non-smelling race, and isn't an undead or Dwarven Construct OR if it is such a race, it's allowed to smell, then give it a smell ability.
		if FormListHas(none, "HnS_SmellTier4Races", DetectingActorRace)
			FormListAdd(DetectingActorRace, "HnS_RacialAbilities", ListOfSpellsToApply[9], false)
			Debug.Trace(TargetRaceName + " can Smell at level: 4")
		elseIf FormListHas(none, "HnS_SmellTier3Races", DetectingActorRace)
			FormListAdd(DetectingActorRace, "HnS_RacialAbilities", ListOfSpellsToApply[8], false)
			Debug.Trace(TargetRaceName + " can Smell at level: 3")
		elseIf FormListHas(none, "HnS_SmellTier2Races", DetectingActorRace)
			FormListAdd(DetectingActorRace, "HnS_RacialAbilities", ListOfSpellsToApply[7], false)
			Debug.Trace(TargetRaceName + " can Smell at level: 2")
		elseIf FormListHas(none, "HnS_SmellTier1Races", DetectingActorRace)
			FormListAdd(DetectingActorRace, "HnS_RacialAbilities", ListOfSpellsToApply[6], false)
			Debug.Trace(TargetRaceName + " can Smell at level: 1")
		elseIf FormListHas(none, "HnS_SmellNPCExceptionRaces", DetectingActorRace) || !(DetectingActorRace.HasKeyWord(ActorTypeNPC) || FormListHas(none, "HnS_SmellTierNPCRaces", DetectingActorRace))
			FormListAdd(DetectingActorRace, "HnS_RacialAbilities", ListOfSpellsToApply[5], false)
			Debug.Trace(TargetRaceName + " can Smell at level: 0")
		else
			FormListAdd(DetectingActorRace, "HnS_RacialAbilities", ListOfSpellsToApply[4], false)
			Debug.Trace(TargetRaceName + " can Smell as an NPC")
		endIf
	endIf
	
	bool TargetHasHeatVision = (FormListHas(none, "HnS_ThermalVisionRaces", DetectingActorRace) || ((isUndead || isVampire) && !FormListHas(none, "HnS_NoThermalVisionUndeadRaces", DetectingActorRace)))
	if TargetHasHeatVision
		FormListAdd(DetectingActorRace, "HnS_RacialAbilities", ListOfSpellsToApply[10], false)
		Debug.Trace(TargetRaceName + " has Heat Vision.")
	endIf
	
	if (FormListHas(none, "HnS_MagickaDetectionRaces", DetectingActorRace) || (isDwarvenConstruct && !FormListHas(none, "HnS_NoMagickaDetectionDwarvenRaces", DetectingActorRace)))
		FormListAdd(DetectingActorRace, "HnS_RacialAbilities", ListOfSpellsToApply[11], false)
		Debug.Trace(TargetRaceName + " has Magicka Detection.")
	endIf
	
	if !FormListHas(none, "HnS_EnviroBlindnessImmuneRaces", DetectingActorRace)
		bool TargetHasNightVision = FormListHas(none, "HnS_NightVisionRaces", DetectingActorRace)
		int BlindnessIndex = 2 * (TargetHasHeatVision as int) + (TargetHasNightVision as int)
		FormListAdd(DetectingActorRace, "HnS_RacialAbilities", ListOfSpellsToApply[BlindnessIndex], false)
		Debug.Trace(TargetRaceName + " can be blinded at level: " + BlindnessIndex)
	endIf
endFunction

function RemoveRacialAbilities()
	Debug.Trace("Racial abilities removed for " + CurrentNameStringforDebugging)
	int SpellRemoveCounter
	while SpellRemoveCounter < CurrentRacialAbilities.Length
		DetectingActor.RemoveSpell(CurrentRacialAbilities[SpellRemoveCounter] as Spell)
		SpellRemoveCounter +=1
	endWhile
endFunction

function AddRacialAbilities()
	Debug.Trace("Adding Racial Abilities for " + CurrentNameStringforDebugging)
	if FormListCount(DetectingActorRace, "HnS_RacialAbilities") > 0
		CurrentRacialAbilities = FormListToArray(DetectingActorRace, "HnS_RacialAbilities")
		int SpellAddCounter = 0
		while SpellAddCounter < CurrentRacialAbilities.Length
			DetectingActor.AddSpell(CurrentRacialAbilities[SpellAddCounter] as Spell)
			SpellAddCounter +=1
		endWhile
	endIf
endFunction

event OnUpdateGameTime()
	Debug.Trace("Spell Expired on: " + CurrentNameStringforDebugging)
	DetectingActor.RemoveSpell(HnS_PARTIES)
endEvent

event OnCellDetach()
	Debug.Trace(CurrentNameStringforDebugging + " is Out of Range!")
	DetectingActor.RemoveSpell(HnS_PARTIES)
endEvent

event OnDetachedFromCell()
	Debug.Trace(CurrentNameStringforDebugging + " is Out of Range!")
	DetectingActor.RemoveSpell(HnS_PARTIES)
endEvent

event OnDying(Actor akKiller)
	Debug.Trace(CurrentNameStringforDebugging + " is dead.")
	DetectingActor.RemoveSpell(HnS_PARTIES)
endEvent

event onHnSEnded()
	Debug.Trace("Hot and Sweaty Uninstalled. Removing abilities from all actors.")
	DetectingActor.RemoveSpell(HnS_PARTIES)
endEvent

event OnRaceSwitchComplete()
	Race NewRace = DetectingActor.GetRace()
	Debug.Trace(CurrentNameStringforDebugging + " has switched races to: " + NewRace.GetName())
	UnregisterForModEvent(MyMCMUpdateEventName)
	RemoveRacialAbilities()
	DetectingActorRace = NewRace
	MyMCMUpdateEventName = "HnS_MCMRaceUpdate" + GetRaceEditorID(DetectingActorRace)
	RegisterForModEvent(MyMCMUpdateEventName, "onMCMRaceUpdate")
	ApplyForAbilityUpdate()
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	RemoveRacialAbilities()
	DetectingActor.RemoveFromFaction(HnS_BlindnessFaction)
	FormListRemove(none, "HnS_DetectingNPCs", DetectingActor, true)
	DetectingActor = none
	DetectingActorRace = none
endEvent

event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
	if akEffect == HnS_ReAR_Ef
		RegisterForModEvent(MyMCMUpdateEventName, "onMCMRaceUpdate")
		RegisterForModEvent("HnS_MCMLoadUpdate", "onMCMRaceUpdate")
		RegisterForModEvent("HnS_Ended", "onHnSEnded")
		Debug.Trace("Reregistered for MCM update event Successfully!")
	endIf
endEvent

event onMCMRaceUpdate(string eventName, string strArg, float RemoveOnly, Form sender)
	WaitMenuMode(RandomFloat(0.0,1.0))
	RemoveRacialAbilities()
	if RemoveOnly
		DetectingActor.RemoveSpell(HnS_PARTIES)
		Debug.Trace(CurrentNameStringforDebugging + " is now ignored. Removing Abilities.")
	else
		ApplyForAbilityUpdate()
		Debug.Trace("Reset abilities for " + CurrentNameStringforDebugging)
	endIf
endEvent

state IseeDeadPeople
	event OnRaceSwitchComplete()
		
	endEvent
	
endState
