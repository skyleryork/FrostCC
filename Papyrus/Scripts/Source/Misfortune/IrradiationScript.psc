Scriptname Misfortune:IrradiationScript extends Runtime:IntervalEffectBaseScript


FormList Property Pristine Auto Const Mandatory
FormList Property Irradiated Auto Const Mandatory


Bool Function ExecuteEffect(Var[] args = None)
    Form[] allItems = GetActorReference().GetInventoryItems()
    Int[] indices = ChanceApi.ShuffledIndices(allItems.Length)

    Form item = None
    Form replaceItem = None
    Int i = 0
    While i < indices.Length
        Int j = indices[i]
        Int k = Pristine.Find(allItems[j])
        If k >= 0
            item = allItems[j]
            replaceItem = Irradiated.GetAt(k)
            i = indices.Length
        EndIf
        i += 1
    EndWhile

    If !item || !replaceItem
        return False
    EndIf

    GetActorReference().RemoveItem(item, abSilent = True)
    GetActorReference().AddItem(replaceItem, abSilent = True)

    return True
EndFunction
