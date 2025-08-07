Scriptname Runtime:IntervalEffectBaseScript extends Runtime:EffectBaseScript


Bool Property CheckRadiation = False Auto Const
Bool Property CheckSprinting = False Auto Const


Bool InRadiation = False


Bool Function ExecuteEffect()
    return False
EndFunction


Bool Function Roll()
    If CheckRadiation
        If !InRadiation
            return False
        Else
            InRadiation = False
            RegisterForRadiationDamageEvent(GetActorReference())
        EndIf
    EndIf
    If CheckSprinting
        If !(GetActorReference().IsSprinting() || (GetActorReference().IsInPowerArmor() && GetActorReference().IsRunning()))
            return False
        EndIf
    EndIf
    return Parent.Roll()
EndFunction


Event OnInit()
    Parent.OnInit()

    If CheckRadiation
        RegisterForRadiationDamageEvent(GetActorReference())
    EndIf

    StartTimer(Utility.RandomFloat(0.0, TimerInterval), 1)
EndEvent


Event OnTimer(Int timerId)
    If Roll()
        If ExecuteEffect()
            DecrementCount()
            ShowExecuteMessage()
            UpdatePerks()
        EndIf
    EndIf

    StartTimer(TimerInterval, timerId)
EndEvent


Event OnRadiationDamage(ObjectReference akTarget, bool abIngested)
    If !abIngested
        InRadiation = True
    EndIf
EndEvent
