using System;
using System.ComponentModel;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using dm.Framework;

namespace dm.Framework
{
    public class ShashTypeConverter : TypeConverter
    {
        public override bool CanConvertFrom(ITypeDescriptorContext context, System.Type sourceType)
        {
            return sourceType == typeof(string) || sourceType == typeof(byte[]);
        }

        public override bool CanConvertTo(ITypeDescriptorContext context, System.Type destinationType)
        {
            return destinationType == typeof(string) || destinationType == typeof(byte[]);
        }

        public override object ConvertFrom(ITypeDescriptorContext context, System.Globalization.CultureInfo culture, object value)
        {
            if (value is string s)
                return (Shash)s;
            else if (value is byte[] b)
                return (Shash)b;
            else
                throw new ArgumentException($"invalid argument type '{value.GetType().Name}'", nameof(value));
        }

        public override object ConvertTo(ITypeDescriptorContext context, System.Globalization.CultureInfo culture, object value, System.Type destinationType)
        {
            if (!(value is Shash sh))
                throw new ArgumentException($"value should be Shash", nameof(value));

            if (destinationType == typeof(string))
                return (string)sh;
            else if (destinationType == typeof(byte[]))
                return (byte[])sh;
            else
                throw new ArgumentException($"invalid argument type '{destinationType.Name}'", nameof(destinationType));
        }
    }
}