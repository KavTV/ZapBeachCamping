using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    public class CampingType
    {
        public string Name { get => name; }
        public DateTime StartDate { get => startDate; set => startDate = value; }
        public DateTime EndDate { get => endDate; set => endDate = value; }

        private string name;
        private DateTime startDate;
        private DateTime endDate;

        public CampingType(string name)
        {
            this.name = name;
        }

        public CampingType(DateTime startDate, DateTime endDate)
        {
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }
}
