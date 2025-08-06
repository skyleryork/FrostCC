Scriptname Swarm:SwarmScript extends ReferenceAlias


Float Property SwarmChance Auto Const Mandatory
Float Property SwarmDuration Auto Const Mandatory

Float Property SwarmMinSpawnDistance Auto Const Mandatory
Float Property SwarmMaxSpawnDistance Auto Const Mandatory

Int Property SwarmMaxSpawns Auto Const Mandatory
Int Property SwarmMaxActiveSpawns Auto Const Mandatory

Form Property SwarmSpawn Auto Const Mandatory
FormList Property SwarmSpawnMarkers Auto Const Mandatory
Faction Property SwarmPlayerEnemyFaction Auto Const Mandatory
ActorValue Property SwarmHoldupImmunity Auto Const Mandatory
ActorValue Property SwarmAssistance Auto Const Mandatory
ActorValue Property SwarmConfidence Auto Const Mandatory
ActorValue Property SwarmAggresion Auto Const Mandatory

FormList Property SwarmPerks Auto Const Mandatory
Message Property SwarmMessage Auto Const Mandatory
Message Property SwarmPerkMessage Auto Const Mandatory

GlobalVariable Property SwarmLastTime Auto Const Mandatory
Float Property SwarmIntervalDays Auto Const Mandatory

String Property SwarmChanceConfig Auto Const Mandatory
String Property SwarmDurationConfig Auto Const Mandatory
String Property SwarmMinSpawnDistanceConfig Auto Const Mandatory
String Property SwarmMaxSpawnDistanceConfig Auto Const Mandatory

RefCollectionAlias Property SwarmSpawns Auto Const Mandatory


Runtime:RPGScript Runtime = None
Float minSpawnDistance = 0.0
Float maxSpawnDistance = 0.0

Actor Player = None
Int SpawnsRemaining = 0


Bool Function Add()
    return Runtime.OnAdded(Self)
EndFunction


Event OnInit()
    If Player == None
        Player = Game.GetPlayer()
    EndIf

    If Runtime == None
        Runtime = GetOwningQuest().GetAlias(0) as Runtime:RPGScript
    EndIf

    If !Runtime.ContainsMisfortune(Self)
        Runtime:RPGScript:StaticData data = new Runtime:RPGScript:StaticData
        data.ref = Self
        data.timerInterval = 1.0
        data.type = Runtime.TypeInterval
        data.staticChance = SwarmChance
        data.staticDuration = SwarmDuration
        data.perks = SwarmPerks
        data.addedMessage = SwarmPerkMessage
        data.runMessage = SwarmMessage
        data.chanceConfig = SwarmChanceConfig
        data.durationConfig = SwarmDurationConfig
        data.handleParseSettings = True
        Runtime.RegisterMisfortune(data)

        ParseSettings()

        Debug.Trace("Swarm:SwarmScript: registered")
    EndIf
EndEvent


Function ParseSettings()
    minSpawnDistance = CrowdControlApi.GetFloatSetting("RPGRuntime", SwarmMinSpawnDistanceConfig, SwarmMinSpawnDistance)
    maxSpawnDistance = CrowdControlApi.GetFloatSetting("RPGRuntime", SwarmMaxSpawnDistanceConfig, SwarmMaxSpawnDistance)
EndFunction


Function StartSwarm(Float time)
    SwarmSpawns.RemoveAll()
    SpawnsRemaining = SwarmMaxSpawns
    StartTimer(0.5, 1)
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
    ObjectReference[] foundMarkers = SpawnUtils.FindSpawnMarkers(Player, SwarmSpawnMarkers, minSpawnDistance, maxSpawnDistance)
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


Event OnTimer(Int timerId)
    CleanupSpawns()
    If AddSpawns()
        SwarmLastTime.SetValue(Utility.GetCurrentGameTime())
        StartTimer(0.5, 1)
    EndIf
EndEvent


Event Runtime:RPGScript.OnParseSettings(Runtime:RPGScript ref, Var[] args)
    ParseSettings()
EndEvent


Event Runtime:RPGScript.OnInterval(Runtime:RPGScript ref, Var[] args)
    If !Runtime:RPGScript.ShouldHandleEvent(Self, args)
        return
    EndIf

    Float now = Utility.GetCurrentGameTime()
    If (now - SwarmLastTime.GetValue()) < SwarmIntervalDays
        ref.OnApplyResult(Self, False)
        return
    EndIf

    StartSwarm(now)
    ref.OnApplyResult(Self, True)
EndEvent
