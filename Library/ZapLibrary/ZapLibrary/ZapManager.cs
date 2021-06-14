using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZapLibrary
{
    class ZapManager
    {
        internal Dal Dal { get => dal; set => dal = value; }


        private Dal dal;

        public ZapManager(string connectionstring)
        {
            dal = new Dal(@"Server=172.16.21.107;Database=myDataBase;User Id=myUsername;Password=Passw0rd;");
        }
    }
}
