using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using dm.Models;
using dm.Framework;
using dm.Data;

namespace dm.Controllers
{
    [Route("api/v1/[controller]")]
    public class ProductController : Controller
    {
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        [HttpGet("{id}")]
        public string Get(int id)
        {
            using (var db = new SqlDatabase("server=ARIN;integrated security=sspi;database=dm$meta;"))
                return Product.GetProduct(id, db)?.ToSmallJson() ?? "no matches";
        }

        [HttpPost]
        public int Post([FromBody]string value)
        {
            Console.WriteLine($"value received: '{value}'");

            var prod = new Product().FromSmallJson(value);
            using (var db = new SqlDatabase("server=ARIN;integrated security=sspi;database=dm$meta;"))
                return Product.AddProduct(prod, db);
        }

        [HttpPut("{id}")]
        public void Put(int id, [FromBody]string value)
        {
        }

        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
