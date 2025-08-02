; Copyright (c) 2023 kmrkle.tv community. All rights reserved.
; Licensed under the MIT License. See LICENSE in the project root for license information.
Scriptname CrowdControl extends ReferenceAlias

Chance CH = None
HostileSpawnScript HostileSpawn = None
HazardSpawnScript HazardSpawn = None
LoseItemMisfortuneScript LoseItemMisfortune = None
ContaminationMisfortuneScript ContaminationMisfortune = None
RadiationHotspotMisfortuneScript RadiationHotspotMisfortune = None

Int[] ItemDie = None
Int[] ItemResults = None
Int[] ItemRolls = None

string lastState = ""

Int lastCommandId = -1
Int lastCommandType = -1

Actor player = None
Faction playerFaction = None
Faction playerEnemyFaction = None
Faction playerAllyFaction = None
Keyword keywordActorFriendlyNpc = None

Int updateTimerId = 10
Int updateTimerKeepAliveId = 11
float LastCellLoadAt = 0.0

bool F4SEFound

Event OnInit()
    Debug.Trace("CrowdControl OnInit.")

	lastCommandId = -1
	lastCommandType = -1
    lastState = ""
    isPlayerInWorkshop = false

    player = Game.GetPlayer()
    InitVars()

    string[] ccTest = CrowdControlApi.StringSplit("1~2", "~")

    if ccTest.length == 2
        F4SEFound = true
        StartTimer(2.0, updateTimerId)
        StartTimer(15.0, updateTimerKeepAliveId)
        PingUpdateTimer()
    else
        StartTimer(10.0, updateTimerId)
    endif
EndEvent

Function InitVars()
    if playerFaction == None
        playerFaction = Game.GetFormFromFile(0x1C21C, "Fallout4.esm") as Faction
    endif

    if playerEnemyFaction == None
        playerEnemyFaction = Game.GetFormFromFile(0x106c2f, "Fallout4.esm") as Faction
    endif

    if playerAllyFaction == None
        playerAllyFaction = Game.GetFormFromFile(0x106c30, "Fallout4.esm") as Faction
    endif

    if keywordActorFriendlyNpc == None
        keywordActorFriendlyNpc = Game.GetFormFromFile(0x10053FF, "CrowdControl.esp") as Keyword
    endif

    ; Get rid of Billy
    ReferenceAlias ra = GetAlias(7)
    Actor a = ra.GetActorReference()
    if a
        ra.Clear()
        a.Disable()
        a.Delete()
    endif

    LastCellLoadAt = 0.0

    If CH == None
        CH = GetOwningQuest().GetAlias(0) as Chance
	Endif

    If HostileSpawn == None
        HostileSpawn = GetOwningQuest().GetAlias(0) as HostileSpawnScript
	Endif

    If HazardSpawn == None
        HazardSpawn = GetOwningQuest().GetAlias(0) as HazardSpawnScript
	Endif

    If LoseItemMisfortune == None
        LoseItemMisfortune = GetOwningQuest().GetAlias(0) as LoseItemMisfortuneScript
    EndIf

    If ContaminationMisfortune == None
        ContaminationMisfortune = GetOwningQuest().GetAlias(0) as ContaminationMisfortuneScript
    EndIf

    If RadiationHotspotMisfortune == None
        RadiationHotspotMisfortune = GetOwningQuest().GetAlias(0) as RadiationHotspotMisfortuneScript
    EndIf
EndFunction

Event OnCellLoad()
    LastCellLoadAt = Utility.GetCurrentRealTime()
endEvent

; This event is called when the player loads a game
Event OnPlayerLoadGame()
    InitVars()

    ; Reset all state
    lastCommandId = -1
	lastCommandType = -1
    lastState = ""
    isPlayerInWorkshop = false

    ; Clear all effect timers, in case player died or reloaded.
	CrowdControlApi.ClearTimers()

    ; Start new timers
    CancelTimer(updateTimerId)
    CancelTimer(updateTimerKeepAliveId)
    if F4SEFound
        StartTimer(2.0, updateTimerId)
        StartTimer(15.0, updateTimerKeepAliveId)
        PingUpdateTimer()
    endif
EndEvent

float LastUpdateTimerPing = 0.0

function PingUpdateTimer()
    LastUpdateTimerPing = Utility.GetCurrentRealTime()
