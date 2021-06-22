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
        //conection to our library
        private static ZapManager connection = new ZapManager();

        private static string saleparameter = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            //if its not a postback then do...
            if (!IsPostBack)
            {

                //if site is not set as parameter then it should return to booking page
                if (string.IsNullOrEmpty(Request.Params["Site"]))
                {
                    //For testing 
                    Response.Redirect("OrderPage.aspx?Site=74&startDate=Mon%20Jun%2021%202021&endDate=Sun%20Jun%2027%202021&typeName=Lille%20campingplads&sale=1%20uges%20plads%20inkl%204%20personer%206%20x%20morgenmad%20og%20billetter%20til%20badeland%20hele%20ugen");

                    //redirect to booking if no parameters in url 
                    //Response.Redirect("Booking.aspx");
                }

                //if its a reservation with a special discount then sale parameter is set 
                if (!string.IsNullOrEmpty(Request.Params["Sale"]) && Request.Params["Sale"] != "false")
                {
                    LeftDiv.Visible = false;
                    saleparameter = Request.Params["Sale"];
                }
                //check if the customer want a site for a season
                else if (Request.Params["typeName"] == "Forår" || Request.Params["typeName"] == "Sommer" ||
                    Request.Params["typeName"] == "Efterår" || Request.Params["typeName"] == "Vinter")
                {
                    LeftDiv.Visible = false;
                }
                else
                {
                    DataBindAdditions();
                }

                List<CampingSite> campingSites = connection.GetCampingSite(Request.QueryString["Site"], Request.QueryString["typeName"], Convert.ToDateTime(Request.QueryString["startDate"]), Convert.ToDateTime(Request.QueryString["endDate"]));
                sitelist.DataSource = campingSites;
                sitelist.DataBind();
                foreach (DataListItem item in sitelist.Items)
                {
                    //get the siteid from the datalist of campingsites
                    string siteid = ((Label)item.FindControl("siteId")).Text;
                    //find the datalist inside the datalist
                    DataList additionsDatalist = (DataList)item.FindControl("siteadditions");
                    //use linq to get camping sites from the specific site and set as datasource
                    additionsDatalist.DataSource = (campingSites.Where(ca => ca.Id == siteid).FirstOrDefault()).CampingAdditions;
                    additionsDatalist.DataBind();
                }
                //after bindings then calculate the totalprice 
                CalculateTotalPrice();

            }

        }
        private void DataBindAdditions()
        {
            //If something happend then catch it and show alert box
            try
            {

                //databound the additions in datalist
                additionDatalist.DataSource = connection.GetAdditions(Convert.ToDateTime(Request.QueryString["startDate"]), Convert.ToDateTime(Request.QueryString["endDate"]));
                additionDatalist.DataBind();
            }
            catch (Exception)
            {

                ExecuteAlertPopup();
            }
        }

        protected void CreateOrSelectCustomer_Click(object sender, EventArgs e)
        {
            if (connection.IsCustomerCreated(email_tb.Text)) //if email match then show book button
            {
                ReadyToBook();
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
                bool customercreatedsuccesfully = connection.CreateCustomer(new Customer(email_tb.Text, Convert.ToInt32(phone.Text), name.Text, Convert.ToInt32(postal.Text), address.Text));
                Debug.WriteLine("Create customer");
                //if customer not created then show error and do not continue
                if (!customercreatedsuccesfully)
                {
                    CustomerError_la.Visible = true;
                }
                else
                {
                    ReadyToBook();
                }
            }
        }
        private void ReadyToBook() //function to hidde unnessesary stuff, show book button and set email to readonly
        {
            //hidde error label, and create customer div. show book button and make email_textbox readonly
            CustomerError_la.Visible = false;
            book_button.Visible = true;
            create_cust_div.Visible = false;
            email_tb.ReadOnly = true;
        }

        protected void book_button_Click(object sender, EventArgs e)
        {
            //Get additions
            List<ReservationAddition> resAdditions = new List<ReservationAddition>();
            if (saleparameter != null)
            {
                resAdditions.Add(new ReservationAddition(new AdditionSeason(saleparameter, null, 0), 1));
            }
            else
            {
                foreach (DataListItem item in additionDatalist.Items)
                {
                    //only add to list if amount is bigger then 0 and the input amount is parse 
                    if (int.TryParse(((TextBox)item.FindControl("additionamount")).Text, out int amount) && amount > 0)
                    {
                        //name of addition 
                        string name = ((Label)item.FindControl("additionname")).Text;
                        resAdditions.Add(new ReservationAddition(new AdditionSeason(name, null, 0), amount));
                    }
                }
            }

            //make connection to our library and execute create reservation method
            try
            {
                int reservationid = connection.CreateReservation(new
                Reservation(email_tb.Text, Request.QueryString["Site"], Request.QueryString["typeName"],
                Convert.ToDateTime(Request.QueryString["startDate"]), Convert.ToDateTime(Request.QueryString["endDate"]), resAdditions));
                Debug.WriteLine("Create reservation");

                PrintReservation(reservationid.ToString());

            }
            catch (Exception)
            {

                ExecuteAlertPopup();
            }


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
        private void PrintReservation(string ordernumber)
        {
            //Hide everything else
            CenterDiv.Visible = false;
            LeftDiv.Visible = false;
            RightDiv.Visible = false;

            //Show confirm div
            Confirm_div.Visible = true;

            //Create the returning reservation as object
            Reservation reservation = connection.GetReservation(ordernumber);
            //Reservation reservation = connection.GetReservation("107934");

            //Set all labels text to the reservation fields
            OrderNumber.Text = reservation.Ordernumber.ToString();
            res_email.Text = reservation.Customer.Email;
            res_campingid.Text = reservation.CampingSite.Id;
            res_typename.Text = reservation.TypeName;
            res_startdate.Text = reservation.StartDate.ToString("d");
            res_enddate.Text = reservation.EndDate.ToString("d");
            res_TotalPrice.Text = reservation.TotalPrice.ToString() + " Kr.";

            //show price comment
            if ((reservation.EndDate - reservation.StartDate).TotalDays > 3)
            {
                pricecomment_la.Visible = true;
            }

            //Set all datalist to the reservation fields
            if (reservation.CampingSite.CampingAdditions != null)
            {
                res_siteadditions.DataSource = reservation.CampingSite.CampingAdditions;
                res_siteadditions.DataBind();
                res_sa_div.Visible = true;

            }
            res_additions.DataSource = reservation.ReservationAdditions;
            res_additions.DataBind();
        }
        private void ExecuteAlertPopup()
        {
            Response.Write($"<script language=javascript>alert('UNDSKYLD! Der gik noget galt, prøv igen eller kontakt os :) Du lander på  siden igen');window.location.href = \"Default.aspx\"</script>");
        }
    }
}