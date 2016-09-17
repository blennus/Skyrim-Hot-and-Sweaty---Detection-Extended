scriptname HotandSweatyMEAT extends ActiveMagicEffect
;{Magicka Exceeds Allowed Threshold: This script handles code when enemies are detectable by Magicka.}

;HotandSweatyDetectionExtended property HnS auto
Actor property PlayerRef auto
GlobalVariable property HnS_TimeBetweenDetectionChecks auto
GlobalVariable property HnS_HiddenMagickaAmount auto
GlobalVariable property HnS_MagickaIgnored auto
GlobalVariable property HnS_MagickaReductionPercent auto
GlobalVariable property HnS_AlertedBonus auto
GlobalVariable property HnS_DetectionSuccessTotalThisCycle auto
Keyword property HnS_MagicManaCloak auto

Actor MagicSensingActor

event OnEffectStart(Actor akTarget, Actor akCaster)
	MagicSensingActor = akTarget
	SenseMagicka()
endEvent

;event OnEffectFinish(Actor akTarget, Actor akCaster)
;	Debug.Trace(MagicSensingActor.GetBaseObject().GetName() + " of Race " + MagicSensingActor.GetName() + " is not longer sensing magicka.")
;endEvent

event OnUpdate()
	SenseMagicka()
endEvent

function SenseMagicka()
	float MagickaExuded= (PlayerRef.GetActorValue("Magicka") - HnS_HiddenMagickaAmount.GetValue()) / HnS_HiddenMagickaAmount.GetValue()
	if !PlayerRef.HasMagicEffectWithKeyword(HnS_MagicManaCloak)
		MagickaExuded *= 2.5 * HnS_MagickaReductionPercent.GetValue()
	endIf
	float DetectionLevel = PapyrusUtil.ClampFloat(MagickaExuded, 0.0, 4.0)
	if DetectionLevel > 0.0
		if MagicSensingActor.GetActorValue("Confidence") > 0.0
			if MagicSensingActor.GetCombatState() == 0 && MagicSensingActor.GetDistance(PlayerRef) < 2500.0
				MagicSensingActor.CreateDetectionEvent(PlayerRef, 1)
			endIf
			HnS_DetectionSuccessTotalThisCycle.Mod(DetectionLevel * HnS_AlertedBonus.GetValue())
			Debug.Trace(MagicSensingActor.GetName() + " of Race " + MagicSensingActor.GetRace().GetName() + " felt Magicka for " + (DetectionLevel) + " points")
		else
			MagicSensingActor.StartCombat(PlayerRef)
		endIf
	endIf
	RegisterForSingleUpdate(HnS_TimeBetweenDetectionChecks.GetValue())
endFunction
