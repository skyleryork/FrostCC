Scriptname Quests:IntervalEffectBaseScript extends Quests:EffectBaseScript


Bool Property CheckRadiation = False Auto Const
Bool Property CheckSprinting = False Auto Const


Bool InRadiation = False


Bool Function Roll()
    If CheckRadiation
        If !InRadiation
            return False
        Else
            InRadiation = False
            RegisterForRadiationDamageEvent(GetPlayer())
        EndIf
    EndIf
    If CheckSprinting
        If !(GetPlayer().IsSprinting() || (GetPlayer().IsInPowerArmor() && GetPlayer().IsRunning()))
            return False
        EndIf
    EndIf
    return Parent.Roll()
EndFunction


Event OnQuestInit()
    Parent.OnQuestInit()
    If CheckRadiation
        RegisterForRadiationDamageEvent(GetPlayer())
    EndIf
    StartTimer(Utility.RandomFloat(0.0, TimerInterval), 1)
EndEvent


Event OnTimer(Int timerId)
    Parent.OnTimer(timerId)
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
    Parent.OnRadiationDamage(akTarget, abIngested)
    If !abIngested
        InRadiation = True
    EndIf
EndEvent
