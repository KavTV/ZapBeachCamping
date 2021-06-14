using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;

namespace ZapLibrary
{
    class Dal
    {
        private string connectionString;

        public Dal(string connectionString)
        {
            this.connectionString = connectionString;
        }

        public bool CreateCustomer(Customer customer)
        {
            SqlConnection con = new SqlConnection();

            SqlCommand cmd = new SqlCommand("EXEC dbo.CreateCustomer @email,@postal,@phone,@address,@name", con);
            cmd.Parameters.AddWithValue("email", customer.Email);
            cmd.Parameters.AddWithValue("postal", customer.CustomerAddress.Postal);
            cmd.Parameters.AddWithValue("phone", customer.Phone);
            cmd.Parameters.AddWithValue("address", customer.CustomerAddress.Address);
            cmd.Parameters.AddWithValue("name", customer.Name);

            ExecuteNonQuery(cmd);

            return true;
        }




        private bool ExecuteNonQuery(SqlCommand cmd)
        {
            // Creates connection
            SqlConnection con = new SqlConnection();
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
