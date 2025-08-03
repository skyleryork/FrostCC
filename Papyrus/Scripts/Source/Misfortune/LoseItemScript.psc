Scriptname Misfortune:LoseItemScript extends ReferenceAlias


Float Property LoseItemChance Auto Const Mandatory
Float Property LoseItemDuration Auto Const Mandatory

FormList Property LoseItemKeywords Auto Const Mandatory
FormList Property LoseItemSounds Auto Const Mandatory
Int[] Property LoseItemDetection Auto Const Mandatory

FormList Property LoseItemPerks Auto Const Mandatory
Message Property LoseItemMessage Auto Const Mandatory
Message Property LoseItemPerkMessage Auto Const Mandatory
String Property LoseItemChanceConfig Auto Const Mandatory
String Property LoseItemDurationConfig Auto Const Mandatory


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
        data.type = Runtime.TypeSprinting
        data.staticChance = LoseItemChance
        data.staticDuration = LoseItemDuration
        data.perks = LoseItemPerks
        data.addedMessage = LoseItemPerkMessage
        data.runMessage = LoseItemMessage
        data.chanceConfig = LoseItemChanceConfig
        data.durationConfig = LoseItemDurationConfig
        Runtime.RegisterMisfortune(data)
    EndIf
EndEvent


Event RPGRuntimeScript.OnSprinting(RPGRuntimeScript source, Var[] args)
    Actor Player = args[0] as Actor

    FormList keywords = LoseItemKeywords
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
        source.OnApplyResult(Self, False)
        return
    EndIf

    Sound loseSound = LoseItemSounds.GetAt(index) as Sound
    Int detection = LoseItemDetection[index]

    Player.RemoveItem(item)

    If loseSound
        loseSound.Play(Player)
    EndIf

    If detection
        Player.CreateDetectionEvent(Player, detection)
    EndIf

    source.OnApplyResult(Self, True)
EndEvent
