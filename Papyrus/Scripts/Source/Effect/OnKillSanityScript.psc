Scriptname Effect:OnKillSanityScript extends OnKillBaseScript


Spell Property OnKillSanityEffect Auto Const Mandatory
FormList Property OnKillActorValues Auto Const Mandatory


Event RPGRuntimeScript.OnKilled(RPGRuntimeScript ref, Var[] args)
    If (args[0] as ScriptObject) != Self
        return
    EndIf

    Actor player = args[1] as Actor
    Actor victim = args[2] as Actor

    Int i = 0
    While i < OnKillActorValues.GetSize()
        If player.GetValue(OnKillActorValues.GetAt(i) as ActorValue) <= 0
            ref.OnApplyResult(Self, False)
            return
        EndIf
        i += 1
    EndWhile

    If !OnKillRaces || OnKillRaces.HasForm(victim.GetRace())
        If !OnKillExcludeKeywords || !victim.HasKeywordInFormList(OnKillExcludeKeywords)
            OnKillSanityEffect.Cast(player)
            ref.OnApplyResult(Self, True)
            return
        EndIf
    EndIf

    ref.OnApplyResult(Self, False)
EndEvent
