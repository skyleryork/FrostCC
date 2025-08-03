Scriptname RPGRuntimeScript extends ReferenceAlias


CustomEvent OnInterval
CustomEvent OnRadiation
CustomEvent OnSprinting
CustomEvent OnKilled


Struct StaticData
    ScriptObject ref = None
    Float timerInterval = 0.0
    Int type = -1
    Float staticChance = 0.0
    Float staticDuration = 0.0
    FormList perks = None
    Message addedMessage = None
    Message runMessage = None
    String chanceConfig = ""
    String durationConfig = ""
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
    Float chanceSetting = CrowdControlApi.GetFloatSetting("RPGRuntime", thisStaticData.chanceConfig, thisStaticData.staticChance)

    If thisStaticData.type != TypeKillValue
        Float durationSetting = CrowdControlApi.GetFloatSetting("RPGRuntime", thisStaticData.durationConfig, thisStaticData.staticDuration)
        thisRuntimeData.calculatedChance = Chance.CalculateTimescaledChance(chanceSetting, durationSetting, thisStaticData.timerInterval)
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
    Int timerId = theStaticData.Length
    Unlock()

    ParseSettings(thisStaticData, thisRuntimeData)

    If thisStaticData.type == TypeIntervalValue
        thisStaticData.ref.RegisterForCustomEvent(Self, "OnInterval")
    ElseIf thisStaticData.type == TypeRadiationValue
        thisStaticData.ref.RegisterForCustomEvent(Self, "OnRadiation")
        RegisterForRadiationDamageEvent(Player)
    ElseIf thisStaticData.type == TypeSprintingValue
        thisStaticData.ref.RegisterForCustomEvent(Self, "OnSprinting")
    ElseIf thisStaticData.type == TypeKillValue
        thisStaticData.ref.RegisterForCustomEvent(Self, "OnKilled")
        RegisterForRemoteEvent(Player, "OnKill")
    EndIf

    StartTimer(Utility.RandomFloat(0.0, thisStaticData.timerInterval), timerId)
EndFunction


Function ShowMessageRank(Message theMessage, Int rank, Var[] args = None)
    If !args || args.Length == 0
        theMessage.Show(rank)
    ElseIf args.Length >= 1
        theMessage.Show(rank, args[0] as Float)
    EndIf
EndFunction


Function ShowMessage(Message theMessage, Var[] args = None)
    If !args || args.Length == 0
        theMessage.Show()
    ElseIf args.Length >= 1
        theMessage.Show(args[0] as Float)
    EndIf
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
                return True
            Else
                return False
            EndIf
        EndIf
        i += 1
    EndWhile
    return False
EndFunction


Function OnApplyResult(ScriptObject ref, Bool success, Var[] messageArgs = None)
    If !theStaticData
        return
    EndIf
    Int i = 0
    While i < theStaticData.Length
        If theStaticData[i].ref == ref
            If success
                ShowMessage(theStaticData[i].runMessage, messageArgs)
            Else
                theRuntimeData[i].count += 1
            EndIf
            return
        EndIf
        i += 1
    EndWhile
EndFunction


Bool Function Roll(Int count, Float scaledChance)
    If !count
        return False
    EndIf
    return Utility.RandomFloat() <= scaledChance
EndFunction


Function UpdatePerks(FormList perks, Int count)
    Int i = 0
    While i < count
        Perk thePerk = perks.GetAt(i) as Perk
        If !Player.HasPerk(thePerk)
            Player.AddPerk(thePerk)
        EndIf
        i += 1
    EndWhile
    While i < perks.GetSize()
        Perk thePerk = perks.GetAt(i) as Perk
        If Player.HasPerk(thePerk)
            Player.RemovePerk(thePerk)
        EndIf
        i += 1
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
                args[0] = theStaticData[i].ref
                args[1] = akSender
                args[2] = akVictim
                args[3] = theRuntimeData[i].count
                theRuntimeData[i].count -= 1
                SendCustomEvent("OnKilled", args)
            EndIf
        EndIf
        i += 1
    EndWhile
EndEvent


Event OnTimer(Int timerId)
    StaticData thisStaticData = theStaticData[timerId - 1]
    RuntimeData thisRuntimeData = theRuntimeData[timerId - 1]

    Bool tryRoll = False
    String eventName = ""
    Var[] extraArgs = None

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
            If extraArgs
                args = new Var[2 + extraArgs.Length]
            Else
                args = new Var[2]
            EndIf
            args[0] = thisStaticData.ref
            args[1] = Player
            args[2] = thisRuntimeData.count
            If extraArgs
                Int i = 0
                While i < extraArgs.Length
                    args[i + 2] = extraArgs[i]
                    i += 1
                EndWhile
            EndIf
            thisRuntimeData.count -= 1
            If thisStaticData.type == TypeIntervalValue
                SendCustomEvent("OnInterval", args)
            ElseIf thisStaticData.type == TypeRadiationValue
                SendCustomEvent("OnRadiation", args)
            ElseIf thisStaticData.type == TypeSprintingValue
                SendCustomEvent("OnSprinting", args)
            EndIf
        EndIf
    EndIf

    UpdatePerks(thisStaticData.perks, thisRuntimeData.count)

    StartTimer(thisStaticData.timerInterval, timerId)
EndEvent
