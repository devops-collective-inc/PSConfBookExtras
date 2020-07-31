# Exploring Experimental Features in PowerShell 7

## Sample Modules with Experimental Features

Within this folder, you will find the two sample modules that was used in the chapter with the same name as above.

### DemoModule

This module is a simple script module written in PowerShell.

The following experimental features are included with the module:

+ `DemoModule.ExperimentalFunction`
+ `DemoModule.ExperimentalParameter`
+ `DemoModule.ExperimentalBehavior`

### PSTemperature

This module is a binary module written in `C#`.

The module includes one experimental feature, `PSTemperature.SupportRankine`.

When this experimental feature is enabled, the cmdlet `ConvertTo-Rankine` is available.
Additionally, the three other `ConvertTo-*` cmdlets will have a `Rankine` parameter.

_The `Temperature` class contains the majority of the functionality for this module.
All cmdlets use the methods of the class for conversions between the four supported temperature scales, specifying the precision, and
providing `decimal` or `string` output._
