Scriptname Loot:OnKillScript extends OnKillBaseScript


Form Property OnKillLoot Auto Const Mandatory


Runtime:RPGScript:ApplyResult Function OnKilled(Actor player, Actor victim, Int rank)
    If !OnKillRaces || OnKillRaces.HasForm(victim.GetRace())
        If !OnKillExcludeKeywords || !victim.HasKeywordInFormList(OnKillExcludeKeywords)
            victim.AddItem(OnKillLoot)
            return new Runtime:RPGScript:ApplyResult
        EndIf
    EndIf

    return None
EndFunction
