using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    public class ReservationAddition
    {
        public int Amount { get => amount; }
        public AdditionSeason AdditionSeason { get => additionSeason; }

        private AdditionSeason additionSeason;
        private int amount;

        public ReservationAddition (AdditionSeason additionSeason, int amount)
        {
            this.additionSeason = additionSeason;
            this.amount = amount;
        }
    }
}
