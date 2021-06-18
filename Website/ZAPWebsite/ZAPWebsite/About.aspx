<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="ZAPWebsite.About" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        body{
            background-color: #ffffff;
        }
        /* Set white background color and 100% height */
        .sidenav {
            padding-top: 20px;
            background-color: #eaeaea;
            height: 100%;
        }

        /* Set height of the grid so .sidenav can be 100% (adjust as needed) */
        .row.content {
            height: 450px
        }
    </style>

    <div class="container-fluid text-center">    
        <div class="row content">
             <div class="col-sm-4 sidenav">
                <div>
                    <h4>Om os:</h4>
                </div>
                <div class="">
                    <p>
                        Hej! Vi er Birthe og Jørgen Carlsen, ejerne af ZAP Beach Camping.
                        Vores mål er at servicere vores gæster bedst muligt samt vedligeholde vores campingplads så vi er klar til at modtage vores dejlige kunder.
                    </p>
                </div>
            </div>
            <div class="col-lg 6">
                <div>
                    <img src="/Images/BirtheogJoergen.jpg" class="float-right" alt="BirtheogJoergen" style="height:450px">
                </div>
            </div>
        </div>
    </div>
</asp:Content>
