Scriptname Effect:OnKillSanityScript extends Runtime:OnKillEffectBaseScript


Spell Property SanityEffect Auto Const Mandatory
FormList Property ActorValues Auto Const Mandatory
FormList Property Races Auto Const
FormList Property ExcludeKeywords Auto Const


Bool Function ExecuteEffect(Var[] args = None)
    Actor victim = args[1] as Actor

    Int i = 0
    While i < ActorValues.GetSize()
        If GetActorReference().GetValue(ActorValues.GetAt(i) as ActorValue) <= 0
            return False
        EndIf
        i += 1
    EndWhile

    If !Races || Races.HasForm(victim.GetRace())
        If !ExcludeKeywords || !victim.HasKeywordInFormList(ExcludeKeywords)
            SanityEffect.Cast(GetActorReference())
            return True
        EndIf
    EndIf

    return False
EndFunction
