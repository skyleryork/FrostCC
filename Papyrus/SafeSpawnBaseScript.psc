Scriptname SafeSpawnBaseScript extends ReferenceAlias


Struct SpawnData
    Form theForm
    Int minQuantity
    Int maxQuantity
    Float minDistance
    Float maxDistance
    Float radius
    Float exclusionRadius
EndStruct


Int Property MaxQueue Auto Mandatory
Int Property SpawnMarkerCount Auto Mandatory
Float Property SpawnDelay Auto Mandatory
FormList Property SpawnMarkers Auto Const Mandatory


CrowdControl CC = None
Actor Player = None
SpawnData[] Queue = None
Int QueueSize = 0
Float LastSpawn = 0.0


Function Init()
    If Player == None
        Player = Game.GetPlayer()
    EndIf

    If CC == None
        CC = GetOwningQuest().GetAlias(0) as CrowdControl
    EndIf

    If Queue == None
        Queue = new SpawnData[MaxQueue]
    EndIf

    CancelTimer(0)
    EndPump()
EndFunction


Bool Function QueueSpawn(SpawnData data)
    Debug.Trace("QueueSpawn: " + QueueSize + " of " + Queue.Length)
    If QueueSize == Queue.Length
        return False
    EndIf

    Queue[QueueSize] = data
    QueueSize += 1
    return True
EndFunction


ObjectReference[] Function PumpQueue()
    ;Debug.Trace("SafeSpawnBaseScript::PumpQueue...")
    If QueueSize == 0
        Debug.Trace("SafeSpawnBaseScript::PumpQueue -- empty")
        EndPump()
        return None
    EndIf

    If ( Utility.GetCurrentRealTime() - LastSpawn ) < SpawnDelay
        Debug.Trace("SafeSpawnBaseScript::PumpQueue -- too soon")
        EndPump()
        return None
    EndIf

    SpawnData data = Queue[0]
    WorldSpace thisWorldspace = Player.GetWorldspace()
    ObjectReference[] markers = Player.FindAllReferencesOfType(SpawnMarkers, data.maxDistance)
    
    ObjectReference[] foundMarkers = new ObjectReference[SpawnMarkerCount]
    Int numFoundMarkers = 0
    int i = 0
    While i < markers.Length
        float distance = Player.GetDistance(markers[i])
        If distance >= data.minDistance && distance <= data.maxDistance && markers[i].GetWorldspace() == thisWorldspace && !Player.HasDirectLOS(markers[i]) && !markers[i].HasDirectLOS(Player)
            If data.exclusionRadius <= 0.0 || markers[i].FindAllReferencesOfType(data.theForm, data.exclusionRadius).Length == 0
                foundMarkers[numFoundMarkers] = markers[i]
                numFoundMarkers += 1
                If numFoundMarkers == foundMarkers.Length
                    i = markers.Length
                EndIf
            EndIf
        EndIf
        i += 1
    EndWhile

    If numFoundMarkers == 0
        Debug.Trace("SafeSpawnBaseScript::PumpQueue -- no markers of " + markers.Length + " between " + data.minDistance + " and " + data.maxDistance)
        EndPump()
        return None
    EndIf

    ObjectReference foundMarker = foundMarkers[Utility.RandomInt(0, numFoundMarkers - 1)]
    i = 0
    Int quantity = Utility.RandomInt(data.minQuantity, data.maxQuantity)
    ObjectReference[] spawned = new ObjectReference[quantity]
    while i < quantity
        CC.PingUpdateTimer()
        Debug.Trace("SafeSpawnBaseScript::PumpQueue -- spawning " + i + " of " + quantity)
        ObjectReference thisSpawn = foundMarker.PlaceAtMe(data.theForm)
        Float offsetX = 0
        Float offsetY = 0
        If data.radius
            Float randomAngle = Utility.RandomFloat(0.0, 360.0)
            Float randomDistance = Utility.RandomFloat(0.0, data.radius)
            offsetX = Math.Cos(randomAngle) * randomDistance
            offsetY = Math.Sin(randomAngle) * randomDistance
        EndIf
        thisSpawn.MoveTo(foundMarker, offsetX, offsetY)
        thisSpawn.SetAngle(0.0, thisSpawn.GetAngleY(), thisSpawn.GetAngleZ())
        spawned[i] = thisSpawn
        i += 1
    EndWhile

    LastSpawn = Utility.GetCurrentRealTime()

    i = 0
    While i < ( QueueSize - 1 )
        Queue[i] = Queue[i + 1]
    EndWhile
    Queue[i] = None
    QueueSize -= 1

    Debug.Trace("SafeSpawnBaseScript::PumpQueue -- done spawning")
    EndPump()
    return spawned
EndFunction


Function EndPump()
    StartTimer(1.0, 0)
EndFunction
