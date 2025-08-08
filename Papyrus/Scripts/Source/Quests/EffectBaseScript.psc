Scriptname Quests:EffectBaseScript extends Quest


Float Property TimerInterval = 1.0 Auto Const
Float Property Chance Auto Const Mandatory
Float Property Duration = 0.0 Auto Const
FormList Property Perks Auto Const Mandatory
Message Property AddMessage Auto Const Mandatory
Message Property ExecuteMessage Auto Const
String Property CategoryConfig Auto Const Mandatory
String Property ChanceConfig Auto Const Mandatory
String Property DurationConfig = "" Auto Const
ReferenceAlias Property PlayerRef Auto Const Mandatory

Actor Player = None
Int Count = 0
Float CalculatedChance = 0.0


Bool Function IncrementCount()
    Count += 1
    ShowAddMessage()
    UpdatePerks()
    return True
EndFunction


Function DecrementCount()
    If Count
        Count -= 1
    EndIf
EndFunction


Actor Function GetPlayer()
    return Player
EndFunction


Int Function GetCount()
    return Count
EndFunction


String Function GetConfigCategory()
    return CategoryConfig
EndFunction


Function ShowAddMessage()
    If AddMessage
        AddMessage.Show(Count)
    EndIf
EndFunction


Function ShowExecuteMessage()
    If ExecuteMessage
        ExecuteMessage.Show()
    EndIf
EndFunction


Function EvaluateSettings()
    Float chanceSetting = CrowdControlApi.GetFloatSetting(CategoryConfig, ChanceConfig, Chance)

    If Duration > 0.0
        Float durationSetting = CrowdControlApi.GetFloatSetting(CategoryConfig, DurationConfig, Duration)
        CalculatedChance = Quests:ChanceLib.CalculateTimescaledChance(chanceSetting, durationSetting, TimerInterval)
        Debug.Trace(GetName() + " - EvaluateSettings -- calculated " + CalculatedChance + " chance every " + TimerInterval + " second(s)")
    Else
        CalculatedChance = chanceSetting
        Debug.Trace(GetName() + " - EvaluateSettings -- calculated " + CalculatedChance + " chance every event")
    EndIf
EndFunction


Bool Function Roll()
    If !Count
        return False
    EndIf
    return Utility.RandomFloat() <= CalculatedChance
EndFunction


Function UpdatePerks()
    Int i = 0
    Int clampedCount = Math.Min(Count, Perks.GetSize()) as Int
    While i < clampedCount
        Perk thePerk = Perks.GetAt(i) as Perk
        If !Player.HasPerk(thePerk)
            Player.AddPerk(thePerk)
        EndIf
        i += 1
    EndWhile
    Int j = Perks.GetSize() - 1
    While j >= i
        Perk thePerk = Perks.GetAt(j) as Perk
        If Player.HasPerk(thePerk)
            Player.RemovePerk(thePerk)
        EndIf
        j -= 1
    EndWhile
EndFunction


Bool Function ExecuteEffect(Var[] args = None)
    return False
EndFunction


Event OnQuestInit()
    If Player == None
        Player = PlayerRef.GetActorRef()
        RegisterForRemoteEvent(Player, "OnPlayerLoadGame")
    EndIf

    EvaluateSettings()
EndEvent


Event Actor.OnPlayerLoadGame(Actor akSender)
    EvaluateSettings()
EndEvent
