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
        public bool Clean { get => clean; }
        public double Price { get => price; }
        public List<string> Typename { get => typename; }
        public List<CampingAddition> CampingAdditions { get => campingAdditions; }
        public string GetCampingAdditions
        {
            get
            {
                //Because we cant use the list with items in the CampingAdditions,
                //Im making this property that puts all additions into one string.
                string list = "";
                for (int i = 0; i < CampingAdditions.Count; i++)
                {
                    list += campingAdditions[i].Name;
                    
                    //If it is the last item in the list, then dont add the ,
                    if (i + 1 != campingAdditions.Count)
                    {
                        list += ", ";
                    }
                }
                return list;
            }
        }
        public string GetTypename
        {
            get
            {
                string list = "";
                for (int i = 0; i < Typename.Count; i++)
                {
                    list += typename[i];

                    //If it is the last item in the list, then dont add the ,
                    if (i + 1 != typename.Count)
                    {
                        list += ", ";
                    }
                }
                return list;
            }
        }

        private string id;
        private bool clean;
        private double price;
        private List<string> typename;
        private List<CampingAddition> campingAdditions;

        public CampingSite() { }
        public CampingSite(string id, bool clean, double price, List<string> typename, List<CampingAddition> campingAdditions)
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
