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
  //document.getElementById("jumbo").style="visibility:hidden";
   //$("div").removeClass("jumbotron");
   //$("h1").removeClass("g-web");

   var value = $('#subfile').val();
   if(value=='')
   {
    alert('Please upload a File!');
   }
   else {

   $('div').removeClass('jumbotron');
   $('#jumbo').empty();
   $('div').removeClass('panel panel-default');
   $('#form-data').empty();

   var d =document.getElementById('result_assembly');
    d.className = 'intro';
   


  console.log('Send');
  var formData = new FormData($(this)[0]);
  console.log("The formdata is");
  console.log(formData);
  sendQuery(formData);
  return false;
}

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

$(document).ready(function() {
  $('#inputfile2').change(function() {
    $('#subfile2').val($(this).val()); // Duplicate value to subfile
  });
});


