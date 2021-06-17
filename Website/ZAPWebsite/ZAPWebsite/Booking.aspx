<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Booking.aspx.cs" Inherits="ZAPWebsite.Booking" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .webForm{
            display: flex;
            height: 100vh;
            background-color: #f1f1f1;
        }
    </style>

    <div class="container-fluid webForm col-sm-8">

        <h3>Registration:</h3>
       
        <div class="reservation row content">

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
                    <input type="date" id="resEnd"/>
                </div>
            </div>

            <!--Printer ledige pladser-->
            <asp:DataList ID="DataListCamping" runat="server" RepeatDirection="Horizontal" CellSpacing="3" RepeatColumns="3">
                <ItemTemplate>
                    <tr>
                        <td>
                            <label>Room: <%# Eval("typename") %></label>
                        </td>
                    </tr>

                    <tr>
                        <td>
<%--                            <asp:LinkButton ID="bookhere" runat="server" OnClick="bookhere_Click" CommandName="CheckForBook" CommandArgument='<%#Eval("roomid") %>' Text="Book her" /> --%>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:DataList>
        </div>
       
        <div class="user-details">
            <div class="input-box">
                <span class="details">Email:</span>
                <input type="text" placeholder="Indtast email"  />
            </div>

            <!--Gemmes væk hvis bruger eksistere-->
            <div class="input-box">
                <span class="details">Fornavn</span>
                <input type="text" placeholder="Indtast fornavn" />
            </div>
            <div class="input-box"> 
                <span class="details">Efternavn</span>
                <input type="text" placeholder="Indtast efternavn" />
            </div>
            <div class="input-box">
                <span class="details">Telefon</span>
                <input type="text" placeholder="Indtast tlf.nr." />
            </div>
            <div class="input-box">
                <span class="details">Addresse</span>
                <input type="text" placeholder="Indtast addresse" />
            </div>
            <div class="input-box">
                <span class="details">Post nr.</span>
                <input type="text" placeholder="Indtast post nr." />
            </div>
        </div>

        <!--Tjekker først om bruger eksistere, hvis ikke skal bruger oprettes (evt notificere brugeren om dette). Ellers send information til database om reservationen-->
        <div class="button">
            <input type="submit" value="Bestil" />
        </div>
    </div>
</asp:Content>