endfunction

Event OnTimer(Int aiTimerID)
    If aiTimerID == updateTimerKeepAliveId
        ; This timer ensures that the main timer is restarted if it stops running for any reason
        if Utility.GetCurrentRealTime() - LastUpdateTimerPing >= 30
            Debug.Trace("Halt detected. Restarting update timer.")

            CancelTimer(updateTimerId)
            StartTimer(1.0, updateTimerId)
            PingUpdateTimer()
        endif

        StartTimer(15.0, updateTimerKeepAliveId)

    elseif aiTimerID == updateTimerId
        PingUpdateTimer()

        if !F4SEFound
            Debug.Notification("CrowdControl disabled: F4SE not found.")

            return
        endif

        string newState = CrowdControlApi.GetCrowdControlState()

        if lastState == ""
            Debug.Notification("CrowdControl v" + CrowdControlApi.Version())

            if newState != lastState
                if newState == "disconnected"
                    Debug.Notification("CrowdControl is connecting...")
                else
                    Debug.Notification("CrowdControl is " + newState)
                endif
            endif
        else
            if newState != lastState
                Debug.Notification("CrowdControl is " + newState)
            endif
        endif

        lastState = newState

        if newState == "running"
            if RunCommands()
                PingUpdateTimer()
                StartTimer(0.5, updateTimerId)
            else
                StartTimer(1, updateTimerId)
            endif

        elseif newState == "stopped"
            CrowdControlApi.Run()

            StartTimer(1, updateTimerId)
        else
            CrowdControlApi.Reconnect()

            StartTimer(1, updateTimerId)
        endif
   EndIf
EndEvent

int ShouldShowNotifications = -1

Function PrintMessage(string _message)
	if ShouldShowNotifications < 0
        int iniSetting = CrowdControlApi.GetIntSetting("General", "bEnableCommandNotify")

        if iniSetting == 1 || iniSetting < 0
            Debug.Notification(_message)
        endif
    elseif ShouldShowNotifications == 1
        Debug.Notification(_message)
	endif
EndFunction

bool Function ShouldNotifyCommand()
    ; Effect notifications can be toggled with this INI setting
	return CrowdControlApi.GetIntSetting("General", "bEnableCommandNotify") == 1
endFunction

Function Respond(int id, int status, string _message = "", int milliseconds = 0)
	CrowdControlApi.Respond(id, status, _message, milliseconds)
EndFunction

bool Function CanRunCommands()
    Actor playerDialogTarget = player.GetDialogueTarget()

    if playerDialogTarget != None
        if playerDialogTarget.IsInDialogueWithPlayer()
            Debug.Trace("    is in dialog with player")

            return false
        endif
    endif

    if !Game.IsLookingControlsEnabled() || !Game.IsMovementControlsEnabled()
        Debug.Trace("    looking or moving is disabled")
        return false
    endif

    if Utility.IsInMenuMode()
        Debug.Trace("    menu mode enabled")
        return false
    endIf

    if LastCellLoadAt > 0.0 && Utility.GetCurrentRealTime() - LastCellLoadAt < 4
        Debug.Trace("    just loaded recently")
        return false
    endif

    return true
endFunction

bool Function RunCommands()
	if player.IsDead() || !CanRunCommands()
        Debug.Trace("  can't run commands!")

		return false
	endif

    int commandCount = CrowdControlApi.GetCommandCount()

	CrowdControlApi:CrowdControlCommand command = CrowdControlApi.GetCommand()

	if command != None
        if lastCommandId == command.id && lastCommandType == command.type
			if command.type == 1
				Respond(command.id, 1, command.viewer + " invalid command (1) \"" + command.command + "\"")
			else
				PrintMessage(command.viewer + " invalid command (2) \"" + command.command  + "\"")
				Respond(command.id, 0, "")
			endif
		else
			lastCommandId = command.id
			lastCommandType = command.type

            ProcessCommand(command)
		endif
	endif

    return commandCount > 1
EndFunction

; Define a custom struct to store the parsed values
Struct ParsedCommand
    String command
    String id
    String quantity
    Int minQuantity
    Int maxQuantity
    int duration
    String param0
    String param1
    String param2
    String param3
    String param4
    String param5
    String param6
    String param7
    String param8
    String param9
