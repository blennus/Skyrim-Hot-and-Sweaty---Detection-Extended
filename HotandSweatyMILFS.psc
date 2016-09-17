scriptname HotandSweatyMILFS extends ActiveMagicEffect
;{Matching Illumination Light Finder Script: This script casts a light spell if they are in the dark for a period of time.}

Spell property HnS_CLEAVAGE auto
Actor LitActor

event OnEffectStart(Actor akTarget, Actor akCaster)
	LitActor = akTarget
	RegisterforSingleUpdate(5.0)
endEvent

event OnUpdate()
	HnS_CLEAVAGE.Cast(LitActor)
endEvent

event OnEffectEnd(Actor akTarget, Actor akCaster)
	LitActor = none
endEvent
