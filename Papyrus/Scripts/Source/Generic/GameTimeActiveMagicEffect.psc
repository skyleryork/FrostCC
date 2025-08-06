Scriptname Generic:GameTimeActiveMagicEffect extends ActiveMagicEffect


Float Property Duration Auto Const Mandatory


Function DoEffectStart(Actor akTarget, Actor akCaster)
    StartTimerGameTime(Duration, 1)
EndFunction


Function DoTimer(Int timerId)
    Self.Dispel()
EndFunction


Event OnEffectStart(Actor akTarget, Actor akCaster)
    DoEffectStart(akTarget, akCaster)
EndEvent


Event OnTimer(Int timerId)
    DoTimer(timerId)
EndEvent
