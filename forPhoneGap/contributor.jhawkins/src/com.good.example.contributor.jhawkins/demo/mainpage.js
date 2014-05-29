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

var module;
com.good.example.contributor.jhawkins._package(
    "com.good.example.contributor.jhawkins.demo.mainpage", module,
function (namespace) {
    /* Constructor function */
    function MainPage() { (function(newMainPage) {
        /* Dependencies */
        var Demo = com.good.example.contributor.jhawkins.demo;
        var Utility = Demo.utility;
        var demoPrefix = "demo";

        function isDemo(classname) {
            return (classname.substr(0,demoPrefix.length) == demoPrefix);
        }
        
        function loggerFor(logNode) {
            return function(/* ... */) {
                for (var i=0; i < arguments.length; i++) {
                    message = arguments[i];
                    if (typeof message == "object" && message) {
                        Utility.appendNode('pre',
                            Utility.toJSON(message, null), logNode);
                    }
                    else {
                        Utility.appendNode('div', message, logNode);
                    }
                }
            }
        }

        function load(myNode_specifier) {
            var myNode = myNode_specifier;
            if (typeof myNode_specifier == "string") {
                myNode = document.getElementById(myNode_specifier);
                if (myNode == null) {
                    // ToDo: change to throw new Error()
                    alert(
                        'MainPage.load(): No node with ID "' +
                        myNode_specifier + '"');
                    return this;
                }
            }

            Utility.removeChilds(myNode);
            Utility.insertNode('h1', "AppKinetics Workflow", myNode);

            for (var demoName in Demo) {
                if (!isDemo(demoName)) { continue; }
                
                var childNode = Utility.appendNode(
                    "div", Demo[demoName].demoLabel() + " >", myNode);
                var logNode = Utility.appendNode( "div", null, childNode );
                childNode.addEventListener( "click",
                    (function(myLogNode, demo) { return function() {
                        var logger = loggerFor(myLogNode)
                        Utility.removeChilds(myLogNode);
                        logger("Running demo...");
                        demo.demoExecute(logger);
                    }})(logNode, Demo[demoName]));
            }
        
            return this;
        }
        
        /* Public methods of new object */
        newMainPage.load = load;
    })(this); }

    /* Public methods */
    namespace.MainPage = MainPage;

    return namespace;
});