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
        return 0
    EndIf
    itemIndex = CommonItems.Find(item)
    If itemIndex >= 0
        CommonItemCounts[itemIndex] += count
        return 1
    EndIf
    itemIndex = RareItems.Find(item)
    If itemIndex >= 0
        RareItemCounts[itemIndex] += count
        return 2
    EndIf
    itemIndex = EpicItems.Find(item)
    If itemIndex >= 0
        EpicItemCounts[itemIndex] += count
        return 3
    EndIf
    itemIndex = LegendaryItems.Find(item)
    If itemIndex >= 0
        LegendaryItemCounts[itemIndex] += count
        return 4
    EndIf
    return -1
EndFunction


Bool Function AddForceLockTier(Int tier, Int count = 1)
    If tier > 0
        ForceLockTierCounts[tier - 1] += count
        return True
    EndIf
    return False
EndFunction


Bool Function AddForceUnlockTier(Int tier, Int count = 1)
    If tier > 0
        ForceUnockTierCounts[tier - 1] += count
        return True
    EndIf
    return False
EndFunction


; junk, common, rare, epic, legendary
Form[] Function RollByLockTier(Int tier, Int filterBits)
    Form[] rolled = new Form[5]
    rolled[0] = ChanceApi.Roll(0, JunkItems, JunkItemCounts, 1 - Math.Pow(1 - JunkChance, tier + 1), filterBits, FoodItems, ChemItems, AmmoItems, ValuableItems, ToolItems)
    If tier >= 1
        rolled[1] = ChanceApi.Roll(0, CommonItems, CommonItemCounts, 1 - Math.Pow(1 - CommonChance, tier), filterBits, FoodItems, ChemItems, AmmoItems, ValuableItems, ToolItems)
    EndIf
    If tier >= 2
        rolled[2] = ChanceApi.Roll(0, RareItems, RareItemCounts, 1 - Math.Pow(1 - RareChance, tier - 1), filterBits, FoodItems, ChemItems, AmmoItems, ValuableItems, ToolItems)
    EndIf
    If tier >= 3
        rolled[3] = ChanceApi.Roll(0, EpicItems, EpicItemCounts, 1 - Math.Pow(1 - EpicChance, tier - 2), filterBits, FoodItems, ChemItems, AmmoItems, ValuableItems, ToolItems)
    EndIf
    If tier >= 4
        rolled[4] = ChanceApi.Roll(0, LegendaryItems, LegendaryItemCounts, 1 - Math.Pow(1 - LegendaryChance, tier - 3), filterBits, FoodItems, ChemItems, AmmoItems, ValuableItems, ToolItems)
    EndIf
    return rolled
EndFunction


; returns the new tier
Int Function RollLock()
    Int[] indices = ChanceApi.ShuffledIndices(0, 4, 1)
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
