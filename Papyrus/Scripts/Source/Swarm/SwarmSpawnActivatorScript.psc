Scriptname Swarm:SwarmSpawnActivatorScript extends ObjectReference


Keyword Property SwarmActiveSpawn Auto Const Mandatory
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
    StartTimer(0.5, 1)
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
        thisActor.AddKeyword(SwarmActiveSpawn)
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
    If AddSpawns()
        StartTimer(0.5, 1)
    Else
        Self.Disable()
        Self.Delete()
    EndIf
EndEvent
