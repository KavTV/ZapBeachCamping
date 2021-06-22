using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace ZapLibrary
{
    public class Email
    {

        private string clientEmail;
        private SmtpClient smtpServer;

        /// <summary>
        /// Email constructor
        /// </summary>
        /// <param name="clientEmail"> This is the gmail you want to send from</param>
        /// <param name="clientPassword">This is the password to the gmail you want to send from</param>
        public Email(string clientEmail, string clientPassword)
        {
            this.clientEmail = clientEmail;

            smtpServer = new SmtpClient("smtp.gmail.com");
            smtpServer.Port = 587;
            smtpServer.Credentials = new NetworkCredential(clientEmail, clientPassword);
            smtpServer.EnableSsl = true;
        }

        /// <summary>
        /// Used to send email
        /// </summary>
        public void SendEmail(string customerEmail, string subject, string message)
        {
            MailMessage mail = CreateEmail(customerEmail, subject, message);
            smtpServer.Send(mail);
            mail.Dispose();
        }

        /// <summary>
        /// Used to send mail with attachement
        /// </summary>
        public void SendEmailAttachement(string customerEmail, string subject, string message, string attachmentPath)
        {
            MailMessage mail = CreateEmail(customerEmail, subject, message);
            mail.Attachments.Add(new Attachment(attachmentPath));
            smtpServer.Send(mail);
            mail.Dispose();
        }

        /// <summary>
        /// Used to create default template for email
        /// </summary>
        private MailMessage CreateEmail(string customerEmail, string subject, string message)
        {
            MailMessage mail = new MailMessage();
            mail.From = new MailAddress(clientEmail);
            mail.To.Add(new MailAddress(customerEmail));
            mail.Subject = subject;
            mail.Body = message;
            return mail;
        }

    }
}
