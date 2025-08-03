Scriptname Scare:FragMineScare extends ObjectReference

Sound Property MineSound Auto Const
Explosion Property MineExplosion Auto Const
Explosion Property DisarmExplosion Auto Const
int Property TickCount Auto Const
float Property TickInterval Auto Const
Message Property SanityMessage Auto Const

Bool disarmed = False


Event OnLoad()
    While !Is3DLoaded()
        Utility.Wait(0.2)
    EndWhile
    int i = 0
    while !disarmed && ( i < TickCount )
        MineSound.Play(self)
        Utility.Wait(TickInterval * 2)
        i += 1
    endwhile
    If !disarmed
        Disable()
        Delete()
        PlaceAtMe(MineExplosion)
        SanityMessage.Show(-1)
    EndIf
EndEvent


Event OnActivate(ObjectReference akActionRef)
    if !disarmed
        disarmed = True
        Disable()
        Delete()
        PlaceAtMe(DisarmExplosion)
    EndIf
EndEvent
