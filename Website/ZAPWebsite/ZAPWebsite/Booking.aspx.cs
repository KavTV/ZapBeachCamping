﻿using System;
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
            //Find campingtypes 
            UpdateCampingTypes();

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

        protected void SeasonPlaceCheck_CheckedChanged(object sender, EventArgs e)
        {
            UpdateCampingTypes();
        }

        private void UpdateCampingTypes()
        {
            DropDownTypes.DataSource = sqlmanager.GetCampingTypes(SeasonPlaceCheck.Checked);
            DropDownTypes.DataValueField = "Name";
            DropDownTypes.DataBind();
        }
        private void UpdateDates()
        {

        }
    }
}