Scriptname Misfortune:ContaminationScript extends ReferenceAlias

Float Property ContamiationChance Auto Const Mandatory
Float Property ContamiationDuration Auto Const Mandatory

FormList Property ContaminationPerks Auto Const Mandatory
FormList Property ContaminationPristine Auto Const Mandatory
FormList Property ContaminationContaminated Auto Const Mandatory

Message Property ContaminationMessage Auto Const Mandatory
Message Property ContaminationPerkMessage Auto Const Mandatory

String Property ContaminationChanceConfig Auto Const Mandatory
String Property ContaminationDurationConfig Auto Const Mandatory


RPGRuntimeScript Runtime = None
Bool oneTimeInit = False


Bool Function Add()
    return Runtime.OnAdded(Self)
EndFunction


Event OnInit()
    If Runtime == None
        Runtime = GetOwningQuest().GetAlias(0) as RPGRuntimeScript
    EndIf

    If !oneTimeInit
        oneTimeInit = True

        RPGRuntimeScript:StaticData data = new RPGRuntimeScript:StaticData
        data.source = Self
        data.timerInterval = 1.0
        data.type = Runtime.TypeRadiation
        data.staticChance = ContamiationChance
        data.staticDuration = ContamiationDuration
        data.perks = ContaminationPerks
        data.addedMessage = ContaminationPerkMessage
        data.runMessage = ContaminationMessage
        data.chanceConfig = ContaminationChanceConfig
        data.durationConfig = ContaminationDurationConfig
        Runtime.RegisterMisfortune(data)
    EndIf
EndEvent


Event RPGRuntimeScript.OnRadiation(RPGRuntimeScript source, Var[] args)
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
        source.OnApplyResult(Self, False)
        return
    EndIf

    Player.RemoveItem(item, abSilent = True)
    Player.AddItem(replaceItem, abSilent = True)

    source.OnApplyResult(Self, True)
EndEvent
