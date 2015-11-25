<% if @post.persisted? %>
  $('div#stream-form').after("<%= j render 'locations/posts/post', post: @post %>");
<% else %>
  alert('Es gab ein Problem, bitte versuche es später nochmal.');
<% end %>
$('div#stream-form').html("<%= j render 'locations/posts/form', author: @post.author %>")
APP.components.stream.init()
