/**
 * All javascript about form
 */

/**
 * Send upload file to A||go
 * @param  {id} '#formUpload' [ID of form for upload]
 * @return {boolean}               [false]

 */

/**
 * This scripts handles the formData submitted through the form
 * Checks the uploaded file and validates if it is correct
 * Sends File to A||GO, wait for computation and returns the output once job is finished

*/




$('#formUpload').on('submit', function(event) {

  
 
   event.preventDefault();    
   
   // Obtaining the values of the three fields of file upload
   var value1 = $('#subfile').val();
   var value2 = $('#subfile2').val();
   var value3 = $('#inputfile3').val();

   //Creating conditions for Checking empty File
   var type = document.getElementById("file_type").value;
   var mode = document.getElementById("mode").value;

   // If Non-Interleaved condition, it checks if both files have been uploaded
   if(type == 'Non-Interleaved Paired Reads (2 Files)'){

     var value1 = $('#subfile').val();
   
     var value2 = $('#subfile2').val();
 
     if(value1=="" || value2==""){
      alert("Please upload a File!");
      return;
     }

   }

   //If Interleaved Paired reads condition and mode is File - checks if file field is not empty
   //If empty, the procedure stops and user is prompted to upload a file
   else if(type == 'Interleaved Paired Reads (1 File)'){
    if(mode=="File"){
     var value1 = $("#subfile").val();
     if(value1==""){
      alert("Please upload a File!");
      return;
     }
    }
    else if(mode=="URL"){
      var value3 = $('#inputfile3').val();
      if(value3==""){
        alert("Please upload a File!");
        return;
      }
    }


   }
   
   // This condition checks when the user hasn't selected anything from dropdown
   // In that case, the user is prompted to enter valid files
   if(value1=="" && value2=="" && value3==""){
    alert("Please select correct options and upload Files");
    return;
   }


   //Cleaning up the form, for the results to be displayed
   $('div').removeClass('jumbotron');
   $('#jumbo').empty();
   $('div').removeClass('panel panel-default');
   $('#form-data').empty();

   var d =document.getElementById('result_assembly');
   d.className = 'intro';
   
   // Basic FormData from the form
   var formData = new FormData($(this)[0]);

  // Appending of parameters to the formData according to the entry point script
  // In case of two files - Non Interleaved Case
  if(type == 'Non-Interleaved Paired Reads (2 Files)'){

     console.log("Noninterleaved Case");
     //Parameter for two files
     var parameter =  "-t pipeline -1 /tmp/"+value1+" -2 /tmp/"+value2;
     console.log(parameter);
     formData.append('job[param]',parameter);

  }

  //Appending of parameters to the formData according to the entry point script
  // In case of one file - Interleaved Paired Reads Case
  else if(type == 'Interleaved Paired Reads (1 File)' && mode=="File"){
    console.log("Interleaved Case");
    //Parameter or one file
      var parameter = "-t pipeline --12 /tmp/"+value1;
      formData.append('job[param]',parameter);

  }
  
  // Appending the URL in case of One File Case and upload via file_url
  if(value3!=''){
    console.log('No Files are uploaded, but url is given');
    
    console.log(value3);
    formData.append('job[file_url]', value3);
  }

  sendQuery(formData);
  return false;

});



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


//END OF script which handles the form