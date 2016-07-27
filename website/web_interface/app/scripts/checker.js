function filetype()
 {

   var s = document.getElementById('file_type').value;
   var mode = document.getElementById('mode').value;
   console.log(mode);
   console.log(s);

   if(s=='Non-Interleaved Paired Reads (2 Files)')
   {
      var selectobject=document.getElementById("mode")
      for (var i=0; i<selectobject.length; i++){
      if (selectobject.options[i].value == 'URL' )
         selectobject.remove(i);
      }
   }
   else if(s=='Interleaved Paired Reads (1 File)'){

      var selectobject = document.getElementById("mode");
      var len = selectobject.length;
      if(len==2){

        var option = document.createElement("option");
        option.text = "URL";
        selectobject.add(option);
      }
   }
 

  //Only when one file is getting uploaded
   if(s=='Interleaved Paired Reads (1 File)' && mode=='File') 
   {
     document.getElementById('file-2').style='display:none';
     document.getElementById('inputfile3').style='display:none;'
     document.getElementById('file-1').style="display:";

     $('#inputfile').bind('change', function() {

      //this.files[0].size gets the size of your file.
       console.log(this.files[0].size);
       //console.log(document.getElementById("subfile").value);
      //console.log(this.files[0].size);
      if(this.files[0].size > 3276800)
      {
        alert("Please enter a file size lesser than 400 MB");
        var file_1 = document.getElementById("subfile");
        file_1.value=file_1.defaultValue;
      }

      });

     // Prompt for Either of the file missing



     console.log('into interleaved');
   }

   //When both files are getting uploaded
   else if(s=='Non-Interleaved Paired Reads (2 Files)' && mode=='File')
   {
     document.getElementById('file-1').style="display:";
     document.getElementById('file-2').style='display:';

     document.getElementById('inputfile3').style='display:none';
      
     var s1, s2;

     var name1="" , name2="";

     $('#inputfile').bind('change', function() {

       //this.files[0].size gets the size of your file.
        s1 = this.files[0].size;

       console.log(this.files[0].size);
       name1 = document.getElementById("subfile").value;
       console.log(name1);
       name2 = document.getElementById("subfile2").value;
       console.log(name2);

       if(name1 == name2)
       {
        alert("Upload Different Files for Non Interleaved Reads");
       }
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
      name1 = document.getElementById("subfile").value;
      name2 = document.getElementById("subfile2").value;
      if(name1==name2)
      {
        alert("Upload Different Files for Non Interleaved Reads");
      }
      console.log(name2);
      //console.log(this.files[0].size);
      if(this.files[0].size > 3276800)
      {
        alert("Please enter a file size lesser than 400 MB");
        var file_3 = document.getElementById("subfile2");
        file_3.value = file_3.defaultValue;
      }

      });



    //console.log(name1);
    //console.log(name2);


      //Prompt for either of the file missing


   }
   else if(mode=='URL')
   {
     document.getElementById('file-1').style='display:none;';
     document.getElementById('file-2').style='display:none;';
     document.getElementById('inputfile3').style='display:';


     var xhr = $.ajax({
      type: "HEAD",
      url: "http://gatb-pipeline.gforge.inria.fr/test/SRR959239_1_small_100Klines.fastq.gz",
      success: function(msg){
      alert(xhr.getResponseHeader('Content-Length') + ' bytes');
     }
    });

     
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

//Prompt for File URL --- Ajax Calls
//Disabling Url Feature for two files