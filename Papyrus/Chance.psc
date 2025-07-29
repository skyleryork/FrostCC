Scriptname Chance extends ReferenceAlias


FormList Property JunkItems Auto
FormList Property CommonItems Auto
FormList Property RareItems Auto
FormList Property EpicItems Auto
FormList Property LegendaryItems Auto

Float Property JunkChance Auto
Float Property CommonChance Auto
Float Property RareChance Auto
Float Property EpicChance Auto
Float Property LegendaryChance Auto

Float[] Property IncreaseLockChances Auto
Float[] Property DecreaseLockChances Auto

FormList Property FoodItems Auto
FormList Property ChemItems Auto
FormList Property AmmoItems Auto
FormList Property ValuableItems Auto
FormList Property ToolItems Auto

; ActorValue Property JunkChanceModifier Auto
; ActorValue Property CommonChanceModifier Auto
; ActorValue Property RareChanceModifier Auto
; ActorValue Property EpicChanceModifier Auto
; ActorValue Property LegendaryChanceModifier Auto

Int[] JunkItemCounts = None
Int[] CommonItemCounts = None
Int[] RareItemCounts = None
Int[] EpicItemCounts = None
Int[] LegendaryItemCounts = None

Int[] ForceLockTierCounts = None
Int[] ForceUnockTierCounts = None


Int Function LockLevelToTier(Int level) Global
    return level / 25
EndFunction


Int Function LockTierToLevel(Int tier) Global
    return tier * 25
EndFunction


; filterBits: 0 = junk only, 1 = aid (food), 2 = aid (non-food), 4 = ammo, 8 = misc (valuable), 16 = tools
; Form Function Roll(FormList items, Int[] counts, Float rollChance, Int tierBoost, Int filterBits)
;     Int[] indices = ShuffledIndices(counts.Length)
;     if rollChance <= 0
;         return None
;     EndIf
;     While tierBoost >= 0
;         Int i = 0
;         While i < indices.Length
;             Int j = indices[i]
;             If counts[j]
;                 Form type = items.GetAt(j)
;                 If !Math.LogicalAnd(filterBits, 1) && FoodItems.HasForm(type)
;                     type = None
;                 ElseIf !Math.LogicalAnd(filterBits, 2) && ChemItems.HasForm(type)
;                     type = None
;                 ElseIf !Math.LogicalAnd(filterBits, 4) && AmmoItems.HasForm(type)
;                     type = None
;                 ElseIf !Math.LogicalAnd(filterBits, 8) && ValuableItems.HasForm(type)
;                     type = None
;                 ElseIf !Math.LogicalAnd(filterBits, 16) && ToolItems.HasForm(type)
;                     type = None
;                 EndIf
;                 If type && ( Utility.RandomFloat(0.0, 1.0) <= rollChance )
;                     counts[j] -= 1
;                     return type
;                 EndIf
;             EndIf
;             i += 1
;         EndWhile
;         tierBoost -= 1
;     EndWhile
;     return None
; EndFunction


Event OnInit()
    If JunkItemCounts == None
        JunkItemCounts = New Int[JunkItems.GetSize()]
    EndIf
    If CommonItemCounts == None
        CommonItemCounts = New Int[CommonItems.GetSize()]
    EndIf
    If RareItemCounts == None
        RareItemCounts = New Int[RareItems.GetSize()]
    EndIf
    If EpicItemCounts == None
        EpicItemCounts = New Int[EpicItems.GetSize()]
    EndIf
    If LegendaryItemCounts == None
        LegendaryItemCounts = New Int[LegendaryItems.GetSize()]
    EndIf

    If ForceLockTierCounts == None
        ForceLockTierCounts = new Int[4]
    EndIf
    If ForceUnockTierCounts == None
        ForceUnockTierCounts = new Int[4]
    EndIf
EndEvent


