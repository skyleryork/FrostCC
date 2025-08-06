Scriptname Generic:GameTimeActiveMagicEffect extends ActiveMagicEffect


Float Property Duration Auto Const Mandatory
Float Property Interval = 1.0 Auto Const


Float endHour = 0.0


Function DoEffectStart(Actor akTarget, Actor akCaster)
    endHour = Utility.GetCurrentGameTime() + Duration
    StartTimer(Interval, 1)
EndFunction


Function DoTimer(Int timerId)
    If Utility.GetCurrentGameTime() >= endHour
        Self.Dispel()
    Else
        StartTimer(Interval, 1)
    EndIf
EndFunction


Event OnEffectStart(Actor akTarget, Actor akCaster)
    DoEffectStart(akTarget, akCaster)
EndEvent


Event OnTimer(Int timerId)
    DoTimer(timerId)
EndEvent
