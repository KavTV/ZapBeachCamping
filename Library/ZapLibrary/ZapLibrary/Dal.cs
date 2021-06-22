using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using System.Globalization;

namespace ZapLibrary
{
    public class Dal
    {
        private string connectionString;

        public Dal(string connectionString)
        {
            this.connectionString = connectionString;
        }

        #region Stored procedures
        /// <summary>
        /// Creates a customer in the database
        /// </summary>
        /// <param name="customer"></param>
        /// <returns>True if successful</returns>
        public bool CreateCustomer(Customer customer)
        {

            SqlCommand cmd = new SqlCommand("EXEC dbo.CreateCustomer @email,@postal,@phone,@address,@name");
            cmd.Parameters.AddWithValue("email", customer.Email);
            cmd.Parameters.AddWithValue("postal", customer.Postal);
            cmd.Parameters.AddWithValue("phone", customer.Phone);
            cmd.Parameters.AddWithValue("address", customer.Address);
            cmd.Parameters.AddWithValue("name", customer.Name);

            return ExecuteNonQuery(cmd);

        }


        /// <summary>
        /// Updates the customer information with the new customer object
        /// </summary>
        /// <param name="oldemail"></param>
        /// <param name="customer"></param>
        /// <returns>true if successful</returns>
        public bool UpdateCustomer(string oldemail, Customer customer)
        {
            SqlCommand cmd = new SqlCommand("EXEC dbo.UpdateCustomer @oldemail,@email,@postal,@phone,@name,@address");
            cmd.Parameters.AddWithValue("oldemail", oldemail);
            cmd.Parameters.AddWithValue("email", customer.Email);
            cmd.Parameters.AddWithValue("postal", customer.Postal);
            cmd.Parameters.AddWithValue("phone", customer.Phone);
            cmd.Parameters.AddWithValue("address", customer.Address);
            cmd.Parameters.AddWithValue("name", customer.Name);

            return ExecuteNonQuery(cmd);

        }
        /// <summary>
        /// Creates a reservation
        /// </summary>
        /// <param name="reservation"></param>
        /// <returns>Ordernumber of the created reservation</returns>
        public int CreateReservation(Reservation reservation)
        {
            //Convert additions into a long string with all additions, for the procedure.
            string additionAndAmount = "";
            int count = 1;
            if (reservation.ReservationAdditions != null)
            {

                foreach (var item in reservation.ReservationAdditions)
                {
                    if (count == reservation.ReservationAdditions.Count)
                    {
                        additionAndAmount += item.AdditionSeason.Name + "." + item.Amount;
                    }
                    else
                    {
                        additionAndAmount += item.AdditionSeason.Name + "." + item.Amount + ",";
                    }
                    count++;
                }
            }

            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("DECLARE @ID INT;EXECUTE dbo.CreateReservation @email, @campingid, @typename, @startdate, @enddate, @additionsandamount, @ReservationID = @ID OUTPUT;SELECT @ID as ordernumber", con);
            cmd.Parameters.AddWithValue("email", reservation.Customer.Email);
            cmd.Parameters.AddWithValue("campingid", reservation.CampingSite.Id);
            cmd.Parameters.AddWithValue("typename", reservation.TypeName);
            cmd.Parameters.AddWithValue("startdate", reservation.StartDate);
            cmd.Parameters.AddWithValue("enddate", reservation.EndDate);
            cmd.Parameters.AddWithValue("additionsandamount", additionAndAmount);

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();

            reader.Read();

            int order = reader.GetInt32(0);

            con.Close();

            return order;
        }
        public bool DeleteReservation(string ordernumber)
        {
            SqlCommand cmd = new SqlCommand("EXEC [dbo].[DeleteReservation] @ordernumber");
            cmd.Parameters.AddWithValue("ordernumber", ordernumber);

            return ExecuteNonQuery(cmd);
        }
        public bool IsCustomerCreated(string email)
        {
            //SQL command and params
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("DECLARE @result BIT EXECUTE @result = dbo.IsCustomerCreated @email SELECT @result", con);
            cmd.Parameters.AddWithValue("email", email);

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();

            //Add the name to the list
            reader.Read();
            bool isCreated = reader.GetBoolean(0);


            con.Close();
            return isCreated;
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
            List<CampingSite> campingSites = new List<CampingSite>();


            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("SELECT * FROM [dbo].[GetAvaliableSites](@startdate,@enddate,@typename) ORDER BY LEN(id), id", con);
            cmd.Parameters.Add("startdate", SqlDbType.Date).Value = startDate;
            cmd.Parameters.Add("enddate", SqlDbType.Date).Value = endDate;
            cmd.Parameters.AddWithValue("typename", typename);

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();



            // Reads table
            while (reader.Read())
            {
                List<CampingAddition> additions = GetAdditionsFromString(reader[2].ToString());
                CampingSite camp = new CampingSite(reader.GetString(0), true, ((double)reader.GetDecimal(1)), new List<string>(), additions);

                campingSites.Add(camp);
            }


            con.Close();
            return campingSites;
        }
        /// <summary>
        /// Gets the additions for this season
        /// </summary>
        /// <param name="startDate"></param>
        /// <param name="endDate"></param>
        /// <returns></returns>
        public List<AdditionSeason> GetAdditions(DateTime startDate, DateTime endDate)
        {
            //Objects
            List<AdditionSeason> additionSeasons = new List<AdditionSeason>();


            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("SELECT * FROM [dbo].[GetAdditions] (@startdate,@enddate)", con);
            cmd.Parameters.Add("startdate", SqlDbType.Date).Value = startDate;
            cmd.Parameters.Add("enddate", SqlDbType.Date).Value = endDate;

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();

            // Reads table
            while (reader.Read())
            {
                additionSeasons.Add(new AdditionSeason(reader.GetString(0), reader.GetString(1),
                    (double)reader.GetDecimal(2), reader.GetString(3)));

            }


            con.Close();
            return additionSeasons;
        }
        /// <summary>
        /// Finds the specific reservation
        /// </summary>
        /// <param name="ordernumber"></param>
        /// <returns></returns>
        public Reservation GetReservation(string ordernumber)
        {

            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("SELECT * FROM [dbo].[GetReservation](@ordernumber)", con);
            cmd.Parameters.AddWithValue("ordernumber", ordernumber);

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();

            // Reads table
            reader.Read();

            List<ReservationAddition> reservationAdditions = new List<ReservationAddition>();
            string additions = reader[7].ToString();
            if (additions != "")
            {
                string[] additionSplit = additions.Split(',');
                foreach (var addition in additionSplit)
                {
                    string[] additionNameSplit = addition.Split(':');
                    reservationAdditions.Add(new ReservationAddition(new AdditionSeason(additionNameSplit[1],
                        "", double.Parse(additionNameSplit[2], CultureInfo.InvariantCulture)), int.Parse(additionNameSplit[0])));
                }
            }

            Reservation reservation = new Reservation(reader.GetInt32(0), new Customer(reader.GetString(1)),
            new CampingSite(reader.GetString(2)), reader.GetString(3), reader.GetDateTime(4),
            reader.GetDateTime(5), (double)reader.GetDecimal(6), false, false, reservationAdditions);

            con.Close();
            return reservation;
        }
        /// <summary>
        /// Returns all campingTypes
        /// </summary>
        /// <returns></returns>
        public List<CampingType> GetCampingTypes(bool IsSeasonType)
        {
            //Create list with campingtypes
            List<CampingType> campingTypes = new List<CampingType>();

            //SQL command and params
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.GetCampingTypes(@IsSeasonType) ORDER BY [name] ASC", con);
            cmd.Parameters.Add("IsSeasonType", SqlDbType.Bit).Value = IsSeasonType;

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();

            //Add the name to the list
            while (reader.Read())
            {
                campingTypes.Add(new CampingType(reader.GetString(0)));
            }

            con.Close();

            return campingTypes;
        }
        public List<CampingSite> GetCampingSite(string campingId, string typename, DateTime startDate, DateTime endDate)
        {
            //Objects
            List<CampingSite> campingSites = new List<CampingSite>();

            //SQL command and params
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("SELECT * FROM [dbo].[GetCampingSite](@CampingID,@typename,@StartDate, @EndDate)", con);
            cmd.Parameters.AddWithValue("CampingID", campingId);
            cmd.Parameters.AddWithValue("typename", typename);
            cmd.Parameters.Add("startdate", SqlDbType.Date).Value = startDate;
            cmd.Parameters.Add("enddate", SqlDbType.Date).Value = endDate;

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();

            //Reads table
            while (reader.Read())
            {
                //Split the string into addition objects
                List<CampingAddition> additions = GetAdditionsFromString(reader[3].ToString());
                CampingSite camp = new CampingSite(reader.GetString(0), true, ((double)reader.GetDecimal(2)), new List<string>() { reader.GetString(1) }, additions);

                campingSites.Add(camp);
            }

            con.Close();
            return campingSites;
        }
        public CampingType GetSeasonDates(string typename)
        {
            //SQL command and params
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("SELECT * FROM [dbo].[GetSeasonDates](@typename)", con);
            cmd.Parameters.AddWithValue("typename", typename);

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();

            //Reads table
            reader.Read();

            CampingType camp = new CampingType(reader.GetDateTime(0), reader.GetDateTime(1));

            con.Close();
            return camp;
        }

        #endregion

        /// <summary>
        /// This is used for splitting a string with campingadditions
        /// </summary>
        /// <param name="reader"></param>
        /// <returns></returns>
        private static List<CampingAddition> GetAdditionsFromString(string reader)
        {
            List<CampingAddition> additions = new List<CampingAddition>();
            string campingAdditions = reader;
            if (campingAdditions != "")
            {
                string[] campingAdditionSplit = campingAdditions.Split(',');
                foreach (var name in campingAdditionSplit)
                {
                    additions.Add(new CampingAddition(name));
                }
            }

            return additions;
        }

        /// <summary>
        /// This executes a command that does not return anything
        /// </summary>
        /// <param name="cmd"></param>
        /// <returns></returns>
        private bool ExecuteNonQuery(SqlCommand cmd)
        {
            // Creates connection
            SqlConnection con = new SqlConnection(connectionString);
            cmd.Connection = con;

            // Opens connections
            con.Open();

            try
            {
                cmd.ExecuteNonQuery();
            }
            catch (Exception)
            {
                con.Close();
                return false;
            }
            //If succeded close connection and return true, for success
            con.Close();
            return true;
        }
    }
}
