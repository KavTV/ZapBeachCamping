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
        ZapManager sqlmanager = new ZapManager();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Find campingtypes 
                UpdateCampingTypes();
            }
            SpecialSale();
            //Check if user has selected dates and type
            GetUrlParams();
        }
        void GetUrlParams()
        {
            //Get all params
            string s = Request.QueryString["startDate"];
            string e = Request.QueryString["endDate"];
            string t = Request.QueryString["typeName"];
            if (s != null && e != null && t != null)
            {
                try
                {
                    //Convert url parameters to datetime
                    DateTime startDate = DateTime.Parse(Request.QueryString["startDate"]);
                    DateTime endDate = DateTime.Parse(Request.QueryString["endDate"]);
                    string typeName = Request.QueryString["typeName"];

                    //Get the available sites for the specified params
                    GetSites(startDate, endDate, typeName);
                }
                catch (Exception)
                {
                    //Sadness
                }
            }


        }
        void GetSites(DateTime startdate, DateTime endDate, string typeName)
        {
            var campingSites = sqlmanager.GetAvailableSites(startdate, endDate, typeName);
            //Check if the list is empty.
            if (campingSites.Count < 1)
            {
                //do error text here.
            }
            else
            {
                DataListCamping.DataSource = campingSites;
                DataListCamping.DataBind();
                DataListCamping.Visible = true;
            }
        }

        /// <summary>
        /// This is where all the sales get checked and applied
        /// </summary>
        void SpecialSale()
        {
            if (Request.QueryString["sale"] == "1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen")
            {
                //Hide enddate, auto calc the enddate
                resEnd.Disabled = true;
                SeasonPlaceCheck.Visible = false;
                if (!string.IsNullOrWhiteSpace(resStart.Value))
                {
                    Page.ClientScript.RegisterStartupScript(this.GetType(), "BookingPage", "document.getElementById('MainContent_resStart').onchange = onResStartChanged()", true);
                    //Get the start date and apply + 7 days for this special to the end date.
                    DateTime date = DateTime.Parse(resStart.Value);
                    resEnd.Value = date.AddDays(7).ToString("yyyy-MM-dd");
                }
            }
        }

        protected void SeasonPlaceCheck_CheckedChanged(object sender, EventArgs e)
        {
            UpdateCampingTypes();
        }

        private void UpdateCampingTypes()
        {
            //Change the campingtypes depending on if it is a seasontype or not
            DropDownTypes.DataSource = sqlmanager.GetCampingTypes(SeasonPlaceCheck.Checked);
            DropDownTypes.DataValueField = "Name";
            DropDownTypes.DataBind();
            if (SeasonPlaceCheck.Checked)
            {
                UpdateDates();
            }
        }
        private void UpdateDates()
        {
            CampingType campingType = sqlmanager.GetSeasonDates(DropDownTypes.SelectedValue);
            resStart.Value = campingType.StartDate.ToString("yyyy-MM-dd");
            resEnd.Value = campingType.EndDate.ToString("yyyy-MM-dd");
        }

        protected void DropDownTypes_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (SeasonPlaceCheck.Checked)
            {
                UpdateDates();
            }
        }
    }
}