Function.prototype.bind = function(target) {
  var func = this;
  return function(){ return func.apply(target, arguments); };
};

var Selusuh = function() {
  this.client = new RiakClient();
  this.bucket = new RiakBucket('RiakTalk', this.client);
  return this;
};

Selusuh.prototype.loadDeck = function(loaded) {
  var self = this;

  this.bucket.link({tag:'start'})
    .run(function(flag, results, req) {
        self.bucket.get('show', function(s, o, r) {
          // TODO: figure out how to get all these elements out
          // in a single map reduce job
          self.getNextSlide(loaded, [], o, 'start');
        });
    });
};

Selusuh.prototype.getNextSlide = function(loaded, deck, prevObj, tag) {
  var self = this;

  var findLink = function(obj) {
    for(var i = 0; i < obj.links.length; ++i) {
      if(obj.links[i].tag == tag) return obj.links[i];
    }
    return null;
  }

  var next = findLink(prevObj);

  if(next == null) {
    loaded(deck);
  } else {
    this.bucket.get(next.target.split("/")[3], function(s, o, r) {
        deck.push({key:o.key,body:JSON.parse(o.body)});
        self.getNextSlide(loaded, deck, o, 'next');
     });
  }
};

Selusuh.prototype.fillMenu = function(deck) {
  $("#side-menu").html($("#menu-item-tmpl").tmpl(deck));
};

Selusuh.prototype.applySlide = function(slide) {
  $("#slide-content").html($("#slide-tmpl").tmpl(slide));
};

$(document).ready(function() {
  var selusuh = new Selusuh();
  selusuh.loadDeck(function(deck) {
    console.log(deck);
    selusuh.applySlide(deck[0]);
    selusuh.fillMenu(deck);
  });
});

