<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Booking.aspx.cs" Inherits="ZAPWebsite.Booking" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .webForm {
            height: auto;
            background-color: #f1f1f1;
        }

        * {
            -webkit-box-sizing: border-box;
            box-sizing: border-box;
        }

        h5 {
            margin: 0px;
            font-size: 1.4em;
            font-weight: 700;
        }

        p {
            font-size: 12px;
        }

        .center {
            height: 100vh;
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* End Non-Essential  */

        .property-card {
            height: 18em;
            width: 14em;
            margin: 10px;
            display: -webkit-box;
            display: -ms-flexbox;
            display: flex;
            -webkit-box-orient: vertical;
            -webkit-box-direction: normal;
            -ms-flex-direction: column;
            flex-direction: column;
            position: relative;
            -webkit-transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            -o-transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            border-radius: 16px;
            overflow: hidden;
            -webkit-box-shadow: 15px 15px 27px #e1e1e3, -15px -15px 27px #ffffff;
            box-shadow: 15px 15px 27px #e1e1e3, -15px -15px 27px #ffffff;
        }
        /* ^-- The margin bottom is necessary for the drop shadow otherwise it gets clipped in certain cases. */

        /* Top Half of card, image. */

        .property-image {
            height: 6em;
            width: 14em;
            padding: 1em 2em;
            position: Absolute;
            top: 0px;
            -webkit-transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            -o-transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            background-image: url('Images/Cards/CardPic.jpg');
            background-size: cover;
            background-repeat: no-repeat;
        }

        /* Bottom Card Section */

        .property-description {
            background-color: #FAFAFC;
            height: 12em;
            width: 14em;
            position: absolute;
            bottom: 0em;
            -webkit-transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            -o-transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            padding: 0.5em 1em;
            text-align: center;
        }

        /* Social Icons */

        .property-bottom {
            width: 12em;
            height: 2em;
            text-align:center;
            border-radius: 30px;
            background-color: #d9534f;
            position: absolute;
            bottom: 1em;
            left: 1em;
            -webkit-transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            -o-transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
            transition: all 0.4s cubic-bezier(0.645, 0.045, 0.355, 1);
        }
        .property-bottom p{
            color: white;
            font-size:19px;
        }
    </style>

    <div class="container-fluid webForm col-lg-12">
        <div id="leftrightdiv" class="left-right hidescroll">
            <%--<h3>Registration:</h3>--%>

            <!--Booking details-->
            <div class="reservation row content">
                <div class="l1">
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
                            <input type="checkbox" id="view" value="Ekstra god udsigt (pr. døgn)">
                        </div>
                    </div>
                    
                    <a class="l2" onclick="AddParams()">Find pladser</a>
                </div>

                <!--Printer ledige pladser-->
                <div class="l2">
                    <asp:DataList ID="DataListCamping" runat="server" RepeatDirection="Horizontal" CellSpacing="2" CellPadding="5" RepeatColumns="5" Visible="true">
                        <ItemTemplate>

                            <div class="">
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
                                        <%--<a href="Order.aspx?Site=<%#Eval("Id") %>&startDate=<%Request.QueryString["startDate"].ToString();%>&endDate=<%Request.QueryString["endDate"].ToString(); %>&typeName=<%Request.QueryString["typeName"].ToString(); %>"> Vælg</a>--%>
                                    </div>
                                    <a href="Order.aspx?Site=<%#Eval("Id") %>&startDate=<%Response.Write(Request.QueryString["startDate"].ToString());%>&endDate=<%Response.Write(Request.QueryString["endDate"].ToString()); %>&typeName=<%Response.Write(Request.QueryString["typeName"].ToString()); %>">
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

    <!--Camping enheder (personer)-->
    <div class="camping-entities">
            <div>
                <span class="details">Voksne:</span>
                <input type="number" id="voksne" min="1" max="10">
            </div>
            <div>
                <span class="details">Børn:</span>
                <input type="number" id="børn" min="0" max="10">
            </div>
            <div>
                <span class="details">Hund:</span>
                <input type="number" id="hund" min="0" max="10">
            </div>
        </div>



    <!--Tilføjelser-->
    <div class="additions">
            <div>
                <span class="details">Sengelinned</span>
                <input type="number" id="addition1" min="0">
            </div>
            <div>
                <span class="details">Morgenkomplet (voksen)</span>
                <input type="number" id="addition2" min="0">
            </div>
            <div>
                <span class="details">Morgenkomplet (børn)</span>
                <input type="number" id="addition3" min="0">
            </div>
            <div>
                <span class="details">Cykelleje (pr. dag)</span>
                <input type="number" id="addition4" min="0">
            </div>
            <div>
                <span class="details">Adgang til badeland (voksen)</span>
                <input type="number" id="addition6" min="0">
            </div>
            <div>
                <span class="details">Adgang til badeland (børn)</span>
                <input type="number" id="addition7" min="0">
            </div>

            <!--Slut rengøring skal kun vises frem til hytter-->
            <div>
                <span class="details">Slut rengøring (Hytte)</span>
                <input type="checkbox" id="addition8" value="Slut rengøring(hytter)">
            </div>
        </div>



    <!--Bruger-->
    <div class="user-details">
            <div class="input-box">
                <span class="details">Email:</span>
                <input type="text" placeholder="Indtast email"  />
            </div>

            <!--Gemmes væk hvis bruger eksistere-->
            <div class="input-box">
                <span class="details">Fornavn:</span>
                <input type="text" placeholder="Indtast fornavn" />
            </div>
            <div class="input-box"> 
                <span class="details">Efternavn:</span>
                <input type="text" placeholder="Indtast efternavn" />
            </div>
            <div class="input-box">
                <span class="details">Telefon:</span>
                <input type="text" placeholder="Indtast tlf.nr." />
            </div>
            <div class="input-box">
                <span class="details">Addresse:</span>
                <input type="text" placeholder="Indtast addresse" />
            </div>
            <div class="input-box">
                <span class="details">Post nr:</span>
                <input type="text" placeholder="Indtast post nr." />
            </div>
        </div>




    <!--Tjekker først om bruger eksistere, hvis ikke skal bruger oprettes (evt notificere brugeren om dette). Ellers send information til database om reservationen-->
    <div class="button">
        <input type="submit" value="Bestil" />
    </div>

            <script src="Scripts/BookingSliding.js"></script>
</asp:Content>
