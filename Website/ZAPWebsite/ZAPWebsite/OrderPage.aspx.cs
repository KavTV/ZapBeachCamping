using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ZapLibrary;
using System.Diagnostics;

namespace ZAPWebsite
{
    public partial class OrderPage : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.Button book_button;

        protected void Page_Load(object sender, EventArgs e)
        {
            //is it a postback then it should not set new databind
            if (!IsPostBack)
            {
                if (string.IsNullOrEmpty(Request.Params["Site"]))
                {
                    //For testing 
                    Response.Redirect("OrderPage.aspx?Site=10&startDate=Mon%20Jun%2021%202021&endDate=Sun%20Jun%2027%202021&typeName=Lille%20campingplads");

                    //redirect to booking if no parameters in url 
                    //Response.Redirect("Booking.aspx");
                }

                //conection to our library
                ZapManager conection = new ZapManager("");
                //this line is for testing 
                additionDatalist.DataSource = conection.GetAdditions(Convert.ToDateTime("2021-06-21"), Convert.ToDateTime("2021-06-28"));
                additionDatalist.DataSource = conection.GetAdditions(Convert.ToDateTime(Request.QueryString["startDate"]), Convert.ToDateTime(Request.QueryString["endDate"]));
                additionDatalist.DataBind();

                #region TEST DATA
                List<CampingSite> mylist = new List<CampingSite>();

                CampingSite testCSite = new CampingSite("id", false, 10, new List<string>()
                {
                    "Lille campingplads"
                }, new List<CampingAddition>()
                {
                    new CampingAddition("god udsigt")
                });

                mylist.Add(testCSite);

                #endregion
                sitelist.DataSource = mylist; //should be changes to a method from library
                sitelist.DataBind();

                foreach (DataListItem item in sitelist.Items)
                {
                    //get the siteid from the datalist of campingsites
                    string siteid = ((Label)item.FindControl("siteId")).Text;
                    //find the datalist inside the datalist
                    DataList additionsDatalist = (DataList)item.FindControl("siteadditions");
                    //use linq to get camping sites from the specific site and set as datasource
                    additionsDatalist.DataSource = ((CampingSite)mylist.Where(ca => ca.Id == siteid).FirstOrDefault()).CampingAdditions;
                    additionsDatalist.DataBind();
                }
                //after bindings then calculate the totalprice 
                CalculateTotalPrice();
            }

        }

        protected void CreateOrSelectCustomer_Click(object sender, EventArgs e)
        {
            if (false) //if email match then show book button
            {
                //Show book now button
                book_button.Visible = true;
            }
            else
            {
                //hide search or create button and show the create button
                findCustomer.Visible = false;
                create_cust_div.Visible = true;

            }
        }

        protected void Createcustomer_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                ZapManager conection = new ZapManager("");

                conection.CreateCustomer(new Customer(email_tb.Text, Convert.ToInt32(phone.Text), name.Text, Convert.ToInt32(postal.Text), address.Text));

                book_button.Visible = true;
            }
        }

        protected void book_button_Click(object sender, EventArgs e)
        {
            //Get additions
            List<ReservationAddition> resAdditions = new List<ReservationAddition>();
            foreach (DataListItem item in additionDatalist.Items)
            {
                //only add to list if amount is bigger then 0 and the input amount is parse 
                if (int.TryParse(((TextBox)item.FindControl("additionamount")).Text, out int amount) && amount > 0)
                {
                    //name of addition 
                    string name = ((TextBox)item.FindControl("additionname")).Text;
                    resAdditions.Add(new ReservationAddition(new AdditionSeason(name, null, 0), amount));
                }
            }
            //make connection to our library and execute create reservation method
            ZapManager conection = new ZapManager("");
            int reservationid = conection.CreateReservation(
                new Reservation(email_tb.Text, Request.QueryString["Site"], Request.QueryString["typeName"],
                    Convert.ToDateTime(Request.QueryString["startDate"]), Convert.ToDateTime(Request.QueryString["endDate"]), resAdditions));

        }

        protected void additionamount_TextChanged(object sender, EventArgs e)
        {
            CalculateTotalPrice();
        }

        private void CalculateTotalPrice()
        {
            double totalprice = 0;

            //add camping site price to totalprice
            foreach (DataListItem siteitem in sitelist.Items)
            {
                totalprice += Convert.ToDouble(((Label)siteitem.FindControl("siteprice")).Text);
            }
            //add addition price to totalprice
            foreach (DataListItem additionitem in additionDatalist.Items)
            {
                //only calculate price for addition who have more then one amount
                if (int.TryParse(((TextBox)additionitem.FindControl("additionamount")).Text, out int amount) && amount > 0)
                {
                    double additionprice = Convert.ToDouble(((Label)additionitem.FindControl("additionprice")).Text);

                    totalprice += (additionprice * amount);
                }
            }
            totalprice_la.Text = totalprice.ToString();
        }
    }
}