Scriptname Runtime:RPGScript extends ReferenceAlias


GlobalVariable Property SwarmLastTime Auto Const Mandatory


CustomEvent OnParseSettings


Struct ApplyResult
    Float param0 = 0.0
EndStruct


Struct StaticData
    ScriptObject ref = None
    Float timerInterval = 0.0
    Int type = -1
    Float staticChance = 0.0
    Float staticDuration = 0.0
    FormList perks = None
    Message addedMessage = None
    Message runMessage = None
    String categoryConfig = ""
    String chanceConfig = ""
    String durationConfig = ""
    Bool handleParseSettings = False
EndStruct


Struct RuntimeData
    Int count = 0
    float calculatedChance = 0.0
    Bool inRadiation = False
EndStruct


Int TypeIntervalValue = 0 Const
Int TypeRadiationValue = 1 Const
Int TypeSprintingValue = 2 Const
Int TypeKillValue = 3 Const

Int IntervalTimerIdStart = 256 Const


Int Property TypeInterval
  Int Function get()
    return TypeIntervalValue
  EndFunction
EndProperty

Int Property TypeRadiation
  Int Function get()
    return TypeRadiationValue
  EndFunction
EndProperty

Int Property TypeSprinting
  Int Function get()
    return TypeSprintingValue
  EndFunction
EndProperty

Int Property TypeKill
  Int Function get()
    return TypeKillValue
  EndFunction
EndProperty


Actor Player = None
StaticData[] theStaticData = None
RuntimeData[] theRuntimeData = None
Bool Locked = False
Bool InRadiation = False


Function Lock()
    While Locked
        Utility.Wait(0.2)
    EndWhile
    Locked = True
EndFunction


Function Unlock()
    Locked = False
EndFunction


Function ParseSettings(StaticData thisStaticData, RuntimeData thisRuntimeData)
    Float chanceSetting = CrowdControlApi.GetFloatSetting(thisStaticData.categoryConfig, thisStaticData.chanceConfig, thisStaticData.staticChance)

    If thisStaticData.type != TypeKillValue
        Float durationSetting = CrowdControlApi.GetFloatSetting(thisStaticData.categoryConfig, thisStaticData.durationConfig, thisStaticData.staticDuration)
        thisRuntimeData.calculatedChance = ChanceLib.CalculateTimescaledChance(chanceSetting, durationSetting, thisStaticData.timerInterval)
    Else
        thisRuntimeData.calculatedChance = chanceSetting
    EndIf
EndFunction


Bool Function ContainsMisfortune(ScriptObject ref)
    If !theStaticData
        return False
    EndIf
    Int i = 0
    While i < theStaticData.Length
        If theStaticData[i].ref == ref
            return True
        EndIf
        i += 1
    EndWhile
    return False
EndFunction


Function RegisterMisfortune(StaticData thisStaticData)
    Lock()
    If theStaticData == None
        theStaticData = new StaticData[1]
        theStaticData[0] = thisStaticData
    Else
        StaticData[] newData = new StaticData[theStaticData.Length + 1]
        Int i = 0
        While i < theStaticData.Length
            newData[i] = theStaticData[i]
            i += 1
        EndWhile
        newData[i] = thisStaticData
        theStaticData = newData
    EndIf

    RuntimeData thisRuntimeData = new RuntimeData
    If theRuntimeData == None
        theRuntimeData = new RuntimeData[1]
        theRuntimeData[0] = thisRuntimeData
    Else
        RuntimeData[] newData = new RuntimeData[theRuntimeData.Length + 1]
        Int i = 0
        While i < theRuntimeData.Length
            newData[i] = theRuntimeData[i]
            i += 1
        EndWhile
        newData[i] = thisRuntimeData
        theRuntimeData = newData
    EndIf
    Int timerId = theStaticData.Length - 1
    Unlock()

    ParseSettings(thisStaticData, thisRuntimeData)

    If thisStaticData.handleParseSettings
        thisStaticData.ref.RegisterForCustomEvent(Self, "OnParseSettings")
    EndIf

    If thisStaticData.type == TypeRadiationValue
        RegisterForRadiationDamageEvent(Player)
    ElseIf thisStaticData.type == TypeKillValue
        RegisterForRemoteEvent(Player, "OnKill")
    EndIf

    StartTimer(Utility.RandomFloat(0.0, thisStaticData.timerInterval), IntervalTimerIdStart + timerId)
EndFunction


Function ShowMessageRank(Message theMessage, Int rank, Var[] args = None)
    If !args || args.Length == 0
        theMessage.Show(rank)
    ElseIf args.Length >= 1
        theMessage.Show(rank, args[0] as Float)
    EndIf
EndFunction


Function ShowMessage(Message theMessage, ApplyResult result)
    theMessage.Show(result.param0)
EndFunction


Bool Function NextSwarm(Float intervalDays)
    Lock()
    Float now = Utility.GetCurrentGameTime()
    If (now - SwarmLastTime.GetValue()) < intervalDays
        Unlock()
        return False
    EndIf
    SwarmLastTime.SetValue(now)
    Unlock()
    return True
EndFunction


