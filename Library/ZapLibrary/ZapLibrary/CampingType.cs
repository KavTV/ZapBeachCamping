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

        private string name;

        public CampingType(string name)
        {
            this.name = name;
        }
    }
}
