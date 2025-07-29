Scriptname SafeSpawnBaseScript extends ReferenceAlias


Struct SpawnData
    Form theForm
    Int quantity
    Float minDistance
    Float maxDistance
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
    Player = Game.GetPlayer()

    If CC == None
        CC = GetOwningQuest().GetAlias(0) as CrowdControl
    EndIf

    If Queue == None
        Queue = new SpawnData[MaxQueue]
    EndIf

    CancelTimer(0)
    StartTimer(1.0, 0)
EndFunction


Bool Function QueueSpawn(SpawnData data)
    If QueueSize == Queue.Length
        return False
    EndIf

    Queue[QueueSize] = data
    QueueSize += 1
    return True
EndFunction


Function PumpQueue()
    If QueueSize == 0
        StartTimer(1.0, 0)
        return
    EndIf

    If ( Utility.GetCurrentRealTime() - LastSpawn ) < SpawnDelay
        StartTimer(1.0, 0)
        return
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
            foundMarkers[numFoundMarkers] = markers[i]
            numFoundMarkers += 1
            If numFoundMarkers == foundMarkers.Length
                i = markers.Length
            EndIf
        EndIf
        i += 1
    EndWhile

    If numFoundMarkers == 0
        StartTimer(1.0, 0)
        return
    EndIf

    ObjectReference foundMarker = foundMarkers[Utility.RandomInt(0, numFoundMarkers - 1)]
    i = 0
    while i < data.quantity
        CC.PingUpdateTimer()
        ObjectReference spawned = foundMarker.PlaceAtMe(data.theForm)
        spawned.SetAngle(0.0, spawned.GetAngleY(), spawned.GetAngleZ())
        i += 1
    EndWhile

    LastSpawn = Utility.GetCurrentRealTime()

    i = 0
    While i < ( QueueSize - 1 )
        Queue[i] = Queue[i + 1]
    EndWhile
    Queue[i] = None
    QueueSize -= 1

    StartTimer(1.0, 0)
EndFunction
