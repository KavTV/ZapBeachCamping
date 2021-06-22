<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OrderPage.aspx.cs" Inherits="ZAPWebsite.OrderPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div id="OP_content">
        <div id="LeftDiv" class="OPgridview" runat="server">
            <%-- the additions and amount--%>
            <div class="additiongroup">
                <asp:Label Text="Antal" runat="server" CssClass="additioninput" />
                <asp:Label Text="Navn" runat="server" CssClass="addition-name" />
                <div class="addition-price">
                    <asp:Label Text="Pris pr.dag" runat="server" />
                </div>
            </div>
            <asp:DataList ID="additionDatalist" runat="server" RepeatDirection="Vertical" CellSpacing="2" RepeatColumns="1" Visible="true">
                <ItemTemplate>
                    <div class="additiongroup">
                        <asp:TextBox ID="additionamount" runat="server" TextMode="Number" CssClass="additioninput" OnTextChanged="additionamount_TextChanged" AutoPostBack="True" CausesValidation="true" ValidationGroup="additionvalidation"></asp:TextBox>
                        <asp:CheckBox ID="additioncheck" CssClass="additioninput" runat="server" Visible="false"/>
                        <asp:Label ID="additionname" runat="server" CssClass="addition-name" Text='<%# Eval("Name") %>'></asp:Label>
                        <asp:CompareValidator ErrorMessage="Ugyldigt tal" ControlToValidate="additionamount" Operator="GreaterThanEqual" ValueToCompare="0" runat="server" ValidationGroup="additionvalidation" CssClass="additionvalidation" />
                        <div class="addition-price">
                            <asp:Label ID="additionprice" runat="server" Text='<%# Eval("Price") %>' />
                            <asp:Label class="addition-price" runat="server"> Kr</asp:Label>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:DataList>
        </div>
        <%-- Customer  --%>
        <div id="CenterDiv" class="OPgridview" runat="server">
            <div class="customergroup">
                <asp:Label ID="email_la" runat="server" Text="Email" CssClass="customerlabel"></asp:Label>
                <asp:TextBox ID="email_tb" runat="server" CssClass="customerinput" TextMode="Email"></asp:TextBox>
                <asp:RequiredFieldValidator ErrorMessage="Skriv din email!" ControlToValidate="email_tb" runat="server" CssClass="customervalidator" />
            </div>
            <asp:Button ID="findCustomer" Text="Søg/Opret" runat="server" OnClick="CreateOrSelectCustomer_Click" />
            <%-- If customer email not exist then create the customer --%>
            <div id="create_cust_div" runat="server" visible="false">
                <div class="customergroup">
                    <asp:Label Text="Navn" runat="server" CssClass="customerlabel" />
                    <asp:TextBox ID="name" runat="server" CssClass="customerinput"></asp:TextBox>
                    <asp:RequiredFieldValidator ErrorMessage="Skriv dit navn!" ControlToValidate="name" runat="server" CssClass="customervalidator" />
                </div>
                <div class="customergroup">
                    <asp:Label Text="mobil nr." runat="server" CssClass="customerlabel" />
                    <asp:TextBox ID="phone" runat="server" CssClass="customerinput" TextMode="Phone"></asp:TextBox>
                    <asp:RequiredFieldValidator ErrorMessage="Skriv dit mobil nr.!" ControlToValidate="phone" runat="server" CssClass="customervalidator" />
                </div>
                <div class="customergroup">
                    <asp:Label Text="post nr." runat="server" CssClass="customerlabel" />
                    <asp:TextBox ID="postal" runat="server" CssClass="customerinput"></asp:TextBox>
                    <asp:RequiredFieldValidator ErrorMessage="Skriv dit post nr.!" ControlToValidate="postal" runat="server" CssClass="customervalidator" />
                </div>
                <div class="customergroup">
                    <asp:Label Text="adresse" runat="server" CssClass="customerlabel" />
                    <asp:TextBox ID="address" runat="server" CssClass="customerinput"></asp:TextBox>
                    <asp:RequiredFieldValidator ErrorMessage="Skriv din adresse!" ControlToValidate="address" runat="server" CssClass="customervalidator" />
                </div>
                <asp:Button ID="createcustomer" Text="Opret" runat="server" OnClick="Createcustomer_Click" />
                <br />
                <asp:Label ID="CustomerError_la" CssClass="CustomerErrorMsg" runat="server" Visible="false">
                    Noget gik galt med at oprette dig som bruger
                    <br />
                    tjek værdierne og prøv igen
                </asp:Label>
            </div>
        </div>
        <%-- The details of periode and site--%>
        <div id="RightDiv" class="OPgridview" runat="server">
            <div id="otherdetails_div">
                <h3>
                    <asp:Label ID="periode_la" Text="Periode" runat="server" />
                </h3>
                <asp:Label CssClass="periode" ID="date_la" runat="server"><%=Convert.ToDateTime(Request.QueryString["startDate"]).ToString("d")%></asp:Label>
                <asp:Label CssClass="periode" runat="server"> - </asp:Label>
                <asp:Label CssClass="periode" ID="Label5" runat="server"><%=Convert.ToDateTime(Request.QueryString["endDate"]).ToString("d")%></asp:Label>


            </div>
            <div id="site_div">
                <h3>
                    <asp:Label ID="siteheader" Text="Plads" runat="server" />
                </h3>
                <asp:DataList ID="sitelist" runat="server">
                    <ItemTemplate>
                        <div class="">
                            <div class="property-card">
                                <div class="property-image">
                                    <h3>
                                        <asp:Label ID="siteheader" Text='<%# Request.QueryString["typename"]%>' runat="server" />

                                    </h3>
                                </div>
                                <div class="property-description">
                                    <h5>
                                        <asp:Label ID="siteId" runat="server" Text='<%# Eval("Id") %>' />
                                    </h5>
                                    <asp:Label ID="siteprice" Text='<%# Eval("Price") %>' runat="server" />
                                    <asp:Label runat="server"> Kr</asp:Label>
                                    <h6 class="OP-h6">
                                        <asp:Label Text="Tilføjelser:" runat="server" />
                                    </h6>
                                    <asp:DataList ID="siteadditions" runat="server">
                                        <ItemTemplate>
                                            <label class="OP-addition-la"><%# Eval("Name") %>,</label>
                                        </ItemTemplate>
                                    </asp:DataList>
                                </div>

                            </div>
                        </div>
                    </ItemTemplate>
                </asp:DataList>
            </div>
            <div id="totalpricediv">
                <asp:Label ID="totalpricetext" CssClass="TotalPriceText" Text="Total pris: " runat="server" />
                <asp:Label ID="totalprice_la" CssClass="TotalPriceText" Text="999" runat="server" />
            </div>
            <asp:Button ID="book_button" Text="Reserver" runat="server" Visible="false" OnClick="book_button_Click" />
        </div>
        <%-- Confim div a summary of the reservation --%>
        <div id="Confirm_div" runat="server" visible="false">
            <div class="confirmdatalist_div">
                <div class="res_fieldgroup">
                    <asp:Label Text="Order nummer: " runat="server" CssClass="reservationfieldname_la" />
                    <asp:Label ID="OrderNumber" Text="Text" runat="server" CssClass="reservation_la" />
                </div>
                <div class="res_fieldgroup">
                    <asp:Label Text="Din email: " runat="server" CssClass="reservationfieldname_la" />
                    <asp:Label ID="res_email" Text="Text" runat="server" CssClass="reservation_la" />
                </div>
                <div class="res_fieldgroup">
                    <asp:Label Text="Plads nummeret: " runat="server" CssClass="reservationfieldname_la" />
                    <asp:Label ID="res_campingid" Text="Text" runat="server" CssClass="reservation_la" />
                </div>
                <div class="res_fieldgroup">
                    <asp:Label Text="Typenavn: " runat="server" CssClass="reservationfieldname_la" />
                    <asp:Label ID="res_typename" Text="Text" runat="server" CssClass="reservation_la" />
                </div>
                <div id="res_sa_div" class="res_fieldgroup" runat="server" visible="false">
                    <h5>
                        <asp:Label Text="Plads tilføjelser:" runat="server" />
                    </h5>
                    <asp:DataList ID="res_siteadditions" runat="server">
                        <ItemTemplate>
                            <asp:Label ID="res_sa_name" Text='<%# Eval("Name") %>' runat="server" CssClass="reservation_la" />
                        </ItemTemplate>
                    </asp:DataList>
                </div>
                <div class="res_fieldgroup">
                    <asp:Label Text="Periode:" runat="server" CssClass="reservationfieldname_la" />
                    <br />
                    <asp:Label ID="res_startdate" Text="Text" runat="server" CssClass="reservation_la" />
                    <asp:Label Text=" - " runat="server" CssClass="reservation_la" />
                    <asp:Label ID="res_enddate" Text="Text" runat="server" CssClass="reservation_la" />
                </div>
                <div class="res_fieldgroup">
                    <h5>
                        <asp:Label Text="Tilføjelser:" runat="server" />
                    </h5>
                    <asp:DataList ID="res_additions" runat="server">
                        <ItemTemplate>
                            <div id="res_addition_div" runat="server">
                                <asp:Label ID="res_addition_amount" Text='<%# Eval("Amount") %>' runat="server" CssClass="reservation_la" />
                                <asp:Label ID="res_addition_name" Text='<%# Eval("AdditionSeason.Name") %>' runat="server" CssClass="reservation_la" />
                            </div>
                        </ItemTemplate>
                    </asp:DataList>
                </div>
                <div class="res_fieldgroup">
                    <asp:Label Text="Totalpris: " runat="server" CssClass="reservationfieldname_la" />
                    <asp:Label ID="res_TotalPrice" Text="Text" runat="server" CssClass="reservation_la" />
                    <br />
                    <asp:Label Visible="false" ID="pricecomment_la" Text="For camping pladser og telte får man hver 4 dag, pladsgebyret gratis" runat="server" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
