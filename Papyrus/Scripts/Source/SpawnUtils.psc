Scriptname SpawnUtils


ObjectReference[] Function FindSpawnMarkers(Actor source, ObjectReference referenceMarker, Form spawnMarkers, Float minSpawnDistance, Float maxSpawnDistance, Int maxResults = -1, Form spawnerKeyword = None) Global
    WorldSpace thisWorldspace = source.GetWorldspace()
    ObjectReference[] markers = source.FindAllReferencesOfType(spawnMarkers, maxSpawnDistance)
    If maxResults == -1
        maxResults = markers.Length
    Else
        maxResults = Math.Min(maxResults, markers.Length) as Int
    EndIf

    ObjectReference[] potentialMarkers = new ObjectReference[maxResults]

    Int numFoundMarkers = 0
    int i = 0
    Int[] indices = ChanceApi.ShuffledIndices(markers.Length)
    While (i < indices.Length) && (numFoundMarkers < potentialMarkers.Length)
        ObjectReference marker = markers[indices[i]]
        If marker.GetWorldspace() == thisWorldspace
            referenceMarker.MoveTo(marker, 0.0, 0.0, 64.0)
            Utility.Wait(0.2)
            float distance = source.GetDistance(referenceMarker)
            If distance >= minSpawnDistance && distance <= maxSpawnDistance
                referenceMarker.MoveToNearestNavmeshLocation()
                Utility.Wait(0.2)
                float angle = referenceMarker.GetHeadingAngle(source)
                referenceMarker.SetAngle(0.0, 0.0, referenceMarker.GetAngleZ() + angle)
                If !source.HasDirectLOS(referenceMarker) && !referenceMarker.HasDirectLOS(source) && !source.HasDetectionLOS(referenceMarker)
                    If !spawnerKeyword || referenceMarker.FindAllReferencesWithKeyword(spawnerKeyword, minSpawnDistance).Length == 0
                        potentialMarkers[numFoundMarkers] = marker
                        numFoundMarkers += 1
                    EndIf
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
