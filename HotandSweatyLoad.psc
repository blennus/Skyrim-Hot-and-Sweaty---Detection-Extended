scriptname HotandSweatyLoad extends ReferenceAlias
;{This script handles the following: On load compatibility and giving the script applying cloak spell to the PlayerRef}

import Game
import Math
import StorageUtil

;=====Vanilla Properties=====
GlobalVariable property TimeScale auto
Actor property PlayerRef Auto

;=====Hot and Sweaty Properties=====
HotandSweatyBUTTS property HnS_BUTTS auto
HotandSweatyConditions property HnS_Conditions auto
HotandSweatyBOOBS property HnS_BOOBS auto ;Blinded Object Outcome Brightness Selector
HotandSweatyBDSM property HnS_BDSM auto ;Background Dirtiness Smell Manager
HotandSweatyTITS property HnS_TITS auto ;Temperature Interface Tracking Script
HotandSweatyDAMES property HnS_DAMES auto ;Determining Allowed Magicka Event Script
HotandSweatySADIST  property HnS_SADIST auto ;Sneak Adjusting Detection Instigating Script Trigger
HotandSweatyBABES property HnS_BABES auto ;Background Atmospherics Bright Evironment Sensor
GlobalVariable property HnS_AllowHeatSeeking auto ;Authorize perspicuity of thermal radiation
Spell property HnS_TAInT_ApplyingCloakAb Auto
Spell property HnS_BUST_Ab Auto
Spell property HnS_ReAR_Sp Auto
ConstructibleObject property HnS_RecipeZeolite1 auto
ConstructibleObject property HnS_RecipeZeolite2 auto
ConstructibleObject property HnS_RecipeDeodorant auto
ConstructibleObject property HnS_RecipeDeodorantXL auto
Potion property HnS_Zeolite auto
Potion property HnS_ZeoliteDLC2 auto

bool AnimallicaLoaded
bool MoonpathLoaded
bool WyrmstoothLoaded
bool FamiliarFacesLoaded
bool DeadlyDragonsLoaded
bool BetterVampiresLoaded
bool climatesOfTamrielLoaded
bool vividWeathersLoaded

;==============================Empty State===============================

event OnInit()
	
endEvent

event OnPlayerLoadGame()
	RunCompatibility()
	if HnS_BUTTS.isRunning()
		HnS_BUTTS.OnLoadInitialize()
		HnS_ReAR_Sp.Cast(PlayerRef)
	endIf
	if HnS_BOOBS.isRunning()
		HnS_BOOBS.OnLoadInitialize()
	endIf
	if HnS_BDSM.isRunning()
		HnS_BDSM.OnLoadInitialize()
	endIf
	if HnS_TITS.isRunning()
		HnS_TITS.OnLoadInitialize()
	endIf
	if HnS_DAMES.isRunning()
		HnS_DAMES.OnLoadInitialize()
	endIf
	if HnS_SADIST.isRunning()
		HnS_SADIST.OnLoadInitialize()
	endIf
	if HnS_BABES.isRunning()
		HnS_BABES.OnLoadInitialize()
	endIf
	RegisterForModEvent("Frostfall_Loaded", "onFrostfallLoaded")
	RegisterForSingleUpdate(0.1)
endEvent

event OnUpdate()
	if !PlayerRef.HasSpell(HnS_TAInT_ApplyingCloakAb)
		PlayerRef.AddSpell(HnS_TAInT_ApplyingCloakAb, false)
		Utility.Wait(1.0)
		PlayerRef.RemoveSpell(HnS_TAInT_ApplyingCloakAb)
	endIf
	RegisterForSingleUpdate(5.0)
endEvent

event onFrostfallLoaded()
	
endEvent

event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	
endEvent

event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	
endEvent

function ToggleState()
	GotoState("inActive")
endFunction

function StateValidation()
	Debug.trace("State Validation - Activated")
	string CorrectState = DetermineActiveState()
	if CorrectState != GetState()
		GotoState(CorrectState)
	endIf
endFunction

