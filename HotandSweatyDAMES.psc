scriptname HotandSweatyDAMES extends Quest
;{Determining Allowed Magicka Event Script: Sets global Magicka threshold to trigger Magicka Detection on endowed NPCs.}

;Hot and Sweaty Properties
Keyword property HnS_MagicManaCloak auto

;Vanilla Properties
Actor property PlayerRef auto
MagicEffect property VoiceMakeEthereal auto

;Background Setting
GlobalVariable property HnS_MagickaIgnored auto
GlobalVariable property HnS_MagickaReductionPercent auto

;Threshold Settings
GlobalVariable property HnS_HiddenMagickaAmount auto

event OnInit()
	if self.IsRunning()
		RegisterForModEvent("HnS_UpdateMagicAura", "OnMagicUpdated")
		SendModEvent("HnS_UpdateMagicAura")
	endIf
endEvent

function OnLoadInitialize()
	RegisterForModEvent("HnS_UpdateMagicAura", "OnMagicUpdated")
endFunction

event OnMagicUpdated(string eventName, string strArg, float numArg, Form sender)
	float HiddenMagickaAmount = HnS_MagickaIgnored.GetValue()
	if PlayerRef.HasMagicEffectWithKeyword(HnS_MagicManaCloak)
		HiddenMagickaAmount /= HnS_MagickaReductionPercent.GetValue()
	endIf
	
	if PlayerRef.HasMagicEffect(VoiceMakeEthereal)
		HiddenMagickaAmount /= 2.0
	endIf
	Debug.Trace("HiddenMagickaAmount: " + HiddenMagickaAmount)
	HnS_HiddenMagickaAmount.SetValue(HiddenMagickaAmount)
endEvent
