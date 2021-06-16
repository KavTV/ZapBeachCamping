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
            Customer customer = new Customer("dennyemail@gmail.com", 22334455, "mand", 4100,"Kaspvejen 21");
            List<ReservationAddition> reservationAddition = new List<ReservationAddition>();
            reservationAddition.Add(new ReservationAddition("Voksne", new AdditionSeason("Højsæson", 82), 3));
            reservationAddition.Add(new ReservationAddition("Børn", new AdditionSeason("Højsæson", 42), 1));
            Reservation reservation = new Reservation("dennyemail@gmail.com",102, "Lille campingplads",new DateTime(2021,06,16),new DateTime(2021,06,21), reservationAddition);
            //manager.CreateCustomer(customer);
            //manager.UpdateCustomer("Detteerenmail@gmail.com",customer);
            //manager.CreateReservation(reservation);
            var sites = manager.GetAvailableSites(new DateTime(2021, 06, 15), new DateTime(2021, 06, 15), "Lille campingplads");
            Console.WriteLine("sejt");
            foreach (var item in sites)
            {
                Console.WriteLine(item.Id);
                Console.WriteLine(item.Price);
            }
            Console.ReadLine();
        }
    }
}
