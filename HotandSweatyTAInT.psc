scriptname HotandSweatyTAInT extends ActiveMagicEffect
;{Trigger Applier Instituting Trigger: This script applies the "Perception Ability Regulating Trigger Script" Ability to surrounding actors on contact}
 
Spell Property HnS_PARTIES Auto

event OnEffectStart(Actor akTarget, Actor akCaster)
	if !StorageUtil.FormListHas(none, "HnS_IgnoredModdedRaces", akTarget.GetRace())
		akTarget.AddSpell(HnS_PARTIES)
	endIf
endEvent
