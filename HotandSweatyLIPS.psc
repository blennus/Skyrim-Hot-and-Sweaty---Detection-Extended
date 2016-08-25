scriptname HotandSweatyLIPS extends ActiveMagicEffect
;{Light Inhibition Permission Signal: Applies Blindness Effect to valid actors.}

Faction property HnS_BlindnessFaction auto
int property BlindnessLevel auto

event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.SetFactionRank(HnS_BlindnessFaction, BlindnessLevel)
endEvent
