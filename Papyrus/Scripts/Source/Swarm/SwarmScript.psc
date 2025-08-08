Scriptname Swarm:SwarmScript extends Runtime:IntervalEffectBaseScript


Float Property MinSpawnDistance Auto Const Mandatory
Float Property MaxSpawnDistance Auto Const Mandatory

Int Property MaxSpawns Auto Const Mandatory
Int Property MaxActiveSpawns Auto Const Mandatory

Form Property SpawnTypes Auto Const Mandatory

Float Property IntervalDays Auto Const Mandatory

String Property MinSpawnDistanceConfig Auto Const Mandatory
String Property MaxSpawnDistanceConfig Auto Const Mandatory
String Property MaxSpawnsConfig Auto Const Mandatory
String Property MaxActiveSpawnsConfig Auto Const Mandatory

GlobalVariable Property LastSwarm Auto Const Mandatory
Keyword Property ActiveSpawn Auto Const Mandatory
Activator Property SpawnActivator Auto Const Mandatory

RefCollectionAlias Property Spawns Auto Const Mandatory
ReferenceAlias Property ReferenceMarker Auto Const Mandatory


Swarm:SwarmSpawnActivatorScript spawnActivatorRef = None
Float calculatedMinSpawnDistance = 0.0
Float calculatedMaxSpawnDistance = 0.0
Int calculatedMaxSpawns = 0
Int calculatedMaxActiveSpawns = 0


Function EvaluateSettings()
    Parent.EvaluateSettings()
    calculatedMinSpawnDistance = CrowdControlApi.GetFloatSetting(GetConfigCategory(), MinSpawnDistanceConfig, MinSpawnDistance)
    calculatedMaxSpawnDistance = CrowdControlApi.GetFloatSetting(GetConfigCategory(), MaxSpawnDistanceConfig, MaxSpawnDistance)
    calculatedMaxSpawns = CrowdControlApi.GetIntSetting(GetConfigCategory(), MaxSpawnsConfig, MaxSpawns)
    calculatedMaxActiveSpawns = CrowdControlApi.GetIntSetting(GetConfigCategory(), MaxActiveSpawnsConfig, MaxActiveSpawns)
EndFunction


Function RemoveActiveSpawns()
    Int i = 0
    While i < Spawns.GetCount()
        Actor thisActor = Spawns.GetAt(i) as Actor
        thisActor.RemoveKeyword(ActiveSpawn)
        i += 1
    EndWhile
EndFunction


Bool Function CleanupSpawns()
    Int i = 0
    While i < Spawns.GetCount()
        Actor thisActor = Spawns.GetAt(i) as Actor
        If thisActor.IsDead() || !thisActor.Is3DLoaded()
            thisActor.RemoveKeyword(ActiveSpawn)
            Spawns.RemoveRef(thisActor)
        Else
            i += 1
        EndIf
    EndWhile
    If spawnActivatorRef && spawnActivatorRef.IsDeleted()
        spawnActivatorRef = None
    EndIf
    return spawnActivatorRef || (Spawns.GetCount() > 0)
EndFunction


Event OnTimer(Int timerId)
    Parent.OnTimer(timerId)
    If timerId == 2
        If CleanupSpawns()
            StartTimer(0.5, 2)
        EndIf
    EndIf
EndEvent


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

    CleanupSpawns()
    RemoveActiveSpawns()

    spawnActivatorRef = GetActorReference().PlaceAtMe(SpawnActivator) As Swarm:SwarmSpawnActivatorScript
    spawnActivatorRef.Init(Spawns, ReferenceMarker.GetReference(), SpawnTypes, calculatedmaxSpawns, calculatedMaxActiveSpawns, calculatedMinSpawnDistance, calculatedMaxSpawnDistance)
    StartTimer(0.5, 2)

    return True
EndFunction