EndStruct

; Define a custom function to parse the command string and return a ParsedCommand struct
ParsedCommand Function ParseCrowdControlCommand(CrowdControlApi:CrowdControlCommand ccCommand)
    ParsedCommand r = new ParsedCommand

    r.command = ccCommand.command
    r.id = ccCommand.param0
    r.quantity = ccCommand.param1

    If CrowdControlApi.StringContains(r.quantity, "~")
        string[] quantities = CrowdControlApi.StringSplit(r.quantity, "~")
        r.minQuantity = quantities[0] as Int
        r.maxQuantity = quantities[1] as Int
    Else
        r.minQuantity = r.quantity as Int
        r.maxQuantity = r.minQuantity
    EndIf

    if ccCommand.durationMS > 0
        r.duration = ccCommand.durationMS / 1000
    else
        r.duration = 0
    endif

    r.param0 = ccCommand.param2
    r.param1 = ccCommand.param3
    r.param2 = ccCommand.param4
    r.param3 = ccCommand.param5
    r.param4 = ccCommand.param6
    r.param5 = ccCommand.param7
    r.param6 = ccCommand.param8
    r.param7 = ccCommand.param9
    r.param8 = ccCommand.param10
    r.param9 = ccCommand.param11

    return r
endfunction

ReferenceAlias Function GetAlias(int index)
    ReferenceAlias ra = GetOwningQuest().GetAlias(index) as ReferenceAlias
    Actor a = ra.GetActorReference()
    if a != None
      ; Clear alias for any dead followers
      if a.IsDead()
        ra.Clear()
        a = None
      endif
    endif

    return ra
endFunction

Form Function FindFormId(int id)
    Form foundForm = Game.GetFormFromFile(id, "Fallout4.esm") as Form

    if foundForm != None
        return foundForm
    endif

    return Game.GetFormFromFile(id, "CrowdControl.esp") as Form
endfunction

string Function NormalizeDataFileName(string fileName)
    if fileName == "fallout4"
		return "Fallout4.esm"
	elseif fileName == "dlcrobot"
		return "DLCRobot.esm"
	elseif fileName == "dlcworkshop01"
		return "DLCworkshop01.esm"
	elseif fileName == "dlcworkshop02"
		return "DLCworkshop02.esm"
	elseif fileName == "dlcworkshop03"
		return "DLCworkshop03.esm"
	elseif fileName == "dlccoast"
		return "DLCCoast.esm"
	elseif fileName == "dlcnukaworld"
		return "DLCNukaWorld.esm"
    elseif fileName == "frost"
		return "FROST.esp"
	elseif fileName == "crowdcontrol"
		return "CrowdControl.esp"
	endif

    return fileName
endfunction

Form Function FindForm(String id)
    if id == ""
        return None
    endif

    if CrowdControlApi.StringContains(id, "-")
        string[] parts = CrowdControlApi.StringSplit(id, "-")

        string fileName = NormalizeDataFileName(parts[0])
        int formId = parts[1] as int

        Form r = Game.GetFormFromFile(formId, fileName) as Form

        return r
    else
        return FindFormId(id as int)
    endif
endFunction

Function StopFriendlyCombatWith(Actor theActor)
    ObjectReference[] kActors = player.FindAllReferencesWithKeyword(keywordActorFriendlyNpc, 2048.0)

    int i = 0
    while (i < kActors.Length)
        Actor kActor = kActors[i] as Actor

        int combatState = kActor.GetCombatState()

        if combatState == 1
            Actor aTarget = kActor.GetCombatTarget()
            if aTarget == theActor || aTarget.HasKeyword(keywordActorFriendlyNpc) || aTarget.IsInFaction(playerFaction) || aTarget.IsInFaction(playerAllyFaction)
                kActor.StopCombat()
            endif

        elseif combatState == 2
            kActor.StopCombat()
        endif

        i += 1
    endWhile
endFunction

Function StopFriendlyCombat(Actor theActor)
    if theActor.GetCombatState() == 1
        Actor aTarget = theActor.GetCombatTarget()
        if aTarget.HasKeyword(keywordActorFriendlyNpc) || aTarget.IsInFaction(playerFaction) || aTarget.IsInFaction(playerAllyFaction)
            aTarget.StopCombat()
        endif
    endif
endFunction