string function DetermineActiveState()
	if (HnS_Conditions.FrostfallLoaded && HnS_Conditions.FrostfallRunning.GetValue() == 2.0) || !HnS_AllowHeatSeeking.GetValue()
		return ""
	else
		return "ActiveNoFrostfall"
	endIf
endFunction

;==============================ActiveNoFrostfall State==============================

bool FrostFallLoadedWhileProcessing

state ActiveNoFrostfall
	
	event onFrostfallLoaded()
		GotoState("")
	endEvent
	
	event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		if (akBaseObject as Armor)
			GotoState("Processing")
			Utility.WaitGameTime(TimeScale.GetValue()/7200.0)
			SendModEvent("HnS_UpdateRadiantHeat")
			if FrostFallLoadedWhileProcessing
				GotoState("")
				FrostFallLoadedWhileProcessing = false
			else
				GotoState("ActiveNoFrostfall")
			endIf
		endIf
	endEvent
	
	event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		if (akBaseObject as Armor)
			GotoState("Processing")
			Utility.WaitGameTime(TimeScale.GetValue()/7200.0)
			SendModEvent("HnS_UpdateRadiantHeat")
			if FrostFallLoadedWhileProcessing
				GotoState("")
				FrostFallLoadedWhileProcessing = false
			else
				GotoState("ActiveNoFrostfall")
			endIf
		endIf
	endEvent
	
endState

state Processing
	
	event onFrostfallLoaded()
		FrostFallLoadedWhileProcessing = true
	endEvent
	
endState
;==============================inActive State==============================

auto state inActive
	event OnBeginState() ;When made inactive
		PlayerRef.RemoveSpell(HnS_BUST_Ab)
		PlayerRef.RemoveSpell(HnS_TAInT_ApplyingCloakAb)
		UnregisterForUpdate()
		Debug.trace("Removing TAINT and BUST.")
	endEvent
	
	event OnEndState()
		;Debug.trace("HnS Load Started")
		RunCompatibility()
		if !PlayerRef.HasSpell(HnS_BUST_Ab)
			PlayerRef.AddSpell(HnS_BUST_Ab, false)
			Debug.trace("Player now has has BUST.")
		endIf
		RegisterForModEvent("Frostfall_Loaded", "onFrostfallLoaded")
		RegisterForSingleUpdate(0.5)
	endEvent
	
	event OnPlayerLoadGame()
		HnS_BUTTS.OnLoadInitialize()
	endEvent
	
	function ToggleState()
		GotoState(DetermineActiveState())
	endFunction
	
	function StateValidation()
		
	endFunction

	event OnUpdate()
		
	endEvent
	
endState

;==========================Compatibility Function==========================

