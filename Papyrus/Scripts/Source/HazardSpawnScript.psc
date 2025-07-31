Scriptname HazardSpawnScript extends SafeSpawnBaseScript


Event OnInit()
    Init()
EndEvent


Event OnPlayerLoadGame()
    Init()
EndEvent


Event OnTimer(Int timerId)
    If timerId == PumpTimerId
        PumpQueue()
    EndIf
EndEvent
