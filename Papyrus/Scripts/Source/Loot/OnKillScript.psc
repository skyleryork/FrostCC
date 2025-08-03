Scriptname Loot:OnKillScript extends ReferenceAlias

Float Property OnKillChance Auto Const Mandatory

FormList Property OnKillPerks Auto Const Mandatory
FormList Property OnKillRaces Auto Const
FormList Property OnKillExcludeKeywords Auto Const
Form Property OnKillLoot Auto Const Mandatory

Message Property OnKillMessage Auto Const Mandatory
Message Property OnKillPerkMessage Auto Const Mandatory

String Property OnKillChanceConfig Auto Const Mandatory


RPGRuntimeScript Runtime = None


Bool Function Add()
    return Runtime.OnAdded(Self)
EndFunction


Event OnInit()
    If Runtime == None
        Runtime = GetOwningQuest().GetAlias(0) as RPGRuntimeScript
    EndIf

    If !Runtime.ContainsMisfortune(Self)
        RPGRuntimeScript:StaticData data = new RPGRuntimeScript:StaticData
        data.ref = Self
        data.timerInterval = 1.0
        data.type = Runtime.TypeKill
        data.staticChance = OnKillChance
        data.perks = OnKillPerks
        data.addedMessage = OnKillPerkMessage
        data.runMessage = OnKillMessage
        data.chanceConfig = OnKillChanceConfig
        Runtime.RegisterMisfortune(data)

        Debug.Trace("Loot:OnKillScript: registered")
    EndIf
EndEvent


Event RPGRuntimeScript.OnKilled(RPGRuntimeScript ref, Var[] args)
    If (args[0] as ScriptObject) != Self
        return
    EndIf

    Actor victim = args[2] as Actor

    If !OnKillRaces || OnKillRaces.HasForm(victim.GetRace())
        If !OnKillExcludeKeywords || !victim.HasKeywordInFormList(OnKillExcludeKeywords)
            victim.AddItem(OnKillLoot)
            ref.OnApplyResult(Self, True)
            return
        EndIf
    EndIf

    ref.OnApplyResult(Self, False)
EndEvent
