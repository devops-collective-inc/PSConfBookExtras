using System.Management.Automation;

namespace PSTemperature
{
    [Cmdlet(VerbsData.ConvertTo, "Celsius", DefaultParameterSetName = "Fahrenheit")]
    public class ConvertToCelsiusCommand : PSCmdlet
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
            ParameterSetName = "Kelvin")]
        public decimal Kelvin { get; set; }

        [Experimental("PSTemperature.SupportRankine", ExperimentAction.Show)]
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ParameterSetName = "Rankine")]
        public decimal Rankine { get; set; }

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

        protected override void BeginProcessing()
        {
            //base.BeginProcessing();
        }
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
                case "Kelvin":
                    temperature = new Temperature(Kelvin, TemperatureUnit.K);
                    WriteVerbose(string.Format(verboseOutput, Kelvin, TemperatureUnit.K));
                    break;
                case "Rankine":
                    temperature = new Temperature(Rankine, TemperatureUnit.R);
                    WriteVerbose(string.Format(verboseOutput, Rankine, TemperatureUnit.R));
                    break;
            }

            if (MyInvocation.BoundParameters.ContainsKey("ToText"))
            {
                outputString = MyInvocation.BoundParameters.ContainsKey("Precision") ?
                    temperature.ConvertToString(TemperatureUnit.C, (int)Precision) :
                    temperature.ConvertToString(TemperatureUnit.C);
            }
            else
            {
                outputDecimal = MyInvocation.BoundParameters.ContainsKey("Precision") ?
                    temperature.ConvertTo(TemperatureUnit.C, (int)Precision) :
                    temperature.ConvertTo(TemperatureUnit.C);
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