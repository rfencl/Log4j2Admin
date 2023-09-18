# Log4j2Admin
This is a simple utility for accessing Log4j2 loggers and changing the log levels with a browser.
The utility is written using jsp scriptlets and just needs to be placed in the root folder of your expanded web application.
No configuration is required.

The loggers defined in log4j2.xml are loaded by the LogManager, this tool manipulates the LogManager directly.
Use the filter input and button to display a subset of the loggers and then set the log level on all of them using the setAll button.
Reset will restore the log levels as originally loaded.

Debug logging for this page is written to the javascript console.


