

using System.Management.Automation;

namespace PSTemperature
{
    public enum TemperatureUnit
    {
        F = 0,  // Fahrenheit
        C = 1,  // Celsius
        K = 2,  // Kelvin
        R = 3   // Rankine
    }

    public class Temperature
    {
        internal static readonly string degreeSymbol = "°";

        private decimal _value;

        public decimal Value
        {
            get { return _value; }
            set
            {
                _value = GetTemperatureValue(value, Unit);
                Comment = GetStateComment();
            }
        }

        public TemperatureUnit Unit { get; set; }

        public string Comment { get; set; }

        public Temperature() { }

        public Temperature(decimal value, TemperatureUnit unit)
        {
            _value = GetTemperatureValue(value, unit);
            Unit = unit;
            Comment = GetStateComment();
        }

        public override string ToString()
        {
            string toStringOutput = (Unit == TemperatureUnit.F || Unit == TemperatureUnit.C) ?
                    $"{Value} {degreeSymbol}{Unit}" :
                    $"{Value} {Unit}";
            return toStringOutput;
        }

        public decimal ConvertTo(TemperatureUnit unit)
        {
            switch (Unit)
            {
                case TemperatureUnit.C:
                    switch (unit)
                    {
                        case TemperatureUnit.C:
                            return Value;
                        case TemperatureUnit.F:
                            return (Value * 9 / 5) + 32;
                        case TemperatureUnit.K:
                            return Value + 273.15M;
                        case TemperatureUnit.R:
                            return (Value + 273.15M) * 9 / 5;
                    }
                    break;
                case TemperatureUnit.F:
                    switch (unit)
                    {
                        case TemperatureUnit.C:
                            return (Value - 32) * 5 / 9;
                        case TemperatureUnit.F:
                            return Value;
                        case TemperatureUnit.K:
                            return (Value - 32) * 5 / 9 + 273.15M;
                        case TemperatureUnit.R:
                            return Value + 459.67M;
                    }
                    break;
                case TemperatureUnit.K:
                    switch (unit)
                    {
                        case TemperatureUnit.C:
                            return Value - 273.15M;
                        case TemperatureUnit.F:
                            return (Value - 273.15M) * 9 / 5 + 32;
                        case TemperatureUnit.K:
                            return Value;
                        case TemperatureUnit.R:
                            return Value * 9 / 5;
                    }
                    break;
                case TemperatureUnit.R:
                    switch (unit)
                    {
                        case TemperatureUnit.C:
                            return (Value - 491.67M) * 5 / 9;
                        case TemperatureUnit.F:
                            return Value - 459.67M;
                        case TemperatureUnit.K:
                            return Value * 5 / 9;
                        case TemperatureUnit.R:
                            return Value;
                    }
                    break;
            }
            return 0;
        }

        public decimal ConvertTo(TemperatureUnit unit, int Precision)
        {
            switch (unit)
            {
                case TemperatureUnit.C:
                    return decimal.Round(ConvertTo(unit), Precision);
                case TemperatureUnit.F:
                    return decimal.Round(ConvertTo(unit), Precision);
                case TemperatureUnit.K:
                    return decimal.Round(ConvertTo(unit), Precision);
                case TemperatureUnit.R:
                    return decimal.Round(ConvertTo(unit), Precision);
            }
            return 0;
        }

        public string ConvertToString(TemperatureUnit unit)
        {
            string toStringOutput = null;            
            switch (unit)
            {
                case TemperatureUnit.C:
                case TemperatureUnit.F:
                case TemperatureUnit.R:
                    toStringOutput = $"{ConvertTo(unit)} {degreeSymbol}{unit}";
                    break;
                case TemperatureUnit.K:
                    toStringOutput = $"{ConvertTo(unit)} {unit}";
                    break;
            }            
            return toStringOutput;
        }

        public string ConvertToString(TemperatureUnit unit, int precision)
        {
            string convertToStringOutput = null;                      
            switch (unit)
            {
                case TemperatureUnit.C:
                case TemperatureUnit.F:
                case TemperatureUnit.R:
                    convertToStringOutput = $"{decimal.Round(ConvertTo(unit), precision)} {degreeSymbol}{unit}";
                    break;
                case TemperatureUnit.K:
                    convertToStringOutput = $"{decimal.Round(ConvertTo(unit), precision)} {unit}";
                    break;
            }                       
            return convertToStringOutput;
        }

        public static bool IsBelowAbsoluteZero(decimal value, TemperatureUnit unit)
        {
            switch (unit)
            {
                case TemperatureUnit.F:
                    return value < -459.67M;
                case TemperatureUnit.C:
                    return value < -273.15M;
                case TemperatureUnit.K:
                    return value < 0M;
                case TemperatureUnit.R:
                    return value < 0M;
                default:
                    return false;
            }
        }

        private decimal GetTemperatureValue(decimal value, TemperatureUnit unit)
        {
            if (IsBelowAbsoluteZero(value, unit))
            {
                string InvalidTemperature = (unit == TemperatureUnit.F || unit == TemperatureUnit.C || unit == TemperatureUnit.R)
                    ? $"{value} {degreeSymbol}{unit} is below absolute zero. Please try again."
                    : $"{value} {unit} is below absolute zero. Please try again.";
                throw new System.ArgumentException(InvalidTemperature);
            }
            return value;
        }

        private string GetStateComment()
        {
            decimal celsius = ConvertTo(TemperatureUnit.C);
            switch (celsius)
            {
                case -273.15M:
                    return "Absolute zero";
                case -195.8M:
                    return "Boiling point of liquid nitrogen";
                case -78:
                    return "Sublimation point of dry ice";
                case -40:
                    return "Intersection of Celsius and Fahrenheit scales";
                case 0:
                    return "Freezing point";
                case 20:
                    return "Room temperature (NIST standard)";
                case 37:
                    return "Normal human body temperature (average)";
                case 100:
                    return "Boiling point";
                case 233:
                    return "Fahrenheit 451 - the temperature at which book paper catches fire and burns";
                case 5505:
                    return "Surface of the Earth's sun";
                default:
                    return null;
            }
        }
    }
}
