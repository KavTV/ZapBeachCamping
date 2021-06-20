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

        .floatRight{
            float:right;
        }

        img{
            height: 450px;
        }

    </style>

    <div class="container-fluid text-center">    
        <div class="row content">
             <div class="col-lg-4 sidenav">
                <div>
                    <h4>Om os:</h4>
                </div>
                <div>
                    <p>
                        Vi er Birthe og Jørgen Carlsen, ejerne af ZAP Beach Camping.
                        Vores mål er at servicere vores dejlige kunder bedst muligt, og give jer den bedste camping oplevelse for dig og din familie.
                    </p>
                </div>
            </div>
            <div class="col-lg-8 floatRight">
                <div>
                    <img src="/Images/Camping/Carlsens.png" alt="BirtheogJoergen">
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid text-center" style="margin-top:40px;">    
        <div class="row content">
            <div class="col-lg-8">
                <div>
                    <img src="/Images/Camping/ZapCamping.png" alt="CampingFoto">
                </div>
            </div>

             <div class="col-lg-4 sidenav floatRight">
                <div>
                    <h4>Den perfekte campingtur!</h4>
                </div>
                <div>
                    <p>
                        Campingpladsen er lokaliseret i det altid smukke Midtjylland - En perle ikke langt fra Lalandia, Givskud Zoo og ikke mindst Legoland.
                        Derover har pladsen direkte adgang til en å med gode fiskemuligheder samt mulighed for udlejning af kajakker og kanoer.
                    </p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