Bool Function OnAdded(ScriptObject ref, Var[] messageArgs = None)
    If !theStaticData
        return False
    EndIf
    Int i = 0
    While i < theStaticData.Length
        If theStaticData[i].ref == ref
            If theRuntimeData[i].count < theStaticData[i].perks.GetSize()
                theRuntimeData[i].count += 1
                ShowMessageRank(theStaticData[i].addedMessage, theRuntimeData[i].count, messageArgs)
                UpdatePerks(theStaticData[i].perks, theRuntimeData[i].count)
                return True
            Else
                return False
            EndIf
        EndIf
        i += 1
    EndWhile
    return False
EndFunction


Bool Function Roll(Int count, Float scaledChance)
    If !count
        return False
    EndIf
    return Utility.RandomFloat() <= scaledChance
EndFunction


Function UpdatePerks(FormList perks, Int count)
    Int i = 0
    Int clampedCount = Math.Min(count, perks.GetSize()) as Int
    While i < clampedCount
        Perk thePerk = perks.GetAt(i) as Perk
        If !Player.HasPerk(thePerk)
            Player.AddPerk(thePerk)
        EndIf
        i += 1
    EndWhile
    Int j = perks.GetSize() - 1
    While j >= i
        Perk thePerk = perks.GetAt(j) as Perk
        If Player.HasPerk(thePerk)
            Player.RemovePerk(thePerk)
        EndIf
        j -= 1
    EndWhile
EndFunction


Event OnInit()
    If Player == None
        Player = Game.GetPlayer()
    EndIf
EndEvent


Event OnPlayerLoadGame()
    If theStaticData && theRuntimeData
        Int i = 0
        While i < theStaticData.Length
            ParseSettings(theStaticData[i], theRuntimeData[i])
            i += 1
        EndWhile
    EndIf
    SendCustomEvent("OnParseSettings", None)
EndEvent


Event OnRadiationDamage(ObjectReference akTarget, bool abIngested)
    If !abIngested
        Int i = 0
        While i < theStaticData.Length
            If theStaticData[i].type == TypeRadiationValue
                theRuntimeData[i].inRadiation = True
            EndIf
            i += 1
        EndWhile
    EndIf
EndEvent


Event Actor.OnKill(Actor akSender, Actor akVictim)
    If !theStaticData
        return
    EndIf
    Int i = 0
    While i < theStaticData.Length
        If theStaticData[i].type == TypeKillValue
            If Roll(theRuntimeData[i].count, theRuntimeData[i].calculatedChance)
                Var[] args = new Var[3]
                args[0] = akSender
                args[1] = akVictim
                args[2] = theRuntimeData[i].count
                ApplyResult resultArgs = theStaticData[i].ref.CallFunction("OnKilled", args) As ApplyResult
                If resultArgs
                    theRuntimeData[i].count -= 1
                    If theStaticData[i].runMessage
                        ShowMessage(theStaticData[i].runMessage, resultArgs)
                    EndIf
                    UpdatePerks(theStaticData[i].perks, theRuntimeData[i].count)
                EndIf
            EndIf
        EndIf
        i += 1
    EndWhile
EndEvent


Float Function HandleSystemTimer(Int timerId)
    return 0
EndFunction


Float Function HandleRPGTimer(Int timerId)
    StaticData thisStaticData = theStaticData[timerId - IntervalTimerIdStart]
    RuntimeData thisRuntimeData = theRuntimeData[timerId - IntervalTimerIdStart]

    Bool tryRoll = False
    String eventName = ""

    If thisStaticData.type == TypeIntervalValue
        tryRoll = True
    ElseIf thisStaticData.type == TypeRadiationValue
        If thisRuntimeData.inRadiation
            tryRoll = True
            thisRuntimeData.inRadiation = False
            RegisterForRadiationDamageEvent(Player)
        EndIf
    ElseIf thisStaticData.type == TypeSprintingValue
        If Player.IsSprinting() || (Player.IsInPowerArmor() && Player.IsRunning())
            tryRoll = True
        EndIf
    EndIf

    If tryRoll
        If Roll(thisRuntimeData.count, thisRuntimeData.calculatedChance)
            Var[] args = None
            args = new Var[2]
            args[0] = Player
            args[1] = thisRuntimeData.count
            ApplyResult resultArgs = None
            If thisStaticData.type == TypeIntervalValue
                resultArgs = thisStaticData.ref.CallFunction("OnInterval", args) As ApplyResult
            ElseIf thisStaticData.type == TypeRadiationValue
                resultArgs = thisStaticData.ref.CallFunction("OnRadiation", args) As ApplyResult
            ElseIf thisStaticData.type == TypeSprintingValue
                resultArgs = thisStaticData.ref.CallFunction("OnSprinting", args) As ApplyResult
            EndIf
            If resultArgs
                thisRuntimeData.count -= 1
                If thisStaticData.runMessage
                    ShowMessage(thisStaticData.runMessage, resultArgs)
                EndIf
                UpdatePerks(thisStaticData.perks, thisRuntimeData.count)
            EndIf
        EndIf
    EndIf

    return thisStaticData.timerInterval
EndFunction


Event OnTimer(Int timerId)
    Float interval
    If timerId < IntervalTimerIdStart
        interval = HandleSystemTimer(timerId)
    Else
        interval = HandleRPGTimer(timerId)
    EndIf

    If interval
        StartTimer(interval, timerId)
    EndIf
EndEvent
