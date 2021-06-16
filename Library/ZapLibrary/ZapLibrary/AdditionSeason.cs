using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    public class AdditionSeason : Addition
    {
        public string Seasonname { get => seasonname;}
        public double Price { get => price;}

        private string seasonname;
        private double price;

        public AdditionSeason(string name, string seasonname, double price)
        {
            this.Name = name;
            this.seasonname = seasonname;
            this.price = price;
        }
    }
}
