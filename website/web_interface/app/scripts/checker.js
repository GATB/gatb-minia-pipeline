function filetype()
 {

   var s = document.getElementById('file_type').value;
   var mode = document.getElementById('mode').value;
   console.log(mode);
   console.log(s);
  //Only when one file is getting uploaded
   if(s=='Interleaved Paired Reads(1 File)' && mode=='File') 
   {
     document.getElementById('file-2').style='display:none';
     document.getElementById('inputfile3').style='display:none;'
     document.getElementById('file-1').style="display:";

     $('#inputfile').bind('change', function() {

      //this.files[0].size gets the size of your file.
       console.log(this.files[0].size);
      //console.log(this.files[0].size);
      if(this.files[0].size > 3276800)
      {
        alert("Please enter a file size lesser than 400 MB");
        var file_1 = document.getElementById("subfile");
        file_1.value=file_1.defaultValue;
      }

      });



     console.log('into interleaved');
   }

   //When both files are getting uploaded
   else if(s=='Non-Interleaved Paired Reads (2 Files)' && mode=='File')
   {
     document.getElementById('file-1').style="display:";
     document.getElementById('file-2').style='display:';

     document.getElementById('inputfile3').style='display:none';
      
     var s1, s2;

     $('#inputfile').bind('change', function() {

       //this.files[0].size gets the size of your file.
        s1 = this.files[0].size;
       console.log(this.files[0].size);
       //console.log(this.files[0].size);
       if(this.files[0].size > 3276800)
       {
         alert("Please enter a file size lesser than 400 MB");
         var file_2 = document.getElementById("subfile");
         file_2.value = file_2.defaultValue;
       }

      });


     $('#inputfile2').bind('change', function() {

      //this.files[0].size gets the size of your file.
       s2 = this.files[0].size;
      console.log(this.files[0].size);
      //console.log(this.files[0].size);
      if(this.files[0].size > 3276800)
      {
        alert("Please enter a file size lesser than 400 MB");
        var file_3 = document.getElementById("subfile2");
        file_3.value = file_3.defaultValue;
      }

      });





   }
   else if(mode=='Url')
   {
     document.getElementById('file-1').style='display:none;';
     document.getElementById('file-2').style='display:none;';
     document.getElementById('inputfile3').style='display:';
   }
 }

/**
$('#inputfile').bind('change', function() {

  //this.files[0].size gets the size of your file.
  console.log(this.files[0].size);
  //console.log(this.files[0].size);

});


$('#inputfile2').bind('change', function() {

  //this.files[0].size gets the size of your file.
  console.log(this.files[0].size);
  //console.log(this.files[0].size);

});


*/