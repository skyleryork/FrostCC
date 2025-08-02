Scriptname ContaminationMisfortuneScript extends ReferenceAlias


Int Property PumpTimerId = 1 AutoReadOnly
Float Property PumpTimerInterval = 1 AutoReadOnly


Float Property MisfortuneChance Auto Const Mandatory
Float Property MisfortuneDuration Auto Const Mandatory

Perk[] Property ContaminationPerks Auto Const Mandatory
FormList Property Pristine Auto Const Mandatory
FormList Property Contaminated Auto Const Mandatory

Message Property ContaminationMessage Auto Const Mandatory
Message Property ContaminationPerkMessage Auto Const Mandatory


Actor Player = None
Bool InRadiation = False
Float ScaledMisfortuneChance = 0.0
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
    While i < ContaminationPerks.Length
        If !Player.HasPerk(ContaminationPerks[i])
            Player.AddPerk(ContaminationPerks[i])
            Unlock()
            ContaminationPerkMessage.Show(i + 1)
            return True
        EndIf
        i += 1
    EndWhile
    Unlock()
    return False
EndFunction


Function ParseSettings()
    Float chanceSetting = CrowdControlApi.GetFloatSetting("Misfortunes", "ContaminationChance", -1.0)
    If chanceSetting < 0.0
        chanceSetting = MisfortuneChance
    EndIf

    Float durationSetting = CrowdControlApi.GetFloatSetting("Misfortunes", "ContaminationDuration", -1.0)
    If durationSetting < 0.0
        durationSetting = MisfortuneDuration
    EndIf

    ScaledMisfortuneChance = Chance.CalculateTimescaledChance(chanceSetting, durationSetting, PumpTimerInterval)
EndFunction


Event OnInit()
    Debug.Trace("ContaminationMisfortuneScript: OnInit")

    If ContaminationPerks.Length == 0 || Pristine.GetSize() != Contaminated.GetSize()
        Debug.Trace("ContaminationMisfortuneScript: ContaminationPerks empty or Pristine/Contaminated size mismatch")
    EndIf

    If Player == None
        Player = Game.GetPlayer()
    EndIf

    ParseSettings()

    RegisterForRadiationDamageEvent(Player)
    StartTimer(Utility.RandomFloat(0.0, PumpTimerInterval), PumpTimerId)
EndEvent


Event OnPlayerLoadGame()
    ParseSettings()
EndEvent


Bool Function RollMisfortune()
    If !Player.HasPerk(ContaminationPerks[0])
        return False
    EndIf
    return Utility.RandomFloat() <= ScaledMisfortuneChance
EndFunction


Perk Function HighestRankPerk()
    Int i = ContaminationPerks.Length - 1
    While i >= 0
        If Player.HasPerk(ContaminationPerks[i])
            return ContaminationPerks[i]
        EndIf
        i -= 1
    EndWhile
    return None
EndFunction


Function ApplyMisfortune()
    Form[] allItems = Player.GetInventoryItems()
    Int[] indices = ChanceApi.ShuffledIndices(allItems.Length)

    Form item = None
    Form replaceItem = None
    Int i = 0
    While i < indices.Length
        Int j = indices[i]
        Int k = Pristine.Find(allItems[j])
        If k >= 0
            item = allItems[j]
            replaceItem = Contaminated.GetAt(k)
            i = indices.Length
        EndIf
        i += 1
    EndWhile

    If !item || !replaceItem
        return
    EndIf

    Player.RemovePerk(HighestRankPerk())
    Player.RemoveItem(item, abSilent = True)
    Player.AddItem(replaceItem, abSilent = True)
    ContaminationMessage.Show()
EndFunction


Event OnRadiationDamage(ObjectReference akTarget, bool abIngested)
    If !abIngested
        InRadiation = True
    EndIf
EndEvent


Event OnTimer(Int timerId)
    If timerId == PumpTimerId
        If InRadiation
            Lock()
            If RollMisfortune()
                ApplyMisfortune()
            EndIf
            Unlock()
            InRadiation = False
        EndIf
        RegisterForRadiationDamageEvent(Player)
        StartTimer(PumpTimerInterval, PumpTimerId)
    EndIf
EndEvent
