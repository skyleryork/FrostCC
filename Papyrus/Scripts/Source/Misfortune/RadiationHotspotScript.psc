Scriptname Misfortune:RadiationHotspotScript extends Runtime:IntervalEffectBaseScript


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

    ObjectReference[] hotspots = GetActorReference().FindAllReferencesOfType(RadiationHotspotActivator, Spacing)
    If hotspots.Length > 0
        return False
    EndIf

    Misfortune:RadiationHotspotActivatorScript hotspot = GetActorReference().PlaceAtMe(RadiationHotspotActivator) as Misfortune:RadiationHotspotActivatorScript
    hotspot.Init(Radiation, DecayScale, DecayDays)

    return True
EndFunction
