scriptname HotandSweatyCLEAVAGE extends ActiveMagicEffect  
;{Character Light Equipping Automated Varying Action Governing Executor: This script equips the appropriate light to the caster}

Form property EquippedLight auto

event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.AddItem(EquippedLight)
	akTarget.EquipItem(EquippedLight, true)
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.UnEquipItem(EquippedLight)
	akTarget.RemoveItem(EquippedLight)
endEvent
