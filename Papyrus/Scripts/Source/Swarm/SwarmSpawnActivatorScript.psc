Scriptname Swarm:SwarmSpawnActivatorScript extends ObjectReference


FormList Property SwarmSpawnMarkers Auto Const Mandatory
ActorValue Property SwarmHoldupImmunity Auto Const Mandatory
ActorValue Property SwarmAssistance Auto Const Mandatory
ActorValue Property SwarmConfidence Auto Const Mandatory
ActorValue Property SwarmAggresion Auto Const Mandatory


Actor Player = None
RefCollectionAlias SwarmSpawns = None
Form SwarmSpawn = None
Int SpawnsRemaining = 0
Int SwarmMaxActiveSpawns = 0
Float SwarmMinSpawnDistance = 0.0
Float SwarmMaxSpawnDistance = 0.0


Function Init(RefCollectionAlias refCollection, Form spawn, Int numSpawns, Int maxActive, Float minDistance, Float maxDistance)
    SwarmSpawns = refCollection
    SwarmSpawn = spawn
    SpawnsRemaining = numSpawns
    SwarmMaxActiveSpawns = maxActive
    SwarmMinSpawnDistance = minDistance
    SwarmMaxSpawnDistance = maxDistance
    SwarmSpawns.RemoveAll()
    StartTimer(0.5, 1)
EndFunction


Int Function GetSpawnsRemaining()
    return SpawnsRemaining
EndFunction


Int Function GetSpawnsActive()
    return SwarmSpawns.GetCount()
EndFunction


Function CleanupSpawns()
    Int i = 0
    While i < SwarmSpawns.GetCount()
        Actor thisActor = SwarmSpawns.GetAt(i) as Actor
        If thisActor.IsDead() || !thisActor.Is3DLoaded()
            SwarmSpawns.RemoveRef(thisActor)
        Else
            i += 1
        EndIf
    EndWhile
EndFunction


Bool Function AddSpawns()
    Int i = 0
    ObjectReference[] foundMarkers = SpawnUtils.FindSpawnMarkers(Player, SwarmSpawnMarkers, SwarmMinSpawnDistance, SwarmMaxSpawnDistance)
    Int[] indices = ChanceApi.ShuffledIndices(foundMarkers.Length)
    Int nextMarker = 0
    While (SpawnsRemaining > 0) && (SwarmSpawns.GetCount() < SwarmMaxActiveSpawns) && (nextMarker < indices.Length)
        ObjectReference marker = foundMarkers[indices[nextMarker]]
        nextMarker += 1

        Actor thisActor = marker.PlaceAtMe(SwarmSpawn, abInitiallyDisabled = True) as Actor
        SwarmSpawns.AddRef(thisActor)
        SpawnsRemaining -= 1

        thisActor.MoveToNearestNavmeshLocation()
        thisActor.SetAngle(0.0, thisActor.GetAngleY(), thisActor.GetAngleZ())
        thisActor.SetValue(SwarmHoldupImmunity, 1)
        thisActor.SetValue(SwarmAssistance, 1)
        thisActor.SetValue(SwarmConfidence, 4)
        thisActor.SetValue(SwarmAggresion, 1)
        thisActor.Enable()
        i += 1
    EndWhile
    return SpawnsRemaining > 0
EndFunction


Event OnInit()
    If Player == None
        Player = Game.GetPlayer()
    EndIf
EndEvent


Event OnTimer(Int timerId)
    CleanupSpawns()
    If AddSpawns()
        StartTimer(0.5, 1)
    EndIf
EndEvent
