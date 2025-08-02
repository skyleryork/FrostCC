Scriptname HostileSpawnScript extends ReferenceAlias


Int Property PumpTimerId = 1 AutoReadOnly
Float Property PumpTimerInterval = 1.0 AutoReadOnly


Float Property SpawnChance Auto Const Mandatory
Float Property SpawnDuration Auto Const Mandatory

Float Property MinSpawnDistance Auto Const Mandatory
Float Property MaxSpawnDistance Auto Const Mandatory

Form[] Property HostileSpawns Auto Const Mandatory
SpawnActivatorScript:SpawnParams Property HostileParams Auto Const Mandatory

Activator Property HostileSpawnActivator Auto Const Mandatory
Perk[] Property HostileSpawnPerks Auto Const Mandatory
Keyword Property HostileSpawnerKeyword Auto Const Mandatory
FormList Property HostileSpawnMarkers Auto Const Mandatory

Message Property HostileSpawnPerkMessage Auto Const Mandatory

String Property HostileSpawnChanceString Auto Const Mandatory
String Property HostileSpawnDurationString Auto Const Mandatory


Actor Player = None
Float ScaledSpawnChance = 0.0
Bool Locked = False


Function Lock()
    While Locked
        Utility.Wait(0.2)
    EndWhile
    Locked = True
EndFunction


Function Unlock()
    Locked = False
EndFunction


Bool Function Add()
    Lock()
    Int i = 0
    While i < HostileSpawnPerks.Length
        If !Player.HasPerk(HostileSpawnPerks[i])
            Player.AddPerk(HostileSpawnPerks[i])
            Unlock()
            HostileSpawnPerkMessage.Show(i + 1)
            return True
        EndIf
        i += 1
    EndWhile
    Unlock()
    return False
EndFunction


Function ParseSettings()
    Float chanceSetting = CrowdControlApi.GetFloatSetting("HostileSpawns", HostileSpawnChanceString, -1.0)
    If chanceSetting < 0.0
        chanceSetting = SpawnChance
    EndIf

    Float durationSetting = CrowdControlApi.GetFloatSetting("HostileSpawns", HostileSpawnDurationString, -1.0)
    If durationSetting < 0.0
        durationSetting = SpawnDuration
    EndIf

    ScaledSpawnChance = Chance.CalculateTimescaledChance(chanceSetting, durationSetting, PumpTimerInterval)
EndFunction


Event OnInit()
    If Player == None
        Player = Game.GetPlayer()
    EndIf

    ParseSettings()

    StartTimer(Utility.RandomFloat(0.0, PumpTimerInterval), PumpTimerId)
EndEvent


Event OnPlayerLoadGame()
    ParseSettings()
EndEvent


Bool Function RollMisfortune()
    If !Player.HasPerk(HostileSpawnPerks[0])
        return False
    EndIf
    return Utility.RandomFloat() <= ScaledSpawnChance
EndFunction


Perk Function HighestRankPerk()
    Int i = HostileSpawnPerks.Length - 1
    While i >= 0
        If Player.HasPerk(HostileSpawnPerks[i])
            return HostileSpawnPerks[i]
        EndIf
        i -= 1
    EndWhile
    return None
EndFunction


Function ApplyMisfortune()
    Float minDistance = MinSpawnDistance
    Float maxDistance = MaxSpawnDistance
    SpawnActivatorScript:SpawnParams params = HostileParams

    WorldSpace thisWorldspace = Player.GetWorldspace()
    ObjectReference[] markers = Player.FindAllReferencesOfType(HostileSpawnMarkers, maxDistance)
    ObjectReference[] foundMarkers = new ObjectReference[markers.Length]
    
    Int numFoundMarkers = 0
    int i = 0
    While i < markers.Length
        float distance = Player.GetDistance(markers[i])
        If distance >= minDistance && distance <= maxDistance && markers[i].GetWorldspace() == thisWorldspace && !Player.HasDirectLOS(markers[i]) && !markers[i].HasDirectLOS(Player)
            If markers[i].FindAllReferencesWithKeyword(HostileSpawnerKeyword, 1.0).Length == 0
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
        return
    EndIf

    ObjectReference marker = foundMarkers[Utility.RandomInt(0, numFoundMarkers - 1)]
    SpawnActivatorScript spawner = marker.PlaceAtMe(HostileSpawnActivator) as SpawnActivatorScript

    Form[] spawns = HostileSpawns
    Form[] toSpawn = new Form[Utility.RandomInt(params.minQuantity, params.maxQuantity)]
    Int[] indices = ChanceApi.ShuffledIndices(spawns.Length)
    i = 0
    While i < toSpawn.Length
        toSpawn[i] = spawns[indices[i]]
        i += 1
    EndWhile

    spawner.Init(toSpawn, params)
EndFunction


Event OnTimer(Int timerId)
    If timerId == PumpTimerId
        Lock()
        If RollMisfortune()
            ApplyMisfortune()
        EndIf
        Unlock()
        StartTimer(PumpTimerInterval, PumpTimerId)
    EndIf
EndEvent
