<%@ page pageEncoding="UTF-8" language="java" contentType="text/html;charset=UTF-8" %>
<%@ page import="org.apache.logging.log4j.LogManager, 
                org.apache.logging.log4j.Level, 
                org.apache.logging.log4j.core.LoggerContext, 
                org.apache.logging.log4j.core.config.LoggerConfig, 
                java.util.Arrays,
                java.util.List,
                java.util.ArrayList,
                java.util.HashMap,
                java.util.Map" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<% long beginPageLoadTime=System.currentTimeMillis();%>
<%@ page isELIgnored="false" %>
<!--
THE REASON THIS UTILITY WAS WRITTEN USING SCRIPLET AND NOT TAGS OR UTILS
WAS EASE OF INSTALLATION AND CONFIGURATION WAS THE HIGHEST PRIORITY ALONG
WITH THE LEAST NUMBER OF DEPENDANCIES.  THE ONLY THING THIS ADMIN UTILITY
REQUIRES IS A JSP ENGINE AND LOG4J.  NO CONFIGURATION IS REQUIRED EXCEPT
DROPPING IN THE JSP PAGE AND INVOKING IT THROUGH A STANDARD WEB BROWSER.

Originally written by Mike Amend, BEA Systems.
Adapted 
    -->
    <%!
        Map<String, String> defaults = new HashMap<String, String>();
        String[] keys;
        List<String> pkeys = new ArrayList<String>();
        
        public boolean isFirstCalltoPage(final HttpServletRequest request) {
                pkeys.clear();
                pkeys.addAll(request.getParameterMap().keySet());
                return pkeys.isEmpty() && defaults.isEmpty();
        }

       %>
    
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
                        String lognameFilter=(String)request.getParameter("logNameFilter");
                        String logLevelAction = (String) request.getParameter("logLevelAction");
                        String selectedLevel = (String) request.getParameter("levelselect");
                        String restore = (String) request.getParameter("restoreDefaults");                        
                        boolean isSaveDefaultLevels = isFirstCalltoPage(request);
                        %>
                          <%-- This is how to write to the javascript console --%>
                          <script> console.log(<%=isSaveDefaultLevels%>) </script>
                        <%
                        LoggerContext logContext=(LoggerContext) LogManager.getContext(false); 
                        Map<String, LoggerConfig> map  = logContext.getConfiguration().getLoggers();
                        if ("root".equals(targetLogger)) { targetLogger=""; }
                        for (LoggerConfig logger : map.values()) {
                            if("changeLogLevel".equals(targetOperation) && targetLogger.equals(logger.getName()))
                            {
                                logger.setLevel(Level.getLevel(targetLogLevel.toUpperCase()));
                                logContext.updateLoggers();
                            } 
                            else if("SetAll".equals(logLevelAction)) {
                                logger.setLevel(Level.toLevel(selectedLevel));
                            }
                            else if(isSaveDefaultLevels) {
                                defaults.put(logger.getName(), String.valueOf(logger.getLevel()));
                            }
                        
                            else if("Reset".equals(restore)) {
                                logger.setLevel(Level.toLevel(defaults.get(logger)));
                            }
                        }  // end for loggerConfig

                        %>
                        <div id="content">
                            <h1>
                                Log4J2 Administration - <%=request.getServerName()%> (<%=request.getLocalName()%>)
                            </h1>
                            <div>
                                <form action="log4j2Admin.jsp" name="logFilterForm">
                                    Filter Loggers:&nbsp;&nbsp; 
                                    <input name ="restoreDefaults" type="hidden" value=""/> 
                                    <input name="logNameFilter" type="text"  size="50" value="<%=((lognameFilter == null) ? "" : lognameFilter)%>" class="filterText" title="Display loggers that contain the filter, blank this field to display all loggers." /> 
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
            LoggerConfig logger = map.get(loggerName);
            if (loggerName.length()==0) { loggerName="root"; }
        %>
            <%-- <tr>
            <td><%=lognameFilter%></td>
            </tr> --%>
        <%
            /*lognameFilter = null;*/
            if ("SetAll".equals(logLevelAction) || "Reset".equals(restore) || null == lognameFilter || lognameFilter.equals("null") || (lognameFilter.length()!=0 && loggerName.contains(lognameFilter))) {
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
                        //args.append("&template=templates/blanktemplate.jsp");

                        if(logger.getLevel() == Level.getLevel(logLevels[cnt].toUpperCase()) )
                        {
        %>
                          [<%=logLevels[cnt].toUpperCase()%>]
        <%
                        } else {
        %>
                          <a href='log4j2Admin.jsp?<%=args.toString()%>'>[<%=logLevels[cnt]%>]</a>&nbsp;
        <%
                        }
                    }
        %>
            </td>
            </tr>
       <%
           } // end if filter
        } // end for keys
          if ("SetAll".equals(logLevelAction)) { logLevelAction = ""; }
        %>              

            </table>

    <h2>            Page Load Time (Millis): <%=(System.currentTimeMillis() - beginPageLoadTime)%>          </h2>
        <h2>            Parameters: 
              <%
                     for (String key : pkeys) {
              %>
                   [<%=(key.toString())%>&nbsp;=
                   <%=((String) request.getParameter(key)).toString() %>]
              <%
                     }
              %>
    
      </h2>

                        </div>
                </body>
                </html>