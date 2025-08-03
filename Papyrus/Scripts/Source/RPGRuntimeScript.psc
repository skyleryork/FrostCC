Scriptname RPGRuntimeScript extends ReferenceAlias


CustomEvent OnInterval
CustomEvent OnRadiation
CustomEvent OnSprinting
CustomEvent OnKilled


Struct StaticData
    ScriptObject source = None
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


Int Property TypeInterval = 0 AutoReadOnly
Int Property TypeRadiation = 1 AutoReadOnly
Int Property TypeSprinting = 2 AutoReadOnly
Int Property TypeKill = 3 AutoReadOnly


Actor Player = None
StaticData[] theStaticData = None
RuntimeData[] theRuntimeData = None
Bool InRadiation = False


Function ParseSettings(StaticData thisStaticData, RuntimeData thisRuntimeData)
    ; todo: ini file parsing
    Float chanceSetting = thisStaticData.staticChance

    If thisStaticData.type != TypeKill
        Float durationSetting = thisStaticData.staticDuration
        thisRuntimeData.calculatedChance = Chance.CalculateTimescaledChance(chanceSetting, durationSetting, thisStaticData.timerInterval)
    Else
        thisRuntimeData.calculatedChance = chanceSetting
    EndIf
EndFunction


Function RegisterMisfortune(StaticData thisStaticData)
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

    ParseSettings(thisStaticData, thisRuntimeData)

    If thisStaticData.type == TypeInterval
        thisStaticData.source.RegisterForCustomEvent(Self, "OnInterval")
    ElseIf thisStaticData.type == TypeRadiation
        thisStaticData.source.RegisterForCustomEvent(Self, "OnRadiation")
        RegisterForRadiationDamageEvent(Player)
    ElseIf thisStaticData.type == TypeSprinting
        thisStaticData.source.RegisterForCustomEvent(Self, "OnSprinting")
    ElseIf thisStaticData.type == TypeKill
        RegisterForRemoteEvent(Player, "OnKill")
    EndIf

    StartTimer(Utility.RandomFloat(0.0, thisStaticData.timerInterval), theStaticData.Length)
EndFunction


Function ShowMessage(Message theMessage, Var[] args = None)
    If !args || args.Length == 0
        theMessage.Show()
    ElseIf args.Length == 1
        theMessage.Show(args[0] as Float)
    ElseIf args.Length == 2
        theMessage.Show(args[0] as Float, args[1] as Float)
    ElseIf args.Length == 3
        theMessage.Show(args[0] as Float, args[1] as Float, args[2] as Float)
    ElseIf args.Length >= 4
        theMessage.Show(args[0] as Float, args[1] as Float, args[2] as Float, args[3] as Float)
    EndIf
EndFunction


Bool Function OnAdded(ScriptObject source, Var[] messageArgs = None)
    Int i = 0
    While i < theStaticData.Length
        If theStaticData[i].source == source
            If theRuntimeData[i].count < theStaticData[i].perks.GetSize()
                theRuntimeData[i].count += 1
                ShowMessage(theStaticData[i].addedMessage, messageArgs)
                return True
            Else
                return False
            EndIf
        EndIf
        i += 1
    EndWhile
    return False
EndFunction


Function OnApplyResult(ScriptObject source, Bool success, Var[] messageArgs = None)
    Int i = 0
    While i < theStaticData.Length
        If theStaticData[i].source == source
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
            If theStaticData[i].type == TypeRadiation
                theRuntimeData[i].inRadiation = True
            EndIf
            i += 1
        EndWhile
    EndIf
EndEvent


Event Actor.OnKill(Actor akSender, Actor akVictim)
    Int i = 0
    While i < theStaticData.Length
        If theStaticData[i].type == TypeKill
            If Roll(theRuntimeData[i].count, theRuntimeData[i].calculatedChance)
                Var[] args = new Var[2]
                args[0] = Player
                args[1] = theRuntimeData[i].count
                theRuntimeData[i].count -= 1
                SendCustomEvent("OnKilled", args)
            EndIf
        EndIf
    EndWhile
EndEvent


Event OnTimer(Int timerId)
    StaticData thisStaticData = theStaticData[timerId - 1]
    RuntimeData thisRuntimeData = theRuntimeData[timerId - 1]

    Bool tryRoll = False
    String eventName = ""
    Var[] extraArgs = None

    If thisStaticData.type == TypeInterval
        tryRoll = True
    ElseIf thisStaticData.type == TypeRadiation
        If thisRuntimeData.inRadiation
            tryRoll = True
            thisRuntimeData.inRadiation = False
            RegisterForRadiationDamageEvent(Player)
        EndIf
    ElseIf thisStaticData.type == TypeSprinting
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
            args[0] = Player
            args[1] = thisRuntimeData.count
            If extraArgs
                Int i = 0
                While i < extraArgs.Length
                    args[i + 2] = extraArgs[i]
                    i += 1
                EndWhile
            EndIf
            thisRuntimeData.count -= 1
            If thisStaticData.type == TypeInterval
                SendCustomEvent("OnInterval", args)
            ElseIf thisStaticData.type == TypeRadiation
                SendCustomEvent("OnRadiation", args)
            ElseIf thisStaticData.type == TypeSprinting
                SendCustomEvent("OnSprinting", args)
            EndIf
        EndIf
    EndIf

    UpdatePerks(thisStaticData.perks, thisRuntimeData.count)
EndEvent
