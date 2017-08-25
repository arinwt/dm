using Newtonsoft.Json;

namespace dm.Models
{
    public class Connection
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string ConnectionString { get; set; }
        public string[] DataFolders { get; set; }

        public string GetToSmallJson() => JsonConvert.SerializeObject(this);
    }
}