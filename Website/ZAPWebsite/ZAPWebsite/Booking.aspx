<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Booking.aspx.cs" Inherits="ZAPWebsite.Booking" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .input-drop-box {
            padding: 20px;
            margin-bottom: 20px;
            margin-top: 20px;
            background-color: #eaeaea;
            width: 33%;
            border-radius: 75px;
        }

        .input-date-box {
            padding: 20px;
            background-color: #eaeaea;
            width: 21%;
            border-radius: 75px;
            resize: none;
        }

        input[type=date], select, textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 20px;
            resize: vertical;
        }

        .content-button {
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 20px;
            background-color: #D9534f;
            color: white;
        }

        .verticalAlign {
            vertical-align: sub;
            transform: scale(1.2);
        }

        /* Popover */
        .popover {
            -webkit-box-shadow: none;
        }

        /* Popover Header */
        .popover-title {
            background-color: #ffffff; 
            color: #000000; 
            font-size: 16px;
            text-align:center;
        }
  
        /* Popover Body */
        .popover-content {
            background-color: #eaeaea;
            color: #000000;
            padding: 25px;
        }

        hr {
            border: 0;
            border-top: 1px solid #c8c8c8;
        }

    </style>

    <div id="leftrightdiv" class="left-right hidescroll">
        <!--l1 content-->
        <div class="l1 inputMargin">
            <div class="container">
                <!--Content row-->
                <div class="row content">
                    <!--Drop down list-->
                    <div class="input-drop-box col-xs-2 col-xs-offset-4">
                        <span class="details">Camping type:</span>
                        <asp:DropDownList ID="DropDownTypes" AutoPostBack="true" OnSelectedIndexChanged="DropDownTypes_SelectedIndexChanged" runat="server">
                            <asp:ListItem>
                            </asp:ListItem>
                        </asp:DropDownList>

                        <!--Season checkbox-->
                        <a href="#" title="Seasonpladser:" data-toggle="popover" data-placement="bottom" data-content="Forår: (1. April 🡲 30. Juni) <hr/> Sommer: (15. August 🡲 30. September) <hr/> Efterår: (15. August 🡲 31. Oktober) <hr/> Vinter: (1. Oktober 🡲 31 Marts)" data-html="true">Seasonplads:</a>
                        <asp:CheckBox runat="server" AutoPostBack="true" OnCheckedChanged="SeasonPlaceCheck_CheckedChanged" ID="SeasonPlaceCheck" CssClass="verticalAlign"/>
                    </div>
                </div>

                <!--Content row-->
                <div class="row content">
                    <!--Date boxes-->
                    <div class="input-date-box col-xs-1 col-xs-offset-3">
                        <span class="details">Start dato:</span>
                        <input type="date" id="resStart" runat="server" style="resize: none" min="2021-06-23" onchange="enddateHigher()" />
                    </div>

                    <div class="input-date-box col-xs-1 col-xs-offset-1">
                        <span class="details">Slut dato:</span>
                        <input type="date" id="resEnd" runat="server" style="resize: none" min="2021-06-23" onchange="enddateHigher()" />
                    </div>
                </div>
            </div>

            <!--Button-->
            <div>
                <a class="l2 btn btn-danger" style="border-radius: 20px;" onclick="AddParams()">Find pladser</a>
            </div>
        </div>

        <!--l2 content-->
        <div class="l2 center">
            <asp:DataList ID="DataListCamping" runat="server" RepeatDirection="Horizontal" CellSpacing="2" CellPadding="5" RepeatColumns="5" Visible="true">
                <ItemTemplate>
                    <div>
                        <!--Prints cards with camping sites-->
                        <div class="property-card">
                            <a href="#">
                                <div class="property-image">
                                    <div class="property-image-title">
                                    </div>
                                </div>
                            </a>
                            <div class="property-description">
                                <h5>
                                    <label>Plads: <%# Eval("Id") %></label>
                                </h5>
                                <label>Pris: <%# Eval("Price") %></label>
                                <label>Tillæg: <%# Eval("GetCampingAdditions") %></label>
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

    <script>
        $(document).ready(function () {
            $('[data-toggle="popover"]').popover();
        });
    </script>

    <script src="Scripts/BookingSliding.js"></script>
    <script src="Scripts/BookingPage.js"></script>
</asp:Content>
