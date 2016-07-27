/**
 *  This function checks the options entered by the user in the drop downs
 *  According to the options, the file/URL upload options will be visible to the user
 *  This also handles the situation when the user uploads two same files
 *  This also handles the situation when the user does not upload files/url according to dropdown selection

*/

function filetype()
 {
   // Type of File (Interleaved or Non Interleaved)
   var s = document.getElementById('file_type').value;
   //Mode of Upload (File/URL)
   var mode = document.getElementById('mode').value;
   // URL Removal when selection of Non Interleaved Reads from the drop down
   if(s=='Non-Interleaved Paired Reads (2 Files)'){
      var selectobject=document.getElementById("mode")
      for (var i=0; i<selectobject.length; i++){
      if (selectobject.options[i].value == 'URL' )
         selectobject.remove(i);
      }
   }
   //Addition of URL in case of Interleaved Paired Reads
   else if(s=='Interleaved Paired Reads (1 File)'){

      var selectobject = document.getElementById("mode");
      var len = selectobject.length;
      if(len==2){

        var option = document.createElement("option");
        option.text = "URL";
        selectobject.add(option);
      }
   }
 

  //Display of option for one file upload
  //Also checks the size of file uploads and validates it
   if(s=='Interleaved Paired Reads (1 File)' && mode=='File') {
     document.getElementById('file-2').style='display:none';
     document.getElementById('inputfile3').style='display:none;'
     document.getElementById('file-1').style="display:";

     $('#inputfile').bind('change', function() {

        //this.files[0].size gets the size of your file.
         console.log(this.files[0].size);
         //console.log(document.getElementById("subfile").value);
        //console.log(this.files[0].size);
        if(this.files[0].size > 3276800){
          alert("Please enter a file size lesser than 400 MB");
          var file_1 = document.getElementById("subfile");
          file_1.value=file_1.defaultValue;
        }

      });

   }

   //Display options for both the file upload
   //Also checks file sizes and validates
   else if(s=='Non-Interleaved Paired Reads (2 Files)' && mode=='File'){
     document.getElementById('file-1').style="display:";
     document.getElementById('file-2').style='display:';

     document.getElementById('inputfile3').style='display:none';
      
     var s1, s2;

     var name1="" , name2="";

     // Checking if both the file names are different for the procedure to go forward
     $('#inputfile').bind('change', function() {

       //this.files[0].size gets the size of your file.
         s1 = this.files[0].size;

         console.log(this.files[0].size);
         name1 = document.getElementById("subfile").value;
         console.log(name1);
         name2 = document.getElementById("subfile2").value;
         console.log(name2);

         if(name1 == name2){
          alert("Upload Different Files for Non Interleaved Reads");
         }
         //console.log(this.files[0].size);
         if(this.files[0].size > 3276800){
           alert("Please enter a file size lesser than 400 MB");
           var file_2 = document.getElementById("subfile");
           file_2.value = file_2.defaultValue;
         }

      });


     $('#inputfile2').bind('change', function() {

      //this.files[0].size gets the size of your file.
         s2 = this.files[0].size;
        console.log(this.files[0].size);
        name1 = document.getElementById("subfile").value;
        name2 = document.getElementById("subfile2").value;
        if(name1==name2){
          alert("Upload Different Files for Non Interleaved Reads");
        }
        console.log(name2);
        //console.log(this.files[0].size);
        if(this.files[0].size > 3276800){
          alert("Please enter a file size lesser than 400 MB");
          var file_3 = document.getElementById("subfile2");
          file_3.value = file_3.defaultValue;
        }

      });


   }
   //Validation or URL mode
   else if(mode=='URL'){
       document.getElementById('file-1').style='display:none;';
       document.getElementById('file-2').style='display:none;';
       document.getElementById('inputfile3').style='display:';

      //AJAX call for checking file size of URL -- NOT WORKING CURRENTLY
       var xhr = $.ajax({
        type: "HEAD",
        url: "http://gatb-pipeline.gforge.inria.fr/test/SRR959239_1_small_100Klines.fastq.gz",
        success: function(msg){
        alert(xhr.getResponseHeader('Content-Length') + ' bytes');
       }
     });     
   }
  }

//END OF CHECKER SCRIPT