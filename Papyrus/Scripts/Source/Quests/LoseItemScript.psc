Scriptname Quests:LoseItemScript extends Quests:IntervalEffectBaseScript


FormList Property Keywords Auto Const Mandatory
FormList Property Sounds Auto Const Mandatory
Int[] Property Detection Auto Const Mandatory


Bool Function ExecuteEffect(Var[] args = None)
    Form[] allItems = GetPlayer().GetInventoryItems()
    Int[] filtered = Keywords.FindFormsByKeywords(allItems)
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
        return False
    EndIf

    Sound loseSound = Sounds.GetAt(index) as Sound
    Int detectionLevel = Detection[index]

    GetPlayer().RemoveItem(item)

    If loseSound
        loseSound.Play(GetPlayer())
    EndIf

    If detectionLevel
        GetPlayer().CreateDetectionEvent(GetPlayer(), detectionLevel)
    EndIf

    return True
EndFunction
