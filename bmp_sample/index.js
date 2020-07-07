var _bunim_murray = (function(){
	var method = {
		init: function() {
			method.utils.init();
			method.nav.init();
			method.videoExpander.init();
			method.contentPanel.init();
			method.draggable.init();

		},
		contentPanel: {
			init: function() {
				method.contentPanel.clickHandler();
				method.contentPanel.viewMore();
			},
			clickHandler: function() {
				$('.content-wrapper.show').click(function(e) {
					e.preventDefault();

					$('#show-panel-wrapper, #dark-overlay').addClass('open');
					method.contentPanel.contentLoader($(this).data('class'), $(this).data('id'), $(this).data('context'));
					$('body').addClass('no-scroll');

					$('.close-panel').click(function(e){
						e.preventDefault();
						method.contentPanel.contentHider(true);
					})
				})
				
				$('#dark-overlay').click(function(){
					method.contentPanel.contentHider(true);
				})
			},
			nextHandler: function() {
				$('#show-panel-wrapper .next, #casting-panel-wrapper .next, #film-panel-wrapper .next').click(function(e){
					e.preventDefault();

					method.contentPanel.contentHider(false);

				})
			},
			contentLoader: function(classType, id, context) {
				$.ajax({
					type: "POST",
					beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
					url: '/get_content',
					data: { class: classType, id: id, context: context},
					success: success,
					dataType: 'json'
				});
				function success(data) {
					var show = false;
					var codecs = 'codecs="avc1.4D401E, mp4a.40.2"';

					if (classType.toLowerCase() == 'show') {
						if(data.assets.video != ''){
							if(data.assets.captions != ''){
								$('#show-panel-wrapper .content-hero').append(' <div class="videoWrapper static panel-vid" id="">'
									+ '<div class="vidPlayer">'
									+ '<video crossorigin="anonymous" src="'+data.assets.video+'" playsinline type="video/mp4" poster="'+data.assets.image+'">'
									+ '<track kind="captions" srclang="en" src="'+data.assets.captions+'" label="English" default="">'
									+ '<source src="'+data.assets.video+'" type="video/mp4; '+ codecs +'">'
									+ '	</video>'
									+ '	</div>'
									+ '</div>');
							}
							else {
								$('#show-panel-wrapper .content-hero').append(' <div class="videoWrapper static panel-vid" id="">'
									+ '<div class="vidPlayer">'
									+ '<video crossorigin="anonymous" src="'+data.assets.video+'" playsinline type="video/mp4" poster="'+data.assets.image+'">'
									+ '<source src="'+data.assets.video+'" type="video/mp4; '+ codecs +'">'
									+ '	</video>'
									+ '	</div>'
									+ '</div>');
							}


							$('#show-panel-wrapper .panel-vid').RTOP_videoPlayer();

							$('#show-panel-wrapper .content-hero video').get(0).oncanplay = function() {
								show = true;
							}
						}
						else {
							$('#show-panel-wrapper .content-hero').append("<img src='"+ data.assets.image +"' class='hero-image'/>");
							$('#show-panel-wrapper .hero-image').on('load', function() {
								show = true;
							})
						}
						$('#show-panel-wrapper .content-title').html(data.copy.name);
						$('#show-panel-wrapper .content-description').append(data.copy.description);
						$('#show-panel-wrapper .content-awards').append(data.copy.awards);
						$('#show-panel-wrapper .content-time-span').html(data.copy.time_span);
						$('#show-panel-wrapper .content-next-title').html(data.next.copy.name);
						$('#show-panel-wrapper .content-next').attr('data-id', data.next.id);
						$('#show-panel-wrapper .content-next').attr('data-class', data.next.class);
						$('#show-panel-wrapper .content-next').attr('data-context', data.next.context);
						if(data.network != "") {
							$('#show-panel-wrapper .content-network').append('<h2>Network</h2><img src="'+data.network.image+'"/>');
						}
						if(data.copy.more_awards != "") {
							$('#show-panel-wrapper .content-more-awards').append(data.copy.more_awards);
							$('#show-panel-wrapper .view-more').addClass('show')
							$('#show-panel-wrapper .view-more').attr('style', '')
						}
					}

					var i = 1;
					var checkForLoaded = setInterval(function(){
						if(show == true || i >= 50) {
							method.contentPanel.revealContent();
							clearInterval(checkForLoaded);
						}
						else {
							i++
						}
					}, 100)
				}
			},
			revealContent: function() {
				setTimeout(function() {
					$('.loader').addClass('hide');
					setTimeout(function() {
						$('.content-panel .row').addClass('loaded');
						setTimeout(function(){
							$('.fade.first').addClass('show');
							setTimeout(function(){
								$('.hero-wrapper').addClass('reveal');
								setTimeout(function() {
									$('.content-panel').addClass('loaded');
									method.contentPanel.nextHandler();
								}, 100)
							}, 200)
						}, 100)
					}, 200)
				}, 300)
			},
			viewMore: function() {
				$('body').on('click', '.panel-wrapper.open .view-more', function(e) {
					e.preventDefault()
					$('.panel-wrapper.open .more-awards').slideDown();
					$(this).fadeOut();
				})
			},
			contentHider: function(close) {
				$('.content-next').unbind('click');

				$('.hero-wrapper').removeClass('reveal');
				setTimeout(function(){
					$('.fade.first').removeClass('show');

					$('.content-panel').removeClass('loaded');
					setTimeout(function() {
						$('.content-hero, .content-description, .content-awards, .content-more-awards, .content-network').html('');
						$('.content-more-awards').css({
							display: 'none'
						});
						$('.view-more').removeClass('show')
						if(close){
							$('.panel-wrapper, #dark-overlay').removeClass('open');
						}
						setTimeout(function(){
							$('.loader').removeClass('hide');
							$('.content-panel .row').removeClass('loaded');
							if(!close){
								var $next = $(".panel-wrapper.open .content-next");


								method.contentPanel.contentLoader($next.attr('data-class'), $next.attr('data-id'), $next.attr('data-context'));
							}
							else {
								$('body').removeClass('no-scroll');
							}
						}, 300)
					}, 350)
				}, 200)
			}
		},
		utils: {
			init: function() {
				method.utils.buildMultiply();
				method.utils.layerParallax();
				method.utils.peopleHover();
				method.utils.statsScroll();
				$(window).scroll(function (event) {
					method.utils.layerParallax();
				});
				$(window).resize(function (event) {
					method.utils.sizeVideo();
				});
			},
			contentWrapperSizer: function() {
				$('.content-wrapper.show .image-wrapper').css({
					height: $('.content-wrapper.show .image-wrapper').first().height()
				})
			},
			sizeVideo: function() {
				var $section = $('#stat_scroller'),
						$video = $('#stat_scroller video');

				if($section.length){


					$video.get(0).onloadeddata = function() {

						var diff = $video.width() - $section.width()
						if(diff > 0){
							$video.css({
								position: "relative",
								right: (diff/2)
							})
						}
					};

				}
			},
			statsScroll: function() {
				var $section = $('#stat_scroller'),
						$video = $('#stat_scroller video'),
						//duration = $video.get(0).duration,
						$infoSection = $('#info_scroller');

				if($section.length){

					// init controller
					var controller = new ScrollMagic.Controller(),
							windowHeight = $(window).height(),
							screenOffset = windowHeight / 2,
							scrollerHeight = $section.height(),
							$bg = $section.find('.bg-wrapper'),
							$stat1 = $('#stat1'),
							$stat2 = $('#stat2'),
							$stat3 = $('#stat3'),
							$lSquare = $('.scroller .large-square'),
							$sSquare = $('.scroller .small-square');


					$bg.css({
						height: windowHeight
					})

					var scene = new ScrollMagic.Scene({triggerElement: "#stat_scroller", duration: scrollerHeight})
							.addTo(controller)
							.on("update", function (e) {
							})
							.on("enter leave", function (e) {
								if(!$video.hasClass('played')){
									$video.each(function(){
										$(this).addClass('played');
										$(this).get(0).play();
									})

								}
								if(e.type == "leave") {
								}
							});
				}

				if($infoSection.length){
					// init controller
					var controller = new ScrollMagic.Controller(),
							windowHeight = $(window).height(),
							screenOffset = windowHeight / 2,
							infoScrollerHeight = $infoSection.outerHeight(),
							$bg = $infoSection.find('.bg-wrapper');



					//about scroller
					if($(window).width() > 768) {
						$bg.css({
							height: windowHeight
						})

						var infoScene = new ScrollMagic.Scene({triggerElement: "#info_scroller", offset: screenOffset, duration: infoScrollerHeight - (windowHeight)})
							.addTo(controller)
							.on("update", function (e) {
							})
							.on("enter leave", function (e) {
								if(e.type == "enter") {
									$bg.addClass('stuck');
									$bg.css({
										height:  $(window).height()
									})
								}
								if(e.type == "leave") {
									$bg.removeClass('stuck');
									if(e.target.controller().info("scrollDirection") == "FORWARD"){
										$bg.addClass('abs');
									}
									else {
										$bg.removeClass('abs');
									}
								}
							})
							.on("start end", function (e) {
							})
							.on("progress", function (e) {
							});

						$('.info-wrapper').each(function(i, v){
							var $this =  $(this),
								id = '#' + $this.attr('id');

							new ScrollMagic.Scene({triggerElement: id,  offset: $this.css('paddingTop'), duration: $this.outerHeight()/2})
								.addTo(controller)
								.on("update", function (e) {
								})
								.on("enter leave", function (e) {
									if(e.type == "enter") {
										$('.info-wrapper').removeClass('active');
										$this.addClass('active')
									}
								})
								.on("start end", function (e) {
								})
								.on("progress", function (e) {

								});
						});
					}

				}

				function convertToRange(value, srcRange, dstRange){
					// value is outside source range return
					if (value < srcRange[0] || value > srcRange[1]){
						return NaN;
					}

					var srcMax = srcRange[1] - srcRange[0],
							dstMax = dstRange[1] - dstRange[0],
							adjValue = value - srcRange[0];

					return (adjValue * dstMax / srcMax) + dstRange[0];

				}
			},
			buildMultiply: function() {
				$('.layer.multiply').each(function(){
					var $this = $(this),
							$black = $this.clone();

					$this.addClass('blue');
					$black.addClass('black');

					$this.after($black);
				})
			},
			layerParallax: function() {
				var scrollPos = $(document).scrollTop();

				$('.layer').each(function(){
					if ($(this).isInViewport()){
						var $this = $(this),
								relativeMovement = ((scrollPos - ($this.offset().top - $(window).height())) / $(window).height() * ($this.hasClass('layer0') ? 130 :
										$this.hasClass('layer1') ? 100 :
												$this.hasClass('layer2') ? 90 :
														$this.hasClass('layer3') ? 70 :
																$this.hasClass('layer4') ? 50 :
																		$this.hasClass('layer5') ? 30 : 10));

						if($this.hasClass('vertical')){
							$this.css({
								transform: "translateY(" + -relativeMovement + "px)"
							})
						}
						else if($this.hasClass('left')) {
							$this.css({
								transform: "translateX(" + -relativeMovement + "px)"
							})
						}
						else if($this.hasClass('right')) {
							$this.css({
								transform: "translateX(" + relativeMovement + "px)"
							})
						}
					}
				});
			},
			peopleHover: function() {
				var $galleryWrapper= $(".gallery-wrapper");

				$(".people li").hoverIntent({
					over: function(){
						var $this = $(this);

						$this.addClass('active');

						$galleryWrapper.prepend("<div class='image-viewer' data-index='"+$this.index()+"'></div>");

						var $img  = $('.image-viewer[data-index="'+ $this.index() +'"]')

						$img.css({
							backgroundImage: 'url(people/'+ $this.data('name')+')'
						});
						$img.fadeTo(200, 1);

					},
					out: function(){
						var $this = $(this);

						var $img  = $('.image-viewer[data-index="'+ $this.index() +'"]')

						$img.fadeTo(300, 0)

						setTimeout(function(){
							$img.remove();
						}, 300)
					},
					sensitivity: 12,
					timeout: 50,
					interval: 70
				})

				$(".people ul").hoverIntent({
					over: function(){
						setTimeout(function(){
							$("img.default").css({
								opacity: 0
							})
						}, 200)
					},
					out:function() {
						$("img.default").css({
							opacity: 1
						})
					},
				})
			}
		},
		nav: {
			init: function() {
				var position = $(window).scrollTop();
				method.nav.scrollProgress();
				method.nav.navDrawer();
				method.nav.searchDrawer();
				method.nav.searchFormListener();
				method.nav.placeLabel();
				$(window).scroll(function (event) {
					var scroll = $(window).scrollTop();

					method.nav.scrollProgress();

					if(scroll > position) {
						method.nav.navPeak('down');
					} else {
						method.nav.navPeak('up');
					}
					position = scroll;
				});
			},
			scrollToSection: function() {
				function getUrlParameter(sParam) {
					var sPageURL = window.location.search.substring(1),
						sURLVariables = sPageURL.split('&'),
						sParameterName,
						i;

					for (i = 0; i < sURLVariables.length; i++) {
						sParameterName = sURLVariables[i].split('=');

						if (sParameterName[0] === sParam) {
							return sParameterName[1] === undefined ? true : decodeURIComponent(sParameterName[1]);
						}
						else
							return false
					}
				};

				var section = getUrlParameter('view');
				if(section){
					var $elem = $("#" + section);

					$('html, body').animate({
						scrollTop: $elem.offset().top - 50
					}, 1000, function(){})
				}

			},

			placeLabel: function () {
				$('.page-label').css({
					left: ($('.page-label').width()/-2) + 40
				})
			},
			navDrawer: function () {
				var $subNavIcon = $('#sub-nav'),
						$navDrawer = $('#nav-drawer'),
						$close = $('.nav-close');

				$subNavIcon.click(function(e) {
					e.preventDefault();
					$navDrawer.addClass('open');
				})

				$close.click(function(e) {
					e.preventDefault();
					$navDrawer.removeClass('open');
				})

				$("#sub-search").click(function(e) {
					e.preventDefault();
					$navDrawer.removeClass('open');
					setTimeout(function(){
						$('#search').trigger('click')
					}, 300)
				})
			},
			searchDrawer: function () {
				var $searchIcon = $('#search'),
						$searchDrawer = $('#search-drawer'),
						$close = $('.nav-close');

				$searchIcon.click(function(e) {
					e.preventDefault();
					$searchDrawer.addClass('open');
					$searchDrawer.find('input').focus();
				})

				$close.click(function(e) {
					e.preventDefault();
					$searchDrawer.removeClass('open');

				})

				$("#sub-menu").click(function(e) {
					e.preventDefault();
					$searchDrawer.removeClass('open');
					setTimeout(function(){
						$('#sub-nav').trigger('click')
					}, 300)
				})
			},
			searchFormListener: function() {
				$(".search-wrapper input").on('keyup', function (e) {
					if (e.keyCode === 13 && $(".search-wrapper input").val() != "") {
						method.nav.searchSubmit();
					}
				});
				$(".search-wrapper .search-icon").click(function(e) {
					if($(".search-wrapper input").val() != ""){
						method.nav.searchSubmit();
					}
				})
			},
			searchSubmit: function() {
				$.ajax({
					type: "POST",
					beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
					url: '/search',
					data: { query: $(".search-wrapper input").val()},
					success: success,
					dataType: 'json'
				});

				function success(data) {
					var offset = $(window).width() < 768 ? 100 : 175
					$(".search-wrapper").addClass('searched');
					$(".results-wrapper").html("");
					$(".results-wrapper").css({
						height: $(window).height() - $('.search-wrapper').outerHeight() - offset
					})
					if(data.length == 0){
						$(".results-wrapper").append("<div class='no-results'>no results</div>")
					}
					$.each(data, function(i, r){
						if(r['class'] == "Show" || r['class'] == "Film"){
							if(!$(".results-wrapper .entertainment").length) {
								$(".results-wrapper").append("<div class='entertainment category'><h6>entertainment - shows & films</h6></div>");
							}
							$(".results-wrapper .entertainment").append("<a href='/"+r['class']+"/"+ r['id'] + "'>" + r['copy']['name'] + "</a>");

						}
						else if (r['class'] == "Article"){
							if(!$(".results-wrapper .search-news").length) {
								$(".results-wrapper").append("<div class='search-news category'><h6>latest news</h6></div>");
							}

							$(".results-wrapper .search-news").append("<a href='/"+r['copy']['link']+"'>" + r['copy']['headline'] + "<div class='dateline'>"+ r['copy']['dateline'] +"</div></a>");

						}
					})
				}
			},
			scrollProgress: function() {
				var winScroll = document.body.scrollTop || document.documentElement.scrollTop;
				var height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
				var scrolled = (winScroll / height) * 100;
				document.getElementById("scroll-progress").style.width = scrolled + "%";
			},

			navPeak: function(direction) {
				var $nav = $('nav');

				if(direction == 'down'){
					$nav.removeClass('peak');
				}
				else {
					!$nav.hasClass('static') ? $nav.addClass('peak') : false;
				}

				if($(window).scrollTop() > 60 ) {
					$nav.addClass('stuck');
					$nav.removeClass('static');
				}
				else {
					$nav.removeClass('stuck');
					$nav.removeClass('peak');
					$nav.addClass('static');
				}
			},
		},
		videoExpander: {

			init: function() {
				method.videoExpander.listeners()
			},
			listeners: function() {
				$('video').click(function(e){
					$(this).removeAttr('controls')
				})

				$('.page-header').find('.videoWrapper').on('click', function() {
					var _that = $('.videoPoster');
					if(!$('.videoContainer').hasClass('grow')){
						_that.addClass('missingVideo');
						$('main').append($('.videoContainer'));
						setTimeout(function(){
							_that.closest('main').find('.videoContainer').addClass('grow');
						}, 50);
						setTimeout(function() {
							_that.closest('main').find('.videoContainer.grow .videoWrapper').RTOP_videoPlayer('playVideo');
						}, 600);
					}
				});

				$('.videoPoster').click(function(e){
					e.preventDefault();
					$('.expandingVideo .videoContainer .videoWrapper').trigger('click');
				})
			}
		},
		draggable: {
			init: function() {
				if($('.awards-inner').length){
					method.draggable.hideDesktop();
					method.draggable.awards();
					method.draggable.milestones();
				}
			},
			hideDesktop: function() {
				if($(window).width() < 768) {
					$('.award-scrubber.mobile-hide, .milestone-scrubber.mobile-hide').remove();
				}
			},
			awards: function() {
				var progPercent = 0,
						relativeProg = 0,
						controller = new ScrollMagic.Controller()
						elementHeights = $('.award-year ul').map(function() {
							return $(this).height();
						}).get(),
						maxHeight = Math.max.apply(null, elementHeights);

				$('.awards-wrapper').css({
					height: maxHeight
				})


				$('.award-year ul').each(function(){
					maxHeight = maxHeight > $(this).height() ? maxHeight : $(this).height();
				})

				new ScrollMagic.Scene({triggerElement: '.awards'})
					.addTo(controller)
					.on("update", function (e) {
					})
					.on("enter leave", function (e) {
						if(e.type == "enter") {
							$('.awards-inner').removeClass('initial');
							setTimeout(function(){$('.awards-inner').removeClass('animate');},300)
						}
					})
					.on("start end", function (e) {
					})
					.on("progress", function (e) {

					});

				$('.award-scrubber .label').draggable({
					axis: 'x',
					scroll: 'false',
					containment: [$('.award-scrubber .label').offset().left,0,$('.award-scrubber .label').offset().left + $('.award-scrubber').width() ,0],
					drag: progressBar,
					stop: progressBar
				})
				$('.awards-inner').draggable({
					axis: 'x',
					scroll: 'false',
					containment: [ -$('.awards-inner').width(),0 ,$('.awards-wrapper').offset().left, 0],
					drag: awardsDrag,
					stop: awardsDrag
				})

				$('.awards-wrapper').bind('mousewheel', function(event) {

					if(event.originalEvent.deltaY < 1 && event.originalEvent.deltaY > -1 ){
						$('.awards-inner').css({
							left: $('.awards-inner').position().left < -$('.awards-inner').width() ? $('.awards-inner').position().left : $('.awards-inner').position().left - event.originalEvent.deltaX
						})

						progPercent = $('.awards-inner').position().left / $('.awards-inner').width() * -100;
						relativeProg = progPercent * $('.award-scrubber').width();

						$('.award-scrubber .progress-bar').css({
							width: progPercent + "%"
						})

						$('.award-scrubber .label').css({
							left: relativeProg / 100
						})
						yearChange()
					}

				});

				function awardsDrag( event, ui) {
					progPercent = $(this).position().left / $('.awards-inner').width() * -100;
					relativeProg = progPercent * $('.award-scrubber').width();
					$('.award-scrubber .progress-bar').css({
						width: progPercent + "%"
					})
					$('.award-scrubber .label').css({
						left: relativeProg / 100
					})
					if(relativeProg < 1){
						$('.award-scrubber .label span, .year-label').text($('.award-year').first().data('year'))
					}
					yearChange()
				}

				function progressBar( event, ui ) {
					progPercent = $(this).position().left / $('.award-scrubber').width() * 100;
					relativeProg = progPercent * $('.awards-inner').width();
					$('.award-scrubber .progress-bar').css({
						width: progPercent + "%"
					})
					$('.awards-inner').css({
						left: relativeProg / -100
					})
					if(relativeProg < 1){
						$('.award-scrubber .label span, .year-label').text($('.award-year').first().data('year'))
					}
					yearChange()
				}

				function yearChange() {
					$('.award-year').each(function(i, y){
						if(collision($('.drop'), $(y))){
							$('.award-scrubber .label span, .year-label').text($(y).data('year'))
						};
					})
				}

				function collision($div1, $div2) {
					var x1 = $div1.offset().left;
					var y1 = $div1.offset().top;
					var h1 = $div1.outerHeight(true);
					var w1 = $div1.outerWidth(true);
					var b1 = y1 + h1;
					var r1 = x1 + w1;
					var x2 = $div2.offset().left;
					var y2 = $div2.offset().top;
					var h2 = $div2.outerHeight(true);
					var w2 = $div2.outerWidth(true);
					var b2 = y2 + h2;
					var r2 = x2 + w2;

					if (b1 < y2 || y1 > b2 || r1 < x2 || x1 > r2) return false;
					return true;
				}

			},
			milestones: function() {
				var progPercent = 0,
						relativeProg = 0,
						controller = new ScrollMagic.Controller(),
						centeroffset = $(window).width() < 768 ? 0 : $(window).width()/2 - $('.milestone').width()/ 2,
						scrollX = 0;


				new ScrollMagic.Scene({triggerElement: '.milestones'})
						.addTo(controller)
						.on("update", function (e) {
						})
						.on("enter leave", function (e) {
							if(e.type == "enter") {
								$('.milestones-inner').removeClass('initial');
								$('.milestones-inner').css({
									left: centeroffset
								})
								setTimeout(function(){$('.milestones-inner').removeClass('animate');},300)
							}
						})
						.on("start end", function (e) {
						})
						.on("progress", function (e) {

						});

				$('.milestone-scrubber .label').draggable({
					axis: 'x',
					scroll: 'false',
					containment: [$('.milestone-scrubber .label').offset().left,0,$('.milestone-scrubber .label').offset().left + $('.award-scrubber').width() ,0],
					drag: progressBar,
					stop: progressBar
				})
				$('.milestones-inner').draggable({
					axis: 'x',
					scroll: 'false',
					containment: [ -$('.milestones-inner').width() + centeroffset,0 ,$('.milestones-wrapper').offset().left + centeroffset, 0],

					drag: milestoneDrag,
					stop: milestoneDrag
				})

				$('.milestones-wrapper').bind('mousewheel', function(event) {
					if(event.originalEvent.deltaY < 1 && event.originalEvent.deltaY > -1 ){
						$('.milestones-inner').css({
							left: $('.milestones-inner').offset().left - event.originalEvent.deltaX
						})

						progPercent = ($('.milestones-inner').position().left - centeroffset) / $('.milestones-inner').width() * -100;
						relativeProg = progPercent * $('.milestone-scrubber').width();

						$('.milestone-scrubber .progress-bar').css({
							width: progPercent + '%'
						})

						$('.milestone-scrubber .label').css({
							left: relativeProg / 100
						})

						yearChange()
					}


				});

				function milestoneDrag( event, ui) {
					progPercent = ($(this).position().left - centeroffset)/ $('.milestones-inner').width() * -100;
					relativeProg = progPercent * $('.milestone-scrubber').width();
					$('.milestone-scrubber .progress-bar').css({
						width: progPercent + "%"
					})
					$('.milestone-scrubber .label').css({
						left: relativeProg / 100
					})
					yearChange()
				}

				function progressBar( event, ui ) {
					progPercent = $(this).position().left / $('.milestone-scrubber').width() * 100;
					relativeProg = convertToRange(progPercent, [0,100], [centeroffset, -$('.milestones-inner').width() + centeroffset] )
					$('.milestone-scrubber .progress-bar').css({
						width: progPercent + "%"
					})
					$('.milestones-inner').css({
						left: (relativeProg)
					})
					yearChange()
				}

				function yearChange() {
					$('.milestone').each(function(i, y){
						if(collision($('.milestone-drop'), $(y))){
							$('.milestone-scrubber .label span').text($(y).data('year'))
						};
					})
				}

				function convertToRange(value, srcRange, dstRange){
					// value is outside source range return
					if (value < srcRange[0] || value > srcRange[1]){
						return NaN;
					}

					var srcMax = srcRange[1] - srcRange[0],
							dstMax = dstRange[1] - dstRange[0],
							adjValue = value - srcRange[0];

					return (adjValue * dstMax / srcMax) + dstRange[0];

				}

				function collision($div1, $div2) {
					var x1 = $div1.offset().left;
					var y1 = $div1.offset().top;
					var h1 = $div1.outerHeight(true);
					var w1 = $div1.outerWidth(true);
					var b1 = y1 + h1;
					var r1 = x1 + w1;
					var x2 = $div2.offset().left;
					var y2 = $div2.offset().top;
					var h2 = $div2.outerHeight(true);
					var w2 = $div2.outerWidth(true);
					var b2 = y2 + h2;
					var r2 = x2 + w2;

					if (b1 < y2 || y1 > b2 || r1 < x2 || x1 > r2) return false;
					return true;
				}
			}
		}
	}

	$.fn.isInViewport = function() {
		var elementTop = $(this).offset().top;
		var elementBottom = elementTop + $(this).outerHeight();
		var viewportTop = $(window).scrollTop();
		var viewportBottom = viewportTop + $(window).height();
		return elementBottom > viewportTop && elementTop < viewportBottom;
	};

	return method;
})(jQuery);

$(document).ready(function() {
	_bunim_murray.init();
});

$(window).on('load', function() {
	_bunim_murray.utils.sizeVideo();
});
