<%@ Page Title="Contact" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="ZAPWebsite.Contact" %>

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
    
    <div class="row content">
        <div class="col-sm-4 sidenav" style="margin-right: 20px;">
            <div>
                <h4>Kontakt:</h4>
            </div>
            <div class="">
                <p>Har du problemer eller spørgsmål, kan du kontakte os her:</p>
                <p>Email: zapbeachc@mping.dk</p>
                <p>Tlf: (45+) 88 88 88 88</p>
            </div>
        </div>
        <div>

        </div>
        <div class="col-lg 2">
            <div>
                <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d22708.432923448323!2d9.382185525976613!3d56.1802408599327!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x464b8b31851a884f%3A0x301ff15a89742d9!2s8600%20Silkeborg!5e0!3m2!1sda!2sdk!4v1624006369514!5m2!1sda!2sdk" width="600" height="450" style="border:0;"></iframe>
            </div>
        </div>
    </div>
</asp:Content>
