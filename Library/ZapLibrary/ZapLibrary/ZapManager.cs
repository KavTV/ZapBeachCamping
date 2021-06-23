using System;
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

        #region PROCEDURES
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
            //Creates a thread that sends an email. Will terminate itself when done.
            Thread emailThread = new Thread(() => mail.SendEmail(reservation.Customer.Email, 
                "Din bestilling er bekræftiget",
                "Dit ordrenummer er: " + ordernumber));
            emailThread.Start();

            return ordernumber;
        }
        /// <summary>
        /// Deletes a reservation
        /// </summary>
        /// <param name="ordernumber"></param>
        /// <returns>true if succeded</returns>
        public bool DeleteReservation(string ordernumber)
        {
            return dal.DeleteReservation(ordernumber);
        }
        /// <summary>
        /// Returns a true if customer is created
        /// </summary>
        /// <param name="email"></param>
        /// <returns>true if customer is created</returns>
        public bool IsCustomerCreated(string email)
        {
            return dal.IsCustomerCreated(email);
        }
        #endregion
        #region FUNCTIONS
        /// <summary>
        /// Returns all available sites for the specified period and campingtype.
        /// </summary>
        /// <param name="startDate"></param>
        /// <param name="endDate"></param>
        /// <param name="typename"></param>
        /// <returns>List of campingSites</returns>
        public List<CampingSite> GetAvailableSites(DateTime startDate, DateTime endDate, string typename)
        {
            return dal.GetAvailableSites(startDate, endDate, typename);
        }

        /// <summary>
        /// Gets the additions for this season
        /// </summary>
        /// <param name="startDate"></param>
        /// <param name="endDate"></param>
        /// <returns></returns>
        public List<AdditionSeason> GetAdditions(DateTime startDate, DateTime endDate, string typeName)
        {
            return dal.GetAdditions(startDate, endDate, typeName);
        }
        /// <summary>
        /// Finds the specific reservation
        /// </summary>
        /// <param name="ordernumber"></param>
        /// <returns></returns>
        public Reservation GetReservation(string ordernumber)
        {
            return dal.GetReservation(ordernumber);
        }
        /// <summary>
        /// Gets a specific campingsite information for a specific period.
        /// Should have been a single object, but makes it easier for implementation in website.
        /// </summary>
        /// <param name="campingId"></param>
        /// <param name="typename"></param>
        /// <param name="startDate"></param>
        /// <param name="endDate"></param>
        /// <returns></returns>
        public List<CampingSite> GetCampingSite(string campingId, string typename, DateTime startDate, DateTime endDate)
        {
            return dal.GetCampingSite(campingId, typename, startDate, endDate);
        }
        /// <summary>
        /// Returns all campingTypes
        /// </summary>
        /// <returns></returns>
        public List<CampingType> GetCampingTypes(bool IsSeasonType, bool IsSale)
        {
            return dal.GetCampingTypes(IsSeasonType, IsSale);
        }
        /// <summary>
        /// Gets the date for the specific season
        /// </summary>
        /// <param name="typename"></param>
        /// <returns></returns>
        public CampingType GetSeasonDates(string typename)
        {
            return dal.GetSeasonDates(typename);
        }
        #endregion
    }
}