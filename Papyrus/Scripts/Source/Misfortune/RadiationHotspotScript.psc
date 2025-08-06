Scriptname Misfortune:RadiationHotspotScript extends ReferenceAlias


Struct RadiationHotspot
    Int radiation
    Float spacing
    Float decayDays
EndStruct


Float Property RadiationHotspotChance Auto Const Mandatory
Float Property RadiationHotspotDuration Auto Const Mandatory

Activator Property RadiationHotspotActivator Auto Const Mandatory
RadiationHotspot[] Property RadiationHotspots Auto Const Mandatory
Float Property RadiationHotspotDecayScale Auto Const Mandatory

FormList Property RadiationHotspotPerks Auto Const Mandatory
Message Property RadiationHotspotPerkMessage Auto Const Mandatory
Message Property RadiationHotspotMessage Auto Const Mandatory

String Property RadiationHotspotCategoryConfig = "Misfortune" Auto Const
String Property RadiationHotspotChanceConfig Auto Const Mandatory
String Property RadiationHotspotDurationConfig Auto Const Mandatory


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
        data.type = Runtime.TypeInterval
        data.staticChance = RadiationHotspotChance
        data.staticDuration = RadiationHotspotDuration
        data.perks = RadiationHotspotPerks
        data.addedMessage = RadiationHotspotPerkMessage
        data.runMessage = RadiationHotspotMessage
        data.categoryConfig = RadiationHotspotCategoryConfig
        data.chanceConfig = RadiationHotspotChanceConfig
        data.durationConfig = RadiationHotspotChanceConfig
        Runtime.RegisterMisfortune(data)

        Debug.Trace("Misfortune:RadiationHotspotScript: registered")
    EndIf
EndEvent


Runtime:RPGScript:ApplyResult Function OnInterval(Actor player, Int rank)
    Int index = rank - 1

    RadiationHotspot data = RadiationHotspots[index]
    ObjectReference[] hotspots = Player.FindAllReferencesOfType(RadiationHotspotActivator, data.spacing)
    If hotspots.Length > 0
        return None
    EndIf

    Misfortune:RadiationHotspotActivatorScript hotspot = Player.PlaceAtMe(RadiationHotspotActivator) as Misfortune:RadiationHotspotActivatorScript

    hotspot.Init(data.radiation, RadiationHotspotDecayScale, data.decayDays)

    Runtime:RPGScript:ApplyResult result = new Runtime:RPGScript:ApplyResult
    result.param0 = data.radiation
    return result
EndFunction
