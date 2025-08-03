Scriptname Misfortune:RadiationHotspotScript extends ReferenceAlias


Float Property RadiationHotspotChance Auto Const Mandatory
Float Property RadiationHotspotDuration Auto Const Mandatory

Hazard[] Property RadiationHotspots Auto Const Mandatory
Float[] Property RadiationHotspotSpacing Auto Const Mandatory
Int[] Property RadiationHotspotRads Auto Const Mandatory

FormList Property RadiationHotspotPerks Auto Const Mandatory
Message Property RadiationHotspotPerkMessage Auto Const Mandatory
Message Property RadiationHotspotMessage Auto Const Mandatory
String Property RadiationHotspotChanceConfig Auto Const Mandatory
String Property RadiationHotspotDurationConfig Auto Const Mandatory


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
        data.type = Runtime.TypeInterval
        data.staticChance = RadiationHotspotChance
        data.staticDuration = RadiationHotspotDuration
        data.perks = RadiationHotspotPerks
        data.addedMessage = RadiationHotspotPerkMessage
        data.runMessage = RadiationHotspotMessage
        data.chanceConfig = RadiationHotspotChanceConfig
        data.durationConfig = RadiationHotspotChanceConfig
        Runtime.RegisterMisfortune(data)
    EndIf
EndEvent


Event RPGRuntimeScript.OnInterval(RPGRuntimeScript source, Var[] args)
    Actor Player = args[0] as Actor
    Int index = (args[1] as Int) - 1

    Hazard hotspot = RadiationHotspots[index]
    Float spacing = RadiationHotspotSpacing[index]
    Int rads = RadiationHotspotRads[index]

    ObjectReference[] hotspots = Player.FindAllReferencesOfType(hotspot, spacing)
    If hotspots.Length == 0
        Player.PlaceAtMe(hotspot)

        Var[] resultArgs = new Var[1]
        resultArgs[0] = rads
        source.OnApplyResult(Self, True, resultArgs)
    Else
        source.OnApplyResult(Self, False)
    EndIf
EndEvent
