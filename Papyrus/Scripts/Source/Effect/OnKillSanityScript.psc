Scriptname Effect:OnKillSanityScript extends OnKillBaseScript


Spell Property OnKillSanityEffect Auto Const Mandatory
FormList Property OnKillActorValues Auto Const Mandatory


Runtime:RPGScript:ApplyResult Function OnKilled(Actor player, Actor victim, Int rank)
    Int i = 0
    While i < OnKillActorValues.GetSize()
        If player.GetValue(OnKillActorValues.GetAt(i) as ActorValue) <= 0
            return None
        EndIf
        i += 1
    EndWhile

    If !OnKillRaces || OnKillRaces.HasForm(victim.GetRace())
        If !OnKillExcludeKeywords || !victim.HasKeywordInFormList(OnKillExcludeKeywords)
            OnKillSanityEffect.Cast(player)
            return new Runtime:RPGScript:ApplyResult
        EndIf
    EndIf

    return None
EndFunction
