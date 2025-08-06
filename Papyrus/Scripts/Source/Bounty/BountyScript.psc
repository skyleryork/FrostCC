Scriptname Bounty:BountyScript extends ReferenceAlias


Float Property BountyChance Auto Const Mandatory
Float Property BountyDuration Auto Const Mandatory

Float Property BountyMinSpawnDistance Auto Const Mandatory
Float Property BountyMaxSpawnDistance Auto Const Mandatory

FormList Property BountySpawns Auto Const Mandatory
Bounty:BountySpawnActivatorScript:BountyParams Property BountyParams Auto Const Mandatory

Activator Property BountySpawnActivator Auto Const Mandatory
Keyword Property BountySpawnerKeyword Auto Const Mandatory
FormList Property BountySpawnMarkers Auto Const Mandatory

FormList Property BountyPerks Auto Const Mandatory
Message Property BountyMessage Auto Const Mandatory
Message Property BountyPerkMessage Auto Const Mandatory

String Property BountyCategoryConfig = "Bounty" Auto Const
String Property BountyChanceConfig Auto Const Mandatory
String Property BountyDurationConfig Auto Const Mandatory
String Property BountyMinSpawnDistanceConfig Auto Const Mandatory
String Property BountyMaxSpawnDistanceConfig Auto Const Mandatory


Runtime:RPGScript Runtime = None
Float minSpawnDistance = 0.0
Float maxSpawnDistance = 0.0


Bool Function Add()
    return Runtime.OnAdded(Self)
EndFunction


Event OnInit()
    If Runtime == None
        Runtime = GetOwningQuest().GetAlias(0) as Runtime:RPGScript
    EndIf

    If !Runtime.ContainsMisfortune(Self)
        Runtime:RPGScript:StaticData data = new Runtime:RPGScript:StaticData
        data.ref = Self
        data.timerInterval = 1.0
        data.type = Runtime.TypeInterval
        data.staticChance = BountyChance
        data.staticDuration = BountyDuration
        data.perks = BountyPerks
        data.addedMessage = BountyPerkMessage
        data.runMessage = BountyMessage
        data.categoryConfig = BountyCategoryConfig
        data.chanceConfig = BountyChanceConfig
        data.durationConfig = BountyDurationConfig
        data.handleParseSettings = True
        Runtime.RegisterMisfortune(data)

        ParseSettings()

        Debug.Trace("Bounty:BountyScript: registered")
    EndIf
EndEvent


Function ParseSettings()
    minSpawnDistance = CrowdControlApi.GetFloatSetting(BountyCategoryConfig, BountyMinSpawnDistanceConfig, BountyMinSpawnDistance)
    maxSpawnDistance = CrowdControlApi.GetFloatSetting(BountyCategoryConfig, BountyMaxSpawnDistanceConfig, BountyMaxSpawnDistance)
EndFunction


Event Runtime:RPGScript.OnParseSettings(Runtime:RPGScript ref, Var[] args)
    ParseSettings()
EndEvent


Runtime:RPGScript:ApplyResult Function OnInterval(Actor player, Int rank)
    Bounty:BountySpawnActivatorScript:BountyParams params = BountyParams

    ObjectReference[] foundMarkers = SpawnUtils.FindSpawnMarkers(player, BountySpawnMarkers, minSpawnDistance, maxSpawnDistance, BountySpawnerKeyword)
    If foundMarkers.Length == 0
        return None
    EndIf

    ObjectReference marker = foundMarkers[Utility.RandomInt(0, foundMarkers.Length - 1)]
    Bounty:BountySpawnActivatorScript spawner = marker.PlaceAtMe(BountySpawnActivator) as Bounty:BountySpawnActivatorScript
    spawner.AddKeyword(BountySpawnerKeyword)

    FormList spawns = BountySpawns
    Form[] toSpawn = new Form[Utility.RandomInt(params.minQuantity, params.maxQuantity)]
    Int[] indices = ChanceApi.ShuffledIndices(spawns.GetSize())
    Int i = 0
    While i < toSpawn.Length
        toSpawn[i] = spawns.GetAt(indices[i % indices.Length])
        i += 1
    EndWhile

    spawner.Init(toSpawn, params)
    return new Runtime:RPGScript:ApplyResult
EndFunction
