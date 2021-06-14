using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    class AdditionSeason
    {
        public string Seasonname { get => seasonname;}
        public double Price { get => price;}

        private string seasonname;
        private double price;

        public AdditionSeason(string seasonname, double price)
        {
            this.seasonname = seasonname;
            this.price = price;
        }
    }
}
