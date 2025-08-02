Scriptname RadiationHotspotMisfortuneScript extends ReferenceAlias

Int Property PumpTimerId = 1 AutoReadOnly
Float Property PumpTimerInterval = 1 AutoReadOnly


Float Property MisfortuneChance Auto Const Mandatory
Float Property MisfortuneDuration Auto Const Mandatory

Hazard[] Property RadiationHotspots Auto Const Mandatory
Float[] Property RadiationHotspotSpacing Auto Const Mandatory
Perk[] Property RadiationHotspotPerks Auto Const Mandatory
Int[] Property RadiationHotspotRads Auto Const Mandatory

Message Property RadiationMessage Auto Const Mandatory
Message Property RadiationPerkMessage Auto Const Mandatory


Actor Player = None
Float ScaledMisfortuneChance = 0.0
Bool Locked = False


Function Lock()
    While Locked
        Utility.Wait(0.2)
    EndWhile
    Locked = True
EndFunction


Function Unlock()
    Locked = False
EndFunction


Bool Function Add()
    Lock()
    Int i = 0
    While i < RadiationHotspotPerks.Length
        If !Player.HasPerk(RadiationHotspotPerks[i])
            Player.AddPerk(RadiationHotspotPerks[i])
            Unlock()
            RadiationPerkMessage.Show(i + 1)
            return True
        EndIf
        i += 1
    EndWhile
    Unlock()
    return False
EndFunction


Function ParseSettings()
    Float chanceSetting = CrowdControlApi.GetFloatSetting("Misfortunes", "RadiationHotspotChance", -1.0)
    If chanceSetting < 0.0
        chanceSetting = MisfortuneChance
    EndIf

    Float durationSetting = CrowdControlApi.GetFloatSetting("Misfortunes", "RadiationHotspotDuration", -1.0)
    If durationSetting < 0.0
        durationSetting = MisfortuneDuration
    EndIf

    ScaledMisfortuneChance = Chance.CalculateTimescaledChance(chanceSetting, durationSetting, PumpTimerInterval)
EndFunction


Event OnInit()
    Debug.Trace("RadiationHotspotMisfortuneScript: OnInit")

    If RadiationHotspots.Length == 0 || RadiationHotspots.Length != RadiationHotspotSpacing.Length || RadiationHotspots.Length != RadiationHotspotPerks.Length || RadiationHotspots.Length != RadiationHotspotRads.Length
        Debug.Trace("RadiationHotspotMisfortuneScript: RadiationHotspots/RadiationHotspotSpacing/RadiationHotspotPerks/RadiationHotspotRads empty or size mismatch")
    EndIf

    If Player == None
        Player = Game.GetPlayer()
    EndIf

    ParseSettings()

    StartTimer(Utility.RandomFloat(0.0, PumpTimerInterval), PumpTimerId)
EndEvent


Event OnPlayerLoadGame()
    ParseSettings()
EndEvent


Bool Function RollMisfortune()
    If !Player.HasPerk(RadiationHotspotPerks[0])
        return False
    EndIf
    return Utility.RandomFloat() <= ScaledMisfortuneChance
EndFunction


Int Function HighestRankPerkIndex()
    Int i = RadiationHotspotPerks.Length - 1
    While i >= 0
        If Player.HasPerk(RadiationHotspotPerks[i])
            return i
        EndIf
        i -= 1
    EndWhile
    return -1
EndFunction


Function ApplyMisfortune()
    Int index = HighestRankPerkIndex()
    Perk thePerk = RadiationHotspotPerks[index]
    Hazard hotspot = RadiationHotspots[index]
    Float spacing = RadiationHotspotSpacing[index]
    Int rads = RadiationHotspotRads[index]

    ObjectReference[] hotspots = Player.FindAllReferencesOfType(hotspot, spacing)
    If hotspots.Length == 0
        Player.RemovePerk(thePerk)
        Player.PlaceAtMe(hotspot)
        RadiationMessage.Show(rads)
    EndIf
EndFunction


Event OnTimer(Int timerId)
    If timerId == PumpTimerId
        Lock()
        If RollMisfortune()
            ApplyMisfortune()
        EndIf
        Unlock()
        StartTimer(PumpTimerInterval, PumpTimerId)
    EndIf
EndEvent
