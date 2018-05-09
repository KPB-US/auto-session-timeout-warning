module AutoSessionTimeoutWarningHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    start = options[:start] || 60
    warning = options[:warning] || options[:timeout] - 120
    code = <<JS
  function PeriodicalQuery() {
console.debug('in PeriodicalQuery ' + (new Date()).toString());
    $.ajax({
      url: '/active'
    }).done(function(data) {
console.debug('  ajax came back with ' + data);
      if (new Date(data.timeout).getTime() < (new Date().getTime() + #{warning} * 1000)) {
        $('#timeoutWarningModal').modal('show');
      }
      if (!data.live) {
        console.debug('  data.live == false, so we should be redirecting to /timeout');
        window.location.href = '/timeout';
      }

    }).always(function() {
      setTimeout(PeriodicalQuery, (#{frequency} * 1000));
    });
  }

  // make sure we only start looping once
  var _auto_session_timout_initialized;
  if (!_auto_session_timout_initialized) {
console.debug('kicking off first call to PeriodicalQuery');
    setTimeout(PeriodicalQuery, (#{start} * 1000));
    _auto_session_timout_initialized = true;
  }
JS
    javascript_tag(code)
  end

  # Generates viewport-covering dialog HTML with message in center
  #   options={} are output to HTML. Be CAREFUL about XSS/CSRF!
  def auto_session_warning_tag(options={})
    default_message = "You are about to be logged out due to inactivity.<br/><br/>Please click &lsquo;Continue&rsquo; to stay logged in."
    html_message = options[:message] || default_message
    warning_title = options[:title] || "Logout Warning"
    warning_classes = !!(options[:classes]) ? options[:classes] : ''

    # Marked .html_safe -- Passed strings are output directly to HTML!

"    <!-- Modal -->
<div class='modal fade #{warning_classes}' id='timeoutWarningModal' tabindex='-1' role='dialog' aria-labelledby='myModalLabel'>
  <div class='modal-dialog' role='document'>
    <div class='modal-content'>
      <div class='modal-header'>
        <button type='button' class='close' data-dismiss='modal' aria-label='Close'><span aria-hidden='true'>&times;</span></button>
        <h4 class='modal-title' id='myModalLabel'>#{warning_title}</h4>
      </div>
      <div class='modal-body'>
        #{html_message}
      </div>
      <div class='modal-footer'>
        <button type='button' class='btn btn-default btn-timeout-warning-continue' data-dismiss='modal'>Continue</button>
      </div>
    </div>
  </div>
</div>".html_safe

  end
end

ActionView::Base.send :include, AutoSessionTimeoutWarningHelper
