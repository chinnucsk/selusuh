//Function.prototype.bind = function(target) {
//  var func = this;
//  return function(){ return func.apply(target, arguments); };
//};

var Selusuh = function() {
  this.client = new RiakClient();
  this.bucket = new RiakBucket('RiakTalk', this.client);
  return this;
};

Selusuh.prototype.loadDeck = function(itemLoaded, completed) {
  var self = this;

  this.bucket.link({tag:'start'})
    .run(function(flag, results, req) {
        self.bucket.get('show', function(s, o, r) {
          // TODO: figure out how to get all these elements out
          // in a single map reduce job
          self.getNextSlide(itemLoaded, completed, [], o, 'start');
        });
    });
};

Selusuh.prototype.getLinkByTag = function(riakObj, tag) {
  for(var i = 0; i < riakObj.links.length; ++i) {
    if(riakObj.links[i].tag == tag) return riakObj.links[i];
  }
  return null;
};

Selusuh.prototype.getNextSlide = function(loaded, completed, deck, prevObj, tag) {
  var self = this;

  var next = this.getLinkByTag(prevObj, tag);

  if(next == null) {
    if(completed != null) completed(deck);
  } else {
    this.bucket.get(next.target.split("/")[3], function(s, o, r) {
        var content = JSON.parse(o.body);
        var item = {key: o.key, title: content.header};
        deck.push(item);
        loaded(item);
        self.getNextSlide(loaded, completed, deck, o, 'next');
     });
  }
};

Selusuh.prototype.getSlideById = function(slideId, loaded) {
  var self = this;
  this.bucket.get(slideId, function(s, o, r) {
      var key = o.key;
      var next = self.getLinkByTag(o, 'next');
      var prev = self.getLinkByTag(o, 'prev');
      var content = JSON.parse(o.body);

      loaded({key: key,
        content: content,
        prev: prev == null ? '#' : '#/slides/' + prev.target.split("/")[3],
        next: next == null ? '#' : '#/slides/' + next.target.split("/")[3]});
  });
};

Selusuh.prototype.applySlide = function(slide) {
  $("#slide-section").text(slide.content.hasOwnProperty('section')
      && $.trim(slide.content.section).length > 0
        ? " - " + slide.content.section
        : "");

  $("#slide-content").html($("#slide-tmpl").tmpl(slide));

  if(slide.next == '#') {
    $("#next-slide").css('visibility', 'hidden');
  } else {
    $("#next-slide").css('visibility', '');
    $("#next-slide").attr('href', slide.next);
  }

  if(slide.prev == '#') {
    $("#prev-slide").css('visibility', 'hidden');
  } else {
    $("#prev-slide").css('visibility', '');
    $("#prev-slide").attr('href', slide.prev);
  }

  $("#side-menu").find('a.current').removeClass('current');
  var menuItem = $("#side-menu").find('a[data-key="' + slide.key + '"]');
  menuItem.addClass('current');
  menuItem.scrollintoview({duration:'fast'});

  $("#slide-content a[rel='colorbox']").each(function() {
      var props = {
          speed:500,
          maxWidth:"900px",
          maxHeight:"95%",
          scalePhotos:true
      };

      if($(this).attr('href')[0] == '#') {
          props.inline = true;
          props.href = $(this).attr('href');
      }
      $(this).colorbox(props);
  });
};

Selusuh.prototype.fillSideMenu = function(context, redirect, completed) {
  this.loadDeck(function(item) {
    $("#menu-item-tmpl").tmpl(item).appendTo("#side-menu");

    if(redirect && $("#slide-content").html() == "") {
      context.redirect('#', 'slides', item.key);
    }
  }, completed);
};

(function($) {
   var selusuh = new Selusuh();
   var sammyApp = $.sammy("#slide-content", function() {
      this.get('#/slides/:slide', function(context) {
        var slideId = this.params['slide'];

        var apply = function() {
          selusuh.getSlideById(slideId, selusuh.applySlide);
        };

        if($.trim($("#side-menu").text()) != "") {
          apply();
        } else {
          selusuh.fillSideMenu(context, false, apply);
        }
      });

     this.get('#/', function(context) {
        $("#side-menu").html('');
        selusuh.fillSideMenu(context, true, function(deck) {
          selusuh.getSlideById(deck[0].key, selusuh.applySlide);
        });
      });
  });

  $(function() {
    sammyApp.run('#/');
  });
})(jQuery);

