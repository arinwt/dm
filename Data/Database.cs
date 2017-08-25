using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace dm.Data
{
    public class SqlDatabase : IDisposable
    {
        private SqlConnectionStringBuilder ConnectionString;
        private SqlConnection Connection;
        public bool IsOpen => Connection?.State == ConnectionState.Open;
        public string Server => ConnectionString.DataSource;
        public string Database => ConnectionString.InitialCatalog;
        public bool IntegratedSecurity => ConnectionString.IntegratedSecurity;
        public string UserId => ConnectionString.UserID;

        public SqlDatabase(string connString)
        {
            ConnectionString = new SqlConnectionStringBuilder(connString);
            Connection = new SqlConnection(connString);
            Connection.Open();
        }

        public SqlDataReader ExecuteReader(string stmt, Dictionary<string, object> pars = null) => Execute(stmt, pars, (cmd) => cmd.ExecuteReader());
        public int ExecuteNonQuery(string stmt, Dictionary<string, object> pars = null) => Execute(stmt, pars, (cmd) => cmd.ExecuteNonQuery());
        public object ExecuteScalar(string stmt, Dictionary<string, object> pars = null) => Execute(stmt, pars, (cmd) => cmd.ExecuteScalar());
        private T Execute<T>(string stmt, Dictionary<string, object> pars, Func<SqlCommand, T> func)
        {
            using (var cmd = new SqlCommand(stmt, Connection))
            {
                if (pars != null)
                    foreach (var p in pars)
                        cmd.Parameters.AddWithValue(p.Key, p.Value);
                return func(cmd);
            }
        }

        private void Execute(string stmt, Dictionary<string, object> pars, Action<SqlCommand> action)
        {
            using (var cmd = new SqlCommand(stmt, Connection))
            {
                if (pars != null)
                    foreach (var p in pars)
                        cmd.Parameters.AddWithValue(p.Key, p.Value);
                action(cmd);
            }
        }

        public SqlDataReader ExecuteReader(string stmt, params (string, object)[] pars) => Execute(stmt, pars, (cmd) => cmd.ExecuteReader());
        public int ExecuteNonQuery(string stmt, params (string, object)[] pars) => Execute(stmt, pars, (cmd) => cmd.ExecuteNonQuery());
        public object ExecuteScalar(string stmt, params (string, object)[] pars) => Execute(stmt, pars, (cmd) => cmd.ExecuteScalar());
        private T Execute<T>(string stmt, (string key, object value)[] pars, Func<SqlCommand, T> func)
        {
            using (var cmd = new SqlCommand(stmt, Connection))
            {
                if (pars != null)
                    foreach (var p in pars)
                        cmd.Parameters.AddWithValue(p.key, p.value);
                return func(cmd);
            }
        }

        private void Execute(string stmt, (string key, object value)[] pars, Action<SqlCommand> action)
        {
            using (var cmd = new SqlCommand(stmt, Connection))
            {
                if (pars != null)
                    foreach (var p in pars)
                        cmd.Parameters.AddWithValue(p.key, p.value);
                action(cmd);
            }
        }
        public void Dispose()
        {
            Connection?.Dispose();
        }
    }
}