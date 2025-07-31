Scriptname FungalAerosolScript extends ActiveMagicEffect


Potion Property FungalAerosol Auto Const Mandatory
Sound Property SpraySound Auto Const Mandatory
Message Property NoHazardsMessage Auto Const Mandatory
Float Property Radius Auto Const Mandatory


Event OnEffectStart(Actor akTarget, Actor akCaster)
    RadiationHotspotScript radiationHotspot = ( Game.GetFormFromFile(0xF99, "CrowdControl.esp") as Quest ).GetAlias(0) as RadiationHotspotScript

    If radiationHotspot.CleanseHotspots(akTarget, Radius)
        SpraySound.Play(akTarget)
    Else
        NoHazardsMessage.Show()
        akCaster.AddItem(FungalAerosol, abSilent = True)
    EndIf
EndEvent
