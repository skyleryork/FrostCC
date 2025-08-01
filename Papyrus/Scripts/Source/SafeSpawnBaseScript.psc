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


Int Property PumpTimerId = 1 AutoReadOnly
Float Property PumpTimerInterval = 1.0 AutoReadOnly


Int Property MaxQueue Auto Mandatory
Int Property SpawnMarkerCount Auto Mandatory
Float Property SpawnDelay Auto Mandatory
FormList Property SpawnMarkers Auto Const Mandatory


CrowdControl CC = None
Actor Player = None
SpawnData[] Queue = None
Int QueueSize = 0
Float LastSpawn = 0.0
Bool locked = False


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

    StartTimer(PumpTimerInterval, PumpTimerId)
EndFunction


Function Lock()
    While locked
        Utility.Wait(0.2)
    EndWhile
    locked = True
EndFunction


Function Unlock()
    locked = False
EndFunction


Bool Function QueueSpawn(SpawnData data)
    Lock()

    ;Debug.Trace("SafeSpawnBaseScript::QueueSpawn: " + (QueueSize + 1) + " of " + Queue.Length)
    If QueueSize == Queue.Length
        Unlock()
        return False
    EndIf

    Queue[QueueSize] = data
    QueueSize += 1

    Unlock()
    return True
EndFunction


ObjectReference[] Function PumpQueue(Bool enableSpawns = True)
    If QueueSize == 0
        ;Debug.Trace("SafeSpawnBaseScript::PumpQueue -- empty")
        StartTimer(PumpTimerInterval, PumpTimerId)
        return None
    EndIf

    If ( Utility.GetCurrentRealTime() - LastSpawn ) < SpawnDelay
        ;Debug.Trace("SafeSpawnBaseScript::PumpQueue -- too soon")
        StartTimer(PumpTimerInterval, PumpTimerId)
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
        ;Debug.Trace("SafeSpawnBaseScript::PumpQueue -- no markers of " + markers.Length + " between " + data.minDistance + " and " + data.maxDistance)
        StartTimer(PumpTimerInterval, PumpTimerId)
        return None
    EndIf

    ; lock to update queue
    Lock()
    i = 0
    While i < ( QueueSize - 1 )
        Queue[i] = Queue[i + 1]
        i += 1
    EndWhile
    Queue[i] = None
    QueueSize -= 1
    Unlock()
    
    ObjectReference foundMarker = foundMarkers[Utility.RandomInt(0, numFoundMarkers - 1)]
    i = 0
    Int quantity = Utility.RandomInt(data.minQuantity, data.maxQuantity)
    ObjectReference[] spawned = new ObjectReference[quantity]
    while i < quantity
        CC.PingUpdateTimer()
        ;Debug.Trace("SafeSpawnBaseScript::PumpQueue -- spawning " + (i + 1) + " of " + quantity)
        ObjectReference thisSpawn = foundMarker.PlaceAtMe(data.theForm, abInitiallyDisabled = True)
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
        If enableSpawns
            thisSpawn.Enable()
        EndIf
        spawned[i] = thisSpawn
        i += 1
    EndWhile

    LastSpawn = Utility.GetCurrentRealTime()
    StartTimer(PumpTimerInterval, PumpTimerId)

    ;Debug.Trace("SafeSpawnBaseScript::PumpQueue -- done spawning")
    return spawned
EndFunction
