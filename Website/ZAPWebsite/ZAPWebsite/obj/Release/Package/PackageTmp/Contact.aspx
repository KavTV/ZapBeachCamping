<%@ Page Title="Contact" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="ZAPWebsite.Contact" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        /* Sets white background color*/
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
            height: 450px;
        }

        /* Sets content to right side*/
        .floatRight{
            float:right;
            margin-left:20px;
        }
    </style>

    <!--Content-->
    <div class="container-fluid text-center">
        <div class="row content">
            <!--Sidebar left-->
            <div class="col-sm-4 sidenav" style="margin-right: 20px;">
                <!--Sidebar content-->
                <div>
                    <h4>Kontakt:</h4>
                </div>
                <div>
                    <p>Har du problemer eller spørgsmål, kan du kontakte os her:</p>
                    <p>Email: zapbeachc@mping.dk</p>
                    <p>Tlf: (45+) 88 88 88 88</p>
                </div>
            </div>

            <!--Google map-->
            <div class="col-lg 2">
                <div>
                    <iframe src="https://www.google.com/maps/embed?pb=!1m12!1m8!1m3!1d2133.438053813995!2d9.8897231!3d55.3342006!3m2!1i1024!2i768!4f13.1!2m1!1ssandager%20n%C3%A6s!5e1!3m2!1sen!2sdk!4v1624433251261!5m2!1sen!2sdk" width="600" height="450" style="border:0;"></iframe>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