function RunCompatibility()
	Form CurrentlyAddingRace
	Debug.trace("Running Compatibility Code...")
	
	if HnS_Conditions.DawnguardLoaded
		HnS_Conditions.DawnguardLoaded = (GetModByName("Dawnguard.esm") != 255)
		if !HnS_Conditions.DawnguardLoaded
			;Do if Dawnguard is ever uninstalled mid play-through (not smart but alas...)
			FixAllFormLists()
		endIf
	else
		HnS_Conditions.DawnguardLoaded = (GetModByName("Dawnguard.esm") != 255)
		if HnS_Conditions.DawnguardLoaded
			;Do Once on Loading Dawnguard DLC for the 1st time
			HnS_Conditions.DLC01SoulCairn = GetFormFromFile(0x02001408, "Dawnguard.esm") as WorldSpace
			HnS_Conditions.DLC01Boneyard = GetFormFromFile(0x0200528D, "Dawnguard.esm") as WorldSpace
			HnS_Conditions.DLC1Eclipse = GetFormFromFile(0x02006AEC, "Dawnguard.esm") as Weather
			
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02019599, "Dawnguard.esm"), false) ;DLC1FalmerValley_bf
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x020195A0, "Dawnguard.esm"), false) ;DLC1FalmerValley_bfDark
			FormListAdd(none, "HnS_IgnoredModdedRaces", GetFormFromFile(0x0200528D, "Dawnguard.esm"), false) ;DLC1SoulCairnSoulWispRace
			FormListAdd(none, "HnS_SmellTier1Races", GetFormFromFile(0x02003D01, "Dawnguard.esm"), false) ;DLC1HuskyArmoredCompanionRace "Dog"
			CurrentlyAddingRace = GetFormFromFile(0x02003D02, "Dawnguard.esm") ;DLC1DeathHoundCompanionRace "Deathhound"
			FormListAdd(none, "HnS_SmellyUnLivingRaces", CurrentlyAddingRace, false)
			FormListAdd(none, "HnS_SmellTier1Races", CurrentlyAddingRace, false)
			CurrentlyAddingRace = GetFormFromFile(0x0200C5F0, "Dawnguard.esm") ;DLC1DeathHoundRace "Dog"
			FormListAdd(none, "HnS_SmellyUnLivingRaces", CurrentlyAddingRace, false)
			FormListAdd(none, "HnS_SmellTier1Races", CurrentlyAddingRace, false)
			FormListAdd(none, "HnS_SmellTier2Races", GetFormFromFile(0x0200D0B2, "Dawnguard.esm"), false) ;DLC1DeerGlowRace "Deer"
			FormListAdd(none, "HnS_NightVisionRaces", GetFormFromFile(0x0200D0B6, "Dawnguard.esm"), false) ;DLC1SabreCatGlowRace "Sabre Cat"
			FormListAdd(none, "HnS_SmellTier1Races", GetFormFromFile(0x020122B7, "Dawnguard.esm"), false) ;DLC1HuskyBareCompanionRace "Dog"
			FormListAdd(none, "HnS_SmellTier1Races", GetFormFromFile(0x02018B33, "Dawnguard.esm"), false) ;DLC1HuskyArmoredRace "Dog"
			FormListAdd(none, "HnS_SmellTier1Races", GetFormFromFile(0x02018B36, "Dawnguard.esm"), false) ;DLC1HuskyBareRace "Dog"
			CurrentlyAddingRace = GetFormFromFile(0x0201AACC, "Dawnguard.esm") ;FalmerFrozenVampRace "Frozen Falmer"
			FormListAdd(none, "HnS_EnviroBlindnessImmuneRaces", CurrentlyAddingRace, false)
			FormListAdd(none, "HnS_SmellTier4Races", CurrentlyAddingRace, false)
			Debug.trace("The Dawnguard is Hot and Sweaty...")
		endIf
	endIf
	
	if HnS_Conditions.HearthfiresLoaded
		HnS_Conditions.HearthfiresLoaded = (GetModByName("HearthFires.esm") != 255)
		if HnS_Conditions.HearthfiresLoaded
			OnLoadHearthfire()
		endIf
	else
		HnS_Conditions.HearthfiresLoaded = (GetModByName("HearthFires.esm") != 255)
		;Do Once on Loading Hearthfires DLC for the 1st time
		if HnS_Conditions.HearthfiresLoaded
			OnLoadHearthfire()
			Debug.trace("The Hearth-fire is Hot and Sweaty...")
		endIf
	endIf
	
	if HnS_Conditions.DragonBornLoaded
		HnS_Conditions.DragonBornLoaded = (GetModByName("Dragonborn.esm") != 255)
		if HnS_Conditions.DragonBornLoaded
			OnLoadDragonborn()
		else
			;Do if Dragonborn is ever uninstalled mid play-through
			int numberOfDLC2Zeolite = PlayerRef.GetItemCount(HnS_ZeoliteDLC2)
			PlayerRef.RemoveItem(HnS_ZeoliteDLC2, numberOfDLC2Zeolite, true)
			PlayerRef.AddItem(HnS_Zeolite, numberOfDLC2Zeolite, true)
			FixAllFormLists()
		endIf
	else
		HnS_Conditions.DragonBornLoaded = (GetModByName("Dragonborn.esm") != 255)
		if HnS_Conditions.DragonBornLoaded
			;Do Once on Loading Dragonborn DLC for the 1st time
			HnS_Conditions.DLC2ApocryphaWorld = GetFormFromFile(0x0201C0B2, "Dragonborn.esm") as WorldSpace
			HnS_Conditions.DLC02VolcanicAshStorm01 = GetFormFromFile(0x02032336, "Dragonborn.esm") as Weather
			FormListAdd(none, "HnS_SevereWeather", HnS_Conditions.DLC02VolcanicAshStorm01, false)
			FormListAdd(none, "HnS_IgnoredModdedRaces", GetFormFromFile(0x02029EFC, "Dragonborn.esm"), false)
			FormListAdd(none, "HnS_NoSmellRaces", GetFormFromFile(0x02014449, "Dragonborn.esm"), false) ;DLC2ExpSpiderBaseRace "Frostbite Spider"
			FormListAdd(none, "HnS_NoSmellRaces", GetFormFromFile(0x0201B637, "Dragonborn.esm"), false) ;DLC2AshSpawnRace "Draugr"
			FormListAdd(none, "HnS_NoSmellRaces", GetFormFromFile(0x0201B647, "Dragonborn.esm"), false) ;DLC2MudcrabSolstheimRace "MudCrab"
			FormListAdd(none, "HnS_NoSmellRaces", GetFormFromFile(0x0201B658, "Dragonborn.esm"), false) ;DLC2AshHopperRace "Scrib"
			FormListAdd(none, "HnS_SmellTier3Races", GetFormFromFile(0x0201E17B, "Dragonborn.esm"), false) ;DLC2WerebearBeastRace "Werewolf"
			FormListAdd(none, "HnS_NoSmellRaces", GetFormFromFile(0x02027483, "Dragonborn.esm"), false) ;DLC2ExpSpiderPackmuleRace "Frostbite Spider"
			FormListAdd(none, "HnS_NoSmellRaces", GetFormFromFile(0x02027BFC, "Dragonborn.esm"), false) ;dlc2AshGuardianRace "Storm Atronach"
			OnLoadDragonborn()
			int numberOfZeolite = PlayerRef.GetItemCount(HnS_Zeolite)
			PlayerRef.RemoveItem(HnS_Zeolite, numberOfZeolite, true)
			PlayerRef.AddItem(HnS_ZeoliteDLC2, numberOfZeolite, true)
			Debug.trace("The first Dragonborn is Hot and Sweaty...")
		endIf
	endIf
	
	if HnS_Conditions.FrostfallLoaded
		HnS_Conditions.FrostfallLoaded = (GetModByName("Frostfall.esp") != 255)
		if !HnS_Conditions.FrostfallLoaded
			StateValidation()
			SendModEvent("HnS_UpdateRadiantHeat")
		endIf
	else
		HnS_Conditions.FrostfallLoaded = (GetModByName("Frostfall.esp") != 255)
		if HnS_Conditions.FrostfallLoaded
			HnS_Conditions.FrostfallRunning = GetFormFromFile(0x0206DCFB, "Frostfall.esp") as GlobalVariable
			HnS_Conditions._Frost_Calc_MaxWarmth = GetFormFromFile(0x02068110, "Frostfall.esp") as GlobalVariable
			HnS_Conditions._Frost_Calc_MaxCoverage = GetFormFromFile(0x02068111, "Frostfall.esp") as GlobalVariable
			StateValidation()
			Debug.trace("Frostfall is Hot and Sweaty...")
		endIf
	endIf
	
	if HnS_Conditions.MzinBathingInSkyrimLoaded
		HnS_Conditions.MzinBathingInSkyrimLoaded = (GetModByName("Bathing in Skyrim - Main.esp") != 255)
		if HnS_Conditions.MzinBathingInSkyrimLoaded
			(GetFormFromFile(0x0200E565, "Bathing in Skyrim - Main.esp") as Spell).SetNthEffectMagnitude( 1, 0)
			(GetFormFromFile(0x0202BAC3, "Bathing in Skyrim - Main.esp") as Spell).SetNthEffectMagnitude( 1, 0)
		else
			HnS_BDSM.GotoState("")
			SendModEvent("HnS_UpdateSmelliness")
		endIf
	else
		HnS_Conditions.MzinBathingInSkyrimLoaded = (GetModByName("Bathing in Skyrim - Main.esp") != 255)
		if HnS_Conditions.MzinBathingInSkyrimLoaded
			HnS_Conditions.mzinDirtinessPercentage = GetFormFromFile(0x02000DA8, "Bathing in Skyrim - Main.esp") as GlobalVariable
			HnS_Conditions.mzinSoapBonusDragonsTongueSpell = GetFormFromFile(0x02000D7D, "Bathing in Skyrim - Main.esp") as Spell
			HnS_Conditions.mzinSoapBonusFlowerBlueSpell = GetFormFromFile(0x02000D7F, "Bathing in Skyrim - Main.esp") as Spell
			HnS_Conditions.mzinSoapBonusFlowerPurpleSpell = GetFormFromFile(0x02000D81, "Bathing in Skyrim - Main.esp") as Spell
			HnS_Conditions.mzinSoapBonusFlowerRBPSpell = GetFormFromFile(0x02000D83, "Bathing in Skyrim - Main.esp") as Spell
			HnS_Conditions.mzinSoapBonusFlowerRedSpell = GetFormFromFile(0x02000D85, "Bathing in Skyrim - Main.esp") as Spell
			HnS_Conditions.mzinSoapBonusDwemerSpell = GetFormFromFile(0x02000D87, "Bathing in Skyrim - Main.esp") as Spell
			HnS_Conditions.mzinSoapBonusFlowerLavenderSpell = GetFormFromFile(0x02000D89, "Bathing in Skyrim - Main.esp") as Spell
			(GetFormFromFile(0x0200E565, "Bathing in Skyrim - Main.esp") as Spell).SetNthEffectMagnitude( 1, 0)
			(GetFormFromFile(0x0202BAC3, "Bathing in Skyrim - Main.esp") as Spell).SetNthEffectMagnitude( 1, 0)
			HnS_BDSM.GotoState("BathingInSkyrimLoaded")
			SendModEvent("HnS_UpdateSmelliness")
			Debug.trace("Bathing in Skyrim is Hot and Sweaty...")
		endIf
	endIf	
	
	if HnS_Conditions.HidespotsLoaded
		HnS_Conditions.HidespotsLoaded = (GetModByName("JZBai_Hidespots.esp") != 255)
	else
		HnS_Conditions.HidespotsLoaded = (GetModByName("JZBai_Hidespots.esp") != 255)
		if HnS_Conditions.HidespotsLoaded
			HnS_Conditions.JZBai_InvisibilityEffect = GetFormFromFile(0x02005360, "JZBai_Hidespots.esp") as MagicEffect
			Debug.trace("Hidespots are Hot and Sweaty...")
		endIf
	endIf
	
	if AnimallicaLoaded
		AnimallicaLoaded = (GetModByName("Animallica.esp") != 255)
		if !AnimallicaLoaded
			FixAllFormLists()
		endIf
	else
		AnimallicaLoaded = (GetModByName("Animallica.esp") != 255)
		if AnimallicaLoaded
			FormListAdd(none, "HnS_NightVisionRaces", GetFormFromFile(0x02000D64, "Animallica.esp"), false) ;Tiger
			FormListAdd(none, "HnS_NightVisionRaces", GetFormFromFile(0x020012E0, "Animallica.esp"), false) ;Panther
			FormListAdd(none, "HnS_NightVisionRaces", GetFormFromFile(0x020055CD, "Animallica.esp"), false) ;Lion
			FormListAdd(none, "HnS_NightVisionRaces", GetFormFromFile(0x0200CCC1, "Animallica.esp"), false) ;Raccoon
			FormListAdd(none, "HnS_NightVisionRaces", GetFormFromFile(0x0201E7C9, "Animallica.esp"), false) ;Lynx
			FormListAdd(none, "HnS_NightVisionRaces", GetFormFromFile(0x020289F0, "Animallica.esp"), false) ;Cat
			FormListAdd(none, "HnS_SmellTier1Races", GetFormFromFile(0x02001DBF, "Animallica.esp"), false) ;Rhino
			FormListAdd(none, "HnS_SmellTier2Races", GetFormFromFile(0x020055C2, "Animallica.esp"), false) ;Hyena
		endIf
	endIf
	
	if MoonpathLoaded
		MoonpathLoaded = (GetModByName("moonpath.esm") != 255)
		if !MoonpathLoaded
			FixAllFormLists()
		endIf
	else
		MoonpathLoaded = (GetModByName("moonpath.esm") != 255)
		if MoonpathLoaded
			FormListAdd(none, "HnS_NoSmellRaces", GetFormFromFile(0x0202FBE9, "moonpath.esm"), false) ;CentipedeRace "Siligonder"
			FormListAdd(none, "HnS_NightVisionRaces", GetFormFromFile(0x0200E5AA, "moonpath.esm"), false) ;Sabretiger_race "Pahmar"
			FormListAdd(none, "HnS_NightVisionRaces", GetFormFromFile(0x0201F352, "moonpath.esm"), false) ;AnvilPahmarRaceSabretiger "Pahmar Guardian"
			FormListAdd(none, "HnS_SmellTier2Races", GetFormFromFile(0x0202F668, "moonpath.esm"), false) ;HyenaRace "Hyena"
		endIf
	endIf
	
	if WyrmstoothLoaded
		WyrmstoothLoaded = (GetModByName("Wyrmstooth.esp") != 255)
		if !WyrmstoothLoaded
			FormListRemove(none, "HnS_SmellTier1Races", none, true)
		endIf
	else
		WyrmstoothLoaded = (GetModByName("Wyrmstooth.esp") != 255)
		if WyrmstoothLoaded
			FormListAdd(none, "HnS_SmellTier1Races", GetFormFromFile(0x02506C41, "Wyrmstooth.esp"), false) ;WTFaelorWolfRace "Wolf"
		endIf
	endIf
	
	if FamiliarFacesLoaded
		FamiliarFacesLoaded = (GetModByName("vMYC_MeetYourCharacters.esp") != 255)
		if !FamiliarFacesLoaded
			FormListRemove(none, "HnS_IgnoredModdedRaces", none, true)
		endIf
	else
		FamiliarFacesLoaded = (GetModByName("vMYC_MeetYourCharacters.esp") != 255)
		if FamiliarFacesLoaded
			FormListAdd(none, "HnS_IgnoredModdedRaces", GetFormFromFile(0x0200DEAC, "vMYC_MeetYourCharacters.esp"), false) ;vMYC_invisibleRace "Invisible Race"
		endIf
	endIf
	
	if DeadlyDragonsLoaded
		DeadlyDragonsLoaded = (GetModByName("DeadlyDragons.esp") != 255)
		if !DeadlyDragonsLoaded
			FormListRemove(none, "HnS_IgnoredModdedRaces", none, true)
		endIf
	else
		DeadlyDragonsLoaded = (GetModByName("DeadlyDragons.esp") != 255)
		if DeadlyDragonsLoaded
			FormListAdd(none, "HnS_IgnoredModdedRaces", GetFormFromFile(0x0202F04A, "DeadlyDragons.esp"), false) ;nInvisibleRace "Invisible Race"
		endIf
	endIf
	
	;if BetterVampiresLoaded
	;	BetterVampiresLoaded = (GetModByName("Better Vampires.esp") != 255)
	;	if !BetterVampiresLoaded
	;		FormListRemove(none, "HnS_SmellyUnLivingRaces", none, true)
	;	endIf
	;else
	;	BetterVampiresLoaded = (GetModByName("Better Vampires.esp") != 255)
	;	if BetterVampiresLoaded
	;		FormListAdd(none, "HnS_SmellyUnLivingRaces", GetFormFromFile(0x02002F9A, "Better Vampires.esp"), false) ;HighElfRaceVampire2
	;		FormListAdd(none, "HnS_SmellyUnLivingRaces", GetFormFromFile(0x02002F9B, "Better Vampires.esp"), false) ;ImperialRaceVampire2
	;		FormListAdd(none, "HnS_SmellyUnLivingRaces", GetFormFromFile(0x02002F9C, "Better Vampires.esp"), false) ;KhajiitRaceVampire2
	;		FormListAdd(none, "HnS_SmellyUnLivingRaces", GetFormFromFile(0x02002F9D, "Better Vampires.esp"), false) ;OrcRaceVampire2
	;		FormListAdd(none, "HnS_SmellyUnLivingRaces", GetFormFromFile(0x02002F9E, "Better Vampires.esp"), false) ;RedguardRaceVampire2
	;		FormListAdd(none, "HnS_SmellyUnLivingRaces", GetFormFromFile(0x02002F9F, "Better Vampires.esp"), false) ;WoodElfRaceVampire2
	;		FormListAdd(none, "HnS_SmellyUnLivingRaces", GetFormFromFile(0x021F0604, "Better Vampires.esp"), false) ;NordRaceVampire2
	;		FormListAdd(none, "HnS_SmellyUnLivingRaces", GetFormFromFile(0x021F0605, "Better Vampires.esp"), false) ;ArgonianRaceVampire2
	;		FormListAdd(none, "HnS_SmellyUnLivingRaces", GetFormFromFile(0x021F0606, "Better Vampires.esp"), false) ;BretonRaceVampire2
	;		FormListAdd(none, "HnS_SmellyUnLivingRaces", GetFormFromFile(0x021F0607, "Better Vampires.esp"), false) ;DarkElfRaceVampire2
	;	endIf
	;endIf
	;The above Vampiric races are only ever used on the player, and as such do not need to be added...
	;except in the very rare case where the player character who has Vampirism advanced enough
	;to have MortalsMask is made into an enemy using the Familiar Faces mod.
	;Still the case is rare enough that if that ever does happen, the player themselves can add the ability to smell to that vampire.
	
	if climatesOfTamrielLoaded
		climatesOfTamrielLoaded = (GetModByName("ClimatesOfTamriel.esm") != 255)
		if !climatesOfTamrielLoaded
			FormListRemove(none, "HnS_FoggyWeather", none, true)
			FormListRemove(none, "HnS_SevereWeather", none, true)
		endIf
	else
		climatesOfTamrielLoaded = (GetModByName("ClimatesOfTamriel.esm") != 255)
		if climatesOfTamrielLoaded
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02044831, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02044832, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02044834, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02044836, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02044838, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0204483A, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02047E31, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0206497D, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02068A17, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02068A18, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02068A1A, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0206C559, "ClimatesOfTamriel.esm"), false)
			
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02045868, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0204586A, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0204586C, "ClimatesOfTamriel.esm"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02047E2E, "ClimatesOfTamriel.esm"), false)
			
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02045869, "ClimatesOfTamriel.esm"), false) ;Partially Foggy?
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0204586D, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0204586E, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02045870, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02045871, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02045872, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02045873, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02047E2F, "ClimatesOfTamriel.esm"), false)
			
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0204586B, "ClimatesOfTamriel.esm"), false) ;Dark, and thunderous but not actually foggy
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0204586F, "ClimatesOfTamriel.esm"), false)
			
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02053567, "ClimatesOfTamriel.esm"), false)  ;Dark Partially Foggy?
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02053568, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02053569, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0205356A, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0205356B, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0205356C, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0205356D, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0205356E, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0205356F, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02053570, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02053571, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02053572, "ClimatesOfTamriel.esm"), false)
			;FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02053573, "ClimatesOfTamriel.esm"), false) ;Blowing Leaves foggy?
			Debug.trace("The Climates of Tamriel are Hot and Sweaty...")
		endIf
	endIf
	
	if vividWeathersLoaded
		vividWeathersLoaded = (GetModByName("ClimatesOfTamriel.esm") != 255)
		if !vividWeathersLoaded
			FormListRemove(none, "HnS_FoggyWeather", none, true)
			FormListRemove(none, "HnS_SevereWeather", none, true)
		endIf
	else
		vividWeathersLoaded = (GetModByName("ClimatesOfTamriel.esm") != 255)
		if vividWeathersLoaded
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0212DDE6, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0212DDE7, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0212DDE8, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0212DDE9, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0212DDEA, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0212DDEB, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0212DDEC, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0212DDED, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0212DDEE, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02167C87, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02167C88, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02167C8A, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02167C8C, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02167C8E, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02167C90, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0216B286, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0216B287, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0216B818, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0216BD7B, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0216BD7C, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x02187DD3, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0218BE6D, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0218BE6E, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0218BE70, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0218F9AF, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0218FDAF, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_SevereWeather", GetFormFromFile(0x0218FDB0, "Vivid Weathers.esp"), false)
			
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02168CC4, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02168CC5, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02168CC6, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02168CC7, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02168CC8, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x02168CC9, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x0216B284, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x021769BD, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x021769BE, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x021769BF, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x021769C6, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x021769C7, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x021769C8, "Vivid Weathers.esp"), false)
			FormListAdd(none, "HnS_FoggyWeather", GetFormFromFile(0x021769C9, "Vivid Weathers.esp"), false)
			
			Debug.trace("Vivid Weathers are Hot and Sweaty...")
		endIf
	endIf
	
