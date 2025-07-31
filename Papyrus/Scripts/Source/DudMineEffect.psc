Scriptname DudMineEffect extends ActiveMagicEffect


Projectile[] Property Mines Auto
Projectile Property Dud Auto
Float Property SearchRadius Auto
Float Property DudChance Auto


Event OnEffectStart(Actor akTarget, Actor akCaster)
    ObjectReference[] FoundMines = new ObjectReference[8]
    Int NextFoundMine = 0
    Int[] indices = ChanceApi.ShuffledIndices(Mines.Length)
    While True
        Int i = 0
        While i < indices.Length
            ObjectReference mine = Game.FindRandomReferenceOfTypeFromRef(Mines[indices[i]], akTarget, SearchRadius)
            If mine
                If FoundMines.Find(mine) < 0
                    Bool disarm = False
                    If Utility.RandomFloat(0.0, 1.0) <= DudChance
                        disarm = True
                    ElseIf NextFoundMine == FoundMines.Length
                        disarm = true
                    Else
                        FoundMines[NextFoundMine] = mine
                        NextFoundMine += 1
                    EndIf
                    If disarm
                        ObjectReference newMine = mine.PlaceAtMe(Dud, abInitiallyDisabled = True)
                        newMine.MoveTo(mine)
                        mine.Disable()
                        mine.Delete()
                        newMine.Enable()
                        return
                    EndIf
                EndIf
            EndIf
            i += 1
        EndWhile
        Utility.Wait(1.0)
    EndWhile
EndEvent
