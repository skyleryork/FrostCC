Scriptname HostileSpawnScript extends SafeSpawnBaseScript


Event OnInit()
    Init()
EndEvent


Event OnPlayerLoadGame()
    Init()
EndEvent


Event OnTimer(Int timerId)
    If timerId == 0
        PumpQueue()
    EndIf
EndEvent
