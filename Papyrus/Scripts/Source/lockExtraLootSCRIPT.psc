Scriptname lockExtraLootSCRIPT extends ChanceContainer


LeveledItem Property pLLI_Loot_Lock_Advanced Auto
LeveledItem Property pLLI_Loot_Lock_Expert Auto
LeveledItem Property pLLI_Loot_Lock_Master Auto


Auto State startState

	Event OnLoad()
		goToState("waitOpen")
		Self.Init()

	    Int lockTier = ChanceLib.LockLevelToTier(Self.GetLockLevel())
	    ; are we an Advanced lock?
	    If lockTier == 1
	    	Self.AddItem(pLLI_Loot_Lock_Advanced)
		; are we an expert lock?
		ElseIf lockTier == 2
			Self.AddItem(pLLI_Loot_Lock_Expert)
		; are we a master lock?
	    ElseIf lockTier == 3
			Self.AddItem(pLLI_Loot_Lock_Master)
		EndIf

		Self.Roll()
	EndEvent

EndState


State waitOpen

    Event OnClose(ObjectReference akActionRef)
		goToState("doNothing")
		Self.EndHighlight()
	EndEvent

EndState


State doNothing
EndState
