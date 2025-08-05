Scriptname Frost:KillActorPenaltyScript extends Actor
;-- Structures --------------------------------------
Struct FactionPenalty
    Faction NPCFaction
    GlobalVariable Modifier
EndStruct

;-- Properties --------------------------------------

Message Property aaSaneWarning_Message Auto Const
Message Property aaInsaneWarning_Message Auto Const
Perk Property aaSanityPerkInsane Auto Const
ActorValue Property aaSanity Auto Const

Group Adults
    FactionPenalty[] Property HumanFactions Auto Const
    GlobalVariable Property HumanBaseModifier Auto Const
    Race Property HumanRace Auto Const

    FactionPenalty[] Property GhoulFactions Auto Const
    GlobalVariable Property GhoulBaseModifier Auto Const
    Race Property GhoulRace Auto Const
EndGroup

Group Children
    Race Property HumanChildRace Auto Const
    GlobalVariable Property HumanChildBaseModifier Auto Const

    Race Property GhoulChildRace Auto Const
    GlobalVariable Property GhoulChildBaseModifier Auto Const
EndGroup

Group Others
    Keyword Property ActorTypeFeralGhoul Auto Const
    GlobalVariable Property FeralGhoulBaseModifier Auto Const

    Faction Property InsanityFaction Auto Const
    GlobalVariable Property InsanityFactionBaseModifier Auto Const

    GlobalVariable Property RemnantsCNModifier Auto Const
EndGroup

;-- Variables ---------------------------------------
Faction ChineseRemnantsFaction
Actor PlayerRef

;-- Events ------------------------------------------
Event OnInit()
    PlayerRef = Game.GetPlayer()
    ChineseRemnantsFaction = Game.GetFormFromFile(0x0006FE32, "aFrostMod.esp") as Faction
EndEvent

Event OnKill(Actor akVictim)
    If (akVictim.GetKiller() != PlayerRef)
        return
    EndIf

    Race VictimRace = akVictim.GetRace()
    int i = 0
    float BaseModifier = 0.0
    float FactionModifier = 0.0

    if akVictim.IsInFaction(InsanityFaction)
        BaseModifier = InsanityFactionBaseModifier.GetValue()
        if BaseModifier > 0
            PlayerRef.RestoreValue(aaSanity, BaseModifier)
        elseif BaseModifier < 0 
            PlayerRef.DamageValue(aaSanity, -1.0 * BaseModifier)
        endif

    elseif akVictim.HasKeyword(ActorTypeFeralGhoul)
        BaseModifier = FeralGhoulBaseModifier.GetValue()
        if BaseModifier > 0
            PlayerRef.RestoreValue(aaSanity, BaseModifier)
        elseif BaseModifier < 0 
            PlayerRef.DamageValue(aaSanity, -1.0 * BaseModifier)
        endif

    elseif VictimRace == HumanRace
        
        BaseModifier = HumanBaseModifier.GetValue()
        if BaseModifier > 0
            PlayerRef.RestoreValue(aaSanity, BaseModifier)
        elseif BaseModifier < 0 
            PlayerRef.DamageValue(aaSanity, -1.0 * BaseModifier)
        endif

        i = HumanFactions.Length

        
        if ChineseRemnantsFaction != None && akVictim.IsInFaction(ChineseRemnantsFaction)
            
            i = 0
            FactionModifier = RemnantsCNModifier.GetValue()
            if FactionModifier > 0
                PlayerRef.RestoreValue(aaSanity, FactionModifier)
            elseif FactionModifier < 0 
                PlayerRef.DamageValue(aaSanity, -1.0 * FactionModifier)
            endif
        endif


        while i > 0
            i -= 1
            if akVictim.IsInFaction(HumanFactions[i].NPCFaction)
                GlobalVariable FactionModifierGlobal = HumanFactions[i].Modifier
                FactionModifier = FactionModifierGlobal.GetValue()
                if FactionModifier > 0
                    PlayerRef.RestoreValue(aaSanity, FactionModifier)
                elseif FactionModifier < 0 
                    PlayerRef.DamageValue(aaSanity, -1.0 * FactionModifier)
                endif
                i = 0
            endif
        endwhile

    elseif VictimRace == GhoulRace
        BaseModifier = GhoulBaseModifier.GetValue()
        if BaseModifier > 0
            PlayerRef.RestoreValue(aaSanity, BaseModifier)
        elseif BaseModifier < 0 
            PlayerRef.DamageValue(aaSanity, -1.0 * BaseModifier)
        endif

        i = GhoulFactions.Length

        if ChineseRemnantsFaction != None && akVictim.IsInFaction(ChineseRemnantsFaction)
            i = 0
            FactionModifier = RemnantsCNModifier.GetValue()
            if FactionModifier > 0
                PlayerRef.RestoreValue(aaSanity, FactionModifier)
            elseif FactionModifier < 0 
                PlayerRef.DamageValue(aaSanity, -1.0 * FactionModifier)
            endif
        endif

        while i > 0
            i -= 1
            if akVictim.IsInFaction(GhoulFactions[i].NPCFaction)
                GlobalVariable FactionModifierGlobal = GhoulFactions[i].Modifier
                FactionModifier = FactionModifierGlobal.GetValue()
                if FactionModifier > 0
                    PlayerRef.RestoreValue(aaSanity, FactionModifier)
                elseif FactionModifier < 0 
                    PlayerRef.DamageValue(aaSanity, -1.0 * FactionModifier)
                endif
                i = 0
            endif
        endwhile

    elseif VictimRace == HumanChildRace
        BaseModifier = HumanChildBaseModifier.GetValue()
        PlayerRef.DamageValue(aaSanity, -1.0 * BaseModifier)
    elseif VictimRace == GhoulChildRace
        BaseModifier = GhoulChildBaseModifier.GetValue()
        PlayerRef.DamageValue(aaSanity, -1.0 * BaseModifier)
    endif
EndEvent
;-- Functions ---------------------------------------
