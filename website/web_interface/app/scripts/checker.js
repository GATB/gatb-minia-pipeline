const FILE_SIZE_LIMIT = 500;//Unit is Mb

function getFileSizeLimit(){
  return FILE_SIZE_LIMIT*1024*1024;//unit is bytes
}
function getFileSizeLimitStr(){
  return FILE_SIZE_LIMIT+" Mb";//for display purpose
}
function filetype()
{
  var s = document.getElementById('file_type').value;
  console.log(s);

  //Only when one file is getting uploaded
  if(s=='Interleaved Paired Reads (1 File)')
  {
    document.getElementById('file-2').style='display:none';
    document.getElementById('file-1').style="display:block";
    $('#inputfile').bind('change', function() {
      console.log(this.files[0].size);
      if(this.files[0].size > getFileSizeLimit())
      {
        alert("Please enter a file sizing less than "+getFileSizeLimitStr());
        var file_1 = document.getElementById("subfile");
        file_1.value=file_1.defaultValue;
      }
    });
    console.log('into interleaved');
  }
  //When both files are getting uploaded
  else if(s=='Non-Interleaved Paired Reads (2 Files)' /*&& mode=='File'*/)
  {
    document.getElementById('file-1').style="display:block";
    document.getElementById('file-2').style='display:block';
    var s1, s2;
    var name1="" , name2="";
    $('#inputfile').bind('change', function() {
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
      if(this.files[0].size > getFileSizeLimit())
      {
        alert("Please enter a file sizing less than "+getFileSizeLimitStr());
        var file_2 = document.getElementById("subfile");
        file_2.value = file_2.defaultValue;
      }
    });
    $('#inputfile2').bind('change', function() {
      s2 = this.files[0].size;
      console.log(this.files[0].size);
      name1 = document.getElementById("subfile").value;
      name2 = document.getElementById("subfile2").value;
      if(name1==name2)
      {
        alert("Upload Different Files for Non Interleaved Reads");
      }
      console.log(name2);
      if(this.files[0].size > getFileSizeLimit())
      {
        alert("Please enter a file sizing less than "+getFileSizeLimitStr());
        var file_3 = document.getElementById("subfile2");
        file_3.value = file_3.defaultValue;
      }
    });
  }
}
