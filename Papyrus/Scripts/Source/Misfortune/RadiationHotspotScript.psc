Scriptname Misfortune:RadiationHotspotScript extends ReferenceAlias


Float Property RadiationHotspotChance Auto Const Mandatory
Float Property RadiationHotspotDuration Auto Const Mandatory

Activator Property RadiationHotspotActivator Auto Const Mandatory
Float[] Property RadiationHotspotSpacing Auto Const Mandatory
Int[] Property RadiationHotspotRads Auto Const Mandatory

FormList Property RadiationHotspotPerks Auto Const Mandatory
Message Property RadiationHotspotPerkMessage Auto Const Mandatory
Message Property RadiationHotspotMessage Auto Const Mandatory
String Property RadiationHotspotChanceConfig Auto Const Mandatory
String Property RadiationHotspotDurationConfig Auto Const Mandatory


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


Event RPGRuntimeScript.OnInterval(RPGRuntimeScript ref, Var[] args)
    If (args[0] as ScriptObject) != Self
        return
    EndIf

    Actor Player = args[1] as Actor
    Int index = (args[2] as Int) - 1

    Float spacing = RadiationHotspotSpacing[index]
    Int rads = RadiationHotspotRads[index]

    ObjectReference[] hotspots = Player.FindAllReferencesOfType(RadiationHotspotActivator, spacing)
    If hotspots.Length == 0
        Misfortune:RadiationHotspotActivatorScript hotspot = Player.PlaceAtMe(RadiationHotspotActivator) as Misfortune:RadiationHotspotActivatorScript

        hotspot.Init(rads, 0.05, 1.0)

        Var[] resultArgs = new Var[1]
        resultArgs[0] = rads
        ref.OnApplyResult(Self, True, resultArgs)
    Else
        ref.OnApplyResult(Self, False)
    EndIf
EndEvent
