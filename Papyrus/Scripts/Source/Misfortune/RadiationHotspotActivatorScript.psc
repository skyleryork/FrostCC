Scriptname Misfortune:RadiationHotspotActivatorScript extends ObjectReference


Int MaxRadiationHazardBits = 4


FormList Property RadiationHazards Auto Const Mandatory


ObjectReference[] hotspots = None
Int startRads = 0
Float finalScale = 0.0
Float startHour = 0.0
Float finalHour = 0.0


Bool Function UpdateHotspots()
    Float now = Utility.GetCurrentGameTime()
    Int rads = Math.Ceiling(startRads * Math.Pow(finalScale, (now - startHour) / (finalHour - startHour))) as Int

    Int i = 0
    Int mask = 1
    While i < hotspots.Length
        If Math.LogicalAnd(rads, mask)
            hotspots[i].Enable()
        Else
            hotspots[i].Disable()
        EndIf
        i += 1
        mask *= 2
    EndWhile

    If now < finalHour
        return True
    EndIf

    i = 0
    While i < hotspots.Length
        hotspots[i].Disable()
        hotspots[i].Delete()
        i += 1
    EndWhile

    Self.Disable()
    Self.Delete()
    return False
EndFunction


Bool Function Init(Int initialRads, Float decayScale, Float decayDays)
    If RadiationHazards.GetSize() != MaxRadiationHazardBits
        Debug.Trace("Misfortune:RadiationHotspotActivatorScript::Init -- missing hazards")
        return False
    EndIf

    If initialRads >= (Math.Pow(2.0, MaxRadiationHazardBits) As Int)
        return False
    EndIf

    hotspots = new ObjectReference[MaxRadiationHazardBits]
    Int i = 0
    While i < hotspots.Length
        hotspots[i] = Self.PlaceAtMe(RadiationHazards.GetAt(i), abInitiallyDisabled = True)
        i += 1
    EndWhile

    startRads = initialRads
    finalScale = decayScale
    startHour = Utility.GetCurrentGameTime()
    finalHour = startHour + decayDays

    If UpdateHotspots()
        StartTimer(5.0, 1)
    EndIf

    return True
EndFunction


Event OnTimer(int timerId)
    If UpdateHotspots()
        StartTimer(5.0, 1)
    EndIf
EndEvent
