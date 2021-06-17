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
            ZapManager sqlmanager = new ZapManager("");
            //DropDownTypes.DataSource = sqlmanager.GetCampingTypes();
            //DropDownTypes.DataValueField = "Name";
            //DropDownTypes.DataBind();             


            //List<CampingObject> campingtypes = new List<CampingObject>();
            //campingtypes.Add(new CampingObject("Teltplads"));

            //DataListCamping.DataSource = campingtypes;

            List<CampingSite> campingSites = new List<CampingSite>(sqlmanager.GetAvailableSites(DateTime.Today, DateTime.Today.AddDays(10), "Teltplads"));

            DataListCamping.DataSource = sqlmanager.GetAvailableSites(DateTime.Today, DateTime.Today.AddDays(10), "Teltplads");
            DataListCamping.DataBind();
            DataListCamping.Visible = true;

        }
    }
    public class CampingObject
    {
        public string Name { get; set; }

        public CampingObject(string name)
        {
            this.Name = name;
        }
    }
}   