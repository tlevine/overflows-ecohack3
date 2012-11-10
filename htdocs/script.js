(function ($) {
  $(document).ready(function() {
    var settings = {
      timeout: 8000,
      current: 0,
      label: 'You might be here?'
    };
    $('#user_address').bind('focus', function() {
      if ($(this).val() == settings.label) {
        $(this).val('');
      }
    });
    $('#user_address').bind('blur', function() {
      if ($(this).val() == '') {
        $(this).val(settings.label);
      }
    });

    $('#user_address').blur();

    $('#the-form').bind('submit', function() {
      geoCodeAddress();
      return false;
    }
    );

    // Rotate quotes.
    var tips = $('.tips .tip');
    if (tips.length > 0) {
      tips.hide();
      $(tips[0]).show();
      setInterval(function() {
        $(tips[settings.current]).fadeOut('slow',
           function() {
             settings.current++;
             if (settings.current >= tips.length) {
               settings.current = 0;
             }
             $(tips[settings.current]).fadeIn('fast');
           });
      }, settings.timeout);
    };
  });
})(jQuery);
