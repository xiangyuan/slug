/*
 * jQuery.gravatar 1.0.1 (2009-01-08)
 *
 * Written by Zach Leatherman
 * http://zachleat.com
 *
 * Licensed under the WTFPL (http://sam.zoy.org/wtfpl/)
 *
 * Requires jQuery http://jquery.com (1.2.6 at time of release)
 * Requires http://pajhome.org.uk/crypt/md5/md5.js
 */

;(function($) {
$.fn.gravatar = function(emailAddress, overrides) {
    var options = {
        // integer size: between 1 and 512, default 80 (in pixels)
        size: '32',
        // rating: g (default), pg, r, x
        rating: 'pg',
        // url to define a default image (can also be one of: identicon, monsterid, wavatar)
        image: ''
    };

    $.extend(options, overrides);

    $(this).attr('src', 'http://www.gravatar.com/avatar/' +
        hex_md5(emailAddress) +
        '.jpg?' +
        (options.size ? 's=' + options.size + '&' : '') +
        (options.rating ? 'r=' + options.rating + '&' : '') +
        (options.image ? 'd=' + encodeURIComponent(options.image) : '') + 
        '"/>');
    return $(this);
};
})(jQuery);
