using System;

namespace Unidex.Model
{
    public class Character
    {
        public string Name { get; set; }
        public Location Birthplace { get; set; }
        public DateTime Birthdate { get; set; }

        public Character() {
            Name = "John Doe";
            DateTime bd;
            DateTime.TryParse("1/1/1990", out bd);
            Birthdate = bd;
            Birthplace = new Location("Mainstreet, USA");
        }
    }
}
