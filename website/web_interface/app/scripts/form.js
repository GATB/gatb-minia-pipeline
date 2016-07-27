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

  

   var value1 = $('#subfile').val();
  var value2 = $('#subfile2').val();
  var value3 = $('#inputfile3').val();



   //Creating conditions for Checking empty File

   var type = document.getElementById("file_type").value;
   var mode = document.getElementById("mode").value;

   if(type == 'Non-Interleaved Paired Reads (2 Files)'){

     var value1 = $('#subfile').val();
   
     var value2 = $('#subfile2').val();

     if(value1=="" || value2==""){
      alert("Please upload a File!");
      return;
     }

   }

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

   if(value1=="" && value2=="" && value3=="")
   {
    alert("Please select correct options and upload Files");
    return;
   }










   console.log($('#file_type').val());
   console.log($('#mode').val());
  
   //
   

  
   $('div').removeClass('jumbotron');
   $('#jumbo').empty();
   $('div').removeClass('panel panel-default');
   $('#form-data').empty();

   var d =document.getElementById('result_assembly');
    d.className = 'intro';

   



  console.log('Send');
  var formData = new FormData($(this)[0]);

  /**
   *   Construction of parameters for Multiple Files
   *   Appending of parameters to formData --- formData.append()
   *   Parameters depend on name of the File


  */
  if(type == 'Non-Interleaved Paired Reads (2 Files)'){

     console.log("Noninterleaved Case");
     //Parameter for two files
     var parameter =  "-t pipeline -1 /tmp/"+value1+" -2 /tmp/"+value2;
     console.log(parameter);
     formData.append('job[param]',parameter);

  }
  else if(type == 'Interleaved Paired Reads (1 File)' && mode=="File"){
    console.log("Interleaved Case");
    //Parameter or one file
      var parameter = "-t pipeline --12 /tmp/"+value1;
      formData.append('job[param]',parameter);

  }


  





  
   if(value3!='')
   {
    console.log('No Files are uploaded, but url is given');
    
    console.log(value3);
    formData.append('job[file_url]', value3);
   }
  console.log('The formdata is');
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

$(document).ready(function() {
  $('#inputfile2').change(function() {
    $('#subfile2').val($(this).val()); // Duplicate value to subfile
  });
});