Function AttachMod(ObjectReference spawnedItem, string modFormId)
    ObjectMod theMod = FindForm(modFormId) as ObjectMod

    if theMod
        spawnedItem.AttachMod(theMod)
    else
        Debug.Trace("Cannot find MOD with id '" + modFormId + "'")

        Debug.Notification("Cannot find MOD with id '" + modFormId + "'")
    endif
endfunction

SafeSpawnBaseScript:SpawnData Function MakeSpawnData(ParsedCommand command)
    SafeSpawnBaseScript:SpawnData data = new SafeSpawnBaseScript:SpawnData
    data.theForm = FindForm(command.id)
    data.minQuantity = command.minQuantity
    data.maxQuantity = command.maxQuantity

    If CrowdControlApi.StringContains(command.param0, "~")
        string[] quantities = CrowdControlApi.StringSplit(command.param0, "~")
        data.minDistance = quantities[0] as Int
        data.maxDistance = quantities[1] as Int
    Else
        data.minDistance = command.param0 as Int
        data.maxDistance = data.minDistance
    EndIf

    If command.param1 != ""
        data.radius = command.param1 as Float
    Else
        data.radius = 0
    EndIf

    If command.param2 != ""
        data.exclusionRadius = command.param2 as Float
    Else
        data.exclusionRadius = 0
    EndIf

    return data
EndFunction

Function ProcessCommand(CrowdControlApi:CrowdControlCommand ccCommand)
    ParsedCommand command = ParseCrowdControlCommand(ccCommand)

    if command == None
        Debug.Notification("Invalid command format received.")
        return
    endif

    int id = ccCommand.id
    string viewer = ccCommand.viewer
    string status
    int type = ccCommand.type

    If command.command == "addlock"
        If CH.AddForceLockTier(command.id as Int, command.minQuantity)
            PrintMessage(status)
            Respond(id, 0, status)
        Else
            PrintMessage(status)
            Respond(id, 1, status)
        EndIf

    ElseIf command.command == "addunlock"
        If CH.AddForceUnlockTier(command.id as Int, command.minQuantity)
            PrintMessage(status)
            Respond(id, 0, status)
        Else
            PrintMessage(status)
            Respond(id, 1, status)
        EndIf

    elseif command.command == "additem"
        If CH.AddItem(FindForm(command.id), command.minQuantity)
            Respond(id, 0, status)
            PrintMessage(status)
        Else
            Respond(id, 1, status)
            PrintMessage(status)
        Endif

    elseif command.command == "itemscare"
		player.PlaceAtMe(FindForm(command.id), command.minQuantity)
        Respond(id, 0, status)
        PrintMessage(status)

    elseif command.command == "hazard-radiation"
        If RadiationHotspotMisfortune.Add()
            Respond(id, 0, status)
            PrintMessage(status)
        Else
            status = viewer + ", radiation hotspots maxed"
            Respond(id, 1, status)
            PrintMessage(status)
        EndIf

    elseif command.command == "addspell"
        (FindForm(command.id) as Spell).Cast(player)

        Respond(id, 0, status)
        PrintMessage(status)

    elseif command.command == "misfortune-loseitem"
        If LoseItemMisfortune.Add()
            Respond(id, 0, status)
            PrintMessage(status)
        Else
            status = viewer + ", lose items maxed"
            Respond(id, 1, status)
            PrintMessage(status)
        EndIf

    elseif command.command == "misfortune-contamination"
        If ContaminationMisfortune.Add()
            Respond(id, 0, status)
            PrintMessage(status)
        Else
            status = viewer + ", contaminations maxed"
            Respond(id, 1, status)
            PrintMessage(status)
        EndIf

    elseif command.command == "spawnstalkers"
        ; SafeSpawnBaseScript:SpawnData data = MakeSpawnData(command)

        ; If !HostileSpawn.QueueSpawn(data)
        ;     status = viewer + ", too many hostile spawns pending"
        ;     PrintMessage(status)
        ;     Respond(id, 1, status)
        ; Else
        ;     PrintMessage(status)
        ;     Respond(id, 0, status)
        ; EndIf

    elseif command.command == "hazard"
        SafeSpawnBaseScript:SpawnData data = MakeSpawnData(command)

        If !HazardSpawn.QueueSpawn(data)
            status = viewer + ", too many hazard spawns pending"
            PrintMessage(status)
            Respond(id, 1, status)
        Else
            PrintMessage(status)
            Respond(id, 0, status)
        EndIf

    elseif command.command == "test"
        Int lockCount = 25
        Int itemCount = 25
        CH.AddForceLockTier(1, lockCount * 4)
        CH.AddForceLockTier(2, lockCount * 3)
        CH.AddForceLockTier(3, lockCount * 2)
        CH.AddForceLockTier(4, lockCount)
        CH.AddItem(Game.GetFormFromFile(0x13570, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x13571, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x13573, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x13574, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1357A, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1357B, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1357C, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1357D, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1357E, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x13584, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x13585, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x13586, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x13587, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x13588, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x13589, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1358A, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1358B, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1BE4F, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1BE50, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1BE51, "CrowdControl.esp") as Form, itemCount)
        CH.AddItem(Game.GetFormFromFile(0x1BE53, "CrowdControl.esp") as Form, itemCount)

        Respond(id, 0, status)
        PrintMessage(status)

    elseif command.command == "fasttravel"
        if Game.IsFastTravelEnabled()
            status = viewer + " requested fast travel to: " + CrowdControlApi.GetName(command.id)

            PrintMessage(status)
            Respond(id, 0, status)

            Utility.Wait(1)

            ObjectReference theMarker = FindForm(command.id) as ObjectReference

            Game.FastTravel(theMarker)
        else
            status = viewer + ", cannot fast travel at this time"

            PrintMessage(status)
            Respond(id, 1, status)
        endif

    elseif command.command == "setweather"
        Weather theWeather = FindForm(command.id) as Weather

        theWeather.SetActive(false, true)

        status = viewer + " changed the weather to: " + CrowdControlApi.GetName(command.id)

        Respond(id, 0, status)
        PrintMessage(status)

    elseif command.command == "playsound"

        if command.id > 0
            PlaySound(command.id)
        endif

        int playerSex = player.GetActorBase().GetSex()

        if playerSex == 0
            ; Male
            if command.param0 != "" && command.param0 as int > 0
                PlaySound(command.param0)
            endif
        elseif playerSex == 1
            ; Female
            if command.param1 != "" && command.param1 as int > 0
                PlaySound(command.param1)
            endif
        endif

        status = viewer + " played a sound"

        PrintMessage(status)
        Respond(id, 0, status)

    else
        Debug.Notification("Unknown command received: " + command.command)
	endif

