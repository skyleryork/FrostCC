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
    If timerId == 0
        ObjectReference[] spawned = PumpQueue()
        If spawned != None
            Int i = 0
            While i < spawned.Length
                Actor theActor = spawned[i] as Actor
                Faction theFaction = theActor.GetFactionOwner()
                If theFaction != None && !theFaction.IsPlayerEnemy()
                    theActor.AddToFaction(PlayerEnemyFaction)
                    theActor.StopCombat()
                EndIf
                If theActor.GetValue(Game.GetAggressionAV()) < 2
                    theActor.SetValue(Game.GetAggressionAV(), 2)
                EndIf
                i += 1
            EndWhile
        EndIf
    EndIf
EndEvent
