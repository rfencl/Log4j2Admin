<%@ page language="java" contentType="text/html;charset=UTF-8"%>
<%@ page import="org.apache.logging.log4j.Level"%>
<%@ page import="org.apache.logging.log4j.LogManager"%>
<%@ page import="org.apache.logging..log4j.Logger"%>
<%@ page import="org.apache.logging.log4j.core.LoggerContext"%>
<%@ page import="org.apache.logging.log4j.core.config.LoggerConfig
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.List"%> 
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.util.Arrays"%>
<%@ page import="java.io.*"%>
<%@ page import="com.metavante.OFXRedirector.utils.StringUtilityBean" %>
<%@ page import="com.metavante.OFXRedirector.utils.ConfigUtil" %>
<%@ page import="com.metavante.OFXRedirector.tools.PropertyFileReader" %>
<html>
<head>
<title>Log Level Configuration</title>
<style type="text/css">
<!--
NOTE: THIS IS THE ORIGINAL LOG4J version of the configuration, I am still porting over the 
filter logic. 
-->
<!--
#content {
    margin: 0px;
    padding: 0px;
    text-align: center;
    background-color: darkseagreen;
    border: 1px solid grey;
    width: 100%;
}

body {
    position: relative;
    margin: 10px;
    padding: 0px;
    color: #333;
}

h1 {
    margin-top: 20px;
    font: 1.5em Verdana, Arial, Helvetica sans-serif;
}

h2 {
    margin-top: 10px;
    font: 0.75em Verdana, Arial, Helvetica sans-serif;
    text-align: left;
}

a,a:link,a:visited,a:active {
    color: blue;
    text-decoration: none;
    text-transform: uppercase;
}

table {
    width: 100%;
    background-color: #000;
    padding: 3px;
    border: 0px;
}

th {
    font-size: 0.75em;
    background-color: #eee;
    color: #000;
    padding-left: 5px;
    text-align: center;
    border: 1px solid #eee;
    white-space: nowrap;
}

td {
    font-size: 0.75em;
    background-color: #fff;
    white-space: nowrap;
}

td.center {
    font-size: 0.75em;
    background-color: #fff;
    text-align: center;
    white-space: nowrap;
}

.filterForm {
    font-size: 0.9em;
    background-color: #000;
    color: #fff;
    padding-left: 5px;
    text-align: left;
    border: 1px solid #000;
    white-space: nowrap;
}

.filterText {
    font-size: 0.75em;
    background-color: #ccc;
    color: #000;
    text-align: left;
    border: 1px solid #ccc;
    white-space: nowrap;
}

.filterButton {
    font-size: 0.75em;
    background-color: brown;
    color: white;
    padding-left: 5px;
    padding-right: 5px;
    text-align: center;
    border: 1px solid #ccc;
    width: 100px;
    white-space: nowrap;
}
–>
</style>
<script type="text/javascript">
   function submitForm(form) 
   {  
      document.logFilterForm.restoreDefaults.value='Reset';
      document.logFilterForm.submit();
   }
