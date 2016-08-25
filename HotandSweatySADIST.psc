scriptname HotandSweatySADIST extends Quest
;{Sneak Adjusting Detection Instigating Script Trigger: This script Adjusts sneak difficulty and creates detection events when detected by auxillary abilities.}

import HotandSweatyGAMS
import Game
import PapyrusUtil

;Hot and Sweaty Properties
GlobalVariable property HnS_TimeTillDetectionResets auto
GlobalVariable property HnS_TimeBetweenDetectionChecks auto
GlobalVariable property HnS_AlertedBonus auto
GlobalVariable property HnS_SneakBaseValueCeiling auto
GlobalVariable property HnS_DetectionSuccessTotalThisCycle auto ;Sum of total detection events score magnitude per cycle.
GlobalVariable property Hns_DetectionProbability auto

;Vanilla Properties
Actor property PlayerRef auto

;Local Variables
bool RecentlyDetected ;returns true when detection achieved or actor is alert for a period of time.
float CountToDetectionReset ;Duration after last detection
float CurrentSneakBaseValue ;Saved Sneak Base Value so that it can be set to the correct value on reload.
float TimeLastChecked ;The Game Hour the last update occurred. Used to figure out how much time has passed since the last update.

event OnInit()
	SetGameSettingFloat("fSneakBaseValue", -5.0)
	SkyTweakUpdate(self)
	CountToDetectionReset = HnS_TimeTillDetectionResets.GetValue()
	if self.IsRunning()
		RegisterForSingleUpdate(1.0)
	endIf
endEvent

function OnLoadInitialize()
	SetGameSettingFloat("fSneakBaseValue", CurrentSneakBaseValue)
endFunction

function CalculateDetectionProbability()
	int DetectingNPCCount = StorageUtil.FormListCount(none, "HnS_DetectingNPCs")
	float DetectionProbability = ClampInt((1760 - DetectingNPCCount*10)/(DetectingNPCCount + 1), 1, 100)
	Hns_DetectionProbability.SetValue(DetectionProbability)
	Debug.Trace("Detection Probability: " + DetectionProbability)
endFunction

event OnUpdate()
	CalculateDetectionProbability()
	CurrentSneakBaseValue = GetGameSettingFloat("fSneakBaseValue")
	float timeBetweenDetectionChecks = HnS_TimeBetweenDetectionChecks.GetValue()
	float WhatTimeIsItNow = Utility.GetCurrentGameTime() * 24.0
	float AmountofTimePassedSinceLastUpdate = WhatTimeIsItNow - TimeLastChecked
	float DetectionSuccessTotalthisCycle = ClampFloat(Math.Sqrt(HnS_DetectionSuccessTotalThisCycle.GetValue()), 0.0, timeBetweenDetectionChecks*2.0)
	if RecentlyDetected && AmountofTimePassedSinceLastUpdate >= 1.0 && CurrentSneakBaseValue > -5.0
		Debug.Trace("Sneak Base value reset to -5")
		CurrentSneakBaseValue = -5.0
		SetGameSettingFloat("fSneakBaseValue", -5.0)
		SkyTweakUpdate(self)
		CountToDetectionReset = HnS_TimeTillDetectionResets.GetValue()
		HnS_DetectionSuccessTotalThisCycle.SetValue(0.0)
		RecentlyDetected = false
	elseIf DetectionSuccessTotalthisCycle > 0.0
		if DetectionSuccessTotalthisCycle > 1.0
			PlayerRef.CreateDetectionEvent(PlayerRef, (64.0 * (DetectionSuccessTotalthisCycle + 1.0)) as int)
		endIf
		CurrentSneakBaseValue = ClampFloat(CurrentSneakBaseValue + DetectionSuccessTotalthisCycle, -5.0, HnS_SneakBaseValueCeiling.GetValue())
		Debug.Trace("Sneak Base value increased to " + (CurrentSneakBaseValue))
		SetGameSettingFloat("fSneakBaseValue", CurrentSneakBaseValue)
		SkyTweakUpdate(self)
		CountToDetectionReset = HnS_TimeTillDetectionResets.GetValue()
		RecentlyDetected = true
		HnS_DetectionSuccessTotalThisCycle.SetValue(0.0)
	elseIf RecentlyDetected && CountToDetectionReset <= 0
		CurrentSneakBaseValue = ClampFloat(CurrentSneakBaseValue - timeBetweenDetectionChecks, -5.0, HnS_SneakBaseValueCeiling.GetValue())
		Debug.Trace("Sneak Base value decreased to " + CurrentSneakBaseValue)
		SetGameSettingFloat("fSneakBaseValue", CurrentSneakBaseValue)
		SkyTweakUpdate(self)
		if CurrentSneakBaseValue == -5.0
			Debug.Notification("$HnS_EnemyLostyourTrail")
			CountToDetectionReset = HnS_TimeTillDetectionResets.GetValue()
			HnS_DetectionSuccessTotalThisCycle.SetValue(0.0)
			RecentlyDetected = false
		endIf
	elseIf RecentlyDetected
		CountToDetectionReset -= timeBetweenDetectionChecks
	else
		HnS_DetectionSuccessTotalThisCycle.SetValue(0.0)
	endIf
	TimeLastChecked = WhatTimeIsItNow
	RegisterForSingleUpdate(timeBetweenDetectionChecks)
endEvent

bool function hasDetectionBonus()
	return true
endFunction

state NoDetectionBonus
	
	event OnBeginState() ;When made inactive
		RecentlyDetected = false
		CurrentSneakBaseValue = -5.0
		SetGameSettingFloat("fSneakBaseValue", CurrentSneakBaseValue)
		CountToDetectionReset = HnS_TimeTillDetectionResets.GetValue()
		TimeLastChecked = 0.0
	endEvent
	
	function OnLoadInitialize()
		
	endFunction
	
	event OnUpdate()
		CalculateDetectionProbability()
		RegisterForSingleUpdate(HnS_TimeBetweenDetectionChecks.GetValue())
	endEvent
	
	bool function hasDetectionBonus()
		return false
	endFunction
endState
