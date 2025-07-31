Scriptname HostileSpawnScript extends SafeSpawnBaseScript


Faction PlayerEnemyFaction = None


Event OnInit()
    Init()

    If PlayerEnemyFaction == None 
        PlayerEnemyFaction = Game.GetFormFromFile(0x106c2f, "Fallout4.esm") as Faction
    EndIf
EndEvent


Event OnPlayerLoadGame()
    Init()
EndEvent


Event OnTimer(Int timerId)
    If timerId == PumpTimerId
        ObjectReference[] spawned = PumpQueue(False)
        If spawned != None
            Int i = 0
            While i < spawned.Length
                Actor theActor = spawned[i] as Actor
                Faction theFaction = theActor.GetFactionOwner()
                If theFaction != None && !theFaction.IsPlayerEnemy()
                    theActor.AddToFaction(PlayerEnemyFaction)
                EndIf
                theActor.StopCombat()
                If theActor.GetValue(Game.GetAggressionAV()) < 2
                    theActor.SetValue(Game.GetAggressionAV(), 2)
                EndIf
                theActor.MoveToNearestNavmeshLocation()
                theActor.Enable()
                i += 1
            EndWhile
        EndIf
    EndIf
EndEvent
