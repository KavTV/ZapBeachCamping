using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    public class CampingSite
    {
        public string Id { get => id; }
        public bool Clean { get => clean;  }
        public double Price { get => price; }
        public List<string> Typename { get => typename; }
        public List<CampingAddition> CampingAdditions { get => campingAdditions; }

        private string id;
        private bool clean;
        private double price;
        private List<string> typename;
        private List<CampingAddition> campingAdditions;

        public CampingSite() { }
        public CampingSite(string id, bool clean,double price, List<string> typename, List<CampingAddition> campingAdditions)
        {
            this.id = id;
            this.clean = clean;
            this.price = price;
            this.typename = typename;
            this.campingAdditions = campingAdditions;
        }

        public CampingSite(string id)
        {
            this.id = id;
        }
    }
}
