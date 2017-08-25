using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace dm.Data
{
    public static class SqlExtensions
    {
        public static T Get<T>(this SqlDataReader r, string n) => r[n] is T t ? t : throw new ArgumentException($"cannot cast column '{n}'");
    }
}