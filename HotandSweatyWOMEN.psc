scriptname HotandSweatyWOMEN extends ActiveMagicEffect
;{Warmth Over Minimum Energy Needed: This script handles code when enemies are detectable by heat.}

Actor property PlayerRef auto
GlobalVariable property HnS_TimeBetweenDetectionChecks auto
GlobalVariable property HnS_HeatDetectionTemperature auto
GlobalVariable property FrostfallCurrentTemperatureReadOnly auto
GlobalVariable property HnS_AlertedBonus auto
GlobalVariable property HnS_DetectionSuccessTotalThisCycle auto

Actor WarmthSeekingActor

event OnEffectStart(Actor akTarget, Actor akCaster)
	WarmthSeekingActor = akTarget
	SeeWarmth()
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	Debug.Trace(WarmthSeekingActor.GetBaseObject().GetName() + " of Race " + WarmthSeekingActor.GetName() + " is not longer detecting warmth.")
endEvent

event OnUpdate()
	SeeWarmth()
endEvent

function SeeWarmth()
	float SneakDifference = WarmthSeekingActor.GetActorValue("Sneak")
	if PlayerRef.IsSneaking()
		SneakDifference -= PlayerRef.GetActorValue("Sneak")
	endIf
	SneakDifference = PapyrusUtil.ClampFloat(SneakDifference / 5.0, -5.0, 5.0)
	float TemperatureDifference = (HnS_HeatDetectionTemperature.GetValue() - FrostfallCurrentTemperatureReadOnly.GetValue() + SneakDifference) / 15.0
	float DetectionLevel = PapyrusUtil.ClampFloat(TemperatureDifference, 0.0, 4.0)
	if DetectionLevel > 0.0
		if WarmthSeekingActor.GetActorValue("Confidence") > 0.0
			if WarmthSeekingActor.GetCombatState() == 0
				WarmthSeekingActor.CreateDetectionEvent(PlayerRef, 1)
			endIf
			HnS_DetectionSuccessTotalThisCycle.Mod(DetectionLevel * HnS_AlertedBonus.GetValue())
			Debug.Trace("Players heat detected for " + DetectionLevel + " points.")
		elseIf WarmthSeekingActor.IsHostileToActor(PlayerRef)
			WarmthSeekingActor.StartCombat(PlayerRef)
		endIf
	endIf
	RegisterForSingleUpdate(HnS_TimeBetweenDetectionChecks.GetValue())
endFunction
