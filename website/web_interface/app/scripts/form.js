/**
 * All javascript about form
 */

/**
 * Send upload file to A||go
 * @param  {id} '#formUpload' [ID of form for upload]
 * @return {boolean}               [false]

 */




$('#formUpload').on('submit', function(event) {
  event.preventDefault();
  console.log('Envoi');
  var formData = new FormData($(this)[0]);
  console.log(formData);
  sendQuery(formData);
  return false;
});


/**
 * CUSTOM TEMPLATE
 * All function about form custom
 */
$(document).ready(function() {
  $('#inputfile').change(function() {
    $('#subfile').val($(this).val()); // Duplicate value to subfile
  });
});
