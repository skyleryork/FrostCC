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
        data.chanceConfig = RadiationHotspotChanceConfig
        data.durationConfig = RadiationHotspotChanceConfig
        Runtime.RegisterMisfortune(data)

        Debug.Trace("Misfortune:RadiationHotspotScript: registered")
    EndIf
EndEvent


Event Runtime:RPGScript.OnInterval(Runtime:RPGScript ref, Var[] args)
    If !Runtime:RPGScript.ShouldHandleEvent(Self, args)
        return
    EndIf

    Actor Player = args[1] as Actor
    Int index = (args[2] as Int) - 1

    RadiationHotspot data = RadiationHotspots[index]
    ObjectReference[] hotspots = Player.FindAllReferencesOfType(RadiationHotspotActivator, data.spacing)
    If hotspots.Length == 0
        Misfortune:RadiationHotspotActivatorScript hotspot = Player.PlaceAtMe(RadiationHotspotActivator) as Misfortune:RadiationHotspotActivatorScript

        hotspot.Init(data.radiation, RadiationHotspotDecayScale, data.decayDays)

        Var[] resultArgs = new Var[1]
        resultArgs[0] = data.radiation
        ref.OnApplyResult(Self, True, resultArgs)
    Else
        ref.OnApplyResult(Self, False)
    EndIf
EndEvent
