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

       <asp:DataList ID="DataList1" runat="server" RepeatDirection="Horizontal" CellSpacing="3" RepeatColumns="3">
           <ItemTemplate>
           <tr>
               <td>
                   <label>Room: <%# Eval("Name") %></label>
               </td>
           </tr>
               </ItemTemplate>
       </asp:DataList>

       <h3>Registration:</h3>
       
       <div class="reservation row content">
            <div class="input-box">
               <span class="details">Camping type:</span>
               <select name="types" id="campingType">
                   <option value="tent">Telt</option>
                   <option value="campingSmall">Campingplads (lille)</option>
                   <option value="campingBig">Campingplads (stor)</option>
                   <option value="cabinStd">Hytte (standard)</option>
                   <option value="cabinLxy">Hytte (luksus)</option>
                   <option value="seasonPlads">Sæsonplads</option>
               </select>
           </div>

           <!--Skal gemmes væk hvis sæsonplads ikke er valgt-->
           <div class="input-box">
               <span class="details">Sæsonplads:</span>
               <select name="types" id="SeasonOptions">
                   <option value="none">Ingen</option>
                   <option value="spring">Forår (1. April 🡲 30. Juni)</option>
                   <option value="summer">Sommer (1. April 🡲 30. September)</option>
                   <option value="fall">Efterår (15. August 🡲 31. Oktober)</option>
                   <option value="vinter">Vinter (1. Oktober 🡲 31. Marts)</option>
               </select>
            </div> 
           
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
           <%--<asp:datalist ID="getData" runat="server"></asp:datalist>--%>
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
                <span class="details">Email</span>
               <input type="text" placeholder="Indtast email" />
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
