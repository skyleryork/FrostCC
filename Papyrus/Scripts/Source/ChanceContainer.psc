Scriptname ChanceContainer extends ObjectReference


Int Property ChanceFilter Auto

Actor Player = None
ChanceLib Chance = None
Form EmptyItem = None

EffectShader JunkHighlight = None
EffectShader CommonHighlight = None
EffectShader RareHighlight = None
EffectShader EpicHighlight = None
EffectShader LegendaryHighlight = None
EffectShader ActiveHighlight = None


Function Init()
    If Player == None
        Player = Game.GetPlayer()
    EndIf

    If Chance == None
        Chance = ( Game.GetFormFromFile(0x24787, "CrowdControl.esp") as Quest ).GetAlias(0) as ChanceLib
    Endif

    If EmptyItem == None
        EmptyItem = Game.GetFormFromFile(0xF, "Fallout4.esm") as Form
    EndIf

    If JunkHighlight == None
        JunkHighlight = Game.GetFormFromFile(0x1358C, "CrowdControl.esp") as EffectShader
    EndIf
    If CommonHighlight == None
        CommonHighlight = Game.GetFormFromFile(0x1358D, "CrowdControl.esp") as EffectShader
    EndIf
    If RareHighlight == None
        RareHighlight = Game.GetFormFromFile(0x1358E, "CrowdControl.esp") as EffectShader
    EndIf
    If EpicHighlight == None
        EpicHighlight = Game.GetFormFromFile(0x1358F, "CrowdControl.esp") as EffectShader
    EndIf
    If LegendaryHighlight == None
        LegendaryHighlight = Game.GetFormFromFile(0x13590, "CrowdControl.esp") as EffectShader
    EndIf
EndFunction


Function SetLockTierAndRefresh(Int tier)
    Self.SetLockLevel(ChanceLib.LockTierToLevel(tier))
    If ( tier > 0 ) && !IsLocked()
        Lock()
    ElseIf ( tier == 0 ) && IsLocked()
        Lock(False)
    EndIf
EndFunction


; forces an unlocked container to be locked, returns true if so
Bool Function RollLock()
    Int tier = ChanceLib.LockLevelToTier(Self.GetLockLevel())
    If tier == 0
        Int newTier = Chance.RollLock()
        If newTier > 0
            SetLockTierAndRefresh(newTier)
            return True
        EndIf
    EndIf
    return False
EndFunction


; forces a locked container to be unlocked, returns true if so
Bool Function RollUnlock()
    Int lockLevel = Self.GetLockLevel()
    If lockLevel > 100
        return False
    EndIf

    Int tier = ChanceLib.LockLevelToTier(lockLevel)
    If tier > 0
        If Chance.RollUnlock(tier)
            SetLockTierAndRefresh(0)
            return True
        EndIf
    EndIf
    return False
EndFunction


Int Function RollItems()
    Int tier = ChanceLib.LockLevelToTier(Self.GetLockLevel())
    Form[] rolled = Chance.RollByLockTier(tier, ChanceFilter)
    Int i = 0
    Int highestTier = -1
    While i < rolled.Length
        Form item = rolled[i]
        If item
            Self.AddItem(item)
            highestTier = i
        EndIf
        i += 1
    EndWhile

    If IsLocked() && ( GetItemCount() == 0 )
        Self.AddItem(EmptyItem)
        highestTier = 0
    EndIf

    return highestTier
EndFunction


Function Roll()
    RollLock()
    Int highestTier = RollItems()
    RollUnlock()
    UpdateHighlight(highestTier)
EndFunction


Function UpdateHighlight(Int highestTier)
    if highestTier >= 0
        StartHighlight(highestTier)
    Else
        EndHighlight()
    EndIf
EndFunction


Function StartHighlight(Int level)
    While !Is3DLoaded()
        Utility.Wait(0.2)
    EndWhile
    If level == 0
        ActiveHighlight = JunkHighlight
    ElseIf level == 1
        ActiveHighlight = CommonHighlight
    ElseIf level == 2
        ActiveHighlight = RareHighlight
    ElseIf level == 3
        ActiveHighlight = EpicHighlight
    ElseIf level == 4
        ActiveHighlight = LegendaryHighlight
    Endif
    ActiveHighlight.Play(self)
EndFunction


Function EndHighlight()
    if ActiveHighlight
        ActiveHighlight.Stop(self)
        ActiveHighlight = None
    EndIf
EndFunction


Int highlightTier


Auto State startState

	Event OnLoad()
        goToState("waitOpen")
        Init()
        Roll()
    EndEvent

EndState


State waitOpen

    Event OnClose(ObjectReference akActionRef)
        goToState("doNothing")
        EndHighlight()
	EndEvent

EndState


State doNothing
EndState
