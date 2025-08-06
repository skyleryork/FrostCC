Scriptname Swarm:SwarmScript extends ReferenceAlias


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

String Property SwarmChanceConfig Auto Const Mandatory
String Property SwarmDurationConfig Auto Const Mandatory
String Property SwarmMinSpawnDistanceConfig Auto Const Mandatory
String Property SwarmMaxSpawnDistanceConfig Auto Const Mandatory

Activator Property SwarmSpawnActivator Auto Const Mandatory
RefCollectionAlias Property SwarmSpawns Auto Const Mandatory


Runtime:RPGScript Runtime = None
Float minSpawnDistance = 0.0
Float maxSpawnDistance = 0.0

Actor Player = None
Swarm:SwarmSpawnActivatorScript SwarmSpawnActivatorRef = None


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


Event Runtime:RPGScript.OnParseSettings(Runtime:RPGScript ref, Var[] args)
    ParseSettings()
EndEvent


Event Runtime:RPGScript.OnInterval(Runtime:RPGScript ref, Var[] args)
    If !Runtime:RPGScript.ShouldHandleEvent(Self, args)
        return
    EndIf

    If !ref.NextSwarm(SwarmIntervalDays)
        ref.OnApplyResult(Self, False)
        return
    EndIf

    SwarmSpawnActivatorRef = Player.PlaceAtMe(SwarmSpawnActivator) As Swarm:SwarmSpawnActivatorScript
    SwarmSpawnActivatorRef.Init(SwarmSpawns, SwarmSpawn, SwarmMaxSpawns, SwarmMaxActiveSpawns, SwarmMinSpawnDistance, SwarmMaxSpawnDistance)

    ref.OnApplyResult(Self, True)
EndEvent
