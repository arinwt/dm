using System;
using dm.Data;
using dm.Framework;
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

        public Product FromSmallJson(string json)
        {
            var obj = new {
                id = Id,
                name = Name,
                root = Root,
                shash = (string)Shash,
                asOf = AsOf
            };
            obj = JsonConvert.DeserializeAnonymousType(json, obj);
            
            Id = obj.id;
            Name = obj.name;
            Root = obj.root;
            Shash = (Shash)obj.shash;
            AsOf = obj.asOf;
            
            return this;
        }

        public static Product GetProduct(int id, SqlDatabase db)
        {
            if (db == null)
            {
                throw new System.ArgumentNullException(nameof(db));
            }

            using (var reader = db.ExecuteReader("EXECUTE dbo.GetProduct @Id = @id;", ("id", id)))
            {
                if (reader.Read())
                {
                    return new Product()
                    {
                        Id = reader.Get<int>("Id"),
                        Name = reader.Get<string>("Name"),
                        Root = reader.Get<string>("Root"),
                        Shash = (Shash)reader.Get<byte[]>("Shash"),
                        AsOf = reader.Get<DateTime>("AsOf")
                    };
                }
                else
                {
                    return null;
                }
            }
        }

        public static int AddProduct(Product product, SqlDatabase db)
        {
            if (db == null)
            {
                throw new ArgumentNullException(nameof(db));
            }

            var sql = @"EXECUTE dbo.NewProduct
    @Name = @name,
    @Root = @root,
    @Shash = @shash,
    @Data = @data;";

            return (int)db.ExecuteScalar(sql,
                ("name", product.Name),
                ("root", product.Root),
                ("shash", (byte[])product.Shash),
                ("data", product.Data));
        }
    }
}