using System;

namespace Unidex.Model
{
    public class Location
    {
        public string Description { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string Address { get; set; }

        public Location(string desc){
            Description = desc;
        }
    }
}
