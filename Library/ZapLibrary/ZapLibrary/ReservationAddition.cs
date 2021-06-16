using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    public class ReservationAddition : Addition
    {
        public int Amount { get => amount; }
        internal AdditionSeason AdditionSeason { get => additionSeason; }

        private AdditionSeason additionSeason;
        private int amount;

        public ReservationAddition (string name, AdditionSeason additionSeason, int amount)
        {
            this.Name = name;
            this.additionSeason = additionSeason;
            this.amount = amount;
        }
    }
}
