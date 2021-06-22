// Invoked on first render + each time a remote form renders

function onRender(callback) {
  $(document).on("ajax:beforeSend", 'form[data-remote=true], a[data-remote=true]', function (event, jqXHR) {
    jqXHR.done(callback);
  });

  callback();
}