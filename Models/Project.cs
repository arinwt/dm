using dm.Data;
using Newtonsoft.Json;

namespace dm.Models
{
    public class Project : Blob
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Root { get; set; }
        public int ProductId { get; set; }
        public Product Product { get; set; }
        public int CustomerId { get; set; }
        public Customer Customer { get; set; }

        public string ToSmallJson()
        {
            var obj = new {
                id = Id,
                name = Name,
                root = Root,
                productId = ProductId,
                customerId = CustomerId,
                shash = (string)Shash,
                asOf = AsOf
            };

            return JsonConvert.SerializeObject(obj);
        }
    }
}