(function() {
  var persisted = <%= @location_post.persisted? %>
  var $streamForm = $("[data-behavior='stream-form']");
  var $paginateLink = $("[data-behavior='paginate-link']");

  function renderPost() {
    $streamForm.after("<%= j render 'stream_post', post: @location_post %>")
  }

  function renderError() {
    alert('Es gab ein Problem, bitte versuche es später nochmal.');
  }

  function updateComponent() {
    persisted ? renderPost() : renderError();
    $streamForm.replaceWith("<%= j render 'form', location: @location_post.author %>");
    APP.components.stream.init();
  }

  updateComponent();
})();
