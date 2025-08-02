// Copyright (c) 2023 kmrkle.tv community. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.

using ConnectorLib.SimpleTCP;
using CrowdControl.Common;
using System;
using System.Collections.Generic;

namespace CrowdControl.Games.Packs.Fallout4_Frost
{
	public class Fallout4_Frost : SimpleTCPPack<SimpleTCPServerConnector>
	{
		public override string Host => "127.0.0.1";

		public override ushort Port => 5420;

		public Fallout4_Frost(UserRecord player, Func<CrowdControlBlock, bool> responseHandler, Action<object> statusUpdateHandler)
			: base(player, responseHandler, statusUpdateHandler)
		{
		}

		public override Game Game { get; } = new Game("Fallout 4: Frost", "Fallout4_Frost", "PC", ConnectorType.SimpleTCPServerConnector);

		private uint? priceOverride = null;
		private double priceScale = 1.0;

		private uint? neutralSpawnDistance = 200;
		private uint? hostileSpawnDistance = 500;
		private uint? hostileSpawnDistanceFar = 1000;
		private uint? hostileSpawnDistanceSwarm = 1500;
		private uint? hostileSpawnMaxDistance = 2000;

		private uint GetPrice(int basePrice)
		{
			return priceOverride ?? (uint)(basePrice * priceScale);
		}

