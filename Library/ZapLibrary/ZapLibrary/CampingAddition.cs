﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    class CampingAddition : Addition
    {
        public double Price { get => price; }

        private double price;

        public CampingAddition(string name, double price)
        {
            this.Name = name;
            this.price = price;
        }
    }
}
