# Building an ETL Process and Data Warehouse Using PowerShell

Extra files by Frank Lesniak

Adopted from the ROMSorter project in the [author's GitHub repo](https://github.com/franklesniak/ROMSorter). Visit the repo for updated code or more ROM Package analysis tools.

## Legal Disclaimer

Unless a software license, author, or publisher states differently, obtaining, using, or distributing commercial software products without paying for them is illegal, immoral, and unethical.
Accordingly, this chapter focuses on using arcade games that are understood to be free to use or possible for you to purchase.
Please do not commit software piracy by illegally downloading, using, or distributing commercial arcade games.

## Arcade Emulation and ROM-Sorting

Please read the [Arcade Emulator Background Info page](./ARCADE_EMULATOR_BACKGROUND_INFO.md) before getting started; it includes highly-recommended background information.
If you are analyzing or sorting ROM packages, or if you are building a ROM list for an arcade system, the process will not make much sense unless you read the background page.

## Larger Code Snippets from the Chapter

For convenience the author has included a few code snippets from the chapter:

+ **Beginning to Form Output** section's [large code block](./ChapterCodeSnip-01-Beginning-to-Form-Output.ps1)
+ **Onward with Elements: `description`, `year`, and `manufacturer`** section's [large code block](./ChapterCodeSnip-02-Onward-With-Elements-description-year-and-manufacturer.ps1)
+ **Exploring Our First Nested Elements: `biosset`, `rom`, `disk`, and `sample`** section's [large code block](./ChapterCodeSnip-03-Exploring-Our-First-Nested-Elements-biosset-rom-disk-and-sample.ps1)
+ **Answering Remaining Open Questions** section's [large code block](./ChapterCodeSnip-04-Answering-Remaining-Open-Questions.ps1)

## Complete MAME 2010 DAT Analysis and Data-Extraction Script

As promised, the complete script [Convert-MAME2010DATToCSV.ps1](./Convert-MAME2010DATToCSV.ps1) is in this folder.

## Extra Scripts Mentioned in the Chapter

The following scripts were mentioned in the chapter as being useful for pulling-in additional data points:

+ Convert the "All Killer, No Filler" game list to tabular CSV using [Create-ConsolidatedAllKillerNoFillerGameList.ps1](./Create-ConsolidatedAllKillerNoFillerGameList.ps1)
+ Convert the Arcade Manager "Classics" list using [Convert-ArcadeManagerClassicsListToCsv.ps1](./Convert-ArcadeManagerClassicsListToCsv.ps1)
+ Convert the Progetto Emma Catver.ini file to tabular CSV using [Convert-ProgettoEmmaCatverIniToCsv.ps1](./Convert-ProgettoEmmaCatverIniToCsv.ps1)
+ Convert the Progetto Snaps BestGames.ini to tabular CSV using [Convert-ProgettoSnapsBestGamesIniToCsv.ps1](./Convert-ProgettoSnapsBestGamesIniToCsv.ps1)
+ Convert the Progetto Snaps Category INI files to tabular CSV using [Convert-ProgettoSnapsCategoryIniFilesToCsv.ps1](./Convert-ProgettoSnapsCategoryIniFilesToCsv.ps1)
+ Convert the Progetto Snaps Catver.ini file to tabular CSV using [Convert-ProgettoSnapsCatverIniToCsv.ps1](./Convert-ProgettoSnapsCatverIniToCsv.ps1)
+ Convert the Progetto Snaps Languages.ini file to tabular CSV using [Convert-ProgettoSnapsLanguagesIniToCsv.ps1](./Convert-ProgettoSnapsLanguagesIniToCsv.ps1)

These scripts require manual download of the relevant data sources; instructions are included in each script.
The script will gracefully report an error if the files are missing (including the URL where you may retrieve them).
