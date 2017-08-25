using System;
using dm.Framework;

namespace dm.Models
{
    public class Blob
    {
        public long BlobId { get; set; }
        public Shash Shash { get; set; }
        public DateTime AsOf { get; set; }
        public long PreviousBlobId { get; set; }
        public Blob PreviousBlob { get; set; }
        public byte[] Data { get; set; }
    }
}