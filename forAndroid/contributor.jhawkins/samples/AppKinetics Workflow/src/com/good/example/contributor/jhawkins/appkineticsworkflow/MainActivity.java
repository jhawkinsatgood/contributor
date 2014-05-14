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

package com.good.example.contributor.jhawkins.appkineticsworkflow;

import java.util.Map;

import android.os.Bundle;
import android.util.Log;
import android.webkit.WebView;

import android.app.Activity;

import com.good.example.contributor.jhawkins.demo.DemoConsumeSendEmail;
import com.good.example.contributor.jhawkins.demo.DemoConsumeTransferFile;
import com.good.example.contributor.jhawkins.demo.DemoProvideTransferFile;
import com.good.example.contributor.jhawkins.demo.MainPage;
import com.good.gd.GDAndroid;
import com.good.gd.GDStateListener;
import com.good.gd.GDUIColorTheme;


/* MainActivity - the entry point activity which will start authorization with Good Dynamics
 * and once done launch the application UI.
 */
public class MainActivity extends Activity implements GDStateListener {

	private static final String TAG = MainActivity.class.getSimpleName();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		setContentView(R.layout.activity_main);
        WebView webView = (WebView) findViewById(R.id.webView);
        String page = "<html><head></head><body><p>MainActivity onCreate</p></body></html>";
        webView.loadData(page, "text/html", null);

        GDAndroid.getInstance().configureUI(
                getResources().getDrawable(R.drawable.workflowlogo_xcf),
                GDUIColorTheme.GDUIWhiteTheme);
		GDAndroid.getInstance().activityInit(this);
	}

	/*
	 * Activity specific implementation of GDStateListener. 
	 * 
	 * If a singleton event Listener is set by the application (as it is in this case) then setting 
	 * Activity specific implementations of GDStateListener is optional   
	 */
	@Override
	public void onAuthorized() {
		//If Activity specific GDStateListener is set then its onAuthorized( ) method is called when 
		//the activity is started if the App is already authorized 
		Log.i(TAG, "onAuthorized()");

		WebView webView = (WebView) findViewById(R.id.webView);
        MainPage mainPage = MainPage.getInstance();
        if (mainPage.loaded()) {
            mainPage.setWebView(webView);
        }
        else {
            mainPage.setWebView(webView).setBackgroundColour("DarkSeaGreen")
            .setTitle( getResources().getString(R.string.app_name) )
            .setInformation(
                    GDAndroid.getVersion() + " " + 
                    GDAndroid.getInstance().getApplicationId())
            .addDemoClasses(
                    DemoConsumeSendEmail.class,
                    DemoConsumeTransferFile.class,
                    DemoProvideTransferFile.class)
            .load();
        }
	}

	@Override
	public void onLocked() {
		Log.i(TAG, "onLocked()");
	}

	@Override
	public void onWiped() {
		Log.i(TAG, "onWiped()");
	}

	@Override
	public void onUpdateConfig(Map<String, Object> settings) {
		Log.i(TAG, "onUpdateConfig()");
	}

	@Override
	public void onUpdatePolicy(Map<String, Object> policyValues) {
		Log.i(TAG, "onUpdatePolicy()");
	}

	@Override
	public void onUpdateServices() {
		Log.i(TAG, "onUpdateServices()");
	}
}
