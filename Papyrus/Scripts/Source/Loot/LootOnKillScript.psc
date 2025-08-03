Scriptname Loot:LootOnKillScript extends ReferenceAlias

Float Property KillChance Auto Const Mandatory

FormList Property KillPerks Auto Const Mandatory
FormList Property KillRaces Auto Const
FormList Property KillExcludeKeywords Auto Const
Form Property KillLoot Auto Const Mandatory

Message Property KillMessage Auto Const Mandatory
Message Property KillPerkMessage Auto Const Mandatory

String Property KillChanceConfig Auto Const Mandatory
String Property KillDurationConfig Auto Const Mandatory


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
        data.type = Runtime.TypeKill
        data.staticChance = KillChance
        data.perks = KillPerks
        data.addedMessage = KillPerkMessage
        data.runMessage = KillMessage
        data.chanceConfig = KillChanceConfig
        data.durationConfig = KillDurationConfig
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
