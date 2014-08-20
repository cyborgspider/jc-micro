#Make some global variables
$win        = $(window)
winHeight   = $win.height()
winWidth    = $win.width()
deviceAgent = navigator.userAgent.toLowerCase()
agentID     = deviceAgent.match(/(iphone|ipod|ipad)/)

#Place all functions to init the page inside pageLoad
pageLoad = ->
  #If a user is at the bottom of the page and refreshes, scroll back to the top and start all animations
  #hashId = window.location.hash

  # if hashId != '#home'
  #   $('.nav').find('a[href="'+hashId+'"]').click()

  # else
  #   $('html,body').velocity 'scroll'

  #Return to top of page upon load
  $('html,body').velocity 'scroll'
  #Empty form
  $('#contact-form')[0].reset()

  sectionSizer()
  animateHeroBG()
  slideTestimony()
  checkTop()
  navHandler()
  contactButtonLoader()
  $('#contact-form').parsley()
  startQuiz($('#intro-slider'))


  #If iOS, remove the video
  if agentID
    #$('head').append('<link href="css/ios.css" rel="stylesheet" />')
    $('#video').remove()

#Check for window resizing
$win.resize ->
  if $win.width() == winWidth
    sectionSizer()

#Contact Form
$("textarea").focus ->
    if $(@).val() == 'Type your message here...'
      $(@).val('')

$("textarea").blur ->
    if $(@).val() == ''
      $(@).val('Type your message here...')

$('#subject').focus ->
  if $(@).val() == 'Question about FATCA/FBAR'
    $(@).val('')

$("#subject").blur ->
    if $(@).val() == ''
      $(@).val('Question about FATCA/FBAR')

$('#contact-form').submit (e)->
  e.preventDefault()
  if $(this).parsley().validate()
    $.ajax
        type: 'POST'
        url: 'php/contact.php'
        data: $(this).serialize()
        success: ->
            $('#contact-form').html('<h3>Thanks for contacting us! We will get back to you shortly.</h3>')
        error: ->
            $('#contact-form').html('<h3>There was an error with your submission. Please contact us at (949) 553-1110</h3>')

#Contact Buttons
contactButtonLoader = ()->
  questionButton = $('.btn-question')

  questionButton.hover(->
    $(@).text 'Contact Us'
  , ->
    $(@).text 'Question?'
  ).click ->
    $('#contact').velocity 'scroll'

#Check scroll positioning, move the navigation bar if not at the top
checkTop = ()->
  $nav = $('nav')
  $win.scroll ->
    if $win.scrollTop() > 0
      $nav.removeClass 'top'
    else
      $nav.addClass 'top'
      #Remove Intro's active state when you reach the top of the page
      $nav.find('a[href="#intro"]').closest('li').removeClass 'active'

#Handle navigation
navHandler = ()->
  #Use bootstrap plugin to detect page location and active link
  $('body').scrollspy(
    target : '#main-nav'
  )

  #Click handler for links
  $('a').filter('.nav-link').on 'click', (e) ->
    section = $(@).attr('href')
    e.preventDefault()
    $(section).velocity 'scroll'
    #window.location.hash = section

#Section Height Setter
sectionSizer = ()->
  #Calculate the window height minus the nav bar height
  winHeight = $win.height()
  navHeight = $('nav').height()

  $('.section').each ->
      $section = $(@)
      $sectionChildren = $section.children('.section-child')
      $sectionChildSmall = $sectionChildren.filter('.section-child-small')

      if $sectionChildren.length
        #If there are subsections, set a height for each subsection divided by total window height
        $subSectionHeight = winHeight/$sectionChildren.length

        #We must also account for the nav height gap, so we subtract the nav height to even things out
        $sectionChildren.height($subSectionHeight - (navHeight/$sectionChildren.length))
        # console.log $section.attr('id') + ' has ' + $sectionChildSmall.length + ' smaller sections.'

      if $section.hasClass('section-half') and $sectionChildren.length
        $section.height((winHeight*0.6) + (navHeight))
        $sectionChildren.height(winHeight*0.6)

      else
        $section.height(winHeight)


