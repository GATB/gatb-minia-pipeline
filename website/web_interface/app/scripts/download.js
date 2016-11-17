// Script for downloading the selected contigs
function get_download()
{
  document.getElementById('getcontigs').innerHTML='';
  var temp='';
  var i;
  var file_url = document.getElementById('all').href;
  console.log('Here is the href');
  var num_entries = document.getElementsByName('example_length');
  console.log(num_entries[0].value);
  console.log(file_url);
  var radios = document.getElementsByName('Download');
  var nums = document.getElementsByClassName('numbers');
  for(i=0;i<radios.length;i++)
  {
    if(radios[i].checked)
    {
      var j =i+1;
      var k = nums[i].textContent;
      temp = temp + k.toString()+',';
      radios[i].checked=false;
    }
  }
  console.log('Clicked Download');
  console.log(temp);

  var formData = new FormData();
  formData.append('job[webapp_id]',122);
  temp = "[" + temp + "]";

  console.log(temp);
  formData.append('job[param]','-t download ' + file_url + ' ' + temp);
  console.log(formData);

  // see http://stackoverflow.com/a/39387533
  // to undertand the following test
  var windowReference = isSafari() ? window.open() : null;

  sendQuery2(formData, windowReference);
}

function sendQuery2(formData, windowReference)
{
  var tok;
  $.getJSON('token.json', function( json ) {
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
        getAllgoResponseLoop2(d,tok,windowReference);
      },
      error: function(d, s, ex) {
        console.log('error');
        console.log(d);
      }
    });
  });
}

function getAllgoResponseLoop2(data,token,windowReference) {
  var result;
  setTimeout(function() {
    result = getAllgoResponse2(data,token);
    if (result.status !== undefined) {
      getAllgoResponseLoop2(data,token);
    } else {
      if (result[data.id] !== undefined) {
        var fileUrl = result[data.id]['extracted_contigs.fasta']; //You must change the name of output file
        console.log('File Url - contigs ');
        console.log(fileUrl);
        // see http://stackoverflow.com/a/39387533
        // to undertand the following test
        if(isSafari()){
          windowReference.location=fileUrl
        }
        else{
          window.open(fileUrl);
        }
        //only for devel: dump file content in console
        //getOutputFile2(fileUrl);
      }
    }
  }, 1000 /*Time to wait, default 1 second */);
}

function getAllgoResponse2(data,token) {
  /*var tok ;
  $.getJSON('token.json', function( json ) {
    tok = json.token;
    //console.log(tok);
  });
  console.log(token);*/
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

function isSafari(){
  var safari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0 || (function (p) { return p.toString() === "[object SafariRemoteNotification]"; })(!window['safari'] || safari.pushNotification);
  return safari;
}