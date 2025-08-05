Scriptname Loot:OnKillScript extends OnKillBaseScript


Form Property OnKillLoot Auto Const Mandatory


Event Runtime:RPGScript.OnKilled(Runtime:RPGScript ref, Var[] args)
    If !Runtime:RPGScript.ShouldHandleEvent(Self, args)
        return
    EndIf

    Actor victim = args[2] as Actor

    If !OnKillRaces || OnKillRaces.HasForm(victim.GetRace())
        If !OnKillExcludeKeywords || !victim.HasKeywordInFormList(OnKillExcludeKeywords)
            victim.AddItem(OnKillLoot)
            ref.OnApplyResult(Self, True)
            return
        EndIf
    EndIf

    ref.OnApplyResult(Self, False)
EndEvent
