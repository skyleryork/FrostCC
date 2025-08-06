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


Runtime:RPGScript Runtime = None
Float minSpawnDistance = 0.0
Float maxSpawnDistance = 0.0

Actor Player = None
Actor[] ActiveSpawns = None
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
    EndSwarm()

    ActiveSpawns = new Actor[SwarmMaxActiveSpawns]
    SpawnsRemaining = SwarmMaxSpawns

    StartTimer(0.5, 1)
EndFunction


Function EndSwarm()
    ActiveSpawns = None
    SpawnsRemaining = 0
    CancelTimer(1)
EndFunction


Bool Function UpdateActiveSpawns()
    Int i = 0
    ObjectReference[] foundMarkers = SpawnUtils.FindSpawnMarkers(Player, SwarmSpawnMarkers, minSpawnDistance, maxSpawnDistance)
    Int nextMarker = 0
    While (SpawnsRemaining > 0) && (i < ActiveSpawns.Length) && (nextMarker < foundMarkers.Length)
        If !ActiveSpawns[i] || ActiveSpawns[i].IsDead()
            ObjectReference marker = foundMarkers[nextMarker]
            nextMarker += 1

            Actor thisActor = marker.PlaceAtMe(SwarmSpawn, abInitiallyDisabled = True) as Actor
            ActiveSpawns[i] = thisActor
            SpawnsRemaining -= 1

            thisActor.MoveToNearestNavmeshLocation()
            thisActor.SetAngle(0.0, thisActor.GetAngleY(), thisActor.GetAngleZ())
            thisActor.AddToFaction(SwarmPlayerEnemyFaction)
            thisActor.Enable()
            thisActor.SetValue(SwarmHoldupImmunity, 1)
			thisActor.SetValue(SwarmAssistance, 1)
			thisActor.SetValue(SwarmConfidence, 4)
			thisActor.SetValue(SwarmAggresion, 1)
            thisActor.SendAssaultAlarm()
            thisActor.SetAlert(True)
            thisActor.StartCombat(Player, True)
            thisActor.SetLookAt(Player, True)
        EndIf
        i += 1
    EndWhile
    return SpawnsRemaining > 0
EndFunction


Event OnTimer(Int timerId)
    If UpdateActiveSpawns()
        SwarmLastTime.SetValue(Utility.GetCurrentGameTime())
        StartTimer(0.5, 1)
    Else
        EndSwarm()
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
