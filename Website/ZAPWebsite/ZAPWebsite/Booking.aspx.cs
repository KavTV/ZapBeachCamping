using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ZapLibrary;

namespace ZAPWebsite
{
    public partial class Booking : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            List<testobj> campingtypes = new List<testobj>();
            campingtypes.Add(new testobj("Teltplads"));
            ZapManager sqlmanager = new ZapManager("");
            DataList1.DataSource = campingtypes;
            //DataList1.DataSource = sqlmanager.GetAvailableSites(DateTime.Today, DateTime.Today.AddDays(10), "Teltplads");
            DataList1.DataBind();
            DataList1.Visible = true;

        }
    }
    public class testobj
    {
        string name;

        public testobj(string name)
        {
            this.Name = name;
        }

        public string Name { get => name; set => name = value; }
    }
}   