EndFunction

;-- Workshop --

bool isPlayerInWorkshop

Event OnWorkshopMode(bool aStart)
  if aStart
    isPlayerInWorkshop = true
  else
    isPlayerInWorkshop = false
  endif
EndEvent

; -- Util --

float Function GetPlayerAngle()
    float gameAngleZ ; the game's version
    float trigAngleZ ; the rest of the world's interpretation of the same

    gameAngleZ = player.GetAngleZ()
    if gameAngleZ < 90
      trigAngleZ = 90 - gameAngleZ
    else
      trigAngleZ = 450 - gameAngleZ
    endif

    return trigAngleZ
endfunction

Function PlaySoundId(int id)
    Sound soundFound = FindForm(id) as Sound
    soundFound.Play(player)
endfunction

Function PlaySound(String id)
    Sound soundFound = FindForm(id) as Sound
    soundFound.Play(player)
endfunction

bool Function GetRandomBool()
    int i = Utility.RandomInt(0, 1)   ; Generate a random integer between 0 and 1
    If i == 0
        return False
    Else
        return True
    EndIf
EndFunction

; -- Debug --

Function TraceInventory()
    Form[] items = player.GetInventoryItems()

    Debug.Trace("TraceInventory() length=" + items.Length)

    int i = 0
    while i < items.Length
        Form item = items[i]

        Debug.Trace("  i: " + i)
        Debug.Trace("    Type: " + item)
        Debug.Trace("    Name: " + item.GetName())

        i += 1
    endWhile
endfunction

Function TraceWornItems()
    ; For each biped slot
    int index = 0
    int end = 43 const

    while (index < end)
        Actor:WornItem wornItem = player.GetWornItem(index)
        Debug.Trace("Slot Index: " + index + ", " + wornItem)
        index += 1
    EndWhile
endfunction