# Run tSQLt Unit Tests

## Description

With this build task, besides running tSQLt Unit Tests on a SQL Database, you'll also be able to:
* Export the test results to the build summary;
* Export the code coverage report to the build summary.

Originally, there is no build task that does all those 3 tasks. Thinking from an automation and engineering perspective, once you run your unit tests, it would be good to have its results published somewhere to inspect and adapt your tests.

This task relies on 3 components:

### SQLCover

Link: https://github.com/GoEddie/SQLCover

This is an Open Source component written by [Ed Elliot](https://github.com/GoEddie) to extract code coverage from a tSQLt test execution.

### OpenCover to Cobertura Converter

Link: https://github.com/danielpalme/OpenCoverToCoberturaConverter

An Open Source tool written by [Daniel Palme](https://github.com/danielpalme) to convert OpenCover code coverage reports to Cobertura, a coverage report supported by Azure DevOps. See more [here](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/test/publish-code-coverage-results?view=vsts).

### Report Generator

Link: https://github.com/danielpalme/ReportGenerator

[Daniel Palme]() also wrote a tool to convert XML Code Coverage reports into human readable reports in various formats.

## Flow

Basically, this extension performs the following tasks, in order:

* Run tSQLt using SQLCover;
* Exports the test results using TSQL Script;
* Save Stored Procedures source files for generating the Code Coverage report;
* Converts the Open Cover XML report into human readable report using Report Generator;