using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    public class Reservation
    {
        //public
        public int Ordernumber { get => ordernumber;}
        public string TypeName { get => typeName;}
        public DateTime StartDate { get => startDate; }
        public DateTime EndDate { get => endDate;  }
        public double TotalPrice { get => totalPrice; }
        public bool Checkin { get => checkin;  }
        public bool Checkout { get => checkout;  }
        internal Customer Customer { get => customer; }
        internal CampingSite CampingSite { get => campingSite; }
        internal List<ReservationAddition> ReservationAdditions { get => reservationAdditions; }

        //privates
        private int ordernumber;
        private Customer customer;
        private CampingSite campingSite;
        private string typeName;
        private DateTime startDate;
        private DateTime endDate;
        private double totalPrice;
        private bool checkin;
        private bool checkout;
        private List<ReservationAddition> reservationAdditions;


        public Reservation() { }
        public Reservation(int ordernumber, Customer customer, CampingSite campingSite, string typeName, DateTime startDate, DateTime endDate, double totalPrice, bool checkin, bool checkout, List<ReservationAddition> reservationAdditions)
        {
            this.ordernumber = ordernumber;
            this.customer = customer;
            this.campingSite = campingSite;
            this.typeName = typeName;
            this.startDate = startDate;
            this.endDate = endDate;
            this.totalPrice = totalPrice;
            this.checkin = checkin;
            this.checkout = checkout;
            this.reservationAdditions = reservationAdditions;
        }

        public Reservation(string email, int campingSiteId, string typeName, DateTime startDate, DateTime endDate, List<ReservationAddition> reservationAdditions)
        {
            this.customer = new Customer(email);
            this.campingSite = new CampingSite(campingSiteId);
            this.typeName = typeName;
            this.startDate = startDate;
            this.endDate = endDate;
            this.reservationAdditions = reservationAdditions;
        }


    }
}
