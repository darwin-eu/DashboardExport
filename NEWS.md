# DashboardExport v1.4.0

## Enhancements
* Add achilles analyses for count by concept id by month
* Add custom analyses on episode table
* Add custom analyses age and gender stratification for drug era
* Rounding to 10s for records per month

## Fixes
* Compatibility with DatabaseConnector v7
* Allow use of DBI Connection Details
* Handle multiple or duplicate cdm_source records
* Remove need for analysis 117

# DashboardExport v1.3.1

* Fix for episode queries

# DashboardExport v1.3.0

* Add analyses for the v5.4 episode table
* Add analyses for fact_relationship table 
* Add analyses 10 and 11 for persons by year_of_birth and gender
* Fix for ICH age groups; remove other category

# DashboardExport v1.2.1

* Add ability to bypass warning when required Achilles analyses are missing.

# DashboardExport v1.2.0

* Add achilles analysis 822, 1822, 900, 1000 by @SofiaMp in #36
* Add analysis 444 - dpc by @MaximMoinat in #41
* Setup tests and github actions by @MaximMoinat in #37
* remove vocab schema from files by @SofiaMp in #42
* Add Descendant Person Count for conditions @MaximMoinat in #38 
* Use `DatabaseConnector::tableExists` to check for Achilles tables

# DashboardExport v1.1.0

* Refactor execution of DashboardExport-specific analyses by @MaximMoinat in #23
* Two new analyses: by concept by age by @MaximMoinat in #18
* Export additional Achilles analyses #22 #24 #25
* Query vocabulary version directly from vocabulary table #19

# DashboardExport v1.0.0

* Check for achilles results before exporting  by @MaximMoinat in #13
* Refactor custom analyses by @MaximMoinat in #14
* Analysis 740 and 741 for drug exposure statistics by route_concept_id #4 

# DashboardExport v0.3.0

* Include source name in export file
* Changed order of analysis ids
* Removed exportMinimal option

# DashboardExport v0.2.0

* Timestamp in export file to prevent overwriting
* Fix sample code in readme

# DashboardExport v0.1.0
First release of DashboardExport