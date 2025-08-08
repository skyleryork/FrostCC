Scriptname Quests:OnKillEffectBaseScript extends Quests:EffectBaseScript


Event OnQuestInit()
    Parent.OnQuestInit()
    RegisterForRemoteEvent(GetPlayer(), "OnKill")
EndEvent


Event Actor.OnKill(Actor akSender, Actor akVictim)
    If Roll()
        Var[] args = new Var[2]
        args[0] = akSender
        args[1] = akVictim
        If ExecuteEffect(args)
            DecrementCount()
            ShowExecuteMessage()
            UpdatePerks()
        EndIf
    EndIf
EndEvent
