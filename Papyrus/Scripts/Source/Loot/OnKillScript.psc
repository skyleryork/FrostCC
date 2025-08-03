Scriptname Loot:OnKillScript extends ReferenceAlias

Float Property OnKillChance Auto Const Mandatory

FormList Property OnKillPerks Auto Const Mandatory
FormList Property OnKillRaces Auto Const
FormList Property OnKillExcludeKeywords Auto Const
Form Property OnKillLoot Auto Const Mandatory

Message Property OnKillMessage Auto Const Mandatory
Message Property OnKillPerkMessage Auto Const Mandatory

String Property OnKillChanceConfig Auto Const Mandatory
String Property OnKillDurationConfig Auto Const Mandatory


RPGRuntimeScript Runtime = None
Bool oneTimeInit = False


Bool Function Add()
    return Runtime.OnAdded(Self)
EndFunction


Event OnInit()
    If Runtime == None
        Runtime = GetOwningQuest().GetAlias(0) as RPGRuntimeScript
    EndIf

    If !oneTimeInit
        oneTimeInit = True

        RPGRuntimeScript:StaticData data = new RPGRuntimeScript:StaticData
        data.source = Self
        data.timerInterval = 1.0
        data.type = Runtime.TypeKill
        data.staticChance = OnKillChance
        data.perks = OnKillPerks
        data.addedMessage = OnKillPerkMessage
        data.runMessage = OnKillMessage
        data.chanceConfig = OnKillChanceConfig
        data.durationConfig = OnKillDurationConfig
        Runtime.RegisterMisfortune(data)
    EndIf
EndEvent


Event RPGRuntimeScript.OnKilled(RPGRuntimeScript source, Var[] args)
    Actor Player = args[0] as Actor
    Actor Victim = args[1] as Actor

   If !OnKillRaces || OnKillRaces.HasForm(Victim.GetRace())
        If !OnKillExcludeKeywords || !Victim.HasKeywordInFormList(OnKillExcludeKeywords)
            Victim.AddItem(OnKillLoot)
            source.OnApplyResult(Self, True)
            return
        EndIf
    EndIf

    source.OnApplyResult(Self, False)
EndEvent
