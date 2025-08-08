Scriptname Generic:GameTimeActiveMagicEffect extends ActiveMagicEffect


Float Property DurationDays Auto Const Mandatory


Event OnEffectStart(Actor akTarget, Actor akCaster)
    StartTimerGameTime(DurationDays * 24.0, 1)
EndEvent


Event OnTimer(Int timerId)
    If timerId == 1
        Self.Dispel()
    EndIf
EndEvent
