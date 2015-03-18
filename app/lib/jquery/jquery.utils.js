/*
 * jQuery canvasResize plugin
 *
 * Version: 1.2.0
 * Date (d/m/y): 02/10/12
 * Update (d/m/y): 14/05/13
 * Original author: @gokercebeci
 * Licensed under the MIT license
 * - This plugin working with jquery.exif.js
 *   (It's under the MPL License http://www.nihilogic.dk/licenses/mpl-license.txt)
 * Demo: http://ios6-image-resize.gokercebeci.com/
 *
 * - I fixed iOS6 Safari's image file rendering issue for large size image (over mega-pixel)
 *   using few functions from https://github.com/stomita/ios-imagefile-megapixel
 *   (detectSubsampling, )
 *   And fixed orientation issue by edited http://blog.nihilogic.dk/2008/05/jquery-exif-data-plugin.html
 *   Thanks, Shinichi Tomita and Jacob Seidelin
 */

(function($) {
    $.dataURLtoBlob =function(data) {
            var mimeString = data.split(',')[0].split(':')[1].split(';')[0];
            var byteString = atob(data.split(',')[1]);
            var ab = new ArrayBuffer(byteString.length);
            var ia = new Uint8Array(ab);
            for (var i = 0; i < byteString.length; i++) {
                ia[i] = byteString.charCodeAt(i);
            }
            var bb = (window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder);
            if (bb) {
                //    console.log('BlobBuilder');
                bb = new (window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder)();
                bb.append(ab);
                return bb.getBlob(mimeString);
            } else {
                //    console.log('Blob');
                bb = new Blob([ab], {
                    'type': (mimeString)
                });
                return bb;
            }
        };

     $.convertImgToBase64 = function(url, callback, outputFormat){
		var canvas = document.createElement('CANVAS');
		var ctx = canvas.getContext('2d');
		var img = new Image;
		img.crossOrigin = 'Anonymous';
		img.onload = function(){
			canvas.height = img.height;
			canvas.width = img.width;
		  	ctx.drawImage(img,0,0);
		  	var dataURL = canvas.toDataURL(outputFormat || 'image/png');
		  	callback.call(this, dataURL);
	        // Clean up
		  	canvas = null;
		};
		img.src = url;
	}

	$.getParameterByName = function(name) {
	    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
	    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
	        results = regex.exec(location.search);
	    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
	}

	$.fn.scrollTo = function( target, options, callback ){
		if(typeof options == 'function' && arguments.length == 2){ callback = options; options = target; }
			var settings = $.extend({
			    scrollTarget  : target,
			    offsetTop     : 50,
			    duration      : 500,
			    easing        : 'swing'
			}, options);
			return this.each(function(){
			    	var scrollPane = $(this);
			    	var scrollTarget = (typeof settings.scrollTarget == "number") ? settings.scrollTarget : $(settings.scrollTarget);
			    	var scrollY = (typeof scrollTarget == "number") ? scrollTarget : scrollTarget.offset().top + scrollPane.scrollTop() - parseInt(settings.offsetTop);
			    	scrollPane.animate({scrollTop : scrollY }, parseInt(settings.duration), settings.easing, function(){
			      	if (typeof callback == 'function') { callback.call(this); }
			    	});
			});
		}


})(jQuery);
