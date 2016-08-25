scriptname HotandSweatyMAIDS extends ActiveMagicEffect  
;{Magicka Allowed Increased and Damage Self: This script reduces the health of the caster by half for the duration of the spell.}

actor MasochisticSpellcaster

event OnEffectStart(Actor akTarget, Actor akCaster)
	SendModEvent("HnS_UpdateMagicAura")
	HurtYourself()
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	SendModEvent("HnS_UpdateMagicAura")
endEvent

event OnUpdate()
	HurtYourself()
endEvent

function HurtYourself()
	if MasochisticSpellcaster.GetActorValuePercentage("Health") > 0.5
		MasochisticSpellcaster.DamageAV("Health", MasochisticSpellcaster.GetActorValue("MaxHealth") * ((MasochisticSpellcaster.GetActorValuePercentage("Health") - 0.5)) + 1)
		Debug.Trace("Heath forcibly lowered to half")
	endIf
	RegisterForSingleUpdate(0.5)
endFunction
