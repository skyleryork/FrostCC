Scriptname Quests:RadiationHotspotScript extends Quests:IntervalEffectBaseScript


Activator Property RadiationHotspotActivator Auto Const Mandatory
Int Property Radiation Auto Const Mandatory
Float Property Spacing Auto Const Mandatory
Float Property DecayDays Auto Const Mandatory
Float Property DecayScale = 0.05 Auto Const


Function ShowExecuteMessage()
    If ExecuteMessage
        ExecuteMessage.Show(Radiation)
    EndIf
EndFunction


Bool Function ExecuteEffect(Var[] args = None)
    Int index = GetCount() - 1

    ObjectReference[] hotspots = GetPlayer().FindAllReferencesOfType(RadiationHotspotActivator, Spacing)
    If hotspots.Length > 0
        return False
    EndIf

    Activators:RadiationHotspotActivatorScript hotspot = GetPlayer().PlaceAtMe(RadiationHotspotActivator) as Activators:RadiationHotspotActivatorScript
    hotspot.Init(Radiation, DecayScale, DecayDays)

    return True
EndFunction
