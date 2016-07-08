/**
 * Connect template to A||go plateform via A||go API
 */

/**
 * Send data (pictures, files, params, etc.) to A||go
 * @param  {FormData} formData [Data who have some data to send and number of application]
 */

function tok(token)
{ 
  var k =token;
  return k;
}

 
function sendQuery(formData) {

  var tok;
  $.getJSON("token.json", function( json ) {
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
      document.getElementById('result_assembly').innerHTML ="Result in progress.......";
    } else {
      if (result[data.id] !== undefined) {
        var fileUrl = result[data.id]['assembly.fasta']; //You must change the name of output file
        var fileUrl2 = result[data.id]['stats.json'];
        console.log(fileUrl);
        console.log(fileUrl2);
        //Giving user an option
        document.getElementById("result_assembly").style="font-size:30px;font-weight:100;";
        document.getElementById("result_assembly").innerHTML="Results";
       
        //Function for parsing through the JSON file 

        // Formation of the table
        $.getJSON( fileUrl2, function( json ) {
        console.log( "JSON Data: " + json.sizes[0] );


        var download = "<a href='"+fileUrl +"' class='btn btn-primary btn-block'>Download Assembly</a>";
        document.getElementById("stats").innerHTML = "<br /><br />"+download;
        //Formation of the mains table

        var basic_header = "<table class='table'><tr><th>Characteristic</th><th></th></tr><tr><td>L50</td><td>"+json.L50+"</td></tr><tr><td>N50</td><td>"+json.N50+"</td></tr><tr><td>Total Size</td><td>"+json.total_size+"</td></tr><tr><td>GC%</td><td>"+ json.GC+ "</td></tr><tr><td>No.of contigs</td><td>"+ json.contig_number+"</td></tr></table>";

        document.getElementById("basic_table").innerHTML = "<br /><br />" + basic_header;

        //Formation of the results table 

        var string_header="<table class='table'><tr><th>Contig No.</th><th>Contig-Size</th><th>Download</th></tr>";
        var no_of_contigs = json.sizes.length;
        var i;

        console.log(no_of_contigs);

        for(i=0;i<no_of_contigs;i++)
        {
           var num = i+1;
           string_header = string_header + "<tr><td>"+ num + "</td><td>"+ json.sizes[i]+"</td><td>Download</td></tr>";

        }

        string_header = string_header +"</table>";

        document.getElementById("result_table").innerHTML = "<br /><br />"+ string_header;


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
  $.getJSON("token.json", function( json ) {

      tok = json.token;
      //console.log(tok);

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