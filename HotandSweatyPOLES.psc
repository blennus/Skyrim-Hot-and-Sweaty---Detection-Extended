scriptname HotandSweatyPOLES extends ActiveMagicEffect
;{Poling On Location Event Script: Calls the event that updates sneak settings when the player moves to a distant location / cell}

Actor property PlayerRef auto
ObjectReference property HnS_PlayerCellPollerRef auto

event OnEffectStart(Actor akTarget, Actor akCaster)
	;Debug.Trace("Player is " + PlayerRef.GetDistance(HnS_PlayerCellPollerRef) + " units away from the Poller")
	HnS_PlayerCellPollerRef.MoveTo(PlayerRef)
	SendModEvent("HnS_UpdateSneakGlobals")
EndEvent
