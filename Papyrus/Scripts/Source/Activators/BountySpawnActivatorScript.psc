Scriptname Activators:BountySpawnActivatorScript extends ObjectReference


Struct BountyParams
    Int minQuantity
    Int maxQuantity
    Float spawnRadius
    Bool hostile
    Form loot
EndStruct


Faction Property PlayerEnemyFaction Auto Const Mandatory
Container Property SpawnLootContainer Auto Const Mandatory


ObjectReference[] Spawns = None
ObjectReference LootContainer = None
Int[] LootDistribution = None
Form[] LootItems = None


Function Init(Form[] toSpawn, BountyParams params)
    ;Debug.Trace("SpawnActivatorScript Init")
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

    If params.loot
        LootContainer = Self.PlaceAtMe(SpawnLootContainer, abInitiallyDisabled = True)
        LootContainer.Lock()
        LootContainer.AddItem(params.loot)

        Int flatCount = 0
        Form[] items = LootContainer.GetInventoryItems()
        i = 0
        While i < items.Length
            flatCount += LootContainer.GetItemCount(items[i])
            i += 1
        EndWhile

        LootItems = new Form[flatCount]
        i = 0
        Int j = 0
        While i < items.Length
            Int count = LootContainer.GetItemCount(items[i])
            While count
                LootItems[j] = items[i]
                count -= 1
                j += 1
            EndWhile
            i += 1
        EndWhile

        LootDistribution = new Int[LootItems.Length]
        i = 0
        While i < LootDistribution.Length
            LootDistribution[i] = Utility.RandomInt(0, Spawns.Length - 1)
            i += 1
        EndWhile
    EndIf
EndFunction


Function HandleSpawnDeath(ObjectReference spawn)
    Int spawnIndex = Spawns.Find(spawn)
    If spawnIndex < 0
        Debug.Trace("BountSpawnActivatorScript::HandleSpawnDeath - unknown spawn!")
        return
    ElseIf !Spawns[spawnIndex]
        Debug.Trace("BountSpawnActivatorScript::HandleSpawnDeath - repeat spawn!")
        return
    EndIf

    Spawns[spawnIndex] = None

    If LootContainer && LootItems && LootDistribution
        Int i = 0
        While i < LootDistribution.Length
            If LootDistribution[i] == spawnIndex
                LootContainer.RemoveItem(LootItems[i], 1, True, spawn)
                LootItems[i] = None
            EndIf
            i += 1
        EndWhile
    EndIf

    Int count = 0
    Int i = 0
    While i < Spawns.Length
        If Spawns[i]
            count += 1
        EndIf
        i += 1
    EndWhile

    If !count
        If LootContainer
            LootContainer.Delete()
        EndIf

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
