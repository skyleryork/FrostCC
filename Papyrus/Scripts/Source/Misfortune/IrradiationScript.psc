Scriptname Misfortune:IrradiationScript extends ReferenceAlias


Float Property IrradiationChance Auto Const Mandatory
Float Property IrradiationDuration Auto Const Mandatory

FormList Property IrradiationPerks Auto Const Mandatory
FormList Property IrradiationPristine Auto Const Mandatory
FormList Property IrradiationContaminated Auto Const Mandatory

Message Property IrradiationMessage Auto Const Mandatory
Message Property IrradiationPerkMessage Auto Const Mandatory

String Property IrradiationCategoryConfig = "Misfortune" Auto Const
String Property IrradiationChanceConfig Auto Const Mandatory
String Property IrradiationDurationConfig Auto Const Mandatory


Runtime:RPGScript Runtime = None


Bool Function Add()
    return Runtime.OnAdded(Self)
EndFunction


Event OnInit()
    If Runtime == None
        Runtime = GetOwningQuest().GetAlias(0) as Runtime:RPGScript
    EndIf

    If !Runtime.ContainsMisfortune(Self)
        Runtime:RPGScript:StaticData data = new Runtime:RPGScript:StaticData
        data.ref = Self
        data.timerInterval = 1.0
        data.type = Runtime.TypeRadiation
        data.staticChance = IrradiationChance
        data.staticDuration = IrradiationDuration
        data.perks = IrradiationPerks
        data.addedMessage = IrradiationPerkMessage
        data.runMessage = IrradiationMessage
        data.categoryConfig = IrradiationCategoryConfig
        data.chanceConfig = IrradiationChanceConfig
        data.durationConfig = IrradiationDurationConfig
        Runtime.RegisterMisfortune(data)

        Debug.Trace("Misfortune:IrradiationScript: registered")
    EndIf
EndEvent


Runtime:RPGScript:ApplyResult Function OnRadiation(Actor player, Int rank)
    Form[] allItems = player.GetInventoryItems()
    Int[] indices = ChanceApi.ShuffledIndices(allItems.Length)

    Form item = None
    Form replaceItem = None
    Int i = 0
    While i < indices.Length
        Int j = indices[i]
        Int k = IrradiationPristine.Find(allItems[j])
        If k >= 0
            item = allItems[j]
            replaceItem = IrradiationContaminated.GetAt(k)
            i = indices.Length
        EndIf
        i += 1
    EndWhile

    If !item || !replaceItem
        return None
    EndIf

    player.RemoveItem(item, abSilent = True)
    player.AddItem(replaceItem, abSilent = True)

    return new Runtime:RPGScript:ApplyResult
EndFunction
