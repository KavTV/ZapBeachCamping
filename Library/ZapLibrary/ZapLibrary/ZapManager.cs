﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;

namespace ZapLibrary
{
    public class ZapManager
    {
        internal Dal Dal { get => dal; set => dal = value; }
        Email mail = new Email("zapcamping123@gmail.com", "Passw0rd123!"); //You would ofc not put your password in like this


        private Dal dal;

        public ZapManager()
        {
            dal = new Dal(@"Server=172.16.21.107;Database=Zap_Base;User Id=sa;Password=Passw0rd;");
        }
        public ZapManager(string connectionstring)
        {
            dal = new Dal(connectionstring);
        }

        /// <summary>
        /// Creates a customer in the database
        /// </summary>
        /// <param name="customer"></param>
        /// <returns>True if successful</returns>
        public bool CreateCustomer(Customer customer)
        {
            return dal.CreateCustomer(customer);
        }
        /// <summary>
        /// Updates the customer information with the new customer object
        /// </summary>
        /// <param name="oldemail"></param>
        /// <param name="customer"></param>
        /// <returns>true if successful</returns>
        public bool UpdateCustomer(string oldemail, Customer customer)
        {
            return dal.UpdateCustomer(oldemail, customer);
        }
        /// <summary>
        /// Creates a reservation, and sends an email with ordernumber
        /// </summary>
        /// <param name="reservation"></param>
        /// <returns>Ordernumber of the created reservation</returns>
        public int CreateReservation(Reservation reservation)
        {
            int ordernumber = dal.CreateReservation(reservation);
            Thread emailThread = new Thread(() => mail.SendEmail(reservation.Customer.Email, 
                "Din bestilling er bekræftiget",
                "Dit ordrenummer er: " + ordernumber));
            emailThread.Start();

            return ordernumber;
        }

        public bool DeleteReservation(string ordernumber)
        {
            return dal.DeleteReservation(ordernumber);
        }

        public List<CampingSite> GetAvailableSites(DateTime startDate, DateTime endDate, string typename)
        {
            return dal.GetAvailableSites(startDate, endDate, typename);
        }

        public List<AdditionSeason> GetAdditions(DateTime startDate, DateTime endDate)
        {
            return dal.GetAdditions(startDate, endDate);
        }
        public Reservation GetReservation(string ordernumber)
        {
            return dal.GetReservation(ordernumber);
        }
        public List<CampingSite> GetCampingSite(string campingId, string typename, DateTime startDate, DateTime endDate)
        {
            return dal.GetCampingSite(campingId, typename, startDate, endDate);
        }
        public bool IsCustomerCreated(string email)
        {
            return dal.IsCustomerCreated(email);
        }
        public List<CampingType> GetCampingTypes(bool IsSeasonType)
        {
            return dal.GetCampingTypes(IsSeasonType);
        }
        public CampingType GetSeasonDates(string typename)
        {
            return dal.GetSeasonDates(typename);
        }
    }
}