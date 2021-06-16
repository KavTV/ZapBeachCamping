using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    public class Customer
    {
        public string Email { get => email; }
        public int Phone { get => phone; }
        public string Name { get => name; }
        public int Postal { get => postal; }
        public string City { get => city; }
        public string Address { get => address;}


        private string email;
        private int phone;
        private string name;
        private int postal;
        private string city;
        private string address;

        public Customer(string email)
        {
            this.email = email;
        }
        public Customer(string email, int phone, string name, int postal, string address)
        {
            this.email = email;
            this.phone = phone;
            this.name = name;
            this.postal = postal;
            this.address = address;
        }
        public Customer(string email, int phone, string name, int postal, string city, string address)
        {
            this.email = email;
            this.phone = phone;
            this.name = name;
            this.postal = postal;
            this.city = city;
            this.address = address;
        }
    }
}
