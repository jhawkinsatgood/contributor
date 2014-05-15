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

import com.good.example.contributor.jhawkins.appkinetics.specific.RequestOpenHTTPURL;
import com.good.example.contributor.jhawkins.demoframework.Component;

public class DemoConsumeOpenHTTPURL extends Component {
   private RequestOpenHTTPURL request; 
    
    public DemoConsumeOpenHTTPURL() {
        super();
        request = new RequestOpenHTTPURL();
        demoLabel = "Open HTTP URL";
        demoIsActive = true;
        demoNeedsPick = false;
        // demoNeedsPick is set to false to get around the problem that Good 
        // Access is not properly registered as a service provider.
        // demoNeedsPick false means that demoExecute() gets invoked instead of
        // demoGetPickList() and demoPickAndExecute().
        // demoExecute() sets the provider to the native identifier of Good 
        // Access by hard-coding.
    }

    // This method is invoked when demoNeedsPick is false, see above note.
    @Override
    public void demoExecute()
    {
        request.setURL("http://helpdesk")
        .setApplication("com.good.gdgma.IccReceivingActivity").sendOrMessage();
        // The above returns a message if there is an error in the send. The
        // message is also inserted into the Request object, which is dumped
        // below, so there is no need to log it additionally.
        if (userInterface != null)
            userInterface.demoLog("Sent request with hard-coded provider:" + 
                    request.toString(2) + "\n");
        return;
    }
    
    // Following method isn't invoked when demoNeedsPick is false, see above
    // note.
    @Override
    public String[] demoGetPickList()
    {
        return request.queryProviders().getProviderNames();
    }
    
    // Following method isn't invoked when demoNeedsPick is false, see above
    // note.
    @Override
    public void demoPickAndExecute(int pickListIndex)
    {
        String error = request.setURL("http://helpdesk")
                .selectProvider(pickListIndex).sendOrMessage();
        if (error != null && userInterface != null) 
            userInterface.demoLog(error);
        return;
    }
}