Scriptname FragGrenadeTrapScareScript extends ActiveMagicEffect


Sound Property TrapSound Auto Const Mandatory
Weapon Property TrapWeapon Auto Const Mandatory
Int Property GrenadeCount Auto Const Mandatory

ReferenceAlias Property SpawnMarkerRef Auto Const Mandatory

Bool locked = False

Event OnEffectStart(Actor akTarget, Actor akCaster)
    While locked
        Utility.Wait(0.2)
    EndWhile
    locked = True

    TrapSound.Play(akTarget)

    ObjectReference marker = SpawnMarkerRef.GetReference()
    Int i = 0
    Int count = GrenadeCount
    While i < count
        Float randomAngle = Utility.RandomFloat(0.0, 360.0)
        Float randomDistance = Utility.RandomFloat(0.0, 48.0)
        Float offsetX = Math.Cos(randomAngle) * randomDistance
        Float offsetY = Math.Sin(randomAngle) * randomDistance
        marker.MoveTo(akTarget, offsetX, offsetY, 100)
        TrapWeapon.Fire(marker)
        i += 1
    EndWhile

    locked = False
EndEvent
