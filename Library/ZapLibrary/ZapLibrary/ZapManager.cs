using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    public class ZapManager
    {
        internal Dal Dal { get => dal; set => dal = value; }


        private Dal dal;

        public ZapManager(string connectionstring)
        {
            dal = new Dal(@"Server=172.16.21.107;Database=Zap_Base;User Id=sa;Password=Passw0rd;");
        }


        public bool CreateCustomer(Customer customer)
        {
            return dal.CreateCustomer(customer);
        }

        public bool UpdateCustomer(string oldemail, Customer customer)
        {
            return dal.UpdateCustomer(oldemail, customer);
        }

        public string CreateReservation(Reservation reservation)
        {
            return dal.CreateReservation(reservation);
        }

        public List<CampingSite> GetAvailableSites(DateTime startDate, DateTime endDate, string typename)
        {
            return dal.GetAvailableSites(startDate, endDate, typename);
        }
    }
}