Scriptname LoseItemMisfortuneScript extends ReferenceAlias


Int Property PumpTimerId = 1 AutoReadOnly
Float Property PumpTimerInterval = 1 AutoReadOnly


Float Property MisfortuneChance Auto Mandatory
FormList Property ItemKeywords Auto Mandatory
FormList Property ItemSounds Auto Mandatory
Int[] Property ItemDetection Auto Mandatory


Actor Player = None
Int QueueSize = 0
Bool Sprinting = False
Float SprintTime = 0.0


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

    StartTimer(PumpTimerInterval, PumpTimerId)
EndEvent


Bool Function RollMisfortune()
    Float calculated = Chance.CalcuateTimedChance(Chance.CalculateChance(MisfortuneChance, QueueSize), SprintTime)
    Debug.Trace("LoseItemMisfortuneScript: RollMisfortune = " + calculated + " (QueueSize = " + QueueSize + ", SprintTime = " + SprintTime + ")")
    return Utility.RandomFloat() <= calculated
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
                SprintTime += PumpTimerInterval
                ;Debug.Trace("LoseItemMisfortuneScript: Still sprinting for " + SprintTime)
                If QueueSize
                    If RollMisfortune()
                        If ApplyMisfortune()
                            QueueSize -= 1
                            SprintTime = 0.0
                        EndIf
                    EndIf
                EndIf
            Else
                ;Debug.Trace("LoseItemMisfortuneScript: Started sprinting")
                Sprinting = True
                SprintTime = 0.0
            EndIf
        ElseIf Sprinting
            ;Debug.Trace("LoseItemMisfortuneScript: Ended sprinting")
            Sprinting = False
        EndIf
        StartTimer(PumpTimerInterval, PumpTimerId)
    EndIf
EndEvent
