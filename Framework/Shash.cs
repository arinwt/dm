using System;
using System.Security.Cryptography;
using System.Text;
using System.ComponentModel;

namespace dm.Framework
{
    [TypeConverter(typeof(ShashTypeConverter))]
    public struct Shash
    {
        const int ByteLength = 32;
        const int StringLength = 44;

        public byte[] Bytes { get; }

        public Shash(byte[] bytes) => Bytes = bytes;

        public static Shash Create(string text)
        {
            var textBytes = Encoding.UTF8.GetBytes(text);
            return new Shash(SHA256.Create().ComputeHash(textBytes));
        }

        public static Shash FromBase64String(string s)
        {
            if (s == null)
                throw new ArgumentNullException(nameof(s));

            if (s.Length != StringLength)
                throw new ArgumentException($"invalid string length; expected {StringLength}, actual {s.Length}", nameof(s));

            return new Shash(Convert.FromBase64String(s));
        }

        public bool Equals(Shash sh) => Bytes.AreSame(sh.Bytes);

        public override bool Equals(object obj) => obj is Shash sh ? Equals(sh) : false;

        public override int GetHashCode()
        {
            int hash = 13;
            foreach (var b in Bytes)
                hash = (hash * 7) + b;
            return hash;
        }

        public override string ToString() => Bytes == null ? null : Convert.ToBase64String(Bytes);

        public static explicit operator string(Shash sh) => sh.ToString();
        public static explicit operator Shash(string s) => FromBase64String(s);

        public static explicit operator byte[](Shash sh) => sh.Bytes;
        public static explicit operator Shash(byte[] b) => new Shash(b);
    }
}