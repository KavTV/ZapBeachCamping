using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapEmbeddedWinService
{
    public class CampingSite
    {
        string id;
        string available;

        public string Id { get => id; set => id = value; }
        public string Available { get => available; set => available = value; }

        public CampingSite(string id, string clean)
        {
            this.id = id;
            this.available = clean;
        }
    }
}
