/**
 * Connect template to A||go plateform via A||go API
 */

/**
 * Send data (pictures, files, params, etc.) to A||go
 * @param  {FormData} formData [Data who have some data to send and number of application]
 */
function sendQuery(formData) {
  $.ajax({
    type: 'POST',
    url: 'https://allgo.inria.fr/api/v1/jobs',
    data: formData,
    cache: false,
    contentType: false,
    processData: false,
    headers: {
      'Authorization': 'Token token=[your_A||go_token]',
      'Accept': 'application/json',
    },
    success: function(d, s, ex) {
      console.log("success");
      console.log(d);
      getAllgoResponseLoop(d);
    },
    error: function(d, s, ex) {
      console.log("error");
      console.log(d);
    }
  });
}

/**
 * While A||go response is 'in progress' : Get some response from A||go
 * @param  {Object} data informations about this job
 */
function getAllgoResponseLoop(data) {
  var result;
  setTimeout(function() {
    result = getAllgoResponse(data);
    if (result.status !== undefined) {
      getAllgoResponseLoop(data);
    } else {
      if (result[data.id] !== undefined) {
        var fileUrl = result[data.id]["[name_of_output]"]; //You must change the name of output file
        console.log(fileUrl);
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
function getAllgoResponse(data) {
  var result;
  $.get({
    url: data.url,
    async: false,
    headers: {
      'Authorization': 'Token token=[your_A||go_token]',
      'Accept': 'application/json',
    },
    success: function(d, s, ex) {
      console.log("success");
      console.log(d);
      console.log(s);
      console.log(ex);
      result = d;
    },
    error: function(d, s, ex) {
      console.log("error");
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
