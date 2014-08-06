/* Copyright (c) 2014 Good Technology Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.good.example.contributor.jhawkins.demo;

import java.util.ArrayList;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.text.TextUtils;
import android.webkit.WebView;

import com.good.example.contributor.jhawkins.demoframework.Component;
import com.good.example.contributor.jhawkins.demoframework.UserInterface;

public class MainPage implements UserInterface {
    // MainPage is a singleton class
    private static MainPage _instance = null;
    private MainPage() {}
    public static MainPage getInstance() {
        if (null == _instance) {
            _instance = new MainPage();
        }
        return _instance;
    }

    // Properties
    private WebView webView = null;
    private Activity activity = null;
    private String backgroundColour = "LightYellow";
    private String title = "Main Page";
    private String information = null;
    private String results = null;
    private String editData = null;
    private String[] pickList = null;
    private int pickFor = -1;
    private Boolean hasLoaded = false;

    private Component save = null;
    
    private ArrayList<Component> demos = null;
    
    // Constant values
    private final String jsObjectName = "mainPage";

    public void demoLog( String newResults )
    {
        if (newResults == null) {
            results = null;
        }
        else {
            results = new StringBuilder(results == null ? "" : results)
            .append(newResults).toString();
        }
        reloadHTML();
    }
    
    public void demoEdit(String content, Component saver)
    {
        save = saver;
        this.showEditData(content);
    }
    
    public MainPage addDemoClasses(Class<?> ... components)
    {
        if (demos == null) demos = new ArrayList<Component>(components.length);
        for(Class<?> component : components) {
            Component componenti;
            try {
                componenti = (Component)component.newInstance();
                demos.add( componenti.setUserInterface(this) );
            } catch (InstantiationException e) {
                throw new Error("Failed to instantiate: " + e.getMessage());
            } catch (IllegalAccessException e) {
                throw new Error("Failed to access legally: " + e.getMessage());
            }
        }
        return this;
    }
    
    @SuppressLint("SetJavaScriptEnabled")
    public MainPage setWebView(WebView webView)
    {
    	if (this.webView != webView) {
    		this.webView = webView;
    		if (this.webView != null) {
    			this.webView.addJavascriptInterface( new JsObject(this), jsObjectName );
    			this.webView.getSettings().setJavaScriptEnabled(true);
    		}
    	}
		reloadHTML();
        return this;
    }
    
    public MainPage setActivity(Activity activity)
    {
    	this.activity = activity;
		reloadHTML();
    	return this;
    }
    
    public MainPage setBackgroundColour( String backgroundColour )
    {
        this.backgroundColour = backgroundColour;
        reloadHTML();
        return this;
    }
    
    public MainPage setTitle( String title )
    {
        this.title = title;
        reloadHTML();
        return this;
    }

    public MainPage setInformation(String information) {
        this.information = information;
        reloadHTML();
        return this;
    }

    public MainPage load()
    {
        if (demos != null && !hasLoaded) for(Component demo: demos) {
            // If this is a passive demo, start it now
            if (!demo.getDemoIsActive()) demo.demoExecute();
        }
        hasLoaded = true;
        reloadHTML();
        return this;
    }
    
    public Boolean loaded()
    {
        return hasLoaded;
    }
    
    public MainPage showEditData( String editData )
    {
        this.editData = editData;
        reloadHTML();
        return this;
    }
    
    private String handleCommand( String command, String parameter )
    {
        if (command.equals("CLEAR")) {
            demoLog(null);
        }
        else if (command.equals("execute")) {
            int parameter_int = Integer.valueOf(parameter);
            Component demoi = demos.get(parameter_int);
            if (demoi.getDemoNeedsPick()) {
                pickList = demoi.demoGetPickList();
                if (pickList == null || pickList.length < 1) {
                    demoLog("No providers.");
                }
                else if (pickList.length == 1) {
                    pickList = null;
                    demoi.demoPickAndExecute(0);
                    reloadHTML();
                }
                else {
                    pickFor = parameter_int;
                    demoLog("Providers: " + pickList.length);
                }
            }
            else {
                demoi.demoExecute();
                reloadHTML();
            }
        }
        else if (command.equals("save")) {
            if (save == null) {
                demoLog("save command when save is null.\n");
            }
            else {
                if (save.demoSave(parameter)) {
                    // Save OK; delete from here.
                    showEditData(null);
                }
                else {
                    // Save failed; keep the content here
                    showEditData(parameter);
                }
            }
        }
        else if (command.equals("discard")) {
            if (save == null) {
                demoLog("discard command when save is null.\n");
            }
            else {
                save.demoSave(null);
                showEditData(null);
            }
        }
        else if (command.equals("pick")) {
            Component demoi = demos.get(pickFor);
            pickList = null;
            pickFor = -1;
            demoi.demoPickAndExecute(Integer.valueOf(parameter));
            reloadHTML();
        }
        else {
            demoLog("handleCommand(" + command + "," + parameter + ")\n");
        }
        return "handleCommand(" + command + ")";
    }

    // JSObject class
    // This is embedded in the web page.
    class JsObject {
        private MainPage mainPage = null;

        // Constructor
        public JsObject(MainPage myPage) {
            mainPage = myPage;
        }

        // Interface method called from the JS layer.
        public String command(String command, String parameter) {
            return mainPage.handleCommand(command, parameter);
        }
    }
    
    static final String HTMLnlSources[] = {      "\r\n",   "\n"     };
    static final String HTMLnlDestinations[] = { "<br />", "<br />" };
    static String HTMLreplace(String str, Boolean newlines)
    {
        String ret = TextUtils.htmlEncode(str);
        // It seems that TextUtils.replace only replaces the first occurrence of
        // each string in the map. So we replace in a loop until nothing 
        // changes.
        if (newlines) for(;;) {
            String retnl = TextUtils.replace(ret, 
                    HTMLnlSources, HTMLnlDestinations).toString();
            if (retnl.equals(ret)) break;
            ret = retnl;
        }
        return ret;
    }

    private String _commandHTML( String command, String label, String value ) {
        return "<span class=\"command\" onclick=\"" + jsObjectName + 
                ".command('" + command + "'," + value +
                ");\">" + label + "</span>";
    }
    private String commandHTML( String command, String label, String value ) {
        return _commandHTML(
                command, label, 
                "document.getElementById('" + value + "').value" );
    }
    private String commandHTML( String command, String label, int value ) {
        return _commandHTML(command, label, "" + value);
    }
    private String commandHTML( String command, String label) {
        return _commandHTML(command, label, "null");
    }

    // Class for scheduling the WebView load on the UI thread.
    private class RunReloadHTML implements Runnable {
    	String html = null;
    	WebView webView = null;
    	
    	public RunReloadHTML(String html, WebView webView) {
    		this.html = html;
    		this.webView = webView;
    	}

		@Override
		public void run() {
	        this.webView.loadDataWithBaseURL( "mainpage.html", this.html,
            "text/html", null, "mainpage.html");
		}
    }

    private void reloadHTML()
    {
        if (webView == null || activity == null || !hasLoaded) return;
        
        StringBuilder pageHTML = new StringBuilder( "<html><head>" +
                "<style>" +
                "  body {" +
                "    font-family: sans-serif; " +
                "    background-color: " + backgroundColour + ";" +
                "  }" +
                "  div {" +
                "      margin-top: 6pt;" +
                "      margin-bottom: 6pt;" +
                "      color: black;" +
                "  }" +
                "  .holder {" +
                "      margin-top: 12pt;" +
                "  }" +
                "  div.picker {" +
                "      margin-top: 12pt;" +
                "      border-top: solid 1pt black;" +
                "  }" +
                "  div.picker div {" +
                "      border-bottom: solid 1pt black;" +
                "      padding-bottom: 8pt;" +
                "  }" +
                "  h1 {margin-top: 20pt; font-size: 24pt;}" +
                "  .command {" +
                "      text-decoration: none;" +
                "      border: 1pt solid black;" +
                "      padding: 4pt;" +
                "      margin-right: 4pt;" +
                "  }" +
                "  .information {" +
                "      font-size: 8pt;" +
                "  }" +
                "  pre {" +
                "      border: 1pt dashed black;" +
                "      white-space: pre-wrap;" +
                "  }" +
                "</style>" +
                "<script type=\"text/javascript\" >" +
                "var " + jsObjectName + ";" +
                "</script>" +
                "</head><body>" +
                "<h1>" + title + "</h1>");
        if (information != null) {
            pageHTML.append(
                "<div class=\"information\">" + information + "</div>");
        }
        if (results != null) {
            pageHTML.append(
                    "<div class=\"holder\"><pre>" + 
                    HTMLreplace(results, true) + "</pre><div>" + 
                    commandHTML("CLEAR", "&lt; Clear") + "</div></div>");
        }
        
        if (pickList != null) {
            pageHTML.append("<div class=\"picker\">"); 
            for(int i=0; i<pickList.length; i++) {
                pageHTML.append("<div>" + pickList[i] + " ");
                pageHTML.append(commandHTML( "pick", "Go &gt;", i));
                pageHTML.append("</div>"); 
            }
            pageHTML.append("</div>"); 
        }

        if (editData != null) {
            String ctrlname = "savearea";
            pageHTML.append(
                    "\n<div class=\"holder\"><textarea name=\"" + 
                            ctrlname + "\" id=\"" + ctrlname + "\">" + 
                    HTMLreplace(editData, false) + "</textarea></div><div>" + 
                    commandHTML("discard", "&lt; Discard") +
                    commandHTML("save", "Save &gt;", ctrlname) + "</div>");
        }
        
        for (int i=0; i<demos.size(); i++) {
            Component demoi = demos.get(i);
            if (pickFor != i && demoi.getDemoIsActive()) {
                pageHTML.append(
                    "<div class=\"holder\">" + 
                    commandHTML("execute", demoi.getDemoLabel() + " &gt;", i) + 
                    "</div>");
            }
        }

        pageHTML.append("</body></html>");

        // Run the loadData on the UI thread.
        this.activity.runOnUiThread( new RunReloadHTML(pageHTML.toString(), this.webView) );
    }
}
