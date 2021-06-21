<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Booking.aspx.cs" Inherits="ZAPWebsite.Booking" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .input-box{
            width: 25%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 4px;
            resize: vertical;
            background-color: #8d3c3c;
        }
        input[type=date], select, textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 4px;
            resize: vertical;
        }
        .details{
            
        }

    </style>

    <div class="container-fluid webForm col-lg-12">
        <div id="leftrightdiv" class="left-right hidescroll">
            <%--<h3>Registration:</h3>--%>

            <!--Booking details-->
            <div class="reservation row content">
                <div class="l1 inputMargin">
                    <span class="details">Camping type:</span>
                    <asp:DropDownList ID="DropDownTypes" runat="server">
                        <asp:ListItem>
                        </asp:ListItem>
                    </asp:DropDownList>

                    <!--Skal gemmes væk hvis sæson plads er valgt-->
                    <div>

                        <div class="input-box">
                            <span class="details">Start dato:</span>
                            <input type="date" id="resStart" />
                        </div>
                        <div class="input-box">
                            <span class="details">Slut dato:</span>
                            <input type="date" id="resEnd" />
                        </div>
                        <div>
                            <a class="l2" onclick="AddParams()">Find pladser</a>
                        </div>
                    </div>

                </div>

                <!--Printer ledige pladser-->
                <div class="l2">
                    <asp:DataList ID="DataListCamping" runat="server" RepeatDirection="Horizontal" CellSpacing="2" CellPadding="5" RepeatColumns="5" Visible="true">
                        <ItemTemplate>
                            <div>
                                <div class="property-card">
                                    <a href="#">
                                        <div class="property-image">
                                            <div class="property-image-title">
                                            </div>
                                        </div>
                                    </a>
                                    <div class="property-description">
                                        <h5>
                                            <label>Rum: <%# Eval("Id") %></label>
                                        </h5>
                                        <label>Pris: <%# Eval("Price") %></label>
                                        <label>Pris: <%# Eval("GetCampingAdditions") %></label>
                                        <%--<a href="Order.aspx?Site=<%#Eval("Id") %>&startDate=<%Request.QueryString["startDate"].ToString();%>&endDate=<%Request.QueryString["endDate"].ToString(); %>&typeName=<%Request.QueryString["typeName"].ToString(); %>"> Vælg</a>--%>
                                    </div>
                                    <a href="OrderPage.aspx?Site=<%#Eval("Id") %>&startDate=<%Response.Write(Request.QueryString["startDate"].ToString());%>&endDate=<%Response.Write(Request.QueryString["endDate"].ToString()); %>&typeName=<%Response.Write(Request.QueryString["typeName"].ToString()); %>&sale=<%Response.Write(Request.QueryString["sale"].ToString()); %>">
                                        <div class="property-bottom">
                                            <p>Vælg</p>
                                        </div>

                                    </a>
                                </div>
                            </div>

                            <%--<asp:LinkButton ID="bookhere" runat="server" OnClick="bookhere_Click" CommandName="CheckForBook" CommandArgument='<%#Eval("roomid") %>' Text="Book her" />--%>
                        </ItemTemplate>
                    </asp:DataList>
                    <a class="l3">Til bestilling</a>
                </div>
            </div>
        </div>
    </div>
    <script src="Scripts/BookingSliding.js"></script>
</asp:Content>
