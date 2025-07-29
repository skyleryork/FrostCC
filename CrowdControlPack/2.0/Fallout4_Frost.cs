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

        private uint GetPrice(int basePrice)
        {
            return priceOverride ?? (uint)(basePrice * priceScale);
        }

        public override EffectList Effects => new[]
        {
			new Effect("Dud Mine", $"scare__{0x1BE55}_1") { Price = GetPrice(5), Category = "Help" },

			new Effect("Frag Mine Scare", $"itemscare_crowdcontrol__{0x1BE6E}_1") { Price = GetPrice(5), Category = "Scares" },

			new Effect("Rare Health Item", $"additem_crowdcontrol__{0x13570}") { Price = GetPrice(5), Category = "Items" },
			new Effect("Rare Money Item", $"additem_crowdcontrol__{0x13573}") { Price = GetPrice(5), Category = "Items" },

			new Effect("Epic Health Item", $"additem_crowdcontrol__{0x13571}") { Price = GetPrice(10), Category = "Items" },
			new Effect("Epic Money Item", $"additem_crowdcontrol__{0x13574}") { Price = GetPrice(10), Category = "Items" },

			new Effect("Legendary Health Item", $"additem_crowdcontrol__{0x1357B}") { Price = GetPrice(20), Category = "Items" },
			new Effect("Legendary Money Item", $"additem_crowdcontrol__{0x1357A}") { Price = GetPrice(20), Category = "Items" },

			new Effect("Junk Item", $"additem_crowdcontrol__{0x1357E}") { Price = GetPrice(1), Category = "Items" },

			new Effect("Increase Locks", $"increaselock") { Price = GetPrice(5), Category = "Locks" },
			new Effect("Decrease Locks", $"decreaselock") { Price = GetPrice(5), Category = "Locks" },

			new Effect("TEST", $"test") { Price = GetPrice(1), Category = "TEST" },

			new Effect("Glowing Ones (3)", $"stalker_866799_3_0_0_0_{hostileSpawnDistanceFar}") { Price = GetPrice(40), Category = "Spawn Hostile NPC" },
		};
    }
}
