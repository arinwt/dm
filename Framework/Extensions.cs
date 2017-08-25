using System.Collections.Generic;
using System.Linq;

namespace dm.Framework
{
    public static class Extensions
    {
        public static bool AreSame<T>(this T[] array, T[] otherArray)
        {
            if (array == otherArray)
                return true;

            if (array == null || otherArray == null || array.Length != otherArray.Length)
                return false;

            for (int i = 0; i < array.Length; i++)
                if (!array[i].Equals(otherArray[i]))
                    return false;

            return true;
        }

        public static bool AreSameEnumerables<T>(this IEnumerable<T> list, IEnumerable<T> otherList)
        {
            if (list == otherList)
                return true;
            
            if (list == null || otherList == null || list.Count() != otherList.Count())
                return false;
            
            var listEnum = list.GetEnumerator();
            var otherEnum = otherList.GetEnumerator();

            for (int i = 0; i < list.Count(); i++)
            {
                var listDone = !listEnum.MoveNext();
                var otherDone = !otherEnum.MoveNext();
                
                if (listDone && otherDone) // both ended abruptly
                    return true;
                else if (listDone || otherDone) // one ended abruptly
                    return false;
                else if (listEnum.Current == null && otherEnum.Current == null) // both null
                    continue;
                else if (listEnum.Current == null || otherEnum.Current == null) // one null value, but not the other
                    return false;
                else if (!listEnum.Current.Equals(otherEnum.Current)) // both non-null and different
                    return false;
                // otherwise both are same
            }

            return true;
        }
    }
}