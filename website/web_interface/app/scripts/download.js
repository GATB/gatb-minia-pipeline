// Script for downloading the selected contigs





function get_download()
{
	//console.log("Here we go");
	//console.log(no_of_contigs);
	//var x = document.querySelectorAll("input.down");
	//x[2].checked()=true;
  document.getElementById('getcontigs').innerHTML='';
	//console.log("end");
    var temp='';
    var i;
    var file_url = document.getElementById('all').href;
    console.log('Here is the href');
    var num_entries = document.getElementsByName('example_length');
    console.log(num_entries[0].value);
    //var pagination = document.getElementsByClassName("paginate_button");
    //console.log(pagination.length);
    //var j


    //var len = num_entries[0].value();
    //console.log(len);
    console.log(file_url);
	var radios = document.getElementsByName('Download');
  var nums = document.getElementsByClassName('numbers');
  //console.log(nums[1].textContent);
	for(i=0;i<radios.length;i++)
	{
		if(radios[i].checked)
			{
				var j =i+1;
				//console.log(i+1);
        var k = nums[i].textContent;

				temp = temp + k.toString()+',';
        radios[i].checked=false;
			}
	}
	console.log('Clicked Download');
	console.log(temp);

	var formData = new FormData();
	formData.append('job[webapp_id]',122);
	//console.log(file_url);
  temp = "[" + temp + "]";

  console.log(temp);
	formData.append('job[param]','-t download ' + file_url + ' ' + temp);
	console.log(formData);

	sendQuery2(formData);
}



function sendQuery2(formData)
{
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
      getAllgoResponseLoop2(d,tok);
    },
    error: function(d, s, ex) {
      console.log('error');
      console.log(d);
    }
  });

});
}


function getAllgoResponseLoop2(data,token) {
  var result;
  setTimeout(function() {
    result = getAllgoResponse2(data,token);
    if (result.status !== undefined) {
      getAllgoResponseLoop2(data,token);
    
    
    } else {
      if (result[data.id] !== undefined) {
        var fileUrl = result[data.id]['extracted_contigs.fasta']; //You must change the name of output file
        console.log('File Url - assembly ');
        console.log(fileUrl);
        window.open(fileUrl);
        //document.getElementById('getcontigs').innerHTML = '<br /><a href=\''+fileUrl +'\' class=\'btn btn-primary btn-block\'>Download Selected Contigs</a>';
       
        //Giving user an option
            
        //Function for parsing through the JSON file 

        // Formation of the table
      

     


        getOutputFile2(fileUrl);
      }
    }
  }, 1000 /*Time to wait, default 1 second */);
}

function getAllgoResponse2(data,token) {
 var tok ;
  $.getJSON('token.json', function( json ) {

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
function getOutputFile2(url) {
  $.get({
    url: url,
    success: function(d) {
      console.log(d);
    }
  });
}
