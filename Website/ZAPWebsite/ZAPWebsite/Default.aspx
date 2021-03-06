<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ZAPWebsite._Default" %>

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

    <!--Sidebar left-->
    <div class="container-fluid text-center">    
        <div class="row content">
             <div class="col-sm-2 sidenav text-left">
                 <p><a href="#">Information</a></p>
                 <p><a href="https://www.rei.com/learn/expert-advice/camping-for-beginners.html">Camping guide</a></p>
                 <p><a href="#">Faciliteter</a></p>
                 <p><a href="#">Mad og resturanter</a></p>
                 <p><a href="#">Hygge</a></p>
                 <p><a href="#">Gode udsigter</a></p>
                 <p><a href="#">Diverse</a></p>
                 <p><a href="Booking.aspx?sale=1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen">TILBUD! 1 uges plads inkl 4 personer 
                     6 x morgenmad og billetter til badeland hele ugen</a></p>
             </div>

            <!--Image slide show-->
            <div class="col-sm-8">
                <div id="campingSlide" class="carousel slide" data-ride="carousel" style="position:relative;">

                    <!--Indicators-->
                    <ol class="carousel-indicators" style="z-index:1 !important">
                        <li data-target="#campingSlide" data-slide-to="0" class="active"></li>
                        <li data-target="#campingSlide" data-slide-to="1"></li>
                        <li data-target="#campingSlide" data-slide-to="2"></li>
                        <li data-target="#campingSlide" data-slide-to="3"></li>
                        <li data-target="#campingSlide" data-slide-to="4"></li>
                        <li data-target="#campingSlide" data-slide-to="5"></li>
                    </ol>

                    <div class="carousel-inner" role="listbox">

                        <div class="item active">
                            <img src="Images/DefaultSlideShow/Pic1.jpg" alt="Pic1" style="width:100%; height:450px">
                        </div>
                        <div class="item">
                            <img src="Images/DefaultSlideShow/Pic2.jpg" alt="Pic2" style="width:100%; height:450px">
                        </div>
                        
                        <div class="item">
                            <img src="/Images/DefaultSlideShow/Pic3.jpg" alt="Pic3" style="width:100%; height:450px">
                        </div>

                        <div class="item">
                            <img src="/Images/DefaultSlideShow/Pic4.jpg" alt="Pic4" style="width:100%; height:450px">
                        </div>

                        <div class="item">
                            <img src="/Images/DefaultSlideShow/Pic5.jpg" alt="Pic5" style="width:100%; height:450px">
                        </div>
                    </div>

                    <!-- Left and right controls -->
                    <a class="left carousel-control" href="#campingSlide" data-slide="prev">
                        <span class="glyphicon glyphicon-chevron-left"></span>
                        <span class="sr-only">Previous</span>
                    </a>

                    <a class="right carousel-control" href="#campingSlide" data-slide="next">
                        <span class="glyphicon glyphicon-chevron-right"></span>
                        <span class="sr-only">Next</span>
                    </a>
                </div>
            </div>

            <!--Sidebar right-->
            <div class="col-sm-2 sidenav">
                <div>
                    <h4>Den perfekte campingtur!</h4>
                    
                    <div>
                        <p>
                            En perle ikke langt fra Lalandia, Givskud Zoo og ikke mindst Legoland.
                            Derover har pladsen direkte adgang til en å med gode fiskemuligheder samt mulighed for udlejning af kajakker og kanoer.
                        </p>
                    </div>
                    
                    <!--Order button-->
                    <a class="btn btn-danger" href="Booking">Bestil nu!</a>
                </div>
                <div>
                    <h4>Sæsonplads</h4>
                    <p>Med vores fantastiske sæsonpladser, kan du få en plads i en hel season til en attraktiv pris!
                        kan vælges på booking siden.
                    </p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
