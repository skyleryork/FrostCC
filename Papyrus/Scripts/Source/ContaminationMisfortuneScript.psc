Scriptname ContaminationMisfortuneScript extends ReferenceAlias


Int Property PumpTimerId = 1 AutoReadOnly
Float Property PumpTimerInterval = 1 AutoReadOnly


Float Property MisfortuneChance Auto Mandatory
Float Property MisfortuneDuration Auto Mandatory
FormList Property Pristine Auto Mandatory
FormList Property Contaminated Auto Mandatory


Actor Player = None
Int QueueSize = 0
Bool InRadiation = False
Float ScaledMisfortuneChance = 0.0


Function Queue()
    QueueSize += 1
EndFunction


Event OnInit()
    If Pristine.GetSize() != Contaminated.GetSize()
        Debug.Trace("ContaminationMisfortuneScript: Pristine.Length != Contaminated.Length")
    EndIf

    If Player == None
        Player = Game.GetPlayer()
    EndIf

    If ScaledMisfortuneChance == 0.0
        ScaledMisfortuneChance = Chance.CalculateTimescaledChance(MisfortuneChance, MisfortuneDuration, PumpTimerInterval)
    EndIf

    RegisterForRadiationDamageEvent(Player)
    StartTimer(PumpTimerInterval, PumpTimerId)
EndEvent


Bool Function RollMisfortune()
    return Utility.RandomFloat() <= ScaledMisfortuneChance
EndFunction


Bool Function ApplyMisfortune()
    Form[] allItems = Player.GetInventoryItems()
    Int[] indices = ChanceApi.ShuffledIndices(allItems.Length)
    
    Form item = None
    Form replaceItem = None
    Int i = 0
    While i < indices.Length
        Int j = indices[i]
        Int k = Pristine.Find(allItems[j])
        If k >= 0
            item = allItems[j]
            replaceItem = Contaminated.GetAt(k)
            i = indices.Length
        EndIf
        i += 1
    EndWhile

    If !item || !replaceItem
        return False
    EndIf

    Player.RemoveItem(item)
    Player.AddItem(replaceItem)

    return True
EndFunction


Event OnRadiationDamage(ObjectReference akTarget, bool abIngested)
    If !abIngested
        InRadiation = True
    EndIf
EndEvent


Event OnTimer(Int timerId)
    If timerId == PumpTimerId
        If InRadiation
            If QueueSize
                If RollMisfortune()
                    If ApplyMisfortune()
                        QueueSize -= 1
                    EndIf
                EndIf
            EndIf
            InRadiation = False
        EndIf
        RegisterForRadiationDamageEvent(Player)
        StartTimer(PumpTimerInterval, PumpTimerId)
    EndIf
EndEvent
