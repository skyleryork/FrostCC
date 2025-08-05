Scriptname OnKillBaseScript extends ReferenceAlias

Float Property OnKillChance Auto Const Mandatory
FormList Property OnKillPerks Auto Const Mandatory
FormList Property OnKillRaces Auto Const
FormList Property OnKillExcludeKeywords Auto Const
Message Property OnKillMessage Auto Const
Message Property OnKillPerkMessage Auto Const Mandatory
String Property OnKillChanceConfig Auto Const Mandatory


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
        data.type = Runtime.TypeKill
        data.staticChance = OnKillChance
        data.perks = OnKillPerks
        data.addedMessage = OnKillPerkMessage
        data.runMessage = OnKillMessage
        data.chanceConfig = OnKillChanceConfig
        Runtime.RegisterMisfortune(data)

        Debug.Trace("OnKillBaseScript: registered")
    EndIf
EndEvent
