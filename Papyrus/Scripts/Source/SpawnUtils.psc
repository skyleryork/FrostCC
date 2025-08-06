Scriptname SpawnUtils


ObjectReference[] Function FindSpawnMarkers(Actor source, Form spawnMarkers, Float minSpawnDistance, Float maxSpawnDistance, Form spawnerKeyword = None, String targetNode = "Head") Global
    WorldSpace thisWorldspace = source.GetWorldspace()
    ObjectReference[] markers = source.FindAllReferencesOfType(spawnMarkers, maxSpawnDistance)
    ObjectReference[] potentialMarkers = new ObjectReference[markers.Length]

    Int numFoundMarkers = 0
    int i = 0
    While i < markers.Length
        float distance = source.GetDistance(markers[i])
        If distance >= minSpawnDistance && distance <= maxSpawnDistance && markers[i].GetWorldspace() == thisWorldspace
            If !source.HasDetectionLOS(markers[i]) && !markers[i].HasDirectLOS(source, asTargetNode = targetNode)
                If !spawnerKeyword || markers[i].FindAllReferencesWithKeyword(spawnerKeyword, minSpawnDistance).Length == 0
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
