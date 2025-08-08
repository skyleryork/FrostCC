Scriptname SpawnUtils


ObjectReference[] Function FindSpawnMarkers(Actor source, ObjectReference referenceMarker, Form spawnMarkers, Float minSpawnDistance, Float maxSpawnDistance, Form spawnerKeyword = None, String targetNode = "Head") Global
    WorldSpace thisWorldspace = source.GetWorldspace()
    ObjectReference[] markers = source.FindAllReferencesOfType(spawnMarkers, maxSpawnDistance)
    ObjectReference[] potentialMarkers = new ObjectReference[markers.Length]

    Int numFoundMarkers = 0
    int i = 0
    While i < markers.Length
        referenceMarker.MoveTo(markers[i], 0.0, 0.0, 88.0)
        float distance = source.GetDistance(referenceMarker)
        If distance >= minSpawnDistance && distance <= maxSpawnDistance && markers[i].GetWorldspace() == thisWorldspace
            If !source.HasDirectLOS(referenceMarker) && !referenceMarker.HasDirectLOS(source, asTargetNode = targetNode)
                If !spawnerKeyword || referenceMarker.FindAllReferencesWithKeyword(spawnerKeyword, minSpawnDistance).Length == 0
                    potentialMarkers[numFoundMarkers] = markers[i]
                    numFoundMarkers += 1
                EndIf
            EndIf
        EndIf
        i += 1
    EndWhile

    ObjectReference[] foundMarkers = new ObjectReference[numFoundMarkers]
    i = 0
    While i < foundMarkers.Length
        foundMarkers[i] = potentialMarkers[i]
        i += 1
    EndWhile
    return foundMarkers
EndFunction
