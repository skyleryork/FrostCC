Scriptname Misfortune:ContaminationScript extends ReferenceAlias


Float Property ContaminationChance Auto Const Mandatory
Float Property ContaminationDuration Auto Const Mandatory

FormList Property ContaminationPerks Auto Const Mandatory
FormList Property ContaminationPristine Auto Const Mandatory
FormList Property ContaminationContaminated Auto Const Mandatory

Message Property ContaminationMessage Auto Const Mandatory
Message Property ContaminationPerkMessage Auto Const Mandatory

String Property ContaminationChanceConfig Auto Const Mandatory
String Property ContaminationDurationConfig Auto Const Mandatory


RPGRuntimeScript Runtime = None


Bool Function Add()
    return Runtime.OnAdded(Self)
EndFunction


Event OnInit()
    If Runtime == None
        Runtime = GetOwningQuest().GetAlias(0) as RPGRuntimeScript
    EndIf

    If !Runtime.ContainsMisfortune(Self)
        RPGRuntimeScript:StaticData data = new RPGRuntimeScript:StaticData
        data.ref = Self
        data.timerInterval = 1.0
        data.type = Runtime.TypeRadiation
        data.staticChance = ContaminationChance
        data.staticDuration = ContaminationDuration
        data.perks = ContaminationPerks
        data.addedMessage = ContaminationPerkMessage
        data.runMessage = ContaminationMessage
        data.chanceConfig = ContaminationChanceConfig
        data.durationConfig = ContaminationDurationConfig
        Runtime.RegisterMisfortune(data)

        Debug.Trace("Misfortune:ContaminationScript: registered")
    EndIf
EndEvent


Event RPGRuntimeScript.OnRadiation(RPGRuntimeScript ref, Var[] args)
    Actor Player = args[0] as Actor

    Form[] allItems = Player.GetInventoryItems()
    Int[] indices = ChanceApi.ShuffledIndices(allItems.Length)

    Form item = None
    Form replaceItem = None
    Int i = 0
    While i < indices.Length
        Int j = indices[i]
        Int k = ContaminationPristine.Find(allItems[j])
        If k >= 0
            item = allItems[j]
            replaceItem = ContaminationContaminated.GetAt(k)
            i = indices.Length
        EndIf
        i += 1
    EndWhile

    If !item || !replaceItem
        ref.OnApplyResult(Self, False)
        return
    EndIf

    Player.RemoveItem(item, abSilent = True)
    Player.AddItem(replaceItem, abSilent = True)

    ref.OnApplyResult(Self, True)
EndEvent
