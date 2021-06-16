using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    public class CampingSite
    {
        public int Id { get => id; }
        public bool Clean { get => clean;  }
        public double Price { get => price; }
        public List<string> Typename { get => typename; }
        internal List<CampingAddition> CampingAdditions { get => campingAdditions; }

        private int id;
        private bool clean;
        private double price;
        private List<string> typename;
        private List<CampingAddition> campingAdditions;

        public CampingSite() { }
        public CampingSite(int id, bool clean,double price, List<string> typename, List<CampingAddition> campingAdditions)
        {
            this.id = id;
            this.clean = clean;
            this.typename = typename;
            this.campingAdditions = campingAdditions;
        }

        public CampingSite(int id)
        {
            this.id = id;
        }
    }
}
