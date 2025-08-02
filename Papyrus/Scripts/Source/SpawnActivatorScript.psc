Scriptname SpawnActivatorScript extends ObjectReference


Struct SpawnParams
    Int minQuantity
    Int maxQuantity
    Float spawnRadius
    Bool hostile
    Form loot
EndStruct


Faction Property PlayerEnemyFaction Auto Const Mandatory

ObjectReference[] Spawns = None
Form Loot = None


Event OnInit()
EndEvent


Function Init(Form[] toSpawn, SpawnParams params)
    Spawns = new ObjectReference[toSpawn.Length]
    Int i = 0
    while i < Spawns.Length
        ObjectReference thisSpawn = Self.PlaceAtMe(toSpawn[i], abInitiallyDisabled = True)
        Spawns[i] = thisSpawn

        thisSpawn.MoveToNearestNavmeshLocation()

        Float offsetX = 0.0
        Float offsetY = 0.0
        If params.spawnRadius > 0.0
            Float randomAngle = Utility.RandomFloat(0.0, 360.0)
            Float randomDistance = Utility.RandomFloat(0.0, params.spawnRadius)
            offsetX = Math.Cos(randomAngle) * randomDistance
            offsetY = Math.Sin(randomAngle) * randomDistance
        EndIf
        thisSpawn.MoveTo(thisSpawn, offsetX, offsetY)
        thisSpawn.SetAngle(0.0, thisSpawn.GetAngleY(), thisSpawn.GetAngleZ())

        Actor thisActor = thisSpawn as Actor
        If thisActor
            RegisterForRemoteEvent(thisActor, "OnDying")
            If params.hostile
                Faction theFaction = thisActor.GetFactionOwner()
                If !theFaction || !theFaction.IsPlayerEnemy()
                    thisActor.AddToFaction(PlayerEnemyFaction)
                EndIf
                thisActor.StopCombat()
                If thisActor.GetValue(Game.GetAggressionAV()) < 2
                    thisActor.SetValue(Game.GetAggressionAV(), 2)
                EndIf
            EndIf
        Else
            RegisterForRemoteEvent(thisSpawn, "OnDestructionStageChanged")
            RegisterForRemoteEvent(thisSpawn, "OnActivate")
        EndIf

        thisSpawn.Enable()

        i += 1
    EndWhile

    Loot = params.loot
EndFunction


Function HandleSpawnDeath(ObjectReference spawn)
    Int i = Spawns.Find(spawn)
    If i < 0
        Debug.Trace("SpawnActivatorScript::HandleSpawnDeath - unknown spawn!")
        return
    EndIf

    Spawns[i] = None

    Int count = 0
    i = 0
    While i < Spawns.Length
        If Spawns[i]
            count += 1
        EndIf
        i += 1
    EndWhile

    Bool spawnLoot = Loot != None
    If count && Utility.RandomInt(0, Spawns.Length - 1)
        spawnLoot = False
    EndIf

    If spawnLoot
        spawn.AddItem(Loot)
        Loot = None
    EndIf

    If !count
        Disable()
        Delete()
    EndIf
EndFunction


Bool Function HandleSpawnDestruction(ObjectReference spawn)
    If !spawn.IsDestroyed()
        return False
    EndIf

    HandleSpawnDeath(spawn)
    return True
EndFunction


Event ObjectReference.OnDestructionStageChanged(ObjectReference akSender, int aiOldStage, int aiCurrentStage)
    If HandleSpawnDestruction(akSender)
        UnregisterForRemoteEvent(akSender, "OnDestructionStageChanged")
        UnregisterForRemoteEvent(akSender, "OnActivate")
    EndIf
EndEvent


Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    If HandleSpawnDestruction(akSender)
        UnregisterForRemoteEvent(akSender, "OnDestructionStageChanged")
        UnregisterForRemoteEvent(akSender, "OnActivate")
    EndIf
EndEvent


Event Actor.OnDying(Actor akSender, Actor akKiller)
    HandleSpawnDeath(akSender)
	UnregisterForRemoteEvent(akSender, "OnDying")
EndEvent
