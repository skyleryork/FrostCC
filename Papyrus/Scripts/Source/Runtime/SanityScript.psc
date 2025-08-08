Scriptname Runtime:SanityScript extends ReferenceAlias


Perk Property aaSanityPerkInsane Auto Const Mandatory
Perk Property TemporaryInsanityPerk Auto Const Mandatory
ActorValue Property aaSanity Auto Mandatory
ActorValue Property TemporaryInsanity Auto Mandatory
Message Property aaInsaneWarning_Message Auto Const Mandatory
Message Property aaSaneWarning_Message Auto Const Mandatory


Int SanityTimerId = 1 Const
Float SanityTimerInterval = 1.0 Const


Event OnInit()
    StartTimer(SanityTimerInterval, SanityTimerId)
EndEvent


Event OnTimer(Int timerId)
    Actor player = GetActorReference()
    If player
        Int currentSanityTier = 0
        If player.HasPerk(TemporaryInsanityPerk)
            currentSanityTier = 2
        ElseIf player.HasPerk(aaSanityPerkInsane)
            currentSanityTier = 1
        EndIf

        Int newSanityTier = 0
        If player.GetValue(TemporaryInsanity) <= 0
            newSanityTier = 2
        ElseIf player.GetValue(aaSanity) <= 0
            newSanityTier = 1
        EndIf

        If newSanityTier >= 2 && !player.HasPerk(TemporaryInsanityPerk)
            player.AddPerk(TemporaryInsanityPerk, False)
        ElseIf !newSanityTier && player.HasPerk(TemporaryInsanityPerk)
            player.RemovePerk(TemporaryInsanityPerk)
        EndIf

        If newSanityTier >= 1 && !player.HasPerk(aaSanityPerkInsane)
            player.AddPerk(aaSanityPerkInsane, False)
        ElseIf !newSanityTier && player.HasPerk(aaSanityPerkInsane)
            player.RemovePerk(aaSanityPerkInsane)
        EndIf

        If newSanityTier && !currentSanityTier
            aaInsaneWarning_Message.Show()
        ElseIf !newSanityTier && currentSanityTier
            aaSaneWarning_Message.Show()
        EndIf
    EndIf

    StartTimer(SanityTimerInterval, SanityTimerId)
EndEvent