Int Function AddItem(Form item, Int count = 1)
    Int itemIndex = JunkItems.Find(item)
    Int tier = -1
    If itemIndex >= 0
        JunkItemCounts[itemIndex] += count
        ;Debug.Trace("Change::AddItem - added Junk item " + item.GetFormID())
        return 0
    EndIf
    itemIndex = CommonItems.Find(item)
    If itemIndex >= 0
        CommonItemCounts[itemIndex] += count
        ;Debug.Trace("Change::AddItem - added Common item " + item.GetFormID())
        return 1
    EndIf
    itemIndex = RareItems.Find(item)
    If itemIndex >= 0
        RareItemCounts[itemIndex] += count
        ;Debug.Trace("Change::AddItem - added Rare item " + item.GetFormID())
        return 2
    EndIf
    itemIndex = EpicItems.Find(item)
    If itemIndex >= 0
        EpicItemCounts[itemIndex] += count
        ;Debug.Trace("Change::AddItem - added Epic item " + item.GetFormID())
        return 3
    EndIf
    itemIndex = LegendaryItems.Find(item)
    If itemIndex >= 0
        LegendaryItemCounts[itemIndex] += count
        ;Debug.Trace("Change::AddItem - added Legendary item " + item.GetFormID())
        return 4
    EndIf
    ;Debug.Trace("Change::AddItem - " + item.GetFormID() + " not added!")
    return -1
EndFunction


Bool Function AddForceLockTier(Int tier, Int count = 1)
    If tier > 0
        ;Debug.Trace("Change::AddForceLockTier - " + tier + ", " + count)
        ForceLockTierCounts[tier - 1] += count
        return True
    EndIf
    return False
EndFunction


Bool Function AddForceUnlockTier(Int tier, Int count = 1)
    If tier > 0
        ;Debug.Trace("Change::AddForceUnlockTier - " + tier + ", " + count)
        ForceUnockTierCounts[tier - 1] += count
        return True
    EndIf
    return False
EndFunction


; junk, common, rare, epic, legendary
Form[] Function RollByLockTier(Int tier, Int filterBits)
    Form[] rolled = new Form[5]
    ;Debug.Trace("Change::RollByLockTier(0) - items = " + JunkItems + ", counts = " + JunkItemCounts + ", rollChance = " + JunkChance + ", tierBoost = " + tier + ", filterBits = " + filterBits)
    ;rolled[0] = Roll(JunkItems, JunkItemCounts, JunkChance, tier, filterBits)
    rolled[0] = ChanceApi.Roll(0, JunkItems, JunkItemCounts, 1 - Math.Pow(1 - JunkChance, tier + 1), filterBits, FoodItems, ChemItems, AmmoItems, ValuableItems, ToolItems)
    If tier >= 1
        ;Debug.Trace("Change::RollByLockTier(1) - items = " + CommonItems + ", counts = " + CommonItemCounts + ", rollChance = " + CommonChance + ", tierBoost = " + (tier - 1) + ", filterBits = " + filterBits)
        ;rolled[1] = Roll(CommonItems, CommonItemCounts, CommonChance, tier - 1, filterBits)
        rolled[1] = ChanceApi.Roll(0, CommonItems, CommonItemCounts, 1 - Math.Pow(1 - CommonChance, tier), filterBits, FoodItems, ChemItems, AmmoItems, ValuableItems, ToolItems)
    EndIf
    If tier >= 2
        ;Debug.Trace("Change::RollByLockTier(2) - items = " + RareItems + ", counts = " + RareItemCounts + ", rollChance = " + RareChance + ", tierBoost = " + (tier - 2) + ", filterBits = " + filterBits)
        ;rolled[2] = Roll(RareItems, RareItemCounts, RareChance, tier - 2, filterBits)
        rolled[2] = ChanceApi.Roll(0, RareItems, RareItemCounts, 1 - Math.Pow(1 - RareChance, tier - 1), filterBits, FoodItems, ChemItems, AmmoItems, ValuableItems, ToolItems)
    EndIf
    If tier >= 3
        ;Debug.Trace("Change::RollByLockTier(3) - items = " + EpicItems + ", counts = " + EpicItemCounts + ", rollChance = " + EpicChance + ", tierBoost = " + (tier - 3) + ", filterBits = " + filterBits)
        ;rolled[3] = Roll(EpicItems, EpicItemCounts, EpicChance, tier - 3, filterBits)
        rolled[3] = ChanceApi.Roll(0, EpicItems, EpicItemCounts, 1 - Math.Pow(1 - EpicChance, tier - 2), filterBits, FoodItems, ChemItems, AmmoItems, ValuableItems, ToolItems)
    EndIf
    If tier >= 4
        ;Debug.Trace("Change::RollByLockTier(4) - items = " + LegendaryItems + ", counts = " + LegendaryItemCounts + ", rollChance = " + LegendaryChance + ", tierBoost = " + (tier - 4) + ", filterBits = " + filterBits)
        ;rolled[4] = Roll(LegendaryItems, LegendaryItemCounts, LegendaryChance, tier - 4, filterBits)
        rolled[4] = ChanceApi.Roll(0, LegendaryItems, LegendaryItemCounts, 1 - Math.Pow(1 - LegendaryChance, tier - 3), filterBits, FoodItems, ChemItems, AmmoItems, ValuableItems, ToolItems)
    EndIf
    return rolled
