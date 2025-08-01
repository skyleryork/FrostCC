Scriptname LoseItemMisfortuneScript extends ReferenceAlias


Int Property PumpTimerId = 1 AutoReadOnly
Float Property PumpTimerInterval = 1 AutoReadOnly


Float Property MisfortuneChance Auto Mandatory
Float Property MisfortuneDuration Auto Mandatory
FormList Property ItemKeywords Auto Mandatory
FormList Property ItemSounds Auto Mandatory
Int[] Property ItemDetection Auto Mandatory


Actor Player = None
Int QueueSize = 0
Bool Sprinting = False
Float ScaledMisfortuneChance = 0.0


Function Queue()
    QueueSize += 1
EndFunction


Event OnInit()
    Debug.Trace("LoseItemMisfortuneScript: OnInit")

    If ( ItemKeywords.GetSize() != ItemSounds.GetSize() ) || ( ItemKeywords.GetSize() != ItemDetection.Length )
        Debug.Trace("LoseItemMisfortuneScript: mismatched property array lengths")
    EndIf

    If Player == None
        Player = Game.GetPlayer()
    EndIf

    If ScaledMisfortuneChance == 0.0
        ScaledMisfortuneChance = Chance.CalculateTimescaledChance(MisfortuneChance, MisfortuneDuration, PumpTimerInterval)
    EndIf

    Utility.Wait(Utility.RandomFloat(0.0, PumpTimerInterval))
    StartTimer(PumpTimerInterval, PumpTimerId)
EndEvent


Bool Function RollMisfortune()
    return Utility.RandomFloat() <= ScaledMisfortuneChance
EndFunction


Bool Function ApplyMisfortune()
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
        ;Debug.Trace("LoseItemMisfortuneScript: no item found of " + allItems.Length)
        return False
    EndIf

    Sound loseSound = ItemSounds.GetAt(index) as Sound
    Int detection = ItemDetection[index]

    Player.RemoveItem(item)
    If loseSound
        loseSound.Play(Player)
    EndIf
    If detection
        Player.CreateDetectionEvent(Player, detection)
    EndIf

    return True
EndFunction


Event OnTimer(Int timerId)
    If timerId == PumpTimerId
        If Player.IsSprinting() || (Player.IsInPowerArmor() && Player.IsRunning())
            If Sprinting
                If QueueSize
                    If RollMisfortune()
                        If ApplyMisfortune()
                            QueueSize -= 1
                        EndIf
                    EndIf
                EndIf
            Else
                Sprinting = True
            EndIf
        ElseIf Sprinting
            Sprinting = False
        EndIf
        StartTimer(PumpTimerInterval, PumpTimerId)
    EndIf
EndEvent