</script>
</head>
<body onLoad='javascript:document.logFilterForm.logNameFilter.focus();'>
    <%!
        List<String> defaults = new ArrayList<String>();
        boolean isDebug = false;  
        String[] keys;
        /**
          *  Returns true if this is the first time the jsp is invoked.
          *  Also, if the variable isDebug is true then this method will write the parameters to the console.   
          */
        public boolean isFirstCalltoPage(final HttpServletRequest request) {
            List<String>pkeys = new ArrayList<String>(request.getParameterMap().keySet());	 
            if (isDebug) {      
	            System.out.println("Begin Parameter Dump ****************");
		        StringBuilder sb = new StringBuilder();
		        sb.append("\n");
		        for (String s : pkeys) {
		           sb.append(s + "=" + Arrays.asList(request.getParameter(s))).append("\n");
		        }
		        System.out.println(sb.toString());
		        System.out.println("End Parameter Dump ****************");
		        System.out.println("Defaults="+defaults);
	        }
	        return pkeys.isEmpty() && defaults.isEmpty();
        }
       public String validateLogNameFilter(final String [] keys, final String filter ) {
           if (null == keys || null == filter) { return ""; }
           for (String s : keys) {
             if (s.contains(filter)) { return filter; }
           }
           return "";
       }
    %>

    <%
        String[] logLevels = { "trace", "debug", "info", "warn", "error", "fatal", "off" };
        String targetOperation = (String) request.getParameter("operation");
        String targetLogger = (String) request.getParameter("logger");
        String targetLogLevel = (String) request.getParameter("newLogLevel");
        String logLevelAction = (String) request.getParameter("logLevelAction");
        String selectedLevel = (String) request.getParameter("levelselect");
        String restore = (String) request.getParameter("restoreDefaults");
        boolean isSaveDefaultLevels = isFirstCalltoPage(request);
        String secretWordKey = "KEY";
        String  secretWord = ConfigUtil.getValidInput("JspKeyValue", request.getParameter(secretWordKey), "JSPKEYVALUE", 15, false, "The key value is invalid.");
        boolean isAuthorized =  StringUtilityBean.getSHA512String(secretWord).equalsIgnoreCase(PropertyFileReader.getPropertiesFromFile(new File("/cspsrc/common/OFXDirectConnect/ProxyConfig.properties")).getProperty("authentication.string"));

    %>
    <% if (isAuthorized) { %>
    <div id="content">
        <h1>Log Level Configuration</h1>

        <div>
            <form action="log4jconfig.jsp?<%=secretWordKey%>=<%=secretWord%>" name="logFilterForm">
                Filter Loggers:&nbsp;&nbsp; 
                <input name ="restoreDefaults" type="hidden" value=""/> 
                 <input name="<%=secretWordKey%>" type="hidden" value="<%=secretWord%>"/>
                <input name="logNameFilter" type="text"  size="50" value="<%=(logNameFilter == null ? "" : logNameFilter)%>" class="filterText" title="Display loggers that contain the filter, blank this field to display all loggers." /> 
                <input name="logNameFilterButton" type="submit" value="Filter" class="filterButton" title="Apply the filter to the list." /> &nbsp; 
                <select name="levelselect" title="Loglevel to apply to all visible loggers. Used with SetAll.">
                  <%    
                        for (int i = 0; i < logLevels.length; i++) {
                  %>
                          <option  value="<%=logLevels[i]%>" <%=0==i?"selected":""%>><%=logLevels[i]%></option>
                  <%
                        }
                  %>     
                </select>
                <input name="logLevelAction" type="submit" value="SetAll" class="filterButton" title="Apply global logLevel to all loggers in the current form."/> &nbsp; 
                <input name="restoreDefault" type="button" value="Reset" class="filterButton" title="Restore the original settings." onclick="javascript:document.logFilterForm.logNameFilter.value='';submitForm()"/> &nbsp;
            </form>
        </div>

        <table cellspacing='1'>
            <tr>
                <th width='25%'>Logger</th>
                <th width='25%'>Parent Logger</th>
                <th width='15%'>Current Level</th>
                <th width='35%'>Change Log Level To</th>
            </tr>

            <%
                @SuppressWarnings("unchecked")
                Enumeration<Logger> loggers = LogManager.getCurrentLoggers();
                Map<String, Logger> loggersMap = new HashMap<String, Logger>(128);
                Logger rootLogger = LogManager.getRootLogger();

                if (null == logNameFilter || logNameFilter.isEmpty() && !loggersMap.containsKey(rootLogger.getName())) {
                    loggersMap.put(rootLogger.getName(), rootLogger);
                }

                while (loggers.hasMoreElements()) {
                    Logger logger = (Logger) loggers.nextElement();

                    if (logNameFilter == null || logNameFilter.trim().length() == 0) {
                        loggersMap.put(logger.getName(), logger);
                    } else {
                        if (logger.getName().toUpperCase()
                                .indexOf(logNameFilter.toUpperCase()) >= 0) {
                            loggersMap.put(logger.getName(), logger);
                        }
                    }
                }
                Set<String> loggerKeys = loggersMap.keySet();

                keys = (String[]) loggerKeys.toArray(new String[loggerKeys.size()]);

                Arrays.sort(keys, String.CASE_INSENSITIVE_ORDER);
                for (int j = 0; j < keys.length; j++) {
                    Logger logger = (Logger) loggersMap.get(keys[j]);
                    if ("changeLogLevel".equals(targetOperation)
                            && targetLogger.equals(logger.getName())) {
                        Logger selectedLogger = (Logger) loggersMap.get(targetLogger);
                        selectedLogger.setLevel(Level.toLevel(targetLogLevel));
                    }
                    else if("SetAll".equals(logLevelAction)) {
                        logger.setLevel(Level.toLevel(selectedLevel));
                    }
                    else if(isSaveDefaultLevels) {
                      defaults.add(String.valueOf(logger.getEffectiveLevel()));
                    }
                    else if("Reset".equals(restore)) {
                      logger.setLevel(Level.toLevel(defaults.get(j)));
                    }

                    String loggerName = null;
                    String loggerEffectiveLevel = null;
                    String loggerParent = null;
                    if (logger != null) {
                        loggerName = logger.getName();
                        loggerEffectiveLevel = String.valueOf(logger.getEffectiveLevel());
                        loggerParent = (logger.getParent() == null ? null : logger.getParent().getName());
                    }
            %>
            <tr>
                <td><%=loggerName%></td>
                <td><%=loggerParent%></td>
                <td><%=loggerEffectiveLevel%></td>
                <td>
                    <%
                        for (int cnt = 0; cnt < logLevels.length; cnt++) {
                                String url = "log4jconfig.jsp?"
                                        + secretWordKey
                                        + "="
                                        + secretWord
                                        + "&operation=changeLogLevel&logger="
                                        + loggerName
                                        + "&newLogLevel="
                                        + logLevels[cnt]
                                        + "&logNameFilter="
                                        + (logNameFilter != null ? logNameFilter : "");

                                if (logger.getLevel() == Level.toLevel(logLevels[cnt])
                                        || logger.getEffectiveLevel() == Level.toLevel(logLevels[cnt])) {
                    %> [<%=logLevels[cnt].toUpperCase()%>] <%
                        } else {
                    %> <a href=<%=url%>>[<%=logLevels[cnt]%>]</a>&nbsp; <%
                        }
                      } // end for loglevels 
                   %>
                </td>
            </tr><%
                    } // end for keys
                    if ("SetAll".equals(logLevelAction)) { logLevelAction = ""; }
                  %>
        </table>
    </div>
       <%} else {  %>
        <div id="content">
         <h1>Not Authorized</h1>
         </div>
      <%} %>
</body>
</html>