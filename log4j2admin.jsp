<%@ page pageEncoding="UTF-8" language="java" contentType="text/html;charset=UTF-8" %>
    <%@ page import="org.apache.logging.log4j.LogManager, org.apache.logging.log4j.Level,
org.apache.logging.log4j.core.LoggerContext   , org.apache.logging.log4j.core.config.LoggerConfig,
                 java.util.Map" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

            <% long beginPageLoadTime=System.currentTimeMillis();%>

<!--
NOTE: THIS UTILITY WAS WRITTEN USING SCRIPLETS WITHOUT TAGS.
RAW JSP ALLOWS FOR EASE OF INSTALLATION WITH THE LEAST NUMBER OF DEPENDANCIES.  
THE ONLY THING THIS ADMIN UTILITY REQUIRES IS A JSP ENGINE AND LOG4J.  
NO CONFIGURATION IS REQUIRED EXCEPT DROPPING IN THE JSP PAGE 
AND INVOKING IT THROUGH A STANDARD WEB BROWSER. FOR TOMCAT DROP THIS INTO 
THE ROOT OF EXPLODED APP FOLDER.

Originally written by Mike Amend, BEA Systems.
Adapted for Log4j2 by Henning Spjelkavik
Extended for production use by Rick Fencl

-->

                <html>

                <head>
                    <title>Log4J2 Administration</title>
                    <style type="text/css">
                        #content {
                            margin: 0px;
                            padding: 0px;
                            text-align: center;
                            background-color: darkseagreen;
                            border: 1px solid grey;
                            width: 100%;
                            z-index: 10000;
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

                        a,
                        a:link,
                        a:visited,
                        a:active {
                            color: lightcoral;
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
                            background-color: #ccc;
                            color: #000;
                            padding-left: 5px;
                            text-align: center;
                            border: 1px solid #ccc;
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
                    </style>
                    <script type="text/javascript">
                        function submitForm(form) 
                        {  
                           document.logFilterForm.restoreDefaults.value='Reset';
                           document.logFilterForm.submit();
                        }
                     </script>
                     </head>
                </head>

                <body onLoad='javascript:document.logFilterForm.logNameFilter.focus();'>
                    <% 
                        String[] logLevels={ "debug" , "info" , "warn" , "error" , "fatal" , "off" }; 
                        String targetOperation=(String)request.getParameter("operation"); String
                        targetLogger=(String)request.getParameter("logger"); 
                        String targetLogLevel=(String)request.getParameter("newLogLevel"); 
                        String logNameFilter="";
                        LoggerContext logContext=(LoggerContext) LogManager .getContext(false); 
                        Map<String, LoggerConfig> map = logContext.getConfiguration().getLoggers();

                        if ("root".equals(targetLogger)) { targetLogger=""; }

                        for (LoggerConfig logger : map.values()) {
                            if("changeLogLevel".equals(targetOperation) && targetLogger.equals(logger.getName()))
                            {
                            logger.setLevel(Level.getLevel(targetLogLevel.toUpperCase()));
                            logContext.updateLoggers();
                            }
                        }

                        %>
                        <div id="content">
                            <h1>
                                Log4J2 Administration - <%=request.getServerName()%> (<%=request.getLocalName()%>)
                            </h1>
                            <div>
                                <form action="log4j2Admin.jsp" name="logFilterForm">
                                    Filter Loggers:&nbsp;&nbsp; 
                                    <input name ="restoreDefaults" type="hidden" value=""/> 
                                    <input name="logNameFilter" type="text"  size="50" value="<%=((logNameFilter == null) ? "" : logNameFilter)%>" class="filterText" title="Display loggers that contain the filter, blank this field to display all loggers." /> 
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
                    
                            <table cellspacing="1">
                                <tr>
                                    <th width="25%">Logger</th>
                                    <th width="25%">Parent Logger</th>
                                    <th width="15%">Effective Level</th>
                                    <th width="35%">Change Log Level To</th>
                                </tr>


     <% for(String k : map.keySet()) {%>
        <%
            String loggerName = k;
            LoggerConfig logger = map.get(k);
            if (k.length()==0) { loggerName="root"; }
        %>
        <tr>
            <td><%= loggerName %></td>
            <td><%= map.get(k).getParent() %></td>
            <td><%= map.get(k).getLevel() %></td>
            <td>
                <%
                    for(int cnt=0; cnt<logLevels.length; cnt++)
                    {
                        StringBuffer args = new StringBuffer();
                        args.append("operation=changeLogLevel&logger=" + loggerName);
                        args.append("&newLogLevel=" + logLevels[cnt]);
                        args.append("&template=templates/blanktemplate.jsp");

                        if(logger.getLevel() == Level.getLevel(logLevels[cnt].toUpperCase()) )
                        {
                %>
                [<%=logLevels[cnt].toUpperCase()%>]
                <%
                }                  else                  {
                %>

                <a href='log4j2Admin.jsp?<%=args.toString()%>'>[<%=logLevels[cnt]%>]</a>&nbsp;
                <%
                        }
                    }
                %>
            </td>


        </tr>
        <%}%>


    </table>

    <h2>            Page Load Time (Millis): <%=(System.currentTimeMillis() - beginPageLoadTime)%>          </h2>

</div>
</body>
</html>