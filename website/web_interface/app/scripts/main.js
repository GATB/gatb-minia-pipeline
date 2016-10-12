/**
* Connect template to A||go plateform via A||go API
*/

/**
* Send data (pictures, files, params, etc.) to A||go
* @param  {FormData} formData [Data who have some data to send and number of application]
*/

function sendQuery(formData) {

  document.getElementById("assembly_test").innerHTML = "Uploading data to server...<br /> May take a few minutes depending on file size.";
  var tok;
  $.getJSON('token.json', function( json ) {
    //console.log(json.token);
    tok = json.token;
    console.log(tok);

    $.ajax({
      type: 'POST',
      url: 'https://allgo.inria.fr/api/v1/jobs',
      data: formData,
      cache: false,
      contentType: false,
      processData: false,
      headers: {
        'Authorization': 'Token token='+tok,
        'Accept': 'application/json',
      },
      success: function(d, s, ex) {
        console.log('success');
        console.log(d);
        getAllgoResponseLoop(d,tok);
      },
      error: function(d, s, ex) {
        document.getElementById("assembly_test").innerHTML = "<span style='color:red;font-weight: bold;'>Error:</span> "+d.status+": "+d.statusText+". Job aborted.";
        console.log('error');
        console.log(d);
      }
    });
  });
}

/**
* While A||go response is 'in progress' : Get some response from A||go
* @param  {Object} data informations about this job
*/
function getAllgoResponseLoop(data,token) {
  var result;
  setTimeout(function() {
    result = getAllgoResponse(data,token);
    if (result.status !== undefined) {
      getAllgoResponseLoop(data,token);
      var d =document.getElementById('result_assembly');
      d.className = 'intro';
      document.getElementById("assembly_test").innerHTML = "<span style='font-weight: bold;'>Job is now running...</span><br /> Running time maybe a few minutes depending on File size";

    } else {
      if (result[data.id] !== undefined) {
        document.getElementById("assembly_test").innerHTML = "";

        // File name returned by A||GO
        var fileUrl = result[data.id]['assembly.fasta']; //You must change the name of output file

        // Check over here if fileURL is not empty
        // IF fileURL is undefined stop the script -- return -- display an error message
        if(fileUrl == null){
          //alert("Please provide valid file");
          console.log("Provide valid file");
          var s_temp = document.getElementById('result_assembly');
          s_temp.className="";
          s_temp.innerHTML = "Error!Please provide valid file";
          return;
        }
        console.log('File Url - assembly ');
        console.log(fileUrl);
        var fileUrl2 = result[data.id]['stats.json'];
        console.log(fileUrl);
        console.log(fileUrl2);
        //Giving user an option
        var e = document.getElementById('result_assembly');
        e.className = '';

        document.getElementById('result_assembly').style='font-size:30px;font-weight:100;';
        document.getElementById('result_assembly').innerHTML='Summary';
        document.getElementById('stat').style='font-size:30px;font-weight:100;';
        document.getElementById('stat').innerHTML = '<br />List of Contigs';
        //Function for parsing through the JSON file

        // Formation of the table
        $.getJSON( fileUrl2, function( json ) {
          console.log( 'JSON Data: ' + json.sizes[0] );

          var download = '<a href=\''+fileUrl +'\' class=\'btn btn-primary btn-block\' id="all" >Download All Contigs</a>';
          console.log('File url');
          console.log(fileUrl);
          document.getElementById('stats').innerHTML = '<br /><br />'+download;
          //Creation of the mains table
          var basic_header = '<table class=\'table\'><tr><th>Features</th><th></th></tr><tr><td>No.of Contigs</td><td>'+json.contig_number+'</td></tr><tr><td>N50</td><td>'+json.N50+'</td></tr><tr><td>Total Size</td><td>'+json.total_size+'</td></tr><tr><td>GC%</td><td>'+ (json.GC).toFixed(2)+ '</td></tr><tr><td>L50</td><td>'+ json.L50+'</td></tr></table>';
          document.getElementById('basic_table').innerHTML = '<br /><br />' + basic_header;

          //Creation of the results table
          var string_header='<table id="example" class=\'table table-striped table-bordered\'><thead><tr><th>Contig No.</th><th>Contig-Size</th><th>Download</th></tr></thead><tfoot><tr><th>Contig No.</th><th>Contig-Size</th><th>Download</th></tr></tfoot><tbody>';
          var no_of_contigs = json.sizes.length;
          var i;
          console.log(no_of_contigs);
          for(i=0;i<no_of_contigs;i++)
          {
            var num = i+1;
            string_header = string_header + '<tr><td class="numbers">'+ num + '</td><td>'+ json.sizes[i]+'</td><td><input type=\'checkbox\' class=\'down\' name=\'Download\'></td></tr>';
          }
          string_header = string_header +'</tbody></table>';
          document.getElementById('result_table').innerHTML = '<br /><br />'+ string_header + '<br /><button class="btn btn-primary btn-block" id="getcontig" onclick=\'get_download();\' >Get Selected Contigs</button>';
          $(document).ready(function() {
            console.log('into example');
            $('#example').DataTable({
              "order": [[ 1, "desc" ]]
            });
          });
        });
        getOutputFile(fileUrl);
      }
    }
  }, 1000 /*Time to wait, default 1 second */);
}

/**
* Get some response from A||go
* @param  {Object} data informations about this job
* @return {Object}      All files of the job (input/output)
*/
function getAllgoResponse(data,token) {
  var tok ;
  $.getJSON('token.json', function( json ) {
    tok = json.token;
  });
  console.log(token);
  var result;
  $.get({
    url: data.url,
    async: false,
    headers: {
      'Authorization': 'Token token='+token,
      'Accept': 'application/json',
    },
    success: function(d, s, ex) {
      console.log('success');
      console.log(d);
      console.log(s);
      console.log(ex);
      result = d;
    },
    error: function(d, s, ex) {
      console.log('error');
      console.log(d);
      console.log(s);
      console.log(ex);
    }
  });
  return result;
}

/**
* Get output file
* @param  {string} url location of the file
*/
function getOutputFile(url) {
  $.get({
    url: url,
    success: function(d) {
      console.log(d);
    }
  });
}

function open1(){
  var win = window.open("info.html", '_blank');
  win.focus();
}

function open2(){
  var win = window.open("https://github.com/GATB/gatb-minia-pipeline/issues","blank");
  win.focus();
}
