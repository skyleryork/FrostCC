Scriptname Misfortune:LoseItemMisfortuneScript extends ReferenceAlias


Int Property PumpTimerId = 1 AutoReadOnly
Float Property PumpTimerInterval = 0.5 AutoReadOnly


Float Property MisfortuneChance Auto Const Mandatory
Float Property MisfortuneDuration Auto Const Mandatory
Perk[] Property LoseItemPerks Auto Const Mandatory

FormList Property ItemKeywords Auto Const Mandatory
FormList Property ItemSounds Auto Const Mandatory
Int[] Property ItemDetection Auto Const Mandatory

Message Property LoseItemMessage Auto Const Mandatory
Message Property LoseItemPerkMessage Auto Const Mandatory


Actor Player = None
Float ScaledMisfortuneChance = 0.0
Bool Locked = False


Function Lock()
    While Locked
        Utility.Wait(0.2)
    EndWhile
    Locked = True
EndFunction


Function Unlock()
    Locked = False
EndFunction


Bool Function Add()
    Lock()
    Int i = 0
    While i < LoseItemPerks.Length
        If !Player.HasPerk(LoseItemPerks[i])
            Player.AddPerk(LoseItemPerks[i])
            Unlock()
            LoseItemPerkMessage.Show(i + 1)
            return True
        EndIf
        i += 1
    EndWhile
    Unlock()
    return False
EndFunction


Function ParseSettings()
    Float chanceSetting = CrowdControlApi.GetFloatSetting("Misfortunes", "LoseItemChance", -1.0)
    If chanceSetting < 0.0
        chanceSetting = MisfortuneChance
    EndIf

    Float durationSetting = CrowdControlApi.GetFloatSetting("Misfortunes", "LoseItemDuration", -1.0)
    If durationSetting < 0.0
        durationSetting = MisfortuneDuration
    EndIf

    ScaledMisfortuneChance = Chance.CalculateTimescaledChance(chanceSetting, durationSetting, PumpTimerInterval)
EndFunction


Event OnInit()
    Debug.Trace("LoseItemMisfortuneScript: OnInit")

    If ( ItemKeywords.GetSize() != ItemSounds.GetSize() ) || ( ItemKeywords.GetSize() != ItemDetection.Length )
        Debug.Trace("LoseItemMisfortuneScript: ItemKeywords/ItemSounds/ItemDetection mismatched lengths")
    EndIf

    If Player == None
        Player = Game.GetPlayer()
    EndIf

    ParseSettings()

    StartTimer(Utility.RandomFloat(0.0, PumpTimerInterval), PumpTimerId)
EndEvent


Event OnPlayerLoadGame()
    ParseSettings()
EndEvent


Bool Function RollMisfortune()
    If !Player.HasPerk(LoseItemPerks[0])
        return False
    EndIf
    return Utility.RandomFloat() <= ScaledMisfortuneChance
EndFunction


Perk Function HighestRankPerk()
    Int i = LoseItemPerks.Length - 1
    While i >= 0
        If Player.HasPerk(LoseItemPerks[i])
            return LoseItemPerks[i]
        EndIf
        i -= 1
    EndWhile
    return None
EndFunction


Function ApplyMisfortune()
    FormList keywords = ItemKeywords
    Form[] allItems = Player.GetInventoryItems()
    Int[] filtered = keywords.FindFormsByKeywords(allItems)
    Int[] indices = ChanceApi.ShuffledIndices(allItems.Length)

    Int index = -1
    Form item = None
    Int i = 0
    While i < indices.Length
        Int j = indices[i]
        Int k = filtered[j]
        If k >= 0
            index = k
            item = allItems[j]
            i = indices.Length
        EndIf
        i += 1
    EndWhile

    If !item || index < 0
        return
    EndIf

    Sound loseSound = ItemSounds.GetAt(index) as Sound
    Int detection = ItemDetection[index]

    Player.RemovePerk(HighestRankPerk())
    Player.RemoveItem(item)

    If loseSound
        loseSound.Play(Player)
    EndIf

    If detection
        Player.CreateDetectionEvent(Player, detection)
    EndIf
EndFunction


Event OnTimer(Int timerId)
    If timerId == PumpTimerId
        If Player.IsSprinting() || (Player.IsInPowerArmor() && Player.IsRunning())
            Lock()
            If RollMisfortune()
                ApplyMisfortune()
            EndIf
            Unlock()
        EndIf
        StartTimer(PumpTimerInterval, PumpTimerId)
    EndIf
EndEvent
