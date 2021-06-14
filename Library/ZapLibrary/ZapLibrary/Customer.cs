using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    class Customer
    {
        public string Email { get => email; }
        public int Phone { get => phone; }
        public string Name { get => name; }
        internal CustomerAddress CustomerAddress { get => cityCode; }


        private string email;
        private int phone;
        private string name;
        private CustomerAddress cityCode;

        public Customer(string email)
        {
            this.email = email;
        }
        public Customer(string email, int phone, string name, CustomerAddress cityCode)
        {
            this.email = email;
            this.phone = phone;
            this.name = name;
            this.cityCode = cityCode;
        }
    }
}
