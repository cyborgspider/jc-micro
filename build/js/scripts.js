(function() {
  var $win, app, winHeight, winWidth;

  $win = $(window);

  winHeight = $win.height();

  winWidth = $win.width();

  app = {
    init: function() {
      if (device === 'desktop') {
        $win.resize(function() {
          if ($win.width() === winWidth) {
            return app.sectionSizer();
          }
        });
      }
      if (device === 'mobile') {
        $('html').addClass('mobile');
        $('#video').remove();
      }
      $('html,body').velocity('scroll');
      $('#contact-form')[0].reset();
      if (device === 'desktop') {
        this.sectionSizer();
      }
      this.animateHeroBG();
      this.slideTestimony();
      this.checkTop();
      this.navHandler();
      this.setupContactForm();
      this.contactButtonLoader();
      $('#contact-form').parsley();
      return this.startQuiz($('#intro-slider'));
    },
    setupContactForm: function() {
      $("textarea").focus(function() {
        if ($(this).val() === 'Type your message here...') {
          return $(this).val('');
        }
      });
      $("textarea").blur(function() {
        if ($(this).val() === '') {
          return $(this).val('Type your message here...');
        }
      });
      $('#subject').focus(function() {
        if ($(this).val() === 'Question about FATCA/FBAR') {
          return $(this).val('');
        }
      });
      $("#subject").blur(function() {
        if ($(this).val() === '') {
          return $(this).val('Question about FATCA/FBAR');
        }
      });
      return $('#contact-form').submit(function(e) {
        e.preventDefault();
        if ($(this).parsley().validate()) {
          return $.ajax({
            type: 'POST',
            url: 'php/contact.php',
            data: $(this).serialize(),
            success: function() {
              return $('#contact-form').html('<h3>Thanks for contacting us! We will get back to you shortly.</h3>');
            },
            error: function() {
              return $('#contact-form').html('<h3>There was an error with your submission. Please contact us at (949) 553-1110</h3>');
            }
          });
        }
      });
    },
    contactButtonLoader: function() {
      var questionButton;
      questionButton = $('.btn-question');
      return questionButton.hover(function() {
        return $(this).text('Contact Us');
      }, function() {
        return $(this).text('Question?');
      }).click(function() {
        return $('#contact').velocity('scroll');
      });
    },
    checkTop: function() {
      var $nav;
      $nav = $('nav');
      return $win.scroll(function() {
        if ($win.scrollTop() > 0) {
          return $nav.removeClass('top');
        } else {
          $nav.addClass('top');
          return $nav.find('a[href="#intro"]').closest('li').removeClass('active');
        }
      });
    },
    navHandler: function() {
      $('body').scrollspy({
        target: '#main-nav'
      });
      return $('a').filter('.nav-link').on('click', function(e) {
        var section;
        section = $(this).attr('href');
        e.preventDefault();
        return $(section).velocity('scroll');
      });
    },
    sectionSizer: function() {
      var navHeight;
      winHeight = $win.height();
      navHeight = $('nav').height();
      return $('.section').each(function() {
        var $section, $sectionChildSmall, $sectionChildren, $subSectionHeight;
        $section = $(this);
        $sectionChildren = $section.children('.section-child');
        $sectionChildSmall = $sectionChildren.filter('.section-child-small');
        if ($sectionChildren.length) {
          $subSectionHeight = winHeight / $sectionChildren.length;
          $sectionChildren.height($subSectionHeight - (navHeight / $sectionChildren.length));
        }
        if ($section.hasClass('section-half') && $sectionChildren.length) {
          $section.height((winHeight * 0.6) + navHeight);
          return $sectionChildren.height(winHeight * 0.6);
        } else {
          return $section.height(winHeight);
        }
      });
    },
    slideTestimony: function() {
      var $container, $quoteArrow, $quotes, $quotesLength, autoSlide, gotoQuote, i, timer;
      $container = $('.quote-slider');
      $quoteArrow = $container.find('.quote-arrow');
      $quotes = $container.find('.quote');
      $quotesLength = $quotes.length;
      i = 0;
      gotoQuote = function(direction) {
        if (direction === 'forward') {
          i++;
          if (i === $quotes.length) {
            i = 0;
          }
        }
        if (direction === 'back') {
          i--;
          if (i < 0) {
            i = $quotes.length - 1;
          }
        }
        $quotes.removeClass('active');
        return $quotes.eq(i).addClass('active');
      };
      autoSlide = function() {
        if (i <= $quotes.length) {
          return gotoQuote('forward');
        }
      };
      $quoteArrow.on('click', function() {
        var direction;
        direction = $(this).data('direction');
        if (direction === 'forward') {
          return gotoQuote('forward');
        } else {
          return gotoQuote('back');
        }
      });
      return timer = setInterval(autoSlide, 8000);
    },
    animateHeroBG: function() {
      return $('#home').velocity({
        'opacity': '1'
      }, {
        duration: 800,
        easing: 'ease-out',
        complete: function() {
          return app.animateMainIntroHeader();
        }
      });
    },
    animateMainIntroHeader: function() {
      return $('#main-intro-header').velocity('transition.slideLeftBigIn', {
        duration: 800,
        complete: function() {
          return app.animateIntroBar();
        }
      });
    },
    animateIntroBar: function() {
      return $('#main-intro-bar').velocity({
        'width': '750px'
      }, {
        duration: 400,
        easing: 'ease-out',
        complete: function() {
          return app.animateIntroSlider();
        }
      });
    },
    animateIntroSlider: function() {
      return $('#main-intro-slider').velocity('transition.fadeIn', {
        complete: function() {
          return app.startSlider($('#main-intro-slider'));
        }
      });
    },
    startSlider: function($container) {
      var $slideIndexContainer, $slides, $slidesLength, autoSlide, gotoSlide, i;
      $slideIndexContainer = $container.find('.slider-index');
      $slides = $container.find('.slide');
      $slidesLength = $slides.length;
      i = 1;
      gotoSlide = function($slideIndex) {
        var $this;
        $this = $(this);
        $slideIndex = $this.index();
        i = $slideIndex;
        $this.addClass('active');
        $this.siblings().removeClass('active');
        $slides.removeClass('active');
        return $slides.eq($slideIndex).addClass('active');
      };
      autoSlide = function() {
        if (i < $slidesLength) {
          $slideIndexContainer.find('li:eq(' + i + ')').click();
          return i++;
        } else if (i = $slidesLength) {
          return i = 0;
        }
      };
      $slideIndexContainer.on('click', 'li', gotoSlide);
      return setInterval(autoSlide, 5000);
    },
    startQuiz: function($container) {
      var $nextArrow, $slideIndexContainer, $slideIndices, $slides, $slidesLength, goNext, gotoSlide, i;
      $slideIndexContainer = $container.find('.slider-index');
      $slideIndices = $slideIndexContainer.find('li');
      $slides = $container.find('.slide');
      $slidesLength = $slides.length;
      $nextArrow = $container.find('.js-slide-next');
      i = 0;
      gotoSlide = function($slideIndex) {
        var $this;
        $this = $(this);
        $slideIndex = $this.index();
        i = $slideIndex;
        $this.addClass('active');
        $this.siblings().removeClass('active');
        $slides.removeClass('active');
        return $slides.eq($slideIndex).addClass('active');
      };
      goNext = function() {
        i++;
        $slides.removeClass('active');
        $slides.eq(i).addClass('active');
        $slideIndices.removeClass('active');
        return $slideIndices.eq(i).addClass('active');
      };
      $slideIndexContainer.on('click', 'li', gotoSlide);
      return $nextArrow.on('click', goNext);
    }
  };

  app.init();

}).call(this);
