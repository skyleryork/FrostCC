Scriptname ChanceContainer extends ObjectReference


Int Property ChanceFilter Auto

Actor Player = None
CrowdControl CC = None
Chance CH = None
Form EmptyItem = None

EffectShader JunkHighlight = None
EffectShader CommonHighlight = None
EffectShader RareHighlight = None
EffectShader EpicHighlight = None
EffectShader LegendaryHighlight = None
EffectShader ActiveHighlight = None

Perk Locksmith1 = None
Perk Locksmith2 = None
Perk Locksmith3 = None


Function Init()
    If Player == None
        Player = Game.GetPlayer()
    EndIf

    If CC == None
        CC = ( Game.GetFormFromFile(0xF99, "CrowdControl.esp") as Quest ).GetAlias(0) as CrowdControl
    Endif

    If CH == None
        CH = ( Game.GetFormFromFile(0xF99, "CrowdControl.esp") as Quest ).GetAlias(0) as Chance
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

    If Locksmith1 == None
        Locksmith1 = Game.GetFormFromFile(0x523FF, "Fallout4.esm") as Perk
    EndIf
    If Locksmith2 == None
        Locksmith2 = Game.GetFormFromFile(0x52400, "Fallout4.esm") as Perk
    EndIf
    If Locksmith3 == None
        Locksmith3 = Game.GetFormFromFile(0x52401, "Fallout4.esm") as Perk
    EndIf

    ;Debug.Trace("ChanceContainer::Init - " + GetFormID() + "; ChanceFilter = " + ChanceFilter)
EndFunction


Int Function GetPlayerLockLevel()
    Int level = 25
    If Player.HasPerk(Locksmith1)
        level += 25
    EndIf
    If Player.HasPerk(Locksmith2)
        level += 25
    EndIf
    If Player.HasPerk(Locksmith3)
        level += 25
    EndIf
    return level
EndFunction


Function SetLockTierAndRefresh(Int tier)
    Self.SetLockLevel(Chance.LockTierToLevel(tier))
    If ( tier > 0 ) && !IsLocked()
        Lock()
    ElseIf ( tier == 0 ) && IsLocked()
        Lock(False)
    EndIf
EndFunction


; forces an unlocked container to be locked, returns true if so
Bool Function RollLock()
    ;Debug.Trace("ChanceContainer::RollLock - " + LocalRollID)

    Int tier = Chance.LockLevelToTier(Self.GetLockLevel())
    If tier == 0
        Int newTier = CH.RollLock()
        If newTier > 0
            SetLockTierAndRefresh(newTier)
            ;Debug.Trace("ChanceContainer::RollLock - changed from 0 to " + newTier)
            return True
        EndIf
    EndIf
    return False
EndFunction


; forces a locked container to be unlocked, returns true if so
Bool Function RollUnlock()
    ;Debug.Trace("ChanceContainer::RollUnlock - " + LocalRollID)

    Int lockLevel = Self.GetLockLevel()
    If lockLevel > 100
        return False
    EndIf

    Int tier = Chance.LockLevelToTier(lockLevel)
    If tier > 0
        If CH.RollUnlock(tier)
            SetLockTierAndRefresh(0)
            ;Debug.Trace("ChanceContainer::RollUnlock - changed from " + tier + " to 0")
            return True
        EndIf
    EndIf
    return False
EndFunction


Int Function RollItems()
    Int tier = Chance.LockLevelToTier(Self.GetLockLevel())
    ;Debug.Trace("ChanceContainer::RollItems - attempting for " + LocalRollID + " at tier " + tier)

    Form[] rolled = CH.RollByLockTier(tier, ChanceFilter)
    Int i = 0
    Int highestTier = -1
    While i < rolled.Length
        Form item = rolled[i]
        If item
            ;Debug.Trace("ChanceContainer::RollItems - rolled " + item.GetFormID())
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
    ;Debug.Trace("ChanceContainer::Roll - " + GetName() + " rolled tier " + highestTier)
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
    ;Debug.Trace("ChanceContainer::StartHighlight - for " + LocalRollID + " at " + level)
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
