Selusuh - A Simple Slide Deck app for Riak
==========================================
**Selusuh** (Indonesian for *Slide*) is a simple structure and a set of scripts which allows for generation of a slide deck that can be served directly out of a [Riak][] cluster. I stole the idea from [Sean Cribbs][] who recently did a presentation which was hosted in Riak, but decided to take it a step further.

Current Status
--------------
This appliation currently contains the slide deck (and demo scripts) that I used for a Riak presentation to the Brisbane [ALT.NET][] group on [11th May 2011][AltNetEvent]. I left it like this so that people can see how the application is structured. It should be easy to modify it to suit your own needs or your own content.

It should be enough to get you going if you want to do something similar. Other than the custom content, it's "good enough" to be used by other people as a starting point.

Note that some of the things that I do with this application might not be considered the best option when dealing with Riak. It's just serving as an example of what can be done.

How does it work?
-----------------
The entire application is served out of a single Riak bucket. When the application is deployed using the provided scripts, the slide deck is linked together, in order, using Riak's [link][RiakLinks] feature.

When the application is loaded, the "root" document (ie the `index.html` file which gets put in the bucket under the key `show`) is examined and the link to the first slide in the deck is loaded. From here, the entire list of slides is loaded one by one and the right-hand slide list is populated with the links to each of the slides. When the list has been fully populated, the first slide in the deck is "loaded" and presented on screen.

When a slide is chosen (through clicking 'Next Slide', 'Previous Slide' or one of the slide headers in the slide menu/list) the slide chosen is identified via the link, and the identifier is used to access Riak and pull the content of the slide from the Riak node. When the content of the slide is extracted, jQuery templates are used to render the content of the slide to screen. The code also examines the links and configures the 'Next Slide' and 'Previous Slide' buttons to reference the sibling slides of the new current slide. This means that continually clicking 'Next Slide' will walk you through the whole slide deck sequentially juse like a normal presentation.

The current slide is highlighted in the menu on the right hand side so that the user knows where they are at with respect to the rest of the deck.

Application Structure
---------------------

### 3rd party libs ###

* [jQuery][] - What else would you use?
* [Sammy.js][] - used for REST-style javascripty, linky goodness. Allows the main page to avoid full-postbacks while still having intuitive handling of links (with support for back/forward browser buttons).
* [riak.js][] - The Javascript client for Riak - used to pull data out of Riak.
* [json2][] - JSON handling, allowing us to take content from Riak as JSON data.
* [colorbox][] - Allows nice presentation of images (and other general popups) without having to leave the current slide.
* [jQuery scrollintoview][] - Allows the menu to scroll along with the currently selected slide.

### Selusuh components ###

* An `index.html` file which is the shell of the slide share application. This contains a hacked version of a template generated using [Initializr][] (because my design skills are non-existant), which is a HTML5 doohicky.
* A folder called `slides` which contains:
    * `slide.index` - a raw text file which lists the individual slides that are part of the deck. This is used to indicate the order in which the slides should appear. Each slide should appear on a single line by itself. Reordering your slides is as simple as moving the entry in this file.
    * `*.json` - these are the slides that make up the slide deck (see the folder content for examples). They are json documents which need to have the following fields:
        * `section` - This is the name that goes in the top-most area of the slide alongside the title of the talk (currently hard-coded to 'Riak').
        * `header` - This is the name of the slide, and it appears in the slide list on the right hand side of the page. It is also the main header content when the slide is currently being displayed.
        * `body` - HTML markup that makes it into the content of the slide.
* A folder called `scripts` which contains:
    * `deploy.sh` - Deploys the application to a Riak instance. By default, it will attempt to deploy to `http://127.0.0.1:8091/riak/RiakTalk`. Change the host/port details at the top of the deploy script if these values aren't correct for your deployment (I might add command-line options later for this). The script will output various things including whether or not the Riak node is avialable. After a successful deployment it will present a link which is the entry-point for the slide deck.
    * `update-libs.sh` - A small script which pulls down the latest version of a few of the JS libs that are used as part of the application.
* A folder called `demos` which contains a few scripts which I used for demoing Riak's link walking and map/reduce features.
* All other folders contain content which is uploaded to Riak in the same bucket as the slides (this makes referencing them via a relative URI really easy). Content that is dropped in those folders is automatically included and uploaded when you run the `deploy.sh` script.

Other Notes
-----------

* If you don't have one already, it's really easy to get a Riak cluster running, just take a look at the information on the [Riak Fast-track][].
* The scripts make heavy use of [cURL][], so make sure you have that installed.
* I'm pretty sure this won't work on Windows/Cygwin, but I haven't tried it.
* Works fine in Chrome and Firefox, probably works in IE8+ too, but not confirmed.

Known Issues
------------

* If any of the JSON in the slides is invalid, loading the slide will fail without any error messages. This should be fixed down the track, I just didn't get the chance to do it prior to releasing the code.

Feedback/suggestions
--------------------
I'm always open to feedback and suggestions. If you want to fork and contribute please do, I would love to see what other people can do with this.

Hopefully this will serve at least as an example of how to get a small Riak web application running, if nothing else :)

Cheers!

OJ - [buffered.io][]

  [cURL]: http://curl.haxx.se/
  [Riak]: http://riak.basho.com/
  [Sean Cribbs]: http://twitter.com/seancribbs
  [RiakLinks]: http://wiki.basho.com/Links.html
  [jQuery]: http://jquery.com/
  [Sammy.js]: http://sammyjs.org/
  [riak.js]: https://github.com/basho/riak-javascript-client
  [json2]: http://www.JSON.org/json2.js
  [colorbox]: http://colorpowered.com/colorbox/
  [jQuery scrollintoview]: http://erraticdev.blogspot.com/2011/02/jquery-scroll-into-view-plugin-with.html
  [Initializr]: http://www.google.com.au/url?sa=t&source=web&cd=1&ved=0CCEQFjAA&url=http%3A%2F%2Finitializr.com%2F&ei=WV7LTZrzJpDLrQfp6vCGBA&usg=AFQjCNFqltOdPeOYGPhZUMkPCk_reRrVPg
  [ALT.NET]: http://www.meetup.com/Brisbane-Alt-Net-Group/
  [AltNetEvent]: http://www.meetup.com/Brisbane-Alt-Net-Group/events/17288004/
  [Riak Fast-track]: http://wiki.basho.com/Building-a-Development-Environment.html
  [buffered.io]: http://buffered.io/

