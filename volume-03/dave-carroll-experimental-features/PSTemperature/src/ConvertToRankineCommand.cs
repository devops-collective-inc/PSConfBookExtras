using System.Management.Automation;

namespace PSTemperature
{

    [Experimental("PSTemperature.SupportRankine", ExperimentAction.Show)]
    [Cmdlet(VerbsData.ConvertTo, "Rankine", DefaultParameterSetName = "Fahrenheit")]
    public class ConvertToRankineCommand : PSCmdlet
    {

        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ParameterSetName = "Fahrenheit")]
        public decimal Fahrenheit { get; set; }

        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ParameterSetName = "Celsius")]
        public decimal Celsius { get; set; }

        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ParameterSetName = "Kelvin")]
        public decimal Kelvin { get; set; }

        [Parameter(
            Position = 1,
            ValueFromPipelineByPropertyName = true)]
        [ValidateRange(0, 28)]
        public int Precision { get; set; }

        [Alias("AsString")]
        [Parameter()]
        public SwitchParameter ToText
        {
            get { return toText; }
            set { toText = value; }
        }

        private bool toText;

        protected override void ProcessRecord()
        {
            Temperature temperature = null;
            string outputString = null;
            decimal outputDecimal = 0;

            string verboseOutput = "Created new instance of [Temperature] class with value {0} and unit {1}";

            switch (ParameterSetName)
            {
                case "Fahrenheit":
                    temperature = new Temperature(Fahrenheit, TemperatureUnit.F);
                    WriteVerbose(string.Format(verboseOutput, Fahrenheit, TemperatureUnit.F));
                    break;
                case "Celsius":
                    temperature = new Temperature(Celsius, TemperatureUnit.C);
                    WriteVerbose(string.Format(verboseOutput, Celsius, TemperatureUnit.C));
                    break;
                case "Kelvin":
                    temperature = new Temperature(Kelvin, TemperatureUnit.K);
                    WriteVerbose(string.Format(verboseOutput, Kelvin, TemperatureUnit.K));
                    break;
            }

            if (MyInvocation.BoundParameters.ContainsKey("ToText"))
            {
                outputString = MyInvocation.BoundParameters.ContainsKey("Precision") ?
                    temperature.ConvertToString(TemperatureUnit.K, (int)Precision) :
                    temperature.ConvertToString(TemperatureUnit.K);
            }
            else
            {
                outputDecimal = MyInvocation.BoundParameters.ContainsKey("Precision") ?
                    temperature.ConvertTo(TemperatureUnit.K, (int)Precision) :
                    temperature.ConvertTo(TemperatureUnit.K);
            }

            if (temperature.Comment != null)
            {
                WriteInformation(new InformationRecord(temperature.Comment, MyInvocation.MyCommand.Name));
            }
            if (outputString != null)
            {
                WriteObject(outputString);
            }
            else
            {
                WriteObject(outputDecimal);
            }
        }
    }
}
