Este.js - The evolutionary JavaScript Framework and Dev Stack
-------------------------------------------------------

  - statically compiled CoffeeScript
  - Google Closure Tools
  - Mocha tests
  - Stylus styles
  - Dev Node.js server
  - Este.js framework
    - a lot of classes
    - MVC mobile first framework
  - settings and snippets for Sublime Text
  - run.coffee

With Este.js, just run one script to automatically update deps.js, run all your Mocha unit tests, and compile CoffeeScript, Stylus, and Soy templates. LiveReload supported.

Tested on and compatible for OSX, Linux, and Windows.

The bulk of the application is a well-documented, thoroughly tested JavaScript framework,
written in statically-typed CoffeeScript. This allows you to write powerful and efficient code for mobile devices and browsers.

Consider it boilerplate for mobile first development, an offline capable MVC web application, streamlined for the developer user experience.

### Quick Start Guide

  - Install Node.js (0.8+)
  - `git clone http://github.com/Steida/este.git`
  - `cd este`
  - `node run app`
  - Point your browser to `localhost:8000`
  - Build something beautiful

#### For Windows Users
  - You have to install Java, Python (Windows for some reason needs version < 3)
  - Then you have to set environment variables for Python and Java
  - http://docs.python.org/using/windows.html#excursus-setting-environment-variables

### More Information

`node run app` options are described in `assets/js/dev/run.coffee`.

The app examples defines structure, feature-based namespacing, template behaviour, custom events, and compilation, all in one compact location.

We're actively working on a mobile version for ShopMVC on this stack, which should give greater
clarity by means of example. In the meantime, take a look at the `assets/js/*` namespaces and
`assets/js/este/demos/` demos.

### Blog

[http://estejs.tumblr.com](http://estejs.tumblr.com)

### Recommended Editor: [Sublime Text](http://www.sublimetext.com)

Must-have Packages

  - Package Control
  - CoffeeScript
  - Stylus
  - SoyTemplate (github.com/anvie/SoyTemplate)

Recommended Packages

  - Open Related (github.com/vojtajina/sublime-OpenRelated)
  - Clipboard History
  - JsFormat
  - LESS

My Sublime Text settings and snippets are [here](https://github.com/Steida/Sublimetext-user-settings).
Code snippets [cheat sheet](http://estejs.tumblr.com/post/29363589575/este-js-sublime-text-code-snippets-cheat-sheet).

## License

(The MIT License)

Copyright (c) 2012 Daniel Steigerwald &lt;daniel@steigerwald.cz&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.