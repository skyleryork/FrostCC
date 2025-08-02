Scriptname Loot:LootOnKillBaseScript extends ReferenceAlias

Float Property LootChance Auto Const Mandatory
Perk[] Property LootPerks Auto Const Mandatory
FormList Property LootRaces Auto Const Mandatory
FormList Property ExcludeKeywords Auto Const
Form Property Loot Auto Const Mandatory
Message Property LootPerkMessage Auto Const Mandatory
Message Property LootMessage Auto Const Mandatory


Actor Player = None
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


Event OnInit()
    If Player == None
        Player = Game.GetPlayer()
    EndIf

    RegisterForRemoteEvent(Player, "OnKill")
EndEvent


Bool Function Add()
    Lock()
    Int i = 0
    While i < LootPerks.Length
        If !Player.HasPerk(LootPerks[i])
            Player.AddPerk(LootPerks[i])
            Unlock()
            LootPerkMessage.Show(i + 1)
            return True
        EndIf
        i += 1
    EndWhile
    Unlock()
    return False
EndFunction


Perk Function HighestRankPerk()
    Int i = LootPerks.Length - 1
    While i >= 0
        If Player.HasPerk(LootPerks[i])
            return LootPerks[i]
        EndIf
        i -= 1
    EndWhile
    return None
EndFunction


Bool Function RollSpawn()
    If !Player.HasPerk(LootPerks[0])
        return False
    EndIf
    return Utility.RandomFloat() <= LootChance
EndFunction


Event Actor.OnKill(Actor akSender, Actor akVictim)
    Lock()
    If RollSpawn()
        If LootRaces.HasForm(akVictim.GetRace())
            If !ExcludeKeywords || !akVictim.HasKeywordInFormList(ExcludeKeywords)
                Player.RemovePerk(HighestRankPerk())
                akVictim.AddItem(Loot)
                LootMessage.Show()
            EndIf
        EndIf
    EndIf
    Unlock()
EndEvent
