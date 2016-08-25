scriptname HotandSweatyBUST extends ActiveMagicEffect  
;{Background Universal Setting Trigger: This script sends a detection threshold changed event}

string[] property EventToSend auto
bool property EndEffectEventActivation auto

float CurrentMagnitude

event OnEffectStart(Actor akTarget, Actor akCaster)
	SendUpdateSpecialEvent(akTarget)
	CurrentMagnitude = GetMagnitude()
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	if EndEffectEventActivation
		Utility.Wait(CurrentMagnitude)
		SendUpdateSpecialEvent(akTarget)
	endIf
endEvent

function SendUpdateSpecialEvent(Actor akTarget)
	int EventNumCounter = 0
	int handle
	while EventNumCounter < EventToSend.Length
		;Debug.Trace("Sending Event: " + EventToSend[EventNumCounter])
		akTarget.SendModEvent(EventToSend[EventNumCounter])
		EventNumCounter += 1
	endWhile
endFunction
