Scriptname Loot:OnKillScript extends Runtime:OnKillEffectBaseScript


Form Property Loot Auto Const Mandatory
FormList Property Races Auto Const
FormList Property ExcludeKeywords Auto Const


Bool Function ExecuteEffect(Var[] args = None)
    Actor victim = args[1] as Actor

    If !Races || Races.HasForm(victim.GetRace())
        If !ExcludeKeywords || !victim.HasKeywordInFormList(ExcludeKeywords)
            victim.AddItem(Loot)
            return True
        EndIf
    EndIf

    return False
EndFunction
