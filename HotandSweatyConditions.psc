scriptname HotandSweatyConditions extends Quest conditional

int property HotAndSweatyActive auto conditional hidden

;float property WeatherVisualMod = 1.0 auto hidden
;float property WeatherSoundMod = 1.0 auto hidden

bool property DawnguardLoaded auto conditional hidden
bool property HearthfiresLoaded auto conditional hidden
bool property DragonBornLoaded auto conditional hidden
bool property MzinBathingInSkyrimLoaded auto conditional hidden
bool property FrostfallLoaded auto conditional hidden
bool property HidespotsLoaded auto conditional hidden

;Dawnguard
WorldSpace property DLC01SoulCairn auto hidden
WorldSpace property DLC01Boneyard auto hidden
Weather property DLC1Eclipse auto hidden

;Dragonborn
Weather property DLC02VolcanicAshStorm01 auto hidden
WorldSpace property DLC2ApocryphaWorld auto hidden

;Frostfall Properties
GlobalVariable property FrostfallRunning auto hidden
GlobalVariable property _Frost_Calc_MaxWarmth auto hidden
GlobalVariable property _Frost_Calc_MaxCoverage auto hidden

;Bathing in Skyrim
float property CurrentDirtinessPercentage auto conditional hidden
GlobalVariable property mzinDirtinessPercentage auto hidden
Spell property mzinSoapBonusDragonsTongueSpell auto hidden
Spell property mzinSoapBonusFlowerRBPSpell auto hidden
Spell property mzinSoapBonusFlowerBlueSpell auto hidden
Spell property mzinSoapBonusFlowerRedSpell auto hidden
Spell property mzinSoapBonusFlowerPurpleSpell auto hidden
Spell property mzinSoapBonusFlowerLavenderSpell auto hidden
Spell property mzinSoapBonusDwemerSpell auto hidden

;Hidespots
MagicEffect property JZBai_InvisibilityEffect auto hidden
