Scriptname Swarm:SwarmSpawnActivatorScript extends ObjectReference


Float SpawnTimerInterval = 0.5 Const
Int SpawnTimerId = 1 Const

Float MarkersTimerInterval = 5.0 Const
Int MarkersTimerId= 2


Keyword Property ActiveSpawn Auto Const Mandatory
FormList Property SpawnMarkers Auto Const Mandatory
ActorValue Property HoldupImmunity Auto Const Mandatory
ActorValue Property Assistance Auto Const Mandatory
ActorValue Property Confidence Auto Const Mandatory
ActorValue Property Aggresion Auto Const Mandatory


Actor FocalRef = None
RefCollectionAlias SwarmSpawns = None
ObjectReference ReferenceMarker = None
ObjectReference[] FoundMarkers = None
Form SwarmSpawn = None
Int SpawnsActive = 0
Int SpawnsRemaining = -1
Float SpawnEndtime = -1.0
Int SwarmMaxActiveSpawns = 0
Float SwarmMinSpawnDistance = 0.0
Float SwarmMaxSpawnDistance = 0.0


Function InitCommon(Actor focal, RefCollectionAlias refCollection, ObjectReference marker, Form spawn, Int maxActive, Float minDistance, Float maxDistance)
    FocalRef = focal
    SwarmSpawns = refCollection
    ReferenceMarker = marker
    SwarmSpawn = spawn
    SwarmMaxActiveSpawns = maxActive
    SwarmMinSpawnDistance = minDistance
    SwarmMaxSpawnDistance = maxDistance
    UpdateMarkers()
    StartTimer(SpawnTimerInterval, SpawnTimerId)
    StartTimer(MarkersTimerInterval, 2)
EndFunction


Function InitMaxCount(Actor focal, RefCollectionAlias refCollection, ObjectReference marker, Form spawn, Int numSpawns, Int maxActive, Float minDistance, Float maxDistance)
    InitCommon(focal, refCollection, marker, spawn, maxActive, minDistance, maxDistance)
    SpawnsRemaining = numSpawns
EndFunction


Function InitMaxTime(Actor focal, RefCollectionAlias refCollection, ObjectReference marker, Form spawn, Float spawnTime, Int maxActive, Float minDistance, Float maxDistance)
    InitCommon(focal, refCollection, marker, spawn, maxActive, minDistance, maxDistance)
    SpawnEndtime = Utility.GetCurrentRealTime() + spawnTime
EndFunction


Function UpdateMarkers()
    MoveTo(FocalRef)
    FoundMarkers = SpawnUtils.FindSpawnMarkers(FocalRef, ReferenceMarker, SpawnMarkers, SwarmMinSpawnDistance, SwarmMaxSpawnDistance)
EndFunction


Function TrySpawn()
    Int i = 0
    Int[] indices = ChanceApi.ShuffledIndices(FoundMarkers.Length)
    Int nextMarker = 0
    While (SpawnsRemaining != 0) && (SpawnsActive < SwarmMaxActiveSpawns) && (nextMarker < indices.Length)
        ObjectReference marker = FoundMarkers[indices[nextMarker]]
        nextMarker += 1

        Actor thisActor = marker.PlaceAtMe(SwarmSpawn, abInitiallyDisabled = True) as Actor
        SwarmSpawns.AddRef(thisActor)
        SpawnsActive += 1
        SpawnsRemaining -= 1

        thisActor.MoveToNearestNavmeshLocation()
        thisActor.SetAngle(0.0, thisActor.GetAngleY(), thisActor.GetAngleZ())
        thisActor.SetValue(HoldupImmunity, 1)
        thisActor.SetValue(Assistance, 1)
        thisActor.SetValue(Confidence, 4)
        thisActor.SetValue(Aggresion, 1)
        RegisterForRemoteEvent(thisActor, "OnDying")
        thisActor.Enable()
        i += 1
    EndWhile
EndFunction


Event OnTimer(Int timerId)
    If timerId == SpawnTimerId
        Bool shouldTrySpawn = (SpawnEndtime < 0.0) || (Utility.GetCurrentGameTime() < SpawnEndtime)
        If shouldTrySpawn
            TrySpawn()
        EndIf
        If shouldTrySpawn || (SpawnsActive > 0)
            StartTimer(SpawnTimerInterval, SpawnTimerId)
        Else
            Self.Disable()
            Self.Delete()
        EndIf
    ElseIf timerId == MarkersTimerId
    EndIf
EndEvent


Event Actor.OnDying(Actor akSender, Actor akKiller)
    SwarmSpawns.RemoveRef(akSender)
    SpawnsActive -= 1
EndEvent