#Testimony Transitions
slideTestimony = () ->
  $container    = $('.quote-slider')
  $quoteArrow   = $container.find('.quote-arrow')
  $quotes       = $container.find('.quote')
  $quotesLength = $quotes.length
  i             = 0

  gotoQuote = (direction) ->
    if direction is 'forward'
      i++
      if i == $quotes.length
        i = 0
    if direction is 'back'
      i--
      if i < 0
        i = $quotes.length-1

    $quotes.removeClass 'active'
    $quotes.eq(i).addClass 'active'

  autoSlide = ->
    if i <= $quotes.length
      gotoQuote('forward')

  $quoteArrow.on 'click', ->
    direction = $(@).data('direction')
    #clearInterval(timer)
    #timer = setInterval(autoSlide, 5000)

    if direction is 'forward'
      gotoQuote('forward')
    else
      gotoQuote('back')

  timer = setInterval(autoSlide, 8000)

#Place animations inside functions to call them using Velocity callbacks
animateHeroBG = ->
  $('#home').velocity(
    'opacity':'1'
  ,
    duration: 800
    easing:   'ease-out'
    complete: ->
      animateMainIntroHeader()
  )

animateMainIntroHeader = ->
  $('#main-intro-header').velocity(
    'transition.slideLeftBigIn'
    ,
      duration: 800
      complete: ->
        animateIntroBar()
  )

animateIntroBar = ->
  $('#main-intro-bar').velocity(
    'width' : '750px'
  ,
    duration: 400
    easing:   'ease-out'
    complete: ->
      animateIntroSlider()
  )

animateIntroSlider = ->
  $('#main-intro-slider').velocity(
    'transition.fadeIn'
  ,
    complete: ->
      startSlider($('#main-intro-slider'))
  )

#Slider
startSlider = ($container) ->
  $slideIndexContainer = $container.find('.slider-index')
  $slides              = $container.find('.slide')
  $slidesLength        = $slides.length
  i                    = 1

  gotoSlide = ($slideIndex) ->
    $this       = $(@)
    $slideIndex = $this.index()
    i           = $slideIndex

    $this.addClass 'active'
    $this.siblings().removeClass 'active'

    $slides.removeClass 'active'
    $slides.eq($slideIndex).addClass 'active'


  autoSlide = ->
    #Increment i, the setInterval below will handle "auto" clicking
    if i < $slidesLength
      $slideIndexContainer.find('li:eq('+i+')').click()
      i++
    #At the end of the slideshow, reset to the first slide
    else if i = $slidesLength
      i = 0

  $slideIndexContainer.on 'click', 'li', gotoSlide
  setInterval(autoSlide, 5000)

#Quiz
startQuiz = ($container) ->
  $slideIndexContainer = $container.find('.slider-index')
  $slideIndices        = $slideIndexContainer.find('li')
  $slides              = $container.find('.slide')
  $slidesLength        = $slides.length
  $nextArrow           = $container.find('.js-slide-next')
  i                    = 0

  gotoSlide = ($slideIndex) ->
    $this       = $(@)
    $slideIndex = $this.index()
    i           = $slideIndex

    $this.addClass 'active'
    $this.siblings().removeClass 'active'

    $slides.removeClass 'active'
    $slides.eq($slideIndex).addClass 'active'

  goNext = () ->
    i++
    $slides.removeClass 'active'
    $slides.eq(i).addClass 'active'

    $slideIndices.removeClass 'active'
    $slideIndices.eq(i).addClass 'active'

  $slideIndexContainer.on 'click', 'li', gotoSlide
  $nextArrow.on 'click', goNext

#Waypoints
#This didn't work very well. TODO: Make it better, I still prefer over ScrollSpy
#http://imakewebthings.com/jquery-waypoints/#get-started
# $('.section').waypoint
#   handler: ->
#     sectionId = $(@).attr('id')
#     $('#logo').removeClass 'active'
#     links.removeClass 'active'

#     #Find out why I can't use the global variable I set earlier (links)
#     $('nav').find('a[href="#'+sectionId+'"]').addClass('active')
#     window.location.hash = sectionId

#   continuous: false


#Page Load (init)
pageLoad()