EndFunction


; returns the new tier
Int Function RollLock()
    Int[] indices = ChanceApi.ShuffledIndices(0, 4, 1)
    Debug.Trace("Chance::RollLock - " + indices)
    Int rollCount = 0
    Bool rolled = True
    While rolled
        rolled = False
        Int i = 0
        While i < indices.Length
            Int tier = indices[i]
            Int tierIndex = tier - 1
            If ForceLockTierCounts[tierIndex] > rollCount
                rolled = True
                If Utility.RandomFloat(0.0, 1.0) < IncreaseLockChances[tierIndex]
                    ForceLockTierCounts[tierIndex] -= 1
                    return tier
                EndIf
            EndIf
            i += 1
        EndWhile
        rollCount += 1
    EndWhile
    return 0
EndFunction


; returns true if unlocked
Bool Function RollUnlock(Int tier)
    Int tierIndex = tier - 1
    Int count = ForceUnockTierCounts[tierIndex]
    While count > 0
        If Utility.RandomFloat(0.0, 1.0) < DecreaseLockChances[tierIndex]
            ForceUnockTierCounts[tierIndex] -= 1
            return True
        EndIf
        count -= 1
    EndWhile
    return False
EndFunction


; ; returns number of lock tiers increased
; Int Function RollIncreaseLockTier(Int tier, Int targetTier)
;     If targetTier > tier
;         Int tierDelta = targetTier - tier
;         Int count = ForceLockTierCounts[targetTier - 1]
;         Float lockChance = IncreaseLockChances[tierDelta - 1]
;         While count > 0
;             If Utility.RandomFloat(0.0, 1.0) < lockChance
;                 ForceLockTierCounts[targetTier - 1] -= 1
;                 return tierDelta
;             EndIf
;             count -= 1
;         EndWhile
;     EndIf
;     return 0
; EndFunction


; ; returns number of lock tiers decreased
; Int Function RollDecreaseLockTier(Int tier, Int targetTier)
;     If targetTier < tier
;         Int tierDelta = tier - targetTier
;         Int count = ForceUnockTierCounts[targetTier - 1]
;         Float lockChance = DecreaseLockChances[tierDelta - 1]
;         While count > 0
;             If Utility.RandomFloat(0.0, 1.0) < lockChance
;                 ForceUnockTierCounts[targetTier - 1] -= 1
;                 return tierDelta
;             EndIf
;             count -= 1
;         EndWhile
;     EndIf
;     return 0
; EndFunction
