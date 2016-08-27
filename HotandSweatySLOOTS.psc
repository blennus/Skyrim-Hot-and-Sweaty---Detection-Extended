scriptname HotandSweatySLOOTS extends ActiveMagicEffect
;{Smell Level Over Odor Threshold Script: This script handles code when enemies are detectable by smell.}

;HotandSweatyDetectionExtended property HnS auto
Actor property PlayerRef auto
GlobalVariable property HnS_TimeBetweenDetectionChecks auto
GlobalVariable property HnS_StinkyDetectionDistance auto
GlobalVariable property HnS_CurrentDetectionDistance_ReadOnly auto
GlobalVariable property HnS_SmellDistanceModifier auto
GlobalVariable property HnS_AlertedBonus auto
GlobalVariable property HnS_DetectionSuccessTotalThisCycle auto

Actor SmellingActor

event OnEffectStart(Actor akTarget, Actor akCaster)
	SmellingActor = akTarget
	;Debug.Trace("Smelling Applied to " + SmellingActor.GetBaseObject().GetName() + " of Race " + SmellingActor.GetName())
	SmellAround()
endEvent

;event OnEffectFinish(Actor akTarget, Actor akCaster)
;	Debug.Trace(SmellingActor.GetBaseObject().GetName() + " of Race " + SmellingActor.GetName() + " is not longer smelling.")
;endEvent

event OnUpdate()
	SmellAround()
endEvent

function SmellAround()
	float HowCloseTothePlayersArmpits = 2.0 * (HnS_StinkyDetectionDistance.GetValue() - SmellingActor.GetDistance(PlayerRef)) / HnS_CurrentDetectionDistance_ReadOnly.GetValue()
	float DetectionLevel = PapyrusUtil.ClampFloat(HowCloseTothePlayersArmpits, 0.0, 4.0)
	if DetectionLevel > 0.0
		if SmellingActor.GetActorValue("Confidence") > 0.0
			if SmellingActor.GetCombatState() == 0
				SmellingActor.CreateDetectionEvent(PlayerRef, 1)
			endIf
			HnS_DetectionSuccessTotalThisCycle.Mod(DetectionLevel * HnS_AlertedBonus.GetValue())
			Debug.Trace(SmellingActor.GetName() + " of Race " + SmellingActor.GetRace().GetName() + " smelled the player for " + DetectionLevel + " points")
		else
			SmellingActor.StartCombat(PlayerRef)
		endIf
	endIf
	RegisterForSingleUpdate(HnS_TimeBetweenDetectionChecks.GetValue())
endFunction
