Scriptname Runtime:SanityScript extends ReferenceAlias

Perk Property aaSanityPerkInsane Auto Const Mandatory
Perk Property TemporaryInsanityPerk Auto Const Mandatory
ActorValue Property aaSanity Auto Mandatory
ActorValue Property TemporaryInsanity Auto Mandatory
Message Property aaInsaneWarning_Message Auto Const Mandatory
Message Property aaSaneWarning_Message Auto Const Mandatory


Int SanityTimerId = 1 Const
Float SanityTimerInterval = 1.0 Const

Actor Player = None


Event OnInit()
    If Player == None
        Player = Game.GetPlayer()
    EndIf

    StartTimer(SanityTimerInterval, SanityTimerId)
EndEvent


Event OnTimer(Int timerId)
    Int currentSanityTier = 0
    If Player.HasPerk(TemporaryInsanityPerk)
        currentSanityTier = 2
    ElseIf Player.HasPerk(aaSanityPerkInsane)
        currentSanityTier = 1
    EndIf

    Int newSanityTier = 0
    If Player.GetValue(TemporaryInsanity) <= 0
        newSanityTier = 2
    ElseIf Player.GetValue(aaSanity) <= 0
        newSanityTier = 1
    EndIf

    If newSanityTier >= 2 && !Player.HasPerk(TemporaryInsanityPerk)
        Player.AddPerk(TemporaryInsanityPerk, False)
    ElseIf !newSanityTier && Player.HasPerk(TemporaryInsanityPerk)
        Player.RemovePerk(TemporaryInsanityPerk)
    EndIf

    If newSanityTier >= 1 && !Player.HasPerk(aaSanityPerkInsane)
        Player.AddPerk(aaSanityPerkInsane, False)
    ElseIf !newSanityTier && Player.HasPerk(aaSanityPerkInsane)
        Player.RemovePerk(aaSanityPerkInsane)
    EndIf

    If newSanityTier && !currentSanityTier
        aaInsaneWarning_Message.Show()
    ElseIf !newSanityTier && currentSanityTier
        aaSaneWarning_Message.Show()
    EndIf

    StartTimer(SanityTimerInterval, SanityTimerId)
EndEvent
