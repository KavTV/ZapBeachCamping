using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data;
using Dapper;

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

        public bool CreateCustomer(Customer customer)
        {
            //return GetDB(c => c.Query<bool>("EXEC dbo.CreateCustomer @email,@postal,@phone,@address,@name", customer).FirstOrDefault());
            return DbExec("EXEC dbo.CreateCustomer @email, @postal, @phone, @address, @name", customer);
        }



        public bool UpdateCustomer(string oldemail, Customer customer)
        {

            return DbExec("EXEC dbo.UpdateCustomer @oldemail,@email,@postal,@phone,@name,@address", new
            {
                oldemail = oldemail,
                email = customer.Email,
                postal = customer.Postal,
                phone = customer.Phone,
                name = customer.Name,
                address = customer.Address
            });
        }
        public string CreateReservation(Reservation reservation)
        {
            string additionAndAmount = "";
            int count = 1;
            if (reservation.ReservationAdditions != null)
            {

                foreach (var item in reservation.ReservationAdditions)
                {
                    if (count == reservation.ReservationAdditions.Count)
                    {
                        additionAndAmount += item.Name + "." + item.Amount;
                    }
                    else
                    {
                        additionAndAmount += item.Name + "." + item.Amount + ",";
                    }
                    count++;
                }
            }
            return GetDB(c => c.Query<string>("DECLARE @ID INT;EXECUTE dbo.CreateReservation @email, @campingid, @typename, @startdate, @enddate, @additionsandamount, @ReservationID = @ID OUTPUT;SELECT @ID as ordernumber"
                , new
                {
                    reservation.Customer.Email,
                    campingid = reservation.CampingSite.Id,
                    reservation.TypeName,
                    reservation.StartDate,
                    reservation.EndDate,
                    additionsandamount = additionAndAmount
                }).FirstOrDefault());

        }
        public bool DeleteReservation(string ordernumber)
        {
            return DbExec("EXEC dbo.CreateCustomer @ordernumber", ordernumber);
            
        }
        #endregion

        #region FUNCTIONS
        public List<CampingSite> GetAvailableSites(DateTime startDate, DateTime endDate, string typename)
        {
            List<CampingSite> campingSites = new List<CampingSite>();
            List<CampingAddition> additions = new List<CampingAddition>();
            //return GetDB(c => c.Query<List<CampingSite>>("SELECT * FROM [dbo].[GetAvaliableSites]('@startdate','@enddate','@typename')",new { startDate, endDate, typename})).ToList();
            using (IDbConnection db = new SqlConnection(connectionString))
            {

                var jens = db.Query<CampingSite>("SELECT * FROM [dbo].[GetAvaliableSites]('@startdate','@enddate','@typename')", new { startDate, endDate, typename }).ToList();
                return jens;
            }
            
            SqlConnection con = new SqlConnection(connectionString);
            SqlCommand cmd = new SqlCommand("SELECT * FROM [dbo].[GetAvaliableSites]('@startdate','@enddate','@typename')", con);
            cmd.Parameters.AddWithValue("startdate", startDate);
            cmd.Parameters.AddWithValue("enddate", endDate);
            cmd.Parameters.AddWithValue("typename", typename);

            con.Open();
            SqlDataReader reader = cmd.ExecuteReader();

            

            // Reads table
            while (reader.Read())
            {
                
                string campingAdditions = reader.GetString(2);
                if (campingAdditions != "NULL")
                {
                    string[] campingAdditionSplit = campingAdditions.Split(',');
                    foreach (var name in campingAdditionSplit)
                    {
                        additions.Add(new CampingAddition(name));
                    }
                }
                CampingSite camp = new CampingSite(reader.GetInt32(0), true, reader.GetDouble(1), new List<string>(), additions);

                campingSites.Add(camp);
            }


            con.Close();
            return campingSites;
        }

        #endregion

        private bool DbExec(string command, object obj)
        {
            using (IDbConnection db = new SqlConnection(connectionString))
            {
                int rowsAffected = db.Execute(command, obj);
                if (rowsAffected > 0)
                {
                    return true;
                }
            }
            return false;
        }

        private T GetDB<T>(Func<IDbConnection, T> func)
        {
            using (IDbConnection c = new SqlConnection(connectionString))
            {
                return func(c);
            }
        }
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
