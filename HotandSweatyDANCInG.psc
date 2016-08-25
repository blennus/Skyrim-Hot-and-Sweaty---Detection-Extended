scriptname HotandSweatyDANCInG extends ActiveMagicEffect
;{Detection Activated Normal Call Instigation Governor: This script sends and On detection event}

GlobalVariable property HnS_AlertedBonus auto
GlobalVariable property HnS_DetectionSuccessTotalThisCycle auto

event OnEffectStart(Actor akTarget, Actor akCaster)
	HnS_DetectionSuccessTotalThisCycle.Mod(HnS_AlertedBonus.GetValue())
endEvent

;event OnEffectFinish(Actor akTarget, Actor akCaster)
;	Debug.Trace("You are no longer being detected by " + akTarget.GetBaseObject().GetName())
;endEvent
