Scriptname RadiationHotspotScript extends ReferenceAlias


Hazard Property SmallHotspot Auto Const Mandatory
Hazard Property MediumHotspot Auto Const Mandatory
Hazard Property LargeHotspot Auto Const Mandatory
FormList Property Hotspots Auto Const Mandatory

Float Property SmallHotspotSpacing Auto Const Mandatory
Float Property MediumHotspotSpacing Auto Const Mandatory
Float Property LargeHotspotSpacing Auto Const Mandatory

ReferenceAlias Property SpawnMarkerRef Auto Const Mandatory


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

    ObjectReference spawnMarker = SpawnMarkerRef.GetReference()
    spawnMarker.MoveTo(target)

    ObjectReference[] hazards = spawnMarker.FindAllReferencesOfType(Hotspots, spacing)
    If hazards.Length > 0
        return False
    EndIf

    spawnMarker.PlaceAtMe(toSpawn)
    return True
EndFunction
