Scriptname ContaminationMisfortuneScript extends ReferenceAlias


Float Property MisfortuneChance Auto Mandatory
Form[] Property Pristine Auto Mandatory
Form[] Property Contaminated Auto Mandatory


Actor Player = None
Int QueueSize = 0


Function Queue()
    QueueSize += 1
EndFunction


Event OnInit()
    If Pristine.Length != Contaminated.Length
        Debug.Trace("ContaminationMisfortuneScript: Pristine.Length != Contaminated.Length")
    EndIf

    If Player == None
        Player = Game.GetPlayer()
    EndIf

    RegisterForRadiationDamageEvent(Player)
EndEvent


Bool Function RollMisfortune()
    return Utility.RandomFloat() < Chance.CalculateChance(MisfortuneChance, QueueSize)
EndFunction


Bool Function ApplyMisfortune()
    Form[] allItems = Player.GetInventoryItems()
    Int[] filtered = new Int[allItems.Length]
    Int count = 0
    Int i = 0
    Int[] indices = ChanceApi.ShuffledIndices(allItems.Length)
    While i < indices.Length
        Int j = indices[i]
        Int k = Pristine.Find(allItems[j])
        If k >= 0
            filtered[count] = k
            count += 1
        EndIf
        i += 1
    EndWhile

    If count == 0
        return False
    EndIf

    i = filtered[Utility.RandomInt(0, count - 1)]
    Player.RemoveItem(Pristine[i])
    Player.AddItem(Contaminated[i])

    return True
EndFunction


Event OnRadiationDamage(ObjectReference akTarget, bool abIngested)
    If !abIngested && QueueSize && RollMisfortune() && ApplyMisfortune()
        QueueSize -= 1
    EndIf
    RegisterForRadiationDamageEvent(Player)
EndEvent
