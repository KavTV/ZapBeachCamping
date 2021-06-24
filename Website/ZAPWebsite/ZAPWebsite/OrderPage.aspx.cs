using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ZapLibrary;
using System.Diagnostics;
using System.Data.SqlClient;

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
                saleparameter = null;

                //if site is not set as parameter then it should return to booking page
                if (string.IsNullOrEmpty(Request.Params["Site"]))
                {
                    //redirect to booking if no parameters in url 
                    Response.Redirect("Booking.aspx");
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
                List<AdditionSeason> additionsList = connection.GetAdditions(Convert.ToDateTime(Request.QueryString["startDate"]), Convert.ToDateTime(Request.QueryString["endDate"]), Request.QueryString["typeName"]);
                //databound the additions in datalist
                additionDatalist.DataSource = additionsList;
                additionDatalist.DataBind();

                foreach (DataListItem addition in additionDatalist.Items)
                {
                    string addition_name = ((Label)addition.FindControl("additionname")).Text;
                    //If the paytype is Onetime the it should be a checkbox instead of input box
                    if (addition_name == "Voksne")
                    {
                        ((RequiredFieldValidator)addition.FindControl("additionrequiredvalidator")).Enabled = true;
                        ((RequiredFieldValidator)addition.FindControl("additionrequiredvalidator")).Display = ValidatorDisplay.Static;

                    }
                    if (additionsList.Exists(a => a.Paytype == "OneTime" && a.Name == addition_name))
                    {
                        ((CheckBox)addition.FindControl("additioncheck")).Visible = true;
                        ((TextBox)addition.FindControl("additionamount")).Visible = false;

                    }
                }
            }
            catch (Exception error)
            {
                Debug.WriteLine(error);
                Response.Write($"<script language=javascript>console.log({error})</script>");
                ExecuteAlertPopup("");
            }
        }

        protected void CreateOrSelectCustomer_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
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
            alertdiv.Visible = false;

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
                    //name of addition 
                    string name = ((Label)item.FindControl("additionname")).Text;
                    //if the additionamount is not visible then check if checkboc checked if its true then add it to addition with amount 1
                    if (!((TextBox)item.FindControl("additionamount")).Visible)
                    {
                        if (((CheckBox)item.FindControl("additioncheck")).Checked)
                        {
                            resAdditions.Add(new ReservationAddition(new AdditionSeason(name, null, 0), 1));
                        }
                    }
                    //only add to list if amount is bigger then 0 and the input amount is parse 
                    else if (int.TryParse(((TextBox)item.FindControl("additionamount")).Text, out int amount) && amount > 0)
                    {
                        resAdditions.Add(new ReservationAddition(new AdditionSeason(name, null, 0), amount));
                    }

                }
            }
            //This is not needed because we have another validate that Voksne should be more then 0 
            //if (resAdditions.Count == 0)
            //{
            //    //Print error msg
            //    Debug.WriteLine("Der er blevet break fordi kunden er idiot");

            //    //hide book button and show alertdiv
            //    book_button.Visible = false;
            //    alertdiv.Visible = true;
            //    Top_ErrorMessage.Text = "Du skal vælge en tilføjelse";
            //    return;
            //}

            //make connection to our library and execute create reservation method
            try
            {
                Reservation testres = new
                Reservation(email_tb.Text, Request.QueryString["Site"], Request.QueryString["typeName"],
                Convert.ToDateTime(Request.QueryString["startDate"]), Convert.ToDateTime(Request.QueryString["endDate"]), resAdditions);
                int reservationid = connection.CreateReservation(new
                Reservation(email_tb.Text, Request.QueryString["Site"], Request.QueryString["typeName"],
                Convert.ToDateTime(Request.QueryString["startDate"]), Convert.ToDateTime(Request.QueryString["endDate"]), resAdditions));
                Debug.WriteLine("Create reservation");

                PrintReservation(reservationid.ToString());

            }
            //Catch sql exeptions
            catch (SqlException sqlerr)
            {
                Debug.WriteLine(sqlerr);
                ExecuteAlertPopup(sqlerr.Message.ToString().Split('/')[0]);
            }
            catch (Exception error)
            {
                Debug.WriteLine(error);
                Response.Write($"<script language=javascript>console.log({error})</script>");
                ExecuteAlertPopup("");
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
                //TODO:Should add onetime additions 

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
        private void ExecuteAlertPopup(string input)
        {
            Debug.WriteLine("Message: "+input);
            Response.Write($"<script language=javascript>alert('UNDSKYLD! Der gik noget galt, prøv igen eller kontakt os :) Du lander på hjem siden igen');window.location.href = \"Default.aspx\"</script>");
        }
    }
}