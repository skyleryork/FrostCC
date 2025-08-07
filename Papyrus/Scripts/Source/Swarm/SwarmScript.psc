Scriptname Swarm:SwarmScript extends ReferenceAlias


ReferenceAlias Property RuntimeAlias Auto Const Mandatory


Float Property SwarmChance Auto Const Mandatory
Float Property SwarmDuration Auto Const Mandatory

Float Property SwarmMinSpawnDistance Auto Const Mandatory
Float Property SwarmMaxSpawnDistance Auto Const Mandatory

Int Property SwarmMaxSpawns Auto Const Mandatory
Int Property SwarmMaxActiveSpawns Auto Const Mandatory

Form Property SwarmSpawn Auto Const Mandatory

FormList Property SwarmPerks Auto Const Mandatory
Message Property SwarmMessage Auto Const Mandatory
Message Property SwarmPerkMessage Auto Const Mandatory

Float Property SwarmIntervalDays Auto Const Mandatory

String Property SwarmCategoryConfig = "Swarm" Auto Const
String Property SwarmChanceConfig Auto Const Mandatory
String Property SwarmDurationConfig Auto Const Mandatory
String Property SwarmMinSpawnDistanceConfig Auto Const Mandatory
String Property SwarmMaxSpawnDistanceConfig Auto Const Mandatory
String Property SwarmMaxSpawnsConfig Auto Const Mandatory
String Property SwarmMaxActiveSpawnsConfig Auto Const Mandatory

Keyword Property SwarmActiveSpawn Auto Const Mandatory
Activator Property SwarmSpawnActivator Auto Const Mandatory
RefCollectionAlias Property SwarmSpawns Auto Const Mandatory


Runtime:RPGScript Runtime = None
Swarm:SwarmSpawnActivatorScript SwarmSpawnActivatorRef = None
Float minSpawnDistance = 0.0
Float maxSpawnDistance = 0.0
Int maxSpawns = 0
Int maxActiveSpawns = 0


Bool Function Add()
    return Runtime.OnAdded(Self)
EndFunction


Event OnInit()
    If Runtime == None
        Runtime = RuntimeAlias as Runtime:RPGScript
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
        data.categoryConfig = SwarmCategoryConfig
        data.chanceConfig = SwarmChanceConfig
        data.durationConfig = SwarmDurationConfig
        data.handleParseSettings = True
        Runtime.RegisterMisfortune(data)

        ParseSettings()

        Debug.Trace("Swarm:SwarmScript: registered")
    EndIf
EndEvent


Function ParseSettings()
    minSpawnDistance = CrowdControlApi.GetFloatSetting(SwarmCategoryConfig, SwarmMinSpawnDistanceConfig, SwarmMinSpawnDistance)
    maxSpawnDistance = CrowdControlApi.GetFloatSetting(SwarmCategoryConfig, SwarmMaxSpawnDistanceConfig, SwarmMaxSpawnDistance)
    maxSpawns = CrowdControlApi.GetIntSetting(SwarmCategoryConfig, SwarmMaxSpawnsConfig, SwarmMaxSpawns)
    maxActiveSpawns = CrowdControlApi.GetIntSetting(SwarmCategoryConfig, SwarmMaxActiveSpawnsConfig, SwarmMaxActiveSpawns)
EndFunction


Function RemoveActiveSpawns()
    Int i = 0
    While i < SwarmSpawns.GetCount()
        Actor thisActor = SwarmSpawns.GetAt(i) as Actor
        thisActor.RemoveKeyword(SwarmActiveSpawn)
        i += 1
    EndWhile
EndFunction


Bool Function CleanupSpawns()
    Int i = 0
    While i < SwarmSpawns.GetCount()
        Actor thisActor = SwarmSpawns.GetAt(i) as Actor
        If thisActor.IsDead() || !thisActor.Is3DLoaded()
            thisActor.RemoveKeyword(SwarmActiveSpawn)
            SwarmSpawns.RemoveRef(thisActor)
        Else
            i += 1
        EndIf
    EndWhile
    If SwarmSpawnActivatorRef && SwarmSpawnActivatorRef.IsDeleted()
        SwarmSpawnActivatorRef = None
    EndIf
    return SwarmSpawnActivatorRef || (SwarmSpawns.GetCount() > 0)
EndFunction


Event OnTimer(Int timerId)
    If CleanupSpawns()
        StartTimer(0.5, 1)
    EndIf
EndEvent


Event Runtime:RPGScript.OnParseSettings(Runtime:RPGScript ref, Var[] args)
    ParseSettings()
EndEvent


Runtime:RPGScript:ApplyResult Function OnInterval(Actor player, Int rank)
    If !Runtime.NextSwarm(SwarmIntervalDays)
        return None
    EndIf

    CleanupSpawns()
    RemoveActiveSpawns()

    SwarmSpawnActivatorRef = player.PlaceAtMe(SwarmSpawnActivator) As Swarm:SwarmSpawnActivatorScript
    SwarmSpawnActivatorRef.Init(SwarmSpawns, SwarmSpawn, maxSpawns, maxActiveSpawns, minSpawnDistance, maxSpawnDistance)
    StartTimer(0.5, 1)

    return new Runtime:RPGScript:ApplyResult
EndFunction
