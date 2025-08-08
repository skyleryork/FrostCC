Scriptname Swarm:SwarmScript extends Runtime:IntervalEffectBaseScript


Float Property MinSpawnDistance Auto Const Mandatory
Float Property MaxSpawnDistance Auto Const Mandatory

Int Property MaxSpawns = -1 Auto Const
Float Property SpawnDuration = -1.0 Auto Const
Int Property MaxActiveSpawns Auto Const Mandatory

Form Property SpawnTypes Auto Const Mandatory

Float Property IntervalDays Auto Const Mandatory

String Property MinSpawnDistanceConfig Auto Const Mandatory
String Property MaxSpawnDistanceConfig Auto Const Mandatory
String Property MaxSpawnsConfig Auto Const Mandatory
String Property SpawnDurationConfig Auto Const Mandatory
String Property MaxActiveSpawnsConfig Auto Const Mandatory

GlobalVariable Property LastSwarm Auto Const Mandatory
Keyword Property ActiveSpawn Auto Const Mandatory
Activator Property SpawnActivator Auto Const Mandatory

RefCollectionAlias Property Spawns Auto Const Mandatory
ReferenceAlias Property ReferenceMarker Auto Const Mandatory


Float calculatedMinSpawnDistance = 0.0
Float calculatedMaxSpawnDistance = 0.0
Int calculatedMaxSpawns = -1
Float calculatedSpawnDuration = -1.0
Int calculatedMaxActiveSpawns = 0


Function EvaluateSettings()
    Parent.EvaluateSettings()
    calculatedMinSpawnDistance = CrowdControlApi.GetFloatSetting(GetConfigCategory(), MinSpawnDistanceConfig, MinSpawnDistance)
    calculatedMaxSpawnDistance = CrowdControlApi.GetFloatSetting(GetConfigCategory(), MaxSpawnDistanceConfig, MaxSpawnDistance)
    calculatedMaxSpawns = CrowdControlApi.GetIntSetting(GetConfigCategory(), MaxSpawnsConfig, MaxSpawns)
    calculatedMaxActiveSpawns = CrowdControlApi.GetIntSetting(GetConfigCategory(), MaxActiveSpawnsConfig, MaxActiveSpawns)
    calculatedSpawnDuration = CrowdControlApi.GetFloatSetting(GetConfigCategory(), SpawnDurationConfig, SpawnDuration)
EndFunction


Bool Function NextSwarm()
    Float now = Utility.GetCurrentGameTime()
    If (now - LastSwarm.GetValue()) < IntervalDays
        return False
    EndIf
    LastSwarm.SetValue(now)
    return True
EndFunction


Bool Function ExecuteEffect(Var[] args = None)
    If !NextSwarm()
        return False
    EndIf

    Swarm:SwarmSpawnActivatorScript spawnActivatorRef = GetActorReference().PlaceAtMe(SpawnActivator) As Swarm:SwarmSpawnActivatorScript
    If calculatedMaxSpawns >= 0
        spawnActivatorRef.InitMaxCount(GetActorReference(), Spawns, ReferenceMarker.GetReference(), SpawnTypes, calculatedMaxSpawns, calculatedMaxActiveSpawns, calculatedMinSpawnDistance, calculatedMaxSpawnDistance)
    ElseIf calculatedSpawnDuration >= 0.0
        spawnActivatorRef.InitMaxTime(GetActorReference(), Spawns, ReferenceMarker.GetReference(), SpawnTypes, calculatedSpawnDuration, calculatedMaxActiveSpawns, calculatedMinSpawnDistance, calculatedMaxSpawnDistance)
    Else
        return False
    EndIf

    return True
EndFunction
