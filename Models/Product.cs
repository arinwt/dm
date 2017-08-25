using System;
using Newtonsoft.Json;

namespace dm.Models
{
    public class Product : Blob
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Root { get; set; }

        public string ToSmallJson()
        {
            var obj = new {
                id = Id,
                name = Name,
                root = Root,
                shash = (string)Shash,
                asOf = AsOf
            };

            return JsonConvert.SerializeObject(obj);
        }
    }
}