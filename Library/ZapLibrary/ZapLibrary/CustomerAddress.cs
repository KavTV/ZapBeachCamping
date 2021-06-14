using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    class CustomerAddress
    {
        public int Postal { get => postal; }
        public string City { get => city; }
        public string Address { get => address; set => address = value; }

        private int postal;
        private string city;
        private string address;

        public CustomerAddress(int postal, string city, string address)
        {
            this.postal = postal;
            this.city = city;
            this.address = address;
        }
        public CustomerAddress(int postal, string address)
        {
            this.postal = postal;
            this.address = address;
        }
    }
}
