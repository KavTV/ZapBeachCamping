using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using System.Net.Http;
using System.Configuration;

namespace ZapEmbeddedWinService
{
    public partial class Scheduler : ServiceBase
    {
        private static string lastpar_request;
        private static int counter;

        private Timer timer = null;
        public Scheduler()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            //configurationmanager is a class where I can get the appsettings values, the values from exe.config file
            timer = new Timer();
            timer.Interval = Convert.ToInt32(ConfigurationManager.AppSettings["Interval"]); //make the interval run the service every...

            timer.Elapsed += async (sender, e) => await RequestMethod();
            timer.Enabled = true;
        }
        protected override void OnStop()
        {
            timer.Enabled = false;
        }

        static async Task RequestMethod()
        {
            SqlManager sql = new SqlManager();
            sql.ConnectionStatus();
            string parameterstr = sql.TransferSiteToParameter();

            //if last parameter and the current parameter match then skip if counter is more or equal 6 then run it
            if (lastpar_request != parameterstr || counter >= 6)
            {
                counter = counter >= 6 ? counter = 0 : counter;
                try
                {
                    string defaultUri = ConfigurationManager.AppSettings["WebIP"];
                    string requesturi = defaultUri + parameterstr;
                    var client = new HttpClient();
                    var content = await client.GetStringAsync(requesturi);
                    Library.WriteErrorLog(parameterstr);
                    lastpar_request = parameterstr;
                }
                catch (Exception)
                {
                    //Catch error if the service cant connect to WebEmbedded
                    Library.WriteErrorLog("Error - Can't connect to WebServer");
                }

            }
            else
            {
                Library.WriteErrorLog("Det samme som sidst");
            }
            counter++; //add 1 every time the service has run the code 
        }
    }

}
