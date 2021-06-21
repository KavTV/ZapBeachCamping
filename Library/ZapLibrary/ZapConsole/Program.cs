using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ZapLibrary;

namespace ZapConsole
{
    class Program
    {
        static void Main(string[] args)
        {
            ZapManager manager = new ZapManager("");
            Customer customer = new Customer("1234@hotmail.com", 22694455, "mand", 4100,"Kvejen 21");
            List<ReservationAddition> reservationAddition = new List<ReservationAddition>();
            reservationAddition.Add(new ReservationAddition( new AdditionSeason("Voksne","Højsæson", 82), 3));
            reservationAddition.Add(new ReservationAddition( new AdditionSeason("Børn","Højsæson", 42), 1));
            Reservation reservation = new Reservation("1234@hotmail.com", "106", "Lille campingplads", new DateTime(2021,06,17),new DateTime(2021,06,30), reservationAddition);
            //manager.CreateCustomer(customer);
            //manager.UpdateCustomer("jenshansensemail@gmail.com", customer);
            //Console.WriteLine(manager.CreateReservation(reservation));
            //Console.WriteLine(manager.DeleteReservation("108417"));
            //var sites = manager.GetAvailableSites(new DateTime(2021, 06, 21), new DateTime(2021, 06, 29), "Lille campingplads");
            //var j = manager.GetCampingSite("71", "Lille campingplads",new DateTime(2021,06,22), new DateTime(2021, 06, 29));
            //var h = manager.IsCustomerCreated("jj@hotmail.dk");
            //Console.WriteLine("sejt");
            //foreach (var item in sites)
            //{
            //    Console.WriteLine("_____NEW_____");
            //    Console.WriteLine(item.Id);
            //    Console.WriteLine(item.Price);
            //    Console.WriteLine(item.CampingAdditions);
            //}
            //var j = manager.GetReservation("104898");
            Console.ReadLine();
        }
    }
}
