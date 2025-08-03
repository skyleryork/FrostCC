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
String Property BountyChanceConfig Auto Const Mandatory
String Property BountyDurationConfig Auto Const Mandatory


RPGRuntimeScript Runtime = None


Bool Function Add()
    return Runtime.OnAdded(Self)
EndFunction


Event OnInit()
    If Runtime == None
        Runtime = GetOwningQuest().GetAlias(0) as RPGRuntimeScript
    EndIf

    If !Runtime.ContainsMisfortune(Self)
        RPGRuntimeScript:StaticData data = new RPGRuntimeScript:StaticData
        data.ref = Self
        data.timerInterval = 1.0
        data.type = Runtime.TypeInterval
        data.staticChance = BountyChance
        data.staticDuration = BountyDuration
        data.perks = BountyPerks
        data.addedMessage = BountyPerkMessage
        data.runMessage = BountyMessage
        data.chanceConfig = BountyChanceConfig
        data.durationConfig = BountyDurationConfig
        Runtime.RegisterMisfortune(data)

        Debug.Trace("Bounty:BountyScript: registered")
    EndIf
EndEvent


Event RPGRuntimeScript.OnInterval(RPGRuntimeScript ref, Var[] args)
    If (args[0] as ScriptObject) != Self
        return
    EndIf
    
    Actor Player = args[1] as Actor

    Float minDistance = BountyMinSpawnDistance
    Float maxDistance = BountyMaxSpawnDistance
    Bounty:BountySpawnActivatorScript:BountyParams params = BountyParams

    WorldSpace thisWorldspace = Player.GetWorldspace()
    ObjectReference[] markers = Player.FindAllReferencesOfType(BountySpawnMarkers, maxDistance)
    ObjectReference[] foundMarkers = new ObjectReference[markers.Length]

    Int numFoundMarkers = 0
    int i = 0
    While i < markers.Length
        float distance = Player.GetDistance(markers[i])
        If distance >= minDistance && distance <= maxDistance && markers[i].GetWorldspace() == thisWorldspace
            If !Player.HasDetectionLOS(markers[i]) && !markers[i].HasDirectLOS(Player)
                If markers[i].FindAllReferencesWithKeyword(BountySpawnerKeyword, minDistance).Length == 0
                    foundMarkers[numFoundMarkers] = markers[i]
                    numFoundMarkers += 1
                EndIf
            EndIf
        EndIf
        i += 1
    EndWhile

    If numFoundMarkers == 0
        ref.OnApplyResult(Self, False)
        return
    EndIf

    ObjectReference marker = foundMarkers[Utility.RandomInt(0, numFoundMarkers - 1)]
    Bounty:BountySpawnActivatorScript spawner = marker.PlaceAtMe(BountySpawnActivator) as Bounty:BountySpawnActivatorScript
    spawner.AddKeyword(BountySpawnerKeyword)

    FormList spawns = BountySpawns
    Form[] toSpawn = new Form[Utility.RandomInt(params.minQuantity, params.maxQuantity)]
    Int[] indices = ChanceApi.ShuffledIndices(spawns.GetSize())
    i = 0
    While i < toSpawn.Length
        toSpawn[i] = spawns.GetAt(indices[i % indices.Length])
        i += 1
    EndWhile

    spawner.Init(toSpawn, params)

    ref.OnApplyResult(Self, True)
EndEvent
