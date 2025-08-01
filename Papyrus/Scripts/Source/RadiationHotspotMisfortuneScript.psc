Scriptname RadiationHotspotMisfortuneScript extends ReferenceAlias

Int Property PumpTimerId = 1 AutoReadOnly
Float Property PumpTimerInterval = 1 AutoReadOnly


Float Property MisfortuneChance Auto Mandatory
Float Property MisfortuneDuration Auto Mandatory

Hazard[] Property RadiationHotspots Auto Const Mandatory
Float[] Property RadiationHotspotSpacing Auto Const Mandatory
Perk[] Property RadiationHotspotPerks Auto Const Mandatory
Int[] Property RadiationHotspotRads Auto Const Mandatory
Message Property RadiationMessage Auto Const Mandatory


Actor Player = None
Float ScaledMisfortuneChance = 0.0


Bool Function Add()
    If Player.HasPerk(RadiationHotspotPerks[2])
        return False
    ElseIf Player.HasPerk(RadiationHotspotPerks[1])
        Player.AddPerk(RadiationHotspotPerks[2], True)
    ElseIf Player.HasPerk(RadiationHotspotPerks[0])
        Player.AddPerk(RadiationHotspotPerks[1], True)
    Else
        Player.AddPerk(RadiationHotspotPerks[0], True)
    EndIf
    return True
EndFunction


Event OnInit()
    Debug.Trace("RadiationHotspotMisfortuneScript: OnInit")

    If RadiationHotspots.Length != RadiationHotspotSpacing.Length || RadiationHotspots.Length != RadiationHotspotPerks.Length || RadiationHotspots.Length != RadiationHotspotRads.Length
        Debug.Trace("RadiationHotspotMisfortuneScript: RadiationHotspots/RadiationHotspotSpacing/RadiationHotspotPerks/RadiationHotspotRads size mismatch")
    EndIf

    If Player == None
        Player = Game.GetPlayer()
    EndIf

    If ScaledMisfortuneChance == 0.0
        ScaledMisfortuneChance = Chance.CalculateTimescaledChance(MisfortuneChance, MisfortuneDuration, PumpTimerInterval)
    EndIf

    Utility.Wait(Utility.RandomFloat(0.0, PumpTimerInterval))
    StartTimer(PumpTimerInterval, PumpTimerId)
EndEvent


Bool Function RollMisfortune()
    If !Player.HasPerk(RadiationHotspotPerks[0])
        return False
    EndIf
    return Utility.RandomFloat() <= ScaledMisfortuneChance
EndFunction


Function ApplyMisfortune()
    Int index = RadiationHotspotPerks.Length - 1
    Bool found = False
    While !found && (index > 0)
        If Player.HasPerk(RadiationHotspotPerks[index])
            found = True
        Else
            index -= 1
        EndIf
    EndWhile
        
    Perk thePerk = RadiationHotspotPerks[index]
    Hazard hotspot = RadiationHotspots[index]
    Float spacing = RadiationHotspotSpacing[index]
    Int rads = RadiationHotspotRads[index]

    ObjectReference[] hotspots = Player.FindAllReferencesOfType(hotspot, spacing)
    If hotspots.Length == 0
        Player.PlaceAtMe(hotspot)
        Player.RemovePerk(thePerk)
        RadiationMessage.Show(rads)
    EndIf
EndFunction


Event OnTimer(Int timerId)
    If timerId == PumpTimerId
        If RollMisfortune()
            ApplyMisfortune()
        EndIf
        StartTimer(PumpTimerInterval, PumpTimerId)
    EndIf
EndEvent
    