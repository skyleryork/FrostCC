Scriptname RadiationHotspotScript extends ReferenceAlias


Hazard Property SmallHotspot Auto Const Mandatory
Hazard Property MediumHotspot Auto Const Mandatory
Hazard Property LargeHotspot Auto Const Mandatory
FormList Property Hotspots Auto Const Mandatory

Float Property SmallHotspotSpacing Auto Const Mandatory
Float Property MediumHotspotSpacing Auto Const Mandatory
Float Property LargeHotspotSpacing Auto Const Mandatory

ReferenceAlias Property SpawnMarkerRef Auto Const Mandatory

Bool locked = False


Function Lock()
    While locked
        Utility.Wait(0.2)
    EndWhile
    locked = True
EndFunction


Function Unlock()
    locked = False
EndFunction


Bool Function SpawnHotspot(Int tier, ObjectReference target)
    Hazard toSpawn = None
    Float spacing = 0
    If tier == 0
        toSpawn = SmallHotspot
        spacing = SmallHotspotSpacing
    ElseIf tier == 1
        toSpawn = MediumHotspot
        spacing = MediumHotspotSpacing
    ElseIf tier == 2
        toSpawn = LargeHotspot
        spacing = LargeHotspotSpacing
    Else
        return False
    EndIf

    Lock()

    ObjectReference spawnMarker = SpawnMarkerRef.GetReference()
    spawnMarker.MoveTo(target)

    ObjectReference[] hazards = spawnMarker.FindAllReferencesOfType(Hotspots, spacing)
    If hazards.Length > 0
        Unlock()
        return False
    EndIf

    spawnMarker.PlaceAtMe(toSpawn)
    Unlock()
    return True
EndFunction


Bool Function CleanseHotspots(ObjectReference target, Float radius)
    Lock()

    ObjectReference[] hazards = target.FindAllReferencesOfType(Hotspots, radius)
    If hazards.Length == 0
        Unlock()
        return False
    EndIf

    Int i = 0
    While i < hazards.Length
        ObjectReference theHazard = hazards[i]
        Form theHazardBase = theHazard.GetBaseObject()
        theHazard.Disable()
        If theHazardBase == MediumHotspot
            theHazard.PlaceAtMe(SmallHotspot)
        ElseIf theHazardBase == LargeHotspot
            theHazard.PlaceAtMe(MediumHotspot)
        EndIf
        theHazard.Delete()
        i += 1
    EndWhile

    Unlock()
    return True
EndFunction