		public override EffectList Effects => new[]
		{
            #region Locks

            new Effect("Add Novice Lock (1)", $"addlock_1_1") { Price = GetPrice(1), Category = "Locks" },
			new Effect("Add Advanced Lock (1)", $"addlock_2_1") { Price = GetPrice(5), Category = "Locks" },
			new Effect("Add Expert Lock (1)", $"addlock_3_1") { Price = GetPrice(10), Category = "Locks" },
			new Effect("Add Master Lock (1)", $"addlock_4_1") { Price = GetPrice(25), Category = "Locks" },

			new Effect("Remove Novice Lock (1)", $"addunlock_1_1") { Price = GetPrice(1), Category = "Locks" },
			new Effect("Remove Advanced Lock (1)", $"addunlock_2_1") { Price = GetPrice(5), Category = "Locks" },
			new Effect("Remove Expert Lock (1)", $"addunlock_3_1") { Price = GetPrice(10), Category = "Locks" },
			new Effect("Remove Master Lock (1)", $"addunlock_4_1") { Price = GetPrice(25), Category = "Locks" },

			#endregion

			#region Items (Junk)

			new Effect("Give Junk Scrap (1)", $"additem_crowdcontrol__{0x1357E}") { Price = GetPrice(5), Category = "Junk Items" },
			new Effect("Give Junk Tools (1)", $"additem_crowdcontrol__{0x1BE53}") { Price = GetPrice(5), Category = "Junk Items" },

			#endregion

			#region Items (Common)

			new Effect("Give Common Tools (1)", $"additem_crowdcontrol__{0x1BE4F}") { Price = GetPrice(5), Category = "Common Items" },
			new Effect("Give Common Food (1)", $"additem_crowdcontrol__{0x13584}") { Price = GetPrice(5), Category = "Common Items" },
			new Effect("Give Common Chems (1)", $"additem_crowdcontrol__{0x1357D}") { Price = GetPrice(5), Category = "Common Items" },
			new Effect("Give Common Ammo (1)", $"additem_crowdcontrol__{0x13588}") { Price = GetPrice(5), Category = "Common Items" },
			new Effect("Give Common Valuables (1)", $"additem_crowdcontrol__{0x1357C}") { Price = GetPrice(5), Category = "Common Items" },

			#endregion

			#region Items (Rare)

			new Effect("Give Rare Tools (1)", $"additem_crowdcontrol__{0x1BE50}") { Price = GetPrice(5), Category = "Rare Items" },
			new Effect("Give Rare Food (1)", $"additem_crowdcontrol__{0x13585}") { Price = GetPrice(5), Category = "Rare Items" },
			new Effect("Give Rare Chems (1)", $"additem_crowdcontrol__{0x13570}") { Price = GetPrice(5), Category = "Rare Items" },
			new Effect("Give Rare Ammo (1)", $"additem_crowdcontrol__{0x13589}") { Price = GetPrice(5), Category = "Rare Items" },
			new Effect("Give Rare Valuables (1)", $"additem_crowdcontrol__{0x13573}") { Price = GetPrice(5), Category = "Rare Items" },

			#endregion

			#region Items (Epic)

			new Effect("Give Epic Tools (1)", $"additem_crowdcontrol__{0x1BE51}") { Price = GetPrice(5), Category = "Epic Items" },
			new Effect("Give Epic Food (1)", $"additem_crowdcontrol__{0x13586}") { Price = GetPrice(5), Category = "Epic Items" },
			new Effect("Give Epic Chems (1)", $"additem_crowdcontrol__{0x13571}") { Price = GetPrice(5), Category = "Epic Items" },
			new Effect("Give Epic Ammo (1)", $"additem_crowdcontrol__{0x1358A}") { Price = GetPrice(5), Category = "Epic Items" },
			new Effect("Give Epic Valuables (1)", $"additem_crowdcontrol__{0x13574}") { Price = GetPrice(5), Category = "Epic Items" },

			#endregion

			#region Items (Legendary)

			new Effect("Give Legendary Food (1)", $"additem_crowdcontrol__{0x13587}") { Price = GetPrice(5), Category = "Legendary Items" },
			new Effect("Give Legendary Chems (1)", $"additem_crowdcontrol__{0x1357B}") { Price = GetPrice(5), Category = "Legendary Items" },
			new Effect("Give Legendary Ammo (1)", $"additem_crowdcontrol__{0x1358B}") { Price = GetPrice(5), Category = "Legendary Items" },
			new Effect("Give Legendary Valuables (1)", $"additem_crowdcontrol__{0x1357A}") { Price = GetPrice(5), Category = "Legendary Items" },

			#endregion

			#region Scares

			new Effect("Frag Mine Scare", $"itemscare_crowdcontrol__{0x1BE6E}_1") { Price = GetPrice(5), Category = "Scares" },
			new Effect("Grenade Bouquet Scare", $"addspell_crowdcontrol__{0x1BE81}") { Price = GetPrice(5), Category = "Scares" },

			#endregion

			#region Hostile Creatures

			new Effect("Feral Ghouls (2-3)", $"spawnstalkers_{0x75337}_2~3_1500~3000") { Price = GetPrice(20), Category = "Hostile Creatures" },
			new Effect("Glowing One (1)", $"spawnstalkers_{0xD39EF}_1_1500~3000") { Price = GetPrice(25), Category = "Hostile Creatures" },

			#endregion

			#region Hostile NPCs

			new Effect("Survivors (2-3)", $"spawnstalkers_{0x22E48}_2~3_1500~3000") { Price = GetPrice(25), Category = "Hostile NPCs" },
			new Effect("Maldenmen (1-2)", $"spawnstalkers_frost__{0x6B45F}_1~2_1500~3000") { Price = GetPrice(25), Category = "Hostile NPCs" },

			#endregion

			#region Hazards

			new Effect("Radiation Hotspot", $"hazard__radiation") { Description = "Spawn a 3\\6\\9 rad/s radiation hazard.", Price = GetPrice(5), Category = "Hazards" },
			new Effect("Frag Mine Cluster (1-2)", $"hazard_{0xE56C3}_2~4_500~1500_32_512") { Price = GetPrice(25), Category = "Hazards" },

			#endregion

			#region Misfortunes

			new Effect("Lose Item", $"misfortune__loseitem") { Description = "Player's loses a random fragile item.", Price = GetPrice(25), Category = "Misfortunes" },
			new Effect("Contamination", $"misfortune__contamination") { Description = "Contaminate a random food item.", Price = GetPrice(25), Category = "Misfortunes" },

			#endregion

			#region Bounties

			new Effect("Feral Ghouls", $"bounty__feralghouls") { Price = GetPrice(25), Category = "Bounties" },

			#endregion

			#region NPC Loot

			new Effect("Cooked Food", $"loot__npc__cookedfood") { Price = GetPrice(25), Category = "NPC Loot" },
			new Effect("Water", $"loot__npc__water") { Price = GetPrice(25), Category = "NPC Loot" },

			#endregion

			#region TEST

			new Effect("TEST", $"test") { Price = GetPrice(1), Category = "TEST" },

			#endregion
		};
	}
}
