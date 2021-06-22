<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Booking.aspx.cs" Inherits="ZAPWebsite.Booking" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .input-drop-box{
            padding: 20px;
            background-color: #c0c0c0;
            width: 40%;
            justify-content: center;
            align-items: center;
            border-radius: 75px;
        }
        .input-date-box{
            padding: 20px;
            background-color: #c0c0c0;
            width: 20%;
            justify-content: center;
            align-items: center;
            border-radius: 75px;
        }
        input[type=date], select, textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 20px;
            resize: vertical;
        }
        
        .details{
            
        }

    </style>

    <div class="container-fluid webForm col-lg-12">
        <div id="leftrightdiv" class="left-right hidescroll">


    <!--l1 content-->
    <div class="l1 inputMargin">
        <!--Content-->
        <div class="container-fluid text-center">    
            <div class="row content">
                <!--Drop down list-->
                <div class="input-drop-box">
                    <span class="details">Camping type:</span>
                    <asp:DropDownList ID="DropDownTypes" runat="server">
                    <asp:ListItem>
                    </asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
        </div>

        <!--Content-->
        <div class="container-fluid text-center">    
            <div class="row content">
                <!--Date boxes-->
                <div>
                    <div class="input-date-box">
                        <span class="details">Start dato:</span>
                        <input type="date" id="resStart" />
                    </div>
                    <div class="input-date-box">
                        <span class="details">Slut dato:</span>
                        <input type="date" id="resEnd" />
                    </div>
                    <div>
                        <a class="l2" onclick="AddParams()">Find pladser</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!--l2 content-->
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
                        </div>
                        <a href="OrderPage.aspx?Site=<%#Eval("Id") %>&startDate=<%Response.Write(Request.QueryString["startDate"].ToString());%>&endDate=<%Response.Write(Request.QueryString["endDate"].ToString()); %>&typeName=<%Response.Write(Request.QueryString["typeName"].ToString()); %>&sale=<%Response.Write(Request.QueryString["sale"].ToString()); %>">
                            <div class="property-bottom">
                                <p>Vælg</p>
                            </div>
                        </a>
                    </div>
                </div>
            </ItemTemplate>
        </asp:DataList>
    </div>


            </div>
        </div>

    <script src="Scripts/BookingSliding.js"></script>
</asp:Content>




<%--    <div class="container-fluid webForm col-lg-12">
        <div id="leftrightdiv" class="left-right hidescroll">
            <div class="row content">
                <div class="l1 inputMargin">
                    <div class="input-drop-box">
                        <span class="details">Camping type:</span>
                        <asp:DropDownList ID="DropDownTypes" runat="server">
                        <asp:ListItem>
                        </asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div>
                        <div class="input-date-box">
                            <span class="details">Start dato:</span>
                            <input type="date" id="resStart" />
                        </div>
                        <div class="input-date-box">
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
                                    </div>
                                    <a href="OrderPage.aspx?Site=<%#Eval("Id") %>&startDate=<%Response.Write(Request.QueryString["startDate"].ToString());%>&endDate=<%Response.Write(Request.QueryString["endDate"].ToString()); %>&typeName=<%Response.Write(Request.QueryString["typeName"].ToString()); %>&sale=<%Response.Write(Request.QueryString["sale"].ToString()); %>">
                                        <div class="property-bottom">
                                            <p>Vælg</p>
                                        </div>
                                    </a>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:DataList>
                    <a class="l3">Til bestilling</a>
                </div>
            </div>
        </div>
    </div>
    <script src="Scripts/BookingSliding.js"></script>
</asp:Content>--%>
