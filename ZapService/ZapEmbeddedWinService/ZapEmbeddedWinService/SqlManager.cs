using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;


namespace ZapEmbeddedWinService
{
    public class SqlManager
    {
        private SqlConnection GetConnection()
        {
            string connectionstr = @"Data Source = ZAP_CAMPING_SER; Initial Catalog = Zap_Base; User ID = admin; Password = Passw0rd; Server=172.16.21.107\ZAPSQLSERVER";
            return new SqlConnection(connectionstr);
        }

        public void ConnectionStatus()
        {
            SqlConnection con = GetConnection();
            try
            {
                con.Open();
                Library.WriteErrorLog("Open");
                con.Close();
            }
            catch (Exception ex)
            {
                Library.WriteErrorLog("ERROR: Cant open ");
            }
        }
        private List<CampingSite> GetTodaysAvaliableSites()
        {
            //Get the connection object and open the connection 
            SqlConnection con = GetConnection();
            con.Open();

            //Create a sql command and a reader to read the sql data
            SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.GetCurrentAvaliableSites()", con);

            SqlDataReader sqlReader = cmd.ExecuteReader();
            List<CampingSite> campingsiteList = new List<CampingSite>();
            //While loop to read everything form the output
            while (sqlReader.Read())
            {
                campingsiteList.Add(new CampingSite(sqlReader[0].ToString(), sqlReader[1].ToString()));
            }
            con.Close();


            return campingsiteList;
        }

        public string TransferSiteToParameter()
        {
            List<CampingSite> campingSites = GetTodaysAvaliableSites();
            string parameterstrv = "?";
            foreach (var item in campingSites)
            {
                parameterstrv += $"{item.Id}={item.Available}&";
            }

            return parameterstrv;
        }
    }
}