endFunction

function OnLoadHearthfire()
	MiscObject BYOHMaterialClay = GetFormFromFile(0x02003043, "HearthFires.esm") as MiscObject ; "Clay"
	MiscObject BYOHMaterialStoneBlock = GetFormFromFile(0x0200306C, "HearthFires.esm") as MiscObject ;"Quarried Stone"
	HnS_RecipeZeolite1.SetNthIngredient(BYOHMaterialClay, 2)
	HnS_RecipeZeolite2.SetNthIngredient(BYOHMaterialClay, 2)
	HnS_RecipeDeodorant.SetNthIngredient(BYOHMaterialStoneBlock, 1)
	HnS_RecipeDeodorantXL.SetNthIngredient(BYOHMaterialStoneBlock, 2)
endFunction

function OnLoadDragonborn()
	HnS_RecipeZeolite2.SetNthIngredient(GetFormFromFile(0x0201CD6D, "Dragonborn.esm"), 1) ;DLC2GhoulAsh "Spawn Ash"
	HnS_RecipeZeolite1.SetResult(HnS_ZeoliteDLC2)
endFunction

function FixAllFormLists()
	FormListRemove(none, "HnS_IgnoredModdedRaces", none, true)
	FormListRemove(none, "HnS_EnviroBlindnessImmuneRaces", none, true)
	FormListRemove(none, "HnS_NightVisionRaces", none, true)
	FormListRemove(none, "HnS_NoSmellRaces", none, true)
	FormListRemove(none, "HnS_SmellyUnLivingRaces", none, true)
	FormListRemove(none, "HnS_SmellTierNPCRaces", none, true)
	FormListRemove(none, "HnS_SmellNPCExceptionRaces", none, true)
	FormListRemove(none, "HnS_SmellTier1Races", none, true)
	FormListRemove(none, "HnS_SmellTier2Races", none, true)
	FormListRemove(none, "HnS_SmellTier3Races", none, true)
	FormListRemove(none, "HnS_SmellTier4Races", none, true)
	FormListRemove(none, "HnS_ThermalVisionRaces", none, true)
	FormListRemove(none, "HnS_NoThermalVisionUndeadRaces", none, true)
	FormListRemove(none, "HnS_MagickaDetectionRaces", none, true)
	FormListRemove(none, "HnS_NoMagickaDetectionDwarvenRaces", none, true)
endFunction